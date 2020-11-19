//
//  SettingsViewController.swift
//  NovelSpeaker
//
//  Created by 飯村卓司 on 2017/11/11.
//  Copyright © 2017年 IIMURA Takuji. All rights reserved.
//

import UIKit
import MessageUI
import Eureka
import RealmSwift

class SettingsViewController: FormViewController, MFMailComposeViewControllerDelegate, RealmObserverResetDelegate {
    var m_NarouContentCacheData:NarouContentCacheData? = nil
    var m_RubySwitchToggleHitCount = 0
    var notificationTokens:[NSObjectProtocol] = []
    
    var globalDataNotificationToken:NotificationToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BehaviorLogger.AddLog(description: "SettingsViewController viewDidLoad", data: [:])
        createSettingsTable()
        registerObserver()
        RealmObserverHandler.shared.AddDelegate(delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addNotificationCenter()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeNotificationCenter()
    }
    
    deinit {
        RealmObserverHandler.shared.RemoveDelegate(delegate: self)
    }
    
    func StopObservers(){
        globalDataNotificationToken = nil

    }
    func RestartObservers(){
        StopObservers()
        registerObserver()
    }
    
    func registerObserver() {
        RealmUtil.RealmBlock { (realm) -> Void in
            if let globalData = RealmGlobalState.GetInstanceWith(realm: realm) {
                self.globalDataNotificationToken = globalData.observe({ (change) in
                    switch change {
                    case .change(_, let properties):
                        var isHit = false
                        for property in properties {
                            switch property.name {
                            case "isSpeechWaitSettingUseExperimentalWait",
                                 "webImportBookmarkArray",
                                 "readedPrivacyPolicy",
                                 "m_bookSelfSortType",
                                 "fgColor",
                                 "bgColor",
                                 "currentWebSearchSite",
                                 "currentReadingNovelID",
                                 "defaultSpeakerID",
                                 "defaultDisplaySettingID",
                                 "searchInfoURL",
                                 "defaultSpeechModURL",
                                 "autopagerizeSiteInfoURL",
                                 "novelSpeakerSiteInfoURL",
                                 "speechViewButtonSettingArrayData",
                                 "cookieArrayData",
                                 "m_DisplayType"
                                :
                                continue
                            default:
                                isHit = true
                                break
                            }
                        }
                        if isHit {
                            DispatchQueue.main.async {
                                self.form.removeAll()
                                self.createSettingsTable()
                            }
                        }
                    case .deleted:
                        break
                    default:
                        break
                    }
                    
                })
            }
        }
    }
    
    // TODO: バックアップファイルからのデータ読み込み完了後にこの Notification を呼ぶ
    func addNotificationCenter(){
        NovelSpeakerNotificationTool.addObserver(selfObject: ObjectIdentifier(self), name: Notification.Name.NovelSpeaker.GlobalStateChanged, queue: .main) { (notification) in
            DispatchQueue.main.async {
                self.form.removeAll()
                self.createSettingsTable()
            }
        }
        NovelSpeakerNotificationTool.addObserver(selfObject: ObjectIdentifier(self), name: Notification.Name.NovelSpeaker.RealmSettingChanged, queue: .main) { (notification) in
            DispatchQueue.main.async {
                self.form.removeAll()
                self.createSettingsTable()
            }
        }
    }

    func removeNotificationCenter(){
        NovelSpeakerNotificationTool.removeObserver(selfObject: ObjectIdentifier(self))
    }
    
    func createSettingsTable(){
        form +++ Section()
            <<< LabelRow() { (row) in
                row.tag = "SettingsTableViewController_Information_TAG"
                row.title = NSLocalizedString("SettingsTableViewController_Information", comment: "お知らせ")
                DispatchQueue.main.async {
                    NiftyUtilitySwift.CheckNewImportantImformation(hasNewInformationAlive: { (text) in
                        DispatchQueue.main.async {
                            if text.count > 0 {
                                row.value = "❗"
                            }else{
                                row.value = ""
                            }
                        }
                    }, hasNoNewInformation: {
                        DispatchQueue.main.async {
                            row.value = ""
                        }
                    })
                }
                row.cell.accessoryType = .disclosureIndicator
            }.onCellSelection({ (butonCellof, buttonRow) in
                NiftyUtilitySwift.FetchNewImportantImformation(fetched: { (text, holeText) in
                    var informationText = NSLocalizedString("SettingsTableViewController_Information_NoImportantInformationAlived", comment: "今現在、重要なお知らせはありません。")
                    if text.count > 0 {
                        informationText = text
                    }
                    DispatchQueue.main.async {
                        NiftyUtilitySwift.SaveCheckedImportantInformation(text: text)
                        self.tabBarController?.tabBar.items?[3].badgeValue = nil
                        if let row = self.form.rowBy(tag: "SettingsTableViewController_Information_TAG") as? LabelRow {
                            row.value = ""
                            row.updateCell()
                        }
                        NiftyUtilitySwift.EasyDialogBuilder(self)
                        .title(title: NSLocalizedString("SettingsTableViewController_Information", comment: "お知らせ"))
                        .textView(content: informationText, heightMultiplier: 0.6)
                            .addButton(title: NSLocalizedString("SettingsTableViewController_Information_ShowOutdatedInformation", comment: "過去のお知らせを確認する"), callback: { (dialog) in
                                DispatchQueue.main.async {
                                    dialog.dismiss(animated: false, completion: {
                                        NiftyUtilitySwift.EasyDialogMessageDialog(viewController: self, title: NSLocalizedString("SettingsTableViewController_Information_PastInformationTitle", comment: "過去のお知らせ"), message: holeText.replacingOccurrences(of: "#", with: "\n"), completion: nil)
                                    })
                                }
                            })
                        .addButton(title: NSLocalizedString("OK_button", comment: "OK"),
                                   callback: { (dialog) in
                            DispatchQueue.main.async {
                                dialog.dismiss(animated: false, completion: nil)
                            }
                        }).build(isForMessageDialog: true).show()
                    }
                }, err: {
                    DispatchQueue.main.async {
                        NiftyUtilitySwift.EasyDialogOneButton(
                            viewController: self,
                            title: NSLocalizedString("SettingsTableViewController_Information", comment: "お知らせ"),
                            message: NSLocalizedString("SettingsTableViewController_Information_CanNotGetInformation", comment: "お知らせの読み込みに失敗しました。"),
                            buttonTitle: nil, buttonAction: nil)
                    }
                })
            })
            <<< ButtonRow() {
                $0.title = NSLocalizedString("SpeakerSettingsViewController_TitleText", comment:"話者・声色設定")
                $0.cell.textLabel?.numberOfLines = 0
            }.onCellSelection({ (_, _) in
                let nextViewController = SpeakerSettingsViewController()
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }).cellUpdate({ (cell, button) in
                cell.textLabel?.textAlignment = .left
                cell.accessoryType = .disclosureIndicator
                cell.editingAccessoryType = cell.accessoryType
                cell.textLabel?.textColor = nil
            })
            <<< ButtonRow() {
                $0.title = NSLocalizedString("SettingsViewController_SpeechModSettingsButtonTitle", comment:"話者変更設定(会話文等で声質を変えたりする設定)")
                $0.cell.textLabel?.numberOfLines = 0
            }.onCellSelection({ (_, _) in
                let nextViewController = SpeechSectionConfigsViewController()
                nextViewController.targetNovelID = RealmSpeechSectionConfig.anyTarget
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }).cellUpdate({ (cell, button) in
                cell.textLabel?.textAlignment = .left
                cell.accessoryType = .disclosureIndicator
                cell.editingAccessoryType = cell.accessoryType
                cell.textLabel?.textColor = nil
            })

            <<< ButtonRow() {
                $0.title = NSLocalizedString("SettingTableViewController_SettingOfTheSpeechDelay", comment:"読み上げ時の間の設定")
                $0.cell.textLabel?.numberOfLines = 0
            }.onCellSelection({ (_, _) in
                let nextViewController = SpeechWaitSettingViewControllerSwift()
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }).cellUpdate({ (cell, button) in
                cell.textLabel?.textAlignment = .left
                cell.accessoryType = .disclosureIndicator
                cell.editingAccessoryType = cell.accessoryType
                cell.textLabel?.textColor = nil
            })

            <<< ButtonRow() {
                $0.title = NSLocalizedString("SettingTableViewController_CorrectionOfTheReading", comment:"読みの修正")
                $0.presentationMode = .segueName(segueName: "speechModSettingSegue", onDismiss: nil)
                $0.cell.textLabel?.numberOfLines = 0
            }
            
            <<< ButtonRow() {
                $0.title = NSLocalizedString("SettingTableViewController_SettingOfTheTextSize", comment:"文字サイズの設定")
                $0.presentationMode = .segueName(segueName: "textSizeSettingSegue", onDismiss: nil)
                $0.cell.textLabel?.numberOfLines = 0
            }
            
            <<< TimeIntervalCountDownRow() { (row) in
                row.title = NSLocalizedString("SettingTableViewController_MaxSpeechTime", comment:"最大連続再生時間")
                row.minuteInterval = 5
                row.cell.textLabel?.numberOfLines = 0
                RealmUtil.RealmBlock { (realm) -> Void in
                    if let globalState = RealmGlobalState.GetInstanceWith(realm: realm) {
                        row.value = Double(globalState.maxSpeechTimeInSec)
                    }else{
                        row.value = 60*60*24-60
                    }
                }
            }.onChange({ row in
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm), let value = row.value else { return }
                    RealmUtil.WriteWith(realm: realm, withoutNotifying:[self.globalDataNotificationToken]) { (realm) in
                        globalState.maxSpeechTimeInSec = Int(value)
                    }
                }
            })
            
            <<< ButtonRow() {
                $0.title = NSLocalizedString("SettingTableViewController_CreateNewUserText", comment:"新規自作本の追加")
                $0.cell.textLabel?.numberOfLines = 0
            }.onCellSelection({ (butonCellof, buttonRow) in
                self.CreateNewUserText()
            })
            
            <<< SwitchRow() { (row) in
                row.title = NSLocalizedString("SettingTableViewController_BackgroundFetch", comment:"小説の自動更新")
                RealmUtil.RealmBlock { (realm) -> Void in
                    row.value = RealmGlobalState.GetInstanceWith(realm: realm)?.isBackgroundNovelFetchEnabled ?? false
                }
                row.cell.textLabel?.numberOfLines = 0
            }.onChange({ row in
                guard let judge = row.value else { return }
                if judge {
                    NiftyUtilitySwift.EasyDialogBuilder(self)
                        .title(title: NSLocalizedString("SettingTableViewController_ConfirmEnableBackgroundFetch_title", comment:"確認"))
                        .label(text: NSLocalizedString("SettingtableViewController_ConfirmEnableBackgroundFetch", comment:"この設定を有効にすると、ことせかい を使用していない時等に小説の更新を確認するようになるため、ネットワーク通信が発生するようになります。よろしいですか？"))
                        .addButton(title: NSLocalizedString("Cancel_button", comment: "cancel"), callback: { dialog in
                            row.value = false
                            row.updateCell()
                            DispatchQueue.main.async {
                                dialog.dismiss(animated: true, completion: nil)
                            }
                        })
                        .addButton(title: NSLocalizedString("OK_button", comment:"OK"), callback: {dialog in
                            NiftyUtilitySwift.RegisterUserNotification()
                            RealmUtil.RealmBlock { (realm) -> Void in
                                if let globalState = RealmGlobalState.GetInstanceWith(realm: realm) {
                                    RealmUtil.WriteWith(realm: realm, withoutNotifying:[self.globalDataNotificationToken]) { (realm) in
                                        globalState.isBackgroundNovelFetchEnabled = true
                                    }
                                    NovelDownloadQueue.shared.StartBackgroundFetchIfNeeded()
                                }
                            }
                            DispatchQueue.main.async {
                                dialog.dismiss(animated: true)
                            }
                        })
                        .build().show()
                }else{
                    RealmUtil.RealmBlock { (realm) -> Void in
                        if let globalState = RealmGlobalState.GetInstanceWith(realm: realm) {
                            RealmUtil.WriteWith(realm: realm, withoutNotifying:[self.globalDataNotificationToken]) { (realm) in
                                globalState.isBackgroundNovelFetchEnabled = false
                            }
                            NovelDownloadQueue.shared.StartBackgroundFetchIfNeeded()
                        }
                    }
                }
            })
            
            <<< SwitchRow("OverrideRubySwitchRow") { (row) in
                row.title = NSLocalizedString("SettingTableViewController_OverrideRuby", comment:"ルビはルビだけ読む")
                row.cell.textLabel?.numberOfLines = 0
                row.value = false
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm) else { return }
                    row.value = globalState.isOverrideRubyIsEnabled
                }
            }.onChange({ row in
                self.m_RubySwitchToggleHitCount += 1
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm), let value = row.value else { return }
                    RealmUtil.WriteWith(realm: realm, withoutNotifying:[self.globalDataNotificationToken]) { (realm) in
                        globalState.isOverrideRubyIsEnabled = value
                    }
                }
            })
            <<< TextRow("OverrideRubyTextRow") { (row) in
                row.title = NSLocalizedString("SettingTableViewController_EditNotRubyStringTitle", comment:"非ルビ文字")
                row.cell.textLabel?.numberOfLines = 0
                row.hidden = .function(["OverrideRubySwitchRow"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "OverrideRubySwitchRow")
                    return row.value ?? false == false
                })
                RealmUtil.RealmBlock { (realm) -> Void in
                    row.value = ""
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm) else { return }
                    row.value = globalState.notRubyCharactorStringArray
                }
            }.onChange({ textRow in
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm), let value = textRow.value else { return }
                    RealmUtil.WriteWith(realm: realm, withoutNotifying:[self.globalDataNotificationToken]) { (realm) in
                        globalState.notRubyCharactorStringArray = value
                    }
                }
            })
            <<< SwitchRow(){ row in
                row.title = NSLocalizedString("SettingTableViewController_DisplayBookmarkPositionOnBookshelf", comment: "本棚に栞の現在位置ゲージを表示する")
                row.cell.textLabel?.numberOfLines = 0
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm) else { return }
                    row.value = globalState.isReadingProgressDisplayEnabled
                }
            }.onChange({ (row) in
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm), let value = row.value else { return }
                    RealmUtil.WriteWith(realm: realm, withoutNotifying:[self.globalDataNotificationToken]) { (realm) in
                        globalState.isReadingProgressDisplayEnabled = value
                    }
                }
            })
            <<< SwitchRow(){ row in
                row.title = NSLocalizedString("SettingTableViewController_OnlyDisplayAddSpeechModSettings", comment: "本文中の長押しメニューを読み替え辞書へ登録のみにする")
                row.cell.textLabel?.numberOfLines = 0
                row.cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm) else { return }
                    row.value = globalState.isMenuItemIsAddNovelSpeakerItemsOnly
                }
            }.onChange({ (row) in
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm), let value = row.value else { return }
                    RealmUtil.WriteWith(realm: realm, withoutNotifying:[self.globalDataNotificationToken]) { (realm) in
                        globalState.isMenuItemIsAddNovelSpeakerItemsOnly = value
                    }
                }
            })
            <<< SwitchRow(){ row in
                row.title = NSLocalizedString("SettingTableViewController_ShortSkipIsEnabled", comment: "コントロールセンターの前後の章(トラック)への移動ボタンを、少し前/少し後の文への移動にする")
                row.cell.textLabel?.numberOfLines = 0
                row.cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm) else { return }
                    row.value = globalState.isShortSkipEnabled
                }
            }.onChange({ (row) in
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm), let value = row.value else { return }
                    RealmUtil.WriteWith(realm: realm, withoutNotifying:[self.globalDataNotificationToken]) { (realm) in
                        globalState.isShortSkipEnabled = value
                    }
                }
            })
            <<< SwitchRow() { row in
                row.title = NSLocalizedString("SettingTableViewController_PlaybackDurationIsEnabled", comment: "コントロールセンターの再生時間ゲージを有効にする(表示される時間は概算で、正確な値にはなりません)")
                row.cell.textLabel?.numberOfLines = 0
                row.cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm) else { return }
                    row.value = globalState.isPlaybackDurationEnabled
                }
            }.onChange({ (row) in
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm), let value = row.value else { return }
                    RealmUtil.WriteWith(realm: realm, withoutNotifying:[self.globalDataNotificationToken]) { (realm) in
                        globalState.isPlaybackDurationEnabled = value
                    }
                }
            })
            <<< SwitchRow() { row in
                row.title = NSLocalizedString("SettingTableViewController_PageTurningSoundIsEnabled", comment: "ページめくり時に音を鳴らす")
                row.cell.textLabel?.numberOfLines = 0
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm) else { return }
                    row.value = globalState.isPageTurningSoundEnabled
                }
            }.onChange({ (row) in
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm), let value = row.value else { return }
                    RealmUtil.WriteWith(realm: realm, withoutNotifying:[self.globalDataNotificationToken]) { (realm) in
                        globalState.isPageTurningSoundEnabled = value
                    }
                }
            })
            <<< SwitchRow() { row in
                row.title = NSLocalizedString("SettingTableViewController_IgnoreURISpeechIsEnabled", comment: "URIを読み上げないようにする")
                row.cell.textLabel?.numberOfLines = 0
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm) else { return }
                    row.value = globalState.isIgnoreURIStringSpeechEnabled
                }
            }.onChange({ (row) in
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm), let value = row.value else { return }
                    RealmUtil.WriteWith(realm: realm, withoutNotifying:[self.globalDataNotificationToken]) { (realm) in
                        globalState.isIgnoreURIStringSpeechEnabled = value
                    }
                }
            })
            <<< AlertRow<String>("RepeatTypeSelectRow") { row in
                row.title = NSLocalizedString("SettingTableViewController_RepeatTypeTitle", comment:"繰り返し再生")
                row.selectorTitle = NSLocalizedString("SettingTableViewController_RepeatTypeTitle", comment:"繰り返し再生")
                row.options = NovelSpeakerUtility.GetAllRepeatSpeechStringType().map({NovelSpeakerUtility.RepeatSpeechTypeToString(type: $0) ?? ""})
                row.value = NovelSpeakerUtility.RepeatSpeechTypeToString(type: .noRepeat)
                row.cell.textLabel?.numberOfLines = 0
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm) else { return }
                    let type = globalState.repeatSpeechType
                    if let typeString = NovelSpeakerUtility.RepeatSpeechTypeToString(type: type) {
                        row.value = typeString
                    }
                }
            }.onChange({ (row) in
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm), let typeString = row.value, let type = NovelSpeakerUtility.RepeatSpeechStringToType(typeString: typeString) else { return }
                    if type == .goToNextSameFolderdNovel, let folderArray = RealmNovelTag.GetObjectsFor(realm: realm, type: RealmNovelTag.TagType.Folder), folderArray.count <= 0, let typeString = NovelSpeakerUtility.RepeatSpeechTypeToString(type: globalState.repeatSpeechType) {
                        DispatchQueue.main.async {
                            row.value = typeString
                            row.updateCell()
                            NiftyUtilitySwift.EasyDialogMessageDialog(viewController: self, message: NSLocalizedString("SettingsViewController_RepeatTypeGoToNextSameFolderdNovel_NoFolderFoundWarning", comment: "フォルダが一つも作成されていないようです。フォルダを作成されていないとこの設定は利用できません。\nフォルダを作成するには、本棚タブで小説を開いて右上にある「詳細」ボタンを押した後に出てくる小説の詳細画面から「フォルダへ分類」を選択してフォルダを追加してください。"))
                        }
                        return
                    }
                    RealmUtil.WriteWith(realm: realm, withoutNotifying:[self.globalDataNotificationToken]) { (realm) in
                        globalState.repeatSpeechType = type
                    }
                }
            })
            <<< SwitchRow() { row in
                row.title = NSLocalizedString("SettingTableViewController_IsEscapeAboutSpeechPositionDisplayBugOniOS12Enabled", comment: "iOS 12 で読み上げ中の読み上げ位置表示がおかしくなる場合への暫定的対応を適用する")
                row.cell.textLabel?.numberOfLines = 0
                row.cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm) else { return }
                    row.value = globalState.isEscapeAboutSpeechPositionDisplayBugOniOS12Enabled
                }
            }.onChange({ (row) in
                let judge = row.value
                if judge! {
                    NiftyUtilitySwift.EasyDialogBuilder(self)
                        .title(title: NSLocalizedString("SettingTableViewController_ConfirmEnableEscapeAboutSpeechPositionDisplayBugOniOS12_title", comment:"確認"))
                        .textView(content: NSLocalizedString("SettingtableViewController_ConfirmEnableEscapeAboutSpeechPositionDisplayBugOniOS12", comment:"この設定を有効にすると、読み上げ中の読み上げ位置表示がおかしくなる原因と思われる文字(多くは空白や改行などの表示されない文字です)について、\"α\"(アルファ)に読み替えるように設定することで回避するようになります。\nこの機能を実装した時点では、\"α\"(アルファ)は読み上げられない文字ですので概ね問題ない動作になると思われますが、将来的に iOS の音声合成エンジン側の変更により「アルファ」と読み上げられるようになる可能性があります。\nまた、この機能が必要となるのは iOS 12(以降) だと思われます。\n以上の事を理解した上でこの設定を有効にしますか？"), heightMultiplier: 0.6)
                        .addButton(title: NSLocalizedString("Cancel_button", comment: "cancel"), callback: { dialog in
                            row.value = false
                            row.updateCell()
                            DispatchQueue.main.async {
                                dialog.dismiss(animated: true, completion: nil)
                            }
                        })
                        .addButton(title: NSLocalizedString("OK_button", comment:"OK"), callback: {dialog in
                            DispatchQueue.main.async {
                                dialog.dismiss(animated: true)
                            }
                            RealmUtil.RealmBlock { (realm) -> Void in
                                guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm) else { return }
                                RealmUtil.WriteWith(realm: realm, withoutNotifying:[self.globalDataNotificationToken]) { (realm) in
                                    globalState.isEscapeAboutSpeechPositionDisplayBugOniOS12Enabled = true
                                }
                            }
                        })
                        .build().show()
                }else{
                    RealmUtil.RealmBlock { (realm) -> Void in
                        guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm) else { return }
                        RealmUtil.WriteWith(realm: realm, withoutNotifying:[self.globalDataNotificationToken]) { (realm) in
                            globalState.isEscapeAboutSpeechPositionDisplayBugOniOS12Enabled = false
                        }
                    }
                }
            })
            <<< SwitchRow("MixWithOthersSwitchRow") { row in
                row.title = NSLocalizedString("SettingTableViewController_MixWithOthersIsEnabled", comment: "他のアプリで音楽が鳴っても止まらないように努力する(イヤホンやコントロールセンターからの操作を受け付けなくなります)")
                row.cell.textLabel?.numberOfLines = 0
                row.cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith( realm: realm) else { return }
                    row.value = globalState.isMixWithOthersEnabled
                }
            }.onChange({ (row) in
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm), let value = row.value else { return }
                    RealmUtil.WriteWith(realm: realm, withoutNotifying:[self.globalDataNotificationToken]) { (realm) in
                        globalState.isMixWithOthersEnabled = value
                    }
                }
            })
            <<< SwitchRow() { row in
                row.title = NSLocalizedString("SettingTableViewController_DuckOthersIsEnabled", comment: "他のアプリの音を小さくする")
                row.cell.textLabel?.numberOfLines = 0
                row.hidden = .function(["MixWithOthersSwitchRow"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "MixWithOthersSwitchRow")
                    return row.value ?? false == false
                })
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm) else { return }
                    row.value = globalState.isDuckOthersEnabled
                }
            }.onChange({ (row) in
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm), let value = row.value else { return }
                    RealmUtil.WriteWith(realm: realm, withoutNotifying:[self.globalDataNotificationToken]) { (realm) in
                        globalState.isDuckOthersEnabled = value
                    }
                }
            })
            <<< SwitchRow("IsOpenRecentBookInStartTime") { row in
                row.title = NSLocalizedString("SettingTableViewController_IsOpenRecentBookInStartTime", comment: "起動時に前回開いていた小説を開く")
                row.cell.textLabel?.numberOfLines = 0
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm) else { return }
                    row.value = globalState.isOpenRecentNovelInStartTime
                }
            }.onChange({ (row) in
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith( realm: realm), let value = row.value else { return }
                    RealmUtil.WriteWith(realm: realm, withoutNotifying:[self.globalDataNotificationToken]) { (realm) in
                        globalState.isOpenRecentNovelInStartTime = value
                    }
                }
            })
            <<< SwitchRow("isDisallowsCellularAccess") { row in
                row.title = NSLocalizedString("SettingTableViewController_IsDisallowsCellularAccess", comment: "携帯電話網ではダウンロードしないようにする")
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm) else { return }
                    row.value = globalState.IsDisallowsCellularAccess
                }
                row.cell.textLabel?.numberOfLines = 0
            }.onChange({ (row) in
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm), let value = row.value else { return }
                    RealmUtil.WriteWith(realm: realm, withoutNotifying:[self.globalDataNotificationToken]) { (realm) in
                        globalState.IsDisallowsCellularAccess = value
                    }
                }
            })
            <<< SwitchRow("isNeedConfirmDeleteBook") { row in
                row.title = NSLocalizedString("SettingTableViewController_IsNeedConfirmDeleteBook", comment: "小説を削除する時に確認する")
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm) else { return }
                    row.value = globalState.IsNeedConfirmDeleteBook
                }
                row.cell.textLabel?.numberOfLines = 0
            }.onChange({ (row) in
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm), let value = row.value else { return }
                    RealmUtil.WriteWith(realm: realm, withoutNotifying: [self.globalDataNotificationToken]) { (realm) in
                        globalState.IsNeedConfirmDeleteBook = value
                    }
                }
            })
            <<< ButtonRow() {
                $0.title = NSLocalizedString("SettingsViewController_AutoSplitStringSetting", comment:"テキスト分割文字列の設定(1ページのみの文章を読み込もうとした時に、特定の文字列で分割して読み込むための設定)")
                $0.cell.textLabel?.numberOfLines = 0
            }.onCellSelection({ (buttonCellOf, button) in
                let nextViewController = AutoSplitStringSettingViewController()
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }).cellUpdate({ (cell, button) in
                cell.textLabel?.textAlignment = .left
                cell.accessoryType = .disclosureIndicator
                cell.editingAccessoryType = cell.accessoryType
                cell.textLabel?.textColor = nil
            })
            <<< ButtonRow() { (row) in
                row.title = NSLocalizedString("SettingsViewController_ManageFolderOrderButton", comment: "自作フォルダを編集する")
                row.cell.textLabel?.numberOfLines = 0
            }.onCellSelection({ (cellOf, row) in
                let nextViewController = NovelFolderManageTableViewController()
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }).cellUpdate({ (cell, button) in
                cell.textLabel?.textAlignment = .left
                cell.accessoryType = .disclosureIndicator
                cell.editingAccessoryType = cell.accessoryType
                cell.textLabel?.textColor = nil
            })
            <<< SwitchRow("IsUseiCloud") {
                $0.title = NSLocalizedString("SettingsViewController_IsUseiCloud_Title", comment: "iCloud 同期を使用する")
                $0.value = RealmUtil.IsUseCloudRealm()
                $0.cell.textLabel?.numberOfLines = 0
            }.onChange({ (row) in
                guard let value = row.value else { return }
                if value == true {
                    if !RealmUtil.IsUseCloudRealm() {
                        self.ConifirmiCloudEnable()
                    }
                }else{
                    if RealmUtil.IsUseCloudRealm() {
                        self.ConifirmiCloudDisable()
                    }
                }
            })
            <<< ButtonRow() {
                $0.title = NSLocalizedString("SettingsViewController_RemoteDataURLSetting", comment:"内部データ参照用URLの設定")
                $0.cell.textLabel?.numberOfLines = 0
            }.onCellSelection({ (buttonCellOf, button) in
                let nextViewController = RemoteDataURLSettingViewController()
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }).cellUpdate({ (cell, button) in
                cell.textLabel?.textAlignment = .left
                cell.accessoryType = .disclosureIndicator
                cell.editingAccessoryType = cell.accessoryType
                cell.textLabel?.textColor = nil
            })
            <<< ButtonRow() {
                $0.title = NSLocalizedString("SpeechViewButtonSettingsViewController_Title", comment: "小説本文画面の右上に表示されるボタン群の設定")
                $0.cell.textLabel?.numberOfLines = 0
            }.onCellSelection({ (buttonCellOf, button) in
                let nextViewController = SpeechViewButtonSettingsViewController()
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }).cellUpdate({ (cell, button) in
                cell.textLabel?.textAlignment = .left
                cell.accessoryType = .disclosureIndicator
                cell.editingAccessoryType = cell.accessoryType
                cell.textLabel?.textColor = nil
            })
            <<< ButtonRow() {
                $0.title = NSLocalizedString("SettingTableViewController_AddDefaultCorrectionOfTheReading", comment:"標準の読みの修正を上書き追加")
                $0.cell.textLabel?.numberOfLines = 0
            }.onCellSelection({ (butonCellof, buttonRow) in
                self.ConfirmAddDefaultSpeechModSetting()
            })
            <<< ButtonRow() {
                $0.title = NSLocalizedString("SettingsViewController_RemoveDefaultSpeechModSettings", comment:"標準の読みの修正と同じものを読み替え辞書登録から削除")
                $0.cell.textLabel?.numberOfLines = 0
            }.onCellSelection({ (butonCellof, buttonRow) in
                DispatchQueue.main.async {
                    NiftyUtilitySwift.EasyDialogTwoButton(
                        viewController: self,
                        title: NSLocalizedString("SettingsViewController_RemoveDefaultSpeechModSettings_ConifirmTitle", comment: "確認"),
                        message: NSLocalizedString("SettingsViewController_RemoveDefaultSpeechModSettings_ConifirmMessage", comment: "読みの修正に登録されているもののうち、標準の読みの修正と同じものを削除します。よろしいですか？"),
                        button1Title: nil, // Cancel
                        button1Action: nil,
                        button2Title: nil, // OK
                        button2Action: {
                            NovelSpeakerUtility.RemoveAllDefaultSpeechModSettings()
                            DispatchQueue.main.async {
                                NiftyUtilitySwift.EasyDialogOneButton(
                                    viewController: self,
                                    title: nil,
                                    message: NSLocalizedString("SettingsViewController_RemoveDefaultSpeechModSettings_DeletedMessage", comment: "読みの修正に登録されているもののうち、標準の読みの修正と同じものを削除しました。"),
                                    buttonTitle: nil, // OK
                                    buttonAction: nil)
                            }
                    })
                }
            })

            <<< ButtonRow() {
                $0.title = NSLocalizedString("SettingTableViewController_GetNcodeDownloadURLScheme", comment:"再ダウンロード用データの生成")
                $0.cell.textLabel?.numberOfLines = 0
            }.onCellSelection({ (butonCellof, buttonRow) in
                self.ShareNcodeListURLScheme()
            })
            
            <<< ButtonRow() {
                $0.title = NSLocalizedString("SettingTableViewController_GoToSupportSite", comment: "サポートサイトを開く")
                $0.cell.textLabel?.numberOfLines = 0
            }.onCellSelection({ (buttonCellof, buttonRow) in
                if let url = URL(string: "https://limura.github.io/NovelSpeaker/") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            <<< ButtonRow() {
                $0.title = NSLocalizedString("SettingTableViewController_SendBugReport", comment: "不都合報告をmailで開発者に送る")
                $0.cell.textLabel?.numberOfLines = 0
                $0.presentationMode = .segueName(segueName: "BugReportViewSegue", onDismiss: nil)
            }
            
            <<< ButtonRow() {
                $0.title = NSLocalizedString("SettingTableViewController_GoToReleaseLog", comment:"更新履歴")
                $0.cell.textLabel?.numberOfLines = 0
            }.onCellSelection({ (buttonCellOf, button) in
                let nextViewController = UpdateLogViewController()
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }).cellUpdate({ (cell, button) in
                cell.textLabel?.textAlignment = .left
                cell.accessoryType = .disclosureIndicator
                cell.editingAccessoryType = cell.accessoryType
                cell.textLabel?.textColor = nil
            })
            
            <<< ButtonRow() {
                $0.title = NSLocalizedString("SettingTableViewController_RightNotation", comment:"権利表記")
                $0.presentationMode = .segueName(segueName: "CreditPageSegue", onDismiss: nil)
                $0.cell.textLabel?.numberOfLines = 0
            }
            
            <<< ButtonRow() {
                $0.title = NSLocalizedString("SettingTableViewController_About", comment: "ことせかい について")
                $0.cell.textLabel?.numberOfLines = 0
            }.onCellSelection({ (buttonCellof, buttonRow) in
                NiftyUtilitySwift.EasyDialogBuilder(self)
                .label(text: NSLocalizedString("SettingTableViewController_About", comment: "ことせかい について"))
                .label(text: "Version: " + NiftyUtilitySwift.GetAppVersionString())
                    .addButton(title: NSLocalizedString("OK_button", comment: "OK"), callback: { (dialog) in
                        dialog.dismiss(animated: false, completion: nil)
                    })
                .build().show()
            })
            
            <<< ButtonRow() {
                $0.title = NSLocalizedString("SettingTableViewController_LICENSE", comment: "LICENSE")
                $0.cell.textLabel?.numberOfLines = 0
            }.onCellSelection({ (buttonCallof, buttonRow) in
                if let path = Bundle.main.path(forResource: "LICENSE", ofType: ".txt") {
                    do {
                        let license = try String(contentsOfFile: path)
                        DispatchQueue.main.async {
                            NiftyUtilitySwift.EasyDialogBuilder(self)
                                .textView(content: license, heightMultiplier: 0.7)
                                .addButton(title: NSLocalizedString("OK_button", comment: "OK"), callback: { (dialog) in
                                    NovelSpeakerUtility.SetLicenseReaded(isRead: true)
                                    DispatchQueue.main.async {
                                        dialog.dismiss(animated: true)
                                    }
                                })
                                .build(isForMessageDialog: true).show()
                        }
                        return
                    }catch{
                        // nothing to do.
                    }
                }
                DispatchQueue.main.async {
                    NiftyUtilitySwift.EasyDialogBuilder(self)
                        .textView(content: NSLocalizedString("SettingTableViewController_LISENSE_file_can_not_read", comment: "LICENSE.txt を読み込めませんでした。ことせかい の GitHub 側の LICENSE.txt を参照してください。"), heightMultiplier: 0.7)
                        .addButton(title: NSLocalizedString("OK_button", comment: "OK"), callback: { (dialog) in
                            DispatchQueue.main.async {
                                dialog.dismiss(animated: true)
                            }
                        })
                        .build().show()
                }
            })
            <<< ButtonRow() {
            $0.title = NSLocalizedString("SettingTableViewController_PrivacyPolicy", comment: "ことせかい のプライバシーポリシーを確認する")
            $0.cell.textLabel?.numberOfLines = 0
            $0.cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
            }.onCellSelection({ (buttonCellOf, buttonRow) in
                if let privacyPolicyUrl = NovelSpeakerUtility.privacyPolicyURL {
                    func privacyPolycyLoadFailed(){
                        DispatchQueue.main.async {
                            NiftyUtilitySwift.EasyDialogBuilder(self)
                            .textView(content: NSLocalizedString("SettingTableViewController_PrivacyPolicy_can_not_load", comment: "最新のプライバシーポリシーを読み込めませんでした。\nSafariでの表示を試みます。"), heightMultiplier: 0.6)
                            .addButton(title: NSLocalizedString("OK_button", comment: "OK"), callback: { (dialog) in
                                DispatchQueue.main.async {
                                    dialog.dismiss(animated: true)
                                    UIApplication.shared.open(privacyPolicyUrl, options: [:], completionHandler: nil)
                                }
                            })
                            .build().show()
                        }
                    }
                    NiftyUtilitySwift.cashedHTTPGet(url: privacyPolicyUrl, delay: 60*60, successAction: { (data, encoding) in
                        if let currentPrivacyPolicy = String(data: data, encoding: encoding ?? .utf8) {
                            DispatchQueue.main.async {
                                NiftyUtilitySwift.EasyDialogBuilder(self)
                                .textView(content: currentPrivacyPolicy, heightMultiplier: 0.6)
                                .addButton(title: NSLocalizedString("OK_button", comment: "OK"), callback: { (dialog) in
                                    DispatchQueue.main.async {
                                        dialog.dismiss(animated: true)
                                    }
                                })
                                .build().show()
                            }
                        }else{
                            privacyPolycyLoadFailed()
                        }
                    }, failedAction: { (error) in
                        privacyPolycyLoadFailed()
                    })
                }
            })

            // デバッグ用の設定は、「ルビはルビだけ読む」のON/OFFを10回位繰り返すと出て来るようにしていて、
            // それらはこの下に記述されます
            +++ Section("Debug") {
                $0.hidden = .function(["OverrideRubySwitchRow"], { form -> Bool in
                    return self.m_RubySwitchToggleHitCount < -10
                })
            }
            <<< ButtonRow() {
                $0.title = NSLocalizedString("SettingsViewController_ClearSiteInfoCache", comment: "SiteInfoキャッシュを削除する")
                $0.cell.textLabel?.numberOfLines = 0
            }.onCellSelection({ (cellOf, row) in
                StoryHtmlDecoder.shared.ClearSiteInfo()
                DispatchQueue.main.async {
                    NiftyUtilitySwift.EasyDialogOneButton(
                        viewController: self,
                        title: nil,
                        message: NSLocalizedString("SettingsViewController_ClearSiteInfoCache_done", comment: "保存されている SiteInfo 情報を削除しました。"),
                        buttonTitle: nil,
                        buttonAction: nil)
                }
            })
            <<< SwitchRow("OverrideForceSiteInfoReload") { row in
                row.title = NSLocalizedString("SettingTableViewController_ForceSiteInfoReload", comment:"SiteInfoを毎回読み直す")
                row.value = false
                row.cell.textLabel?.numberOfLines = 0
                row.value = RealmGlobalState.GetIsForceSiteInfoReloadIsEnabled()
            }.onChange({ row in
                guard let value = row.value else { return }
                RealmGlobalState.SetIsForceSiteInfoReloadIsEnabled(newValue: value)
            })
            <<< ButtonRow(){
                $0.title = NSLocalizedString("SettingsViewController_ClearWebSearchSiteInfoCache", comment: "Web検索タブの検索データを読み直す")
                $0.cell.textLabel?.numberOfLines = 0
            }.onCellSelection({ (cellOf, row) in
                NovelSearchViewController.SearchInfoCacheClear()
                DispatchQueue.main.async {
                    NiftyUtilitySwift.EasyDialogOneButton(
                        viewController: self,
                        title: nil,
                        message: NSLocalizedString("SettingsViewController_ClearWebSearchSiteInfoCache_done", comment: "Web検索タブに戻ると読み込み直すように設定しました。"),
                        buttonTitle: nil,
                        buttonAction: nil)
                }
            })
            <<< ButtonRow() {
                $0.title = NSLocalizedString("SettingTableViewController_ShowDebugLog", comment:"デバッグログの表示")
                $0.presentationMode = .segueName(segueName: "debugLogViewSegue", onDismiss: nil)
                $0.cell.textLabel?.numberOfLines = 0
            }
            /*
            <<< ButtonRow() {
                $0.title = "iCloud pull (with remove server change token)"
                $0.cell.textLabel?.numberOfLines = 0
            }.onCellSelection({ (cellOf, row) in
                DispatchQueue.main.async {
                    NiftyUtilitySwift.EasyDialogNoButton(viewController: self, title: nil, message: NSLocalizedString("SettingsViewController_CloudPullProcessingDialog", comment: "iCloud からデータを読み込み中です。"), completion: { (dialog) in
                        RealmUtil.stopSyncEngine()
                        RealmUtil.ForceRemoveIceCreamDatabaseSyncTokens()
                        try! RealmUtil.EnableSyncEngine()
                        RealmUtil.WaitAllLongLivedOperationIDCleared(completion: {
                            RealmUtil.CheckCloudDataIsValid { (result) in
                                DispatchQueue.main.async {
                                    dialog.dismiss(animated: false, completion: nil)
                                }
                            }
                        })
                    })
                }
            })
            <<< ButtonRow() {
                $0.title = "iCloud pull (normal pull)"
                $0.cell.textLabel?.numberOfLines = 0
            }.onCellSelection({ (cellOf, row) in
                DispatchQueue.main.async {
                    NiftyUtilitySwift.EasyDialogNoButton(viewController: self, title: nil, message: NSLocalizedString("SettingsViewController_CloudPullProcessingDialog", comment: "iCloud からデータを読み込み中です。"), completion: { (dialog) in
                        DispatchQueue.main.async {
                            try! RealmUtil.EnableSyncEngine()
                            RealmUtil.CloudPull()
                            dialog.dismiss(animated: false, completion: nil)
                        }
                    })
                }
            })
            <<< ButtonRow() {
                $0.title = "iCloud push"
                $0.cell.textLabel?.numberOfLines = 0
            }.onCellSelection({ (cellOf, row) in
                DispatchQueue.main.async {
                    NiftyUtilitySwift.EasyDialogNoButton(viewController: self, title: nil, message: NSLocalizedString("SettingsViewController_CloudPushProcessingDialog", comment: "iCloud 側へデータを書き込み中です。"), completion: { (dialog) in
                        DispatchQueue.main.async {
                            try! RealmUtil.EnableSyncEngine()
                            RealmUtil.CloudPush()
                            dialog.dismiss(animated: false, completion: nil)
                        }
                    })
                }
            })
            */
            <<< ButtonRow() {
                $0.title = "次回起動時に CoreData(旧データベース) の情報に書き戻す"
                $0.cell.textLabel?.numberOfLines = 0
            }.onCellSelection({ (cellOf, row) in
                CoreDataToRealmTool.UnregisterConvertFromCoreDataFinished()
                DispatchQueue.main.async {
                    NiftyUtilitySwift.EasyDialogOneButton(viewController: self, title: nil, message: "次回起動時に CoreData(旧データベース) の情報に書き戻すように設定しました。", buttonTitle: nil, buttonAction: nil)
                }
            })
        
            <<< LabelRow() {
                $0.title = "以下は cookie 周りの処理を行う物です。一部は Xcode でログを確認しないと意味が無いボタンになります。"
                $0.cell.textLabel?.numberOfLines = 0
            }
            <<< ButtonRow() {
                $0.title = "dump(URLSession.shared)"
            }.onCellSelection({ (cellOf, row) in
                NiftyUtilitySwift.getAllCookies { (cookieArray) in
                    guard let cookieArray = cookieArray else {
                        print("NiftyUtilitySwift.getAllCookies return nil")
                        return
                    }
                    NiftyUtilitySwift.DumpHTTPCookieArray(cookieArray: cookieArray)
                }
            })
            <<< ButtonRow() {
                $0.title = "dump(WkWebView)"
            }.onCellSelection({ (cellOf, row) in
                let headlessClient = HeadlessHttpClient()
                headlessClient.getAllCookies { (cookieArray) in
                    guard let cookieArray = cookieArray else {
                        print("headlessClient.getAllCookies return nil")
                        return
                    }
                    NiftyUtilitySwift.DumpHTTPCookieArray(cookieArray: cookieArray)
                }
            })
            <<< ButtonRow() {
                $0.title = "dump(Realm)"
            }.onCellSelection({ (cellOf, row) in
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let cookieArray = RealmGlobalState.GetInstanceWith(realm: realm)?.GetCookieArray() else {
                        print("dump(Realm) failed. cookieArray is nil")
                        return
                    }
                    NiftyUtilitySwift.DumpHTTPCookieArray(cookieArray: cookieArray)
                }
            })
            <<< ButtonRow() {
                $0.title = "save to Realm(URLSession.shared)"
            }.onCellSelection({ (cellOf, row) in
                HTTPCookieSyncTool.shared.Save()
            })
            <<< ButtonRow() {
                $0.title = "save to Realm(WkWebView)"
            }.onCellSelection({ (cellOf, row) in
                let headlessClient = HeadlessHttpClient()
                headlessClient.getAllCookies { (cookieArray) in
                    guard let cookieArray = cookieArray else {
                        print("headlessClient.getAllCookies return nil")
                        return
                    }
                    RealmUtil.RealmBlockWrite { (realm) in
                        HTTPCookieSyncTool.shared.SaveCookiesFromCookieArrayWith(realm: realm, cookieArray: cookieArray)
                    }
                }
            })
            <<< ButtonRow() {
                $0.title = "load to URLSession.shared"
            }.onCellSelection({ (cellOf, row) in
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let cookieArray = RealmGlobalState.GetInstanceWith(realm: realm)?.GetCookieArray() else {
                        print("load to URLSession.shared error. can not get cookieArray.")
                        return
                    }
                    guard let cookieStorage = URLSession.shared.configuration.httpCookieStorage else {
                        print("load to URLSession.shared error. can not get cookieStorage for URLSession.shared")
                        return
                    }
                    NiftyUtilitySwift.AssignCookieArrayToCookieStorage(cookieArray: cookieArray, cookieStorage: cookieStorage)
                }
            })
            <<< ButtonRow() {
                $0.title = "load to WkWebView"
            }.onCellSelection({ (cellOf, row) in
                RealmUtil.RealmBlock { (realm) -> Void in
                    guard let cookieArray = RealmGlobalState.GetInstanceWith(realm: realm)?.GetCookieArray() else {
                        print("load to URLSession.shared error. can not get cookieArray.")
                        return
                    }
                    let client = HeadlessHttpClient()
                    client.AssignCookieArray(cookieArray: cookieArray) {
                        print("load to WkWebview done.")
                    }
                }
            })
            <<< ButtonRow() {
                $0.title = "RemoveAll(URLSession.shared)"
            }.onCellSelection({ (cellOf, row) in
                guard let cookieStorage = URLSession.shared.configuration.httpCookieStorage else {
                    print("cookieStorage is nil")
                    return
                }
                NiftyUtilitySwift.RemoveAllCookieInCookieStorage(cookieStorage: cookieStorage)
                print("RemoveAllCookieInCookieStorage executed.")
            })
            <<< ButtonRow() {
                $0.title = "RemoveAll(headless)"
            }.onCellSelection({ (cellOf, row) in
                let headlessClient = HeadlessHttpClient()
                headlessClient.removeAllCookies {
                    print("headlessClient.removeAllCookies done.")
                }
            })
            <<< ButtonRow() {
                $0.title = "RemoveAll(realm)"
            }.onCellSelection({ (cellOf, row) in
                RealmUtil.RealmBlockWrite { (realm) in
                    guard let globalState = RealmGlobalState.GetInstanceWith(realm: realm) else {
                        print("RemoveAll(realm) failed. globalState is nil")
                        return
                    }
                    globalState.MergeCookieArrayWith(realm: realm, cookieArray: [])
                }
            })

    }

    func AssignMessageTo(tag:Int, text:String, dialog:EasyDialog) {
        DispatchQueue.main.async {
            if let label = dialog.view.viewWithTag(tag) as? UILabel {
                label.text = text
            }
        }
    }
    
    func overrideiCloudToLocal() {
        DispatchQueue.main.async {
            NiftyUtilitySwift.EasyDialogNoButton(
                viewController: self, title: NSLocalizedString("SettingsViewController_CopyingCloudToLocal", comment: "iCloud側のデータを端末側のデータへ変換中"), message: "-", completion: { (dialog) in
                    DispatchQueue.global(qos: .userInitiated).async {
                        autoreleasepool {
                            guard let cloudRealm = try? RealmUtil.GetCloudRealm(), let localRealm = try? RealmUtil.GetLocalRealm() else {
                                DispatchQueue.main.async {
                                    dialog.dismiss(animated: false, completion: {
                                        DispatchQueue.main.async {
                                            NiftyUtilitySwift.EasyDialogOneButton(
                                                viewController: self,
                                                title: nil,
                                                message: NSLocalizedString("SettingsViewController_CopyCloudToLocalFailed", comment: "iCloudのデータの取得に失敗しました。") + "(1)",
                                                buttonTitle: nil,
                                                buttonAction: nil)
                                            guard let row = self.form.rowBy(tag: "IsUseiCloud") as? SwitchRow else { return }
                                            row.value = true
                                            row.updateCell()
                                            RealmUtil.ChangeToCloudRealm()
                                        }
                                    })
                                }
                                return
                            }
                            do {
                                try RealmToRealmCopyTool.DoCopy(from: cloudRealm, to: localRealm, progress: { (text) in
                                    self.AssignMessageTo(tag: 100, text: text, dialog: dialog)
                                })
                            }catch {
                                DispatchQueue.main.async {
                                    dialog.dismiss(animated: false, completion: {
                                        NiftyUtilitySwift.EasyDialogOneButton(
                                            viewController: self,
                                            title: nil,
                                            message: NSLocalizedString("SettingsViewController_CopyCloudToLocalFailed", comment: "iCloudのデータの取得に失敗しました。") + "(2)",
                                            buttonTitle: nil, buttonAction: nil)
                                        guard let row = self.form.rowBy(tag: "IsUseiCloud") as? SwitchRow else { return }
                                        row.value = true
                                        row.updateCell()
                                        RealmUtil.ChangeToCloudRealm()
                                    })
                                }
                                return
                            }
                            DispatchQueue.main.async {
                                dialog.dismiss(animated: false) {
                                    RealmUtil.ChangeToLocalRealm()
                                    NiftyUtilitySwift.EasyDialogOneButton(
                                        viewController: self,
                                        title: nil,
                                        message: NSLocalizedString("SettingsViewController_iCloudDisable_done", comment: "iCloud同期を停止しました"),
                                        buttonTitle: nil,
                                        buttonAction: nil)
                                }
                            }
                        }
                    }

            })
        }
    }
    
    func removeICloudDataAndUploadLocalData() {
        // TODO RealmUtil.ClearCloudRealmModels() は iCloud 同期が終わっていない状態で呼び出すと消し損ないが発生するのであまりよろしくありません。
        DispatchQueue.main.async {
            NiftyUtilitySwift.EasyDialogNoButton(viewController: self, title: NSLocalizedString("SettingsViewController_RemoveICloudData", comment: "iCloud側に残っているデータを消去しています"), message: nil) { (dialog) in
                RealmUtil.ClearCloudRealmModels()
                DispatchQueue.main.async {
                    dialog.dismiss(animated: false) {
                        self.overrideLocalToiCloud()
                    }
                }
            }
        }
    }
    
    func overrideLocalToiCloud() {
        DispatchQueue.main.async {
            NiftyUtilitySwift.EasyDialogNoButton(
                viewController: self, title: NSLocalizedString("SettingsViewController_CopyingLocalToCloud", comment: "現在のデータをiCloud側に登録中"), message: "-", completion: { (dialog) in
                    DispatchQueue.global(qos: .userInitiated).async {
                        autoreleasepool {
                            RealmUtil.ForceRemoveIceCreamDatabaseSyncTokens()
                            RealmUtil.CloudPull()
                            guard let cloudRealm = try? RealmUtil.GetCloudRealm(), let localRealm = try? RealmUtil.GetLocalRealm() else {
                                DispatchQueue.main.async {
                                    dialog.dismiss(animated: false, completion: {
                                        DispatchQueue.main.async {
                                            NiftyUtilitySwift.EasyDialogOneButton(
                                                viewController: self,
                                                title: nil,
                                                message: NSLocalizedString("SettingsViewController_CopyLocalToCloudFailed", comment: "現在のデータのiCloud側への登録に失敗しました。") + "(1)",
                                                buttonTitle: nil, buttonAction: nil)
                                            guard let row = self.form.rowBy(tag: "IsUseiCloud") as? SwitchRow else { return }
                                            row.value = false
                                            row.updateCell()
                                            RealmUtil.ChangeToLocalRealm()
                                        }
                                    })
                                }
                                return
                            }
                            do {
                                try RealmToRealmCopyTool.DoCopy(from: localRealm, to: cloudRealm, progress: { (text) in
                                    self.AssignMessageTo(tag: 100, text: text, dialog: dialog)
                                })
                            }catch {
                                DispatchQueue.main.async {
                                    dialog.dismiss(animated: false, completion: {
                                        NiftyUtilitySwift.EasyDialogOneButton(
                                            viewController: self,
                                            title: nil,
                                            message: NSLocalizedString("SettingsViewController_CopyLocalToCloudFailed", comment: "現在のデータのiCloud側への登録に失敗しました。") + "(2)",
                                            buttonTitle: nil, buttonAction: nil)
                                        guard let row = self.form.rowBy(tag: "IsUseiCloud") as? SwitchRow else { return }
                                        row.value = false
                                        row.updateCell()
                                        RealmUtil.ChangeToLocalRealm()
                                    })
                                }
                                return
                            }
                            DispatchQueue.main.async {
                                dialog.dismiss(animated: false) {
                                    RealmUtil.ChangeToCloudRealm()
                                    NiftyUtilitySwift.EasyDialogLongMessageDialog(
                                        viewController: self,
                                        message: NSLocalizedString("SettingsViewController_iCloudEnable_done", comment: "iCloud同期を開始しました。\n同期は開始されましたが、端末側に保存されているデータをiCloud側へ登録する作業は続いています。\n端末側に保存されているデータが多い場合には、iCloud側への転送が終わるまでかなりの時間がかかる可能性があります。\nなお、残念ながらiCloud側への転送が終わったかどうかを知るすべが(開発者の知る限りでは)ありません。Appleの解説によると24時間の間はアプリを再度立ち上げれば転送を継続してくれるそうですが、機内モードにすると全てを諦められてしまうなどといった問題があるという話をWeb上でみかけたりしましたので、あまり安心はできないかもしれません。\n一応未送信や未受信のデータがある場合には通信中のインジケータを回すように努力はしますが、このインジケータが消えた事で送信が終了したというわけではないかもしれない、という事を理解しておいてください。"))
                                }
                            }
                        }
                    }

            })
        }
    }
    
    func ChooseUseiCloudDataOrOverrideLocalData() {
        DispatchQueue.main.async {
            NiftyUtilitySwift.EasyDialogBuilder(self)
            .label(text: NSLocalizedString("SettingsViewController_IsUseiCloud_ChooseiCloudDataOrLocalData", comment: "iCloud側に利用可能なデータが存在するようです。iCloud側のデータをそのまま利用するか、現在のデータでiCloud上のデータを上書きするかを選択してください。"))
            .addButton(title: NSLocalizedString("SettingsViewController_IsUseiCloud_ChooseiCloudDataOrLocalData_ChooseiCloud", comment: "iCloudのデータをそのまま利用する"), callback: { (dialog) in
                DispatchQueue.main.async {
                    dialog.dismiss(animated: false) {
                        DispatchQueue.main.async {
                            NiftyUtilitySwift.EasyDialogTwoButton(
                                viewController: self,
                                title: nil,
                                message: NSLocalizedString("SettingsViewController_IsUseiCloud_ConifirmRemoveLocalData", comment: "iCloud上のデータを利用する事にします。現在のデータは破棄されます。この操作は元に戻せません。よろしいですか？"),
                                button1Title: nil, // cancel
                                button1Action: {
                                    DispatchQueue.main.async {
                                        guard let row = self.form.rowBy(tag: "IsUseiCloud") as? SwitchRow else { return }
                                        row.value = false
                                        row.updateCell()
                                        RealmUtil.ChangeToLocalRealm()
                                    }
                                },
                                button2Title: nil, // OK
                                button2Action: {
                                    DispatchQueue.main.async {
                                        RealmUtil.ChangeToCloudRealm()
                                        NiftyUtilitySwift.StartiCloudDataVersionChecker()
                                        NiftyUtilitySwift.EasyDialogLongMessageDialog(
                                            viewController: self,
                                            message: NSLocalizedString("SettingsViewController_iCloudEnable_done", comment: "iCloud同期を開始しました"))
                                    }
                                }
                            )
                        }
                    }
                }
            })
            .addButton(title: NSLocalizedString("SettingsViewController_IsUseiCloud_ChooseiCloudDataOrLocalData_ChooseLocal", comment: "現在のデータでiCloud上のデータを上書きする"), callback: { (dialog) in
                DispatchQueue.main.async {
                    dialog.dismiss(animated: false, completion: {
                        self.overrideLocalToiCloud()
                    })
                }
            })
                /*
                 removeICloudDataAndUploadLocalData() は
                 RealmUtil.ClearCloudRealmModels() を内部で呼び出しますが、
                 RealmUtil.ClearCloudRealmModels() は
                 iCloud 同期が終わっていない状態で呼び出すと消し損ないが発生するため、
                 利用すべきではありません。
                 そのため、今の所は
                 iCloud上のデータを消して現在のデータを送信する機能は有効化できません。
                 やるとするなら、設定アプリ側で → iCloud → ストレージを管理 → ことせかい → データを削除 みたいな感じで消すのが良さそうです。
            .addButton(title: NSLocalizedString("SettingsViewController_IsUseiCloud_ChooseiCloudDataOrLocalData_ChooseLocalOnly", comment: "iCloud上のデータは全て消去し、現在のデータをiCloudに送信する"), callback: { (dialog) in
                DispatchQueue.main.async {
                    dialog.dismiss(animated: false, completion: {
                        self.removeICloudDataAndUploadLocalData()
                    })
                }
            })
                 */
            .addButton(title: NSLocalizedString("SettingsViewController_IsUseiCloud_ChooseiCloudDataOrLocalData_Cancel", comment: "iCloud同期をやめる(キャンセル)"), callback: { (dialog) in
                DispatchQueue.main.async {
                    dialog.dismiss(animated: false, completion: nil)
                    guard let row = self.form.rowBy(tag: "IsUseiCloud") as? SwitchRow else { return }
                    row.value = false
                    row.updateCell()
                    RealmUtil.ChangeToLocalRealm()
                }
            })
            .build().show()
        }
    }
    
    // データは入っているけれど完全ではないぽい iCloudデータ を受信してしまったけれどどうする？
    // とユーザに尋ねる
    func ChooseInvalidiCloudDataProcess() {
        DispatchQueue.main.async {
            NiftyUtilitySwift.EasyDialogBuilder(self)
            .textView(content: NSLocalizedString("SettingsViewController_ChooseInvalidiCloudData_Message", comment: "iCloud 側にデータが存在する事は確認したのですが、ことせかい で利用するために必須のデータを取得できませんでした。\n\nネットワークの状態が悪い場合や iCloud側 に保存されているデータの量が多かった場合、以前 iCloud同期 を行った端末のデータが iCloud側 へ転送しきれていなかった場合といったような色々な場合が考えられますが、とにかくこのままでは正常に利用する事はできそうにありません。\n\nなお、この端末にあるデータを iCloud側 に上書き保存する形で iCloud同期 を ON にする事もできます。iCloud側 に上書き保存する場合、iCloud側とこの端末側の両方に存在する設定や小説はこの端末側の値に、iCloud側にしか存在しない設定や小説はiCloud側の物が残るという形になります。\n\n上書き保存する形でiCloud同期を開始しますか？"), heightMultiplier: 0.65)
            .addButton(title: NSLocalizedString("SettingsViewController_IsUseiCloud_ChooseiCloudDataOrLocalData_ChooseLocal", comment: "現在のデータでiCloud上のデータを上書きする"), callback: { (dialog) in
                DispatchQueue.main.async {
                    dialog.dismiss(animated: false, completion: {
                        self.overrideLocalToiCloud()
                    })
                }
            })
            .addButton(title: NSLocalizedString("SettingsViewController_IsUseiCloud_ChooseiCloudDataOrLocalData_Cancel", comment: "iCloud同期をやめる(キャンセル)"), callback: { (dialog) in
                DispatchQueue.main.async {
                    dialog.dismiss(animated: false, completion: nil)
                    guard let row = self.form.rowBy(tag: "IsUseiCloud") as? SwitchRow else { return }
                    row.value = false
                    row.updateCell()
                    RealmUtil.ChangeToLocalRealm()
                }
            })
            .build().show()
        }
    }
    
    func CheckiCloudDataForiCloudEnable() {
        DispatchQueue.main.async {
            // 全てのダウンロードを止めてから作業を行います。
            NovelDownloadQueue.shared.ClearAllDownloadQueue()
            NiftyUtilitySwift.EasyDialogNoButton(
                viewController: self,
                title: NSLocalizedString("SettingsViewController_IsUseiCloud_CheckiCloudData_pulling_Title", comment: "iCloud側のデータを確認しています"),
                message: NSLocalizedString("SettingsViewController_IsUseiCloud_CheckiCloudData_pulling", comment: "iCloud側のデータを確認しています"),
                completion: { (dialog) in
                    // SyncEngine 周りを綺麗さっぱり消しておきます
                    RealmUtil.stopSyncEngine()
                    RealmUtil.ForceRemoveIceCreamDatabaseSyncTokens()
                    RealmUtil.RemoveCloudRealmFile()
                    do {
                        try RealmUtil.EnableSyncEngine()
                    }catch{
                        DispatchQueue.main.async {
                            dialog.dismiss(animated: false, completion: {
                                NiftyUtilitySwift.EasyDialogOneButton(
                                    viewController: self,
                                    title: nil,
                                    message: NSLocalizedString("SettingsViewController_IsUseiCloud_FailedSyncEngineStart", comment: "iCloud への接続に失敗しました。"),
                                    buttonTitle: nil,
                                    buttonAction: nil)
                                guard let row = self.form.rowBy(tag: "IsUseiCloud") as? SwitchRow else { return }
                                row.value = false
                                row.updateCell()
                                RealmUtil.ChangeToLocalRealm()
                            })
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        RealmUtil.CheckCloudDataIsValid { (result) in
                            func checkCloudVersionIsInvalid() -> Bool {
                                // iCloud側のデータバージョンが実行中のバイナリよりも新しかった場合は拒否します
                                if RealmCloudVersionChecker.CheckCloudDataHasInvalidVersion() == true {
                                    guard let row = self.form.rowBy(tag: "IsUseiCloud") as? SwitchRow else { return false }
                                    row.value = false
                                    row.updateCell()
                                    RealmUtil.ChangeToLocalRealm()
                                    NiftyUtilitySwift
                                        .EasyDialogOneButton(viewController: self, title: NSLocalizedString("SettingsViewController_FailediCloudEnableBecauseDataVersionInvalid_Title", comment: "アプリのバージョンアップが必要です"), message: NSLocalizedString("SettingsViewController_FailediCloudEnableBecauseDataVersionInvalid_Message", comment: "iCloud側に保存されているデータは新しいバージョンで作成された物でした。iCloud同期を行うにはアプリのバージョンアップを行う必要があります。"), buttonTitle: nil, buttonAction: nil)
                                    return true
                                }
                                return false
                            }
                            switch result {
                            case .validDataAlive:
                                // iCloud側に使えそうなデータがあった
                                DispatchQueue.main.async {
                                    dialog.dismiss(animated: false) {
                                        if checkCloudVersionIsInvalid() {
                                            return
                                        }
                                        self.ChooseUseiCloudDataOrOverrideLocalData()
                                    }
                                }
                                break
                            case .dataAliveButNotValid:
                                DispatchQueue.main.async {
                                    dialog.dismiss(animated: false) {
                                        if checkCloudVersionIsInvalid() {
                                            return
                                        }
                                        self.ChooseInvalidiCloudDataProcess()
                                    }
                                }
                            case .networkError:
                                DispatchQueue.main.async {
                                    dialog.dismiss(animated: false) {
                                        guard let row = self.form.rowBy(tag: "IsUseiCloud") as? SwitchRow else { return }
                                        row.value = false
                                        row.updateCell()
                                        RealmUtil.ChangeToLocalRealm()
                                        NiftyUtilitySwift.EasyDialogOneButton(viewController: self, title: nil, message: NSLocalizedString("SettingsViewController_FailedCheck_NetworkError", comment: "iCloud側のデータ確認に失敗しました。ネットワークに接続されていないようです。機内モードになっていたり電波の届かない場所に居るなどの問題があるかもしれません。iCloud同期の初回チェックは安定したインターネット接続ができる環境で行ってください。"), buttonTitle: nil, buttonAction: nil)
                                    }
                                }
                            case .validDataNotAlive:
                                DispatchQueue.main.async {
                                    dialog.dismiss(animated: false) {
                                        self.overrideLocalToiCloud()
                                    }
                                }
                            case .checkFailed:
                                DispatchQueue.main.async {
                                    dialog.dismiss(animated: false) {
                                        guard let row = self.form.rowBy(tag: "IsUseiCloud") as? SwitchRow else { return }
                                        row.value = false
                                        row.updateCell()
                                        RealmUtil.ChangeToLocalRealm()
                                        NiftyUtilitySwift.EasyDialogOneButton(viewController: self, title: nil, message: NSLocalizedString("SettingsViewController_FailedCheckIcloudDataIsValid", comment: "iCloud側のデータ確認に失敗しました。"), buttonTitle: nil, buttonAction: nil)
                                    }
                                }
                            }
                        }
                    }
            })
        }
    }
    
    func ConifirmiCloudEnable() {
        if RealmUtil.CheckIsCloudRealmCreated() {
            DispatchQueue.main.async {
                NiftyUtilitySwift.EasyDialogOneButton(viewController: self, title: NSLocalizedString("SettingsViewController_IsNeedRestartApp_Title", comment: "アプリの再起動が必要です"), message: NSLocalizedString("SettingsViewController_IsNeedRestartApp_Message", comment: "この操作を行うためには一旦アプリを再起動させる必要があります。Appスイッチャーなどからアプリを終了させ、再度起動させた後にもう一度お試しください。"), buttonTitle: nil, buttonAction: {
                    DispatchQueue.main.async {
                        guard let row = self.form.rowBy(tag: "IsUseiCloud") as? SwitchRow else { return }
                        row.value = false
                        row.updateCell()
                    }
                })
            }
            return
        }
        
        CheckiCloudAccountStatusIsValid(okHandler: {
            DispatchQueue.main.async {
                NiftyUtilitySwift.EasyDialogLongMessageTwoButton(
                    viewController: self,
                    title: NSLocalizedString("SettingsViewController_IsUseiCloud_ConifirmTitle", comment: "iCloud 同期を有効にしますか？"),
                    message: NSLocalizedString("SettingsViewController_IsUseiCloud_ConifirmMessage", comment: "iCloud 同期を有効にすると、ことせかい 内のデータを書き換えるたびに iCloud による通信が試みるようになります。例えば小説を開いたり、読み上げを行ったりしただけでもデータが書き換わりますので、頻繁に通信が発生する事になります。"),
                    button1Title: nil,
                    button1Action: {
                        DispatchQueue.main.async {
                            guard let row = self.form.rowBy(tag: "IsUseiCloud") as? SwitchRow else { return }
                            row.value = false
                            row.updateCell()
                        }
                    },
                    button2Title: nil,
                    button2Action: {
                        self.CheckiCloudDataForiCloudEnable()
                    })
            }
        }, ngHandler: { (errorDescription) in
            DispatchQueue.main.async {
                guard let row = self.form.rowBy(tag: "IsUseiCloud") as? SwitchRow else { return }
                
                row.value = false
                row.updateCell()
                NiftyUtilitySwift.EasyDialogOneButton(
                    viewController: self,
                    title: NSLocalizedString("SettingsViewController_InvalidiCloudStatus", comment: "iCloud の状態に問題がありました。"),
                    message: errorDescription,
                    buttonTitle: nil,
                    buttonAction: nil)
            }
        })
    }
    
    func CheckiCloudAccountStatusIsValid(okHandler:(() -> Void)?, ngHandler:((String)->Void)?) {
        RealmUtil.GetCloudAccountStatus { (accountStatus, error) in
            if let error = error {
                ngHandler?(error.localizedDescription)
                return
            }
            switch accountStatus {
            case .available:
                okHandler?()
            case .restricted:
                ngHandler?(NSLocalizedString("SettingsViewController_iCloudAccountInvalid_restricted", comment: "iCloud アカウントが制限付きの状態でしたので利用できません。"))
            case .noAccount:
                ngHandler?(NSLocalizedString("SettingsViewController_iCloudAccountInvalid_noAccount", comment: "iCloud アカウントが設定されていません。"))
            case .couldNotDetermine:
                fallthrough
            @unknown default:
                ngHandler?(NSLocalizedString("SettingsViewController_iCloudAccountInvalid_cloudNotDetermine", comment: "iCloud アカウントの状態を取得できませんでした。"))
            }
        }
    }
    
    func ConifirmiCloudDisable() {
        if RealmUtil.CheckIsLocalRealmCreated() {
            DispatchQueue.main.async {
                NiftyUtilitySwift.EasyDialogOneButton(viewController: self, title: NSLocalizedString("SettingsViewController_IsNeedRestartApp_Title", comment: "アプリの再起動が必要です"), message: NSLocalizedString("SettingsViewController_IsNeedRestartApp_Message", comment: "この操作を行うためには一旦アプリを再起動させる必要があります。Appスイッチャーなどからアプリを終了させ、再度起動させた後にもう一度お試しください。"), buttonTitle: nil, buttonAction: {
                    DispatchQueue.main.async {
                        guard let row = self.form.rowBy(tag: "IsUseiCloud") as? SwitchRow else { return }
                        row.value = true
                        row.updateCell()
                    }
                })
            }
            return
        }
        CheckiCloudAccountStatusIsValid(okHandler: {
            DispatchQueue.main.async {
                NiftyUtilitySwift.EasyDialogTwoButton(
                    viewController: self,
                    title: NSLocalizedString("SettingsViewController_IsUseiCloud_ConifirmTitle_disable", comment: "iCloud 同期を無効にしますか？"),
                    message: nil,
                    button1Title: nil,
                    button1Action: {
                        DispatchQueue.main.async {
                            guard let row = self.form.rowBy(tag: "IsUseiCloud") as? SwitchRow else { return }
                            row.value = true
                            row.updateCell()
                        }
                    },
                    button2Title: nil,
                    button2Action: {
                        self.overrideiCloudToLocal()
                })
            }
        }) { (errorDescription) in
            DispatchQueue.main.async {
                guard let row = self.form.rowBy(tag: "IsUseiCloud") as? SwitchRow else { return }
                row.value = true
                row.updateCell()
                NiftyUtilitySwift.EasyDialogOneButton(
                    viewController: self,
                    title: NSLocalizedString("SettingsViewController_InvalidiCloudStatus", comment: "iCloud の状態に問題がありました。"),
                    message: errorDescription,
                    buttonTitle: nil,
                    buttonAction: nil)
            }
        }
    }
    
    // 新規のユーザ本を追加して、編集ページに遷移する
    func CreateNewUserText(){
        performSegue(withIdentifier: "CreateNewUserTextSegue", sender: self)
        /* MEMO: 自前でWidgetを配置することができればこういう感じで segue を使わずに画面遷移しようと思っています。
        let novel = RealmNovel()
        let nextViewController = EditBookViewController()
        nextViewController.targetNovel = novel
        self.navigationController?.pushViewController(nextViewController, animated: true)
         */
    }
    /// 標準で用意された読み上げ辞書を上書き追加します。
    func AddDefaultSpeechModSetting(){
        RealmUtil.RealmBlock { (realm) -> Void in
            NovelSpeakerUtility.OverrideDefaultSpeechModSettingsWith(realm: realm)
        }
        DispatchQueue.main.async {
            NiftyUtilitySwift.EasyDialogBuilder(self)
                .label(text: NSLocalizedString("SettingTableViewController_AnAddressAddedAStandardParaphrasingDictionary", comment: "標準の読み替え辞書を上書き追加しました。"))
                .addButton(title: NSLocalizedString("OK_button", comment: "OK"), callback: {dialog in
                    DispatchQueue.main.async {
                        dialog.dismiss(animated: false)
                    }
                })
                .build().show()
        }
    }
    /// 標準で用意された読み上げ辞書で上書きして良いか確認した上で、上書き追加します。
    func ConfirmAddDefaultSpeechModSetting(){
        DispatchQueue.main.async {
            NiftyUtilitySwift.EasyDialogBuilder(self)
                .title(title: NSLocalizedString("SettingTableViewController_ConfirmAddDefaultSpeechModSetting", comment:"確認"))
                .label(text: NSLocalizedString("SettingtableViewController_ConfirmAddDefaultSpeechModSettingMessage", comment:"用意された読み替え辞書を追加・上書きします。よろしいですか？"))
                .addButton(title: NSLocalizedString("Cancel_button", comment:"Cancel"), callback: { dialog in
                    DispatchQueue.main.async {
                        dialog.dismiss(animated: true)
                    }
                })
                .addButton(title: NSLocalizedString("OK_button", comment:"OK"), callback: {dialog in
                    DispatchQueue.main.async {
                        dialog.dismiss(animated: false, completion: nil)
                    }
                    self.AddDefaultSpeechModSetting()
                })
                .build().show()
        }
    }

    @discardableResult
    func sendMailWithBinary(data:Data, fileName:String, mimeType:String) -> Bool {
        if !MFMailComposeViewController.canSendMail() {
            return false;
        }
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self;
        picker.setSubject(NSLocalizedString("SettingTableView_SendEmailForBackupTitle", comment:"ことせかい バックアップ"))
        var messageBody = NSLocalizedString("SettingTableView_SendEmailForBackupBody", comment:"添付されたファイルを ことせかい で読み込む事で、小説のリストが再生成されます。")
        if data.count >= 1024*1024*5 { // 5MBytes以上
            messageBody += "\r\n" + String(format: NSLocalizedString("SettingTableView_SendEmailWithLargeFileWarning", comment: "なお、今回添付されているファイルは %@ ととても大きいため、メールの転送経路によってはエラーを引き起こす可能性があります。\r\niCloud DriveのMail Dropという機能を使うとかなり大きなファイル(最大5GBytesまで)のファイルを送信できるようになるので、そちらの利用を検討したほうが良いかもしれません。"), NiftyUtilitySwift.ByteSizeToVisibleString(byteSize: data.count)) 
        }
        picker.setMessageBody(messageBody, isHTML: false)
        picker.addAttachmentData(data, mimeType: mimeType, fileName: fileName)
        present(picker, animated: true, completion: nil)
        return true;
    }
    
    /// 現在の本棚にある小説のリストを再ダウンロードするためのURLを取得して、シェアします。
    func ShareNcodeListURLScheme(){
        DispatchQueue.main.async {
            NiftyUtilitySwift.EasyDialogBuilder(self)
            .text(content: NSLocalizedString("SettingsViewController_IsCreateFullBackup?", comment: "小説の本文まで含めた完全なバックアップファイルを生成しますか？\r\n登録小説数が多い場合は生成に膨大な時間と本体容量が必要となります。"))
            .addButton(title: NSLocalizedString("SettingsViewController_ChooseFullBackup", comment: "完全バックアップを生成する(時間がかかります)")) { (dialog) in
                DispatchQueue.main.async {
                    dialog.dismiss(animated: false, completion: {
                        self.ShareBackupData(withAllStoryContent: true)
                    })
                }
            }.addButton(title: NSLocalizedString("SettingsViewController_ChooseSmallBackup", comment: "軽量バックアップを生成する(時間はかかりません)")) { (dialog) in
                DispatchQueue.main.async {
                    dialog.dismiss(animated: false, completion: {
                        self.ShareBackupData(withAllStoryContent: false)
                    })
                }
            }.addButton(title: NSLocalizedString("SettingsViewController_ChooseCancel", comment: "キャンセル")) { (dialog) in
                DispatchQueue.main.async {
                    dialog.dismiss(animated: false, completion: nil)
                }
            }.build().show()
        }
    }
    
    func ShareToFile(dataFileURL:URL, fileName:String) {
        DispatchQueue.main.async {
            let activityViewController = UIActivityViewController(activityItems: [dataFileURL], applicationActivities: nil)
            let frame = UIScreen.main.bounds
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: frame.width / 2 - 60, y: frame.size.height - 50, width: 120, height: 50)
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func ShareBackupData(dataFileURL:URL, fileName:String) {
        if !MFMailComposeViewController.canSendMail() {
            ShareToFile(dataFileURL: dataFileURL, fileName: fileName)
            return
        }
        DispatchQueue.main.async {
            let dialog = NiftyUtilitySwift.EasyDialogBuilder(self)
            dialog.title(title: NSLocalizedString("SettingsViewController_ShareBackupDataSelectHow_Title", comment: "バックアップデータの送信方式を選んで下さい"))
                .addButton(title: NSLocalizedString("Cancel_button", comment: "Cancel"), callback: { (dialog) in
                    dialog.dismiss(animated: false, completion: nil)
                })
            .addButton(title: NSLocalizedString("SettingsViewController_ShareBackupDataSelectHow_Mail", comment: "メールに添付する"), callback: { (dialog) in
                dialog.dismiss(animated: false) {
                    if let data = try? Data(contentsOf: dataFileURL, options: .dataReadingMapped) {
                        self.sendMailWithBinary(data: data, fileName: fileName, mimeType: "application/octet-stream")
                    }else{
                        NiftyUtilitySwift.EasyDialogOneButton(viewController: self, title: NSLocalizedString("SettingsViewController_ShareBackupSelect_FailedAppendToMail", comment: "メールへのファイルの添付に失敗しました。"), message: nil, buttonTitle: nil, buttonAction: nil)
                    }
                }
            }).addButton(title: NSLocalizedString("SettingsViewController_ShareBackupDataSelectHow_ShareButton", comment: "シェア")) { (dialog) in
                dialog.dismiss(animated: false) {
                    self.ShareToFile(dataFileURL: dataFileURL, fileName: fileName)
                }
            }.build().show()
        }
    }
    /// 現在の状態をファイルにして mail に添付します。
    func ShareBackupData(withAllStoryContent:Bool){
        let labelTag = 100
        let dialog = NiftyUtilitySwift.EasyDialogBuilder(self)
            .label(text: NSLocalizedString("SettingsViewController_CreatingBackupData", comment: "バックアップデータ作成中です。\r\nしばらくお待ち下さい……"), textAlignment: NSTextAlignment.center, tag: labelTag)
            .build()
        DispatchQueue.main.async {
            dialog.show()
        }
        DispatchQueue.global(qos: .userInitiated).async {
            guard let backupData = NovelSpeakerUtility.CreateBackupData(withAllStoryContent: withAllStoryContent, progress: { (description) in
                DispatchQueue.main.async {
                    if let label = dialog.view.viewWithTag(labelTag) as? UILabel {
                        label.text = NSLocalizedString("SettingsViewController_CreatingBackupData", comment: "バックアップデータ作成中です。\r\nしばらくお待ち下さい……") + "\r\n"
                            + description
                    }
                }
            }) else {
                DispatchQueue.main.async {
                    dialog.dismiss(animated: false, completion: nil)
                    NiftyUtilitySwift.EasyDialogOneButton(viewController: self, title: NSLocalizedString("SettingsViewController_GenerateBackupDataFailed", comment: "バックアップデータの生成に失敗しました。"), message: nil, buttonTitle: nil, buttonAction: nil)
                }
                return
            }
            let fileName = backupData.lastPathComponent
            DispatchQueue.main.async {
                dialog.dismiss(animated: false) {
                    self.ShareBackupData(dataFileURL: backupData, fileName: fileName)
                }
            }
        }
    }
    
    // MFMailComposeViewController でmailアプリ終了時に呼び出されるのでこのタイミングで viewController を取り戻します
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "CreateNewUserTextSegue":
                if let nextViewController:EditBookViewController = segue.destination as? EditBookViewController {
                    let novelID = RealmNovel.AddNewNovelOnlyText(content: "", title: NSLocalizedString("GlobalDataSingleton_NewUserBookTitle", comment: "新規ユーザ小説"))
                    nextViewController.targetNovelID = novelID
                }
                break
            default:
                break
            }
        }
    }
}
