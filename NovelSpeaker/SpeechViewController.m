//
//  ViewController.m
//  NovelSpeaker
//
//  Created by 飯村 卓司 on 2014/05/06.
//  Copyright (c) 2014年 IIMURA Takuji. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Social/Social.h>
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/NSAttributedString.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SpeechViewController.h"
#import "Story.h"
#import "NarouContent.h"
#import "GlobalDataSingleton.h"
#import "EasyShare.h"
#import "CreateSpeechModSettingViewController.h"
#import "EditUserBookViewController.h"
#import "NovelSpeaker-Swift.h"
#import "PickerViewDialog.h"

@interface SpeechViewController ()

@end

@implementation SpeechViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [BehaviorLogger AddLogWithDescription:@"SpeechViewController viewDidLoad" data:@{@"ncode": self.NarouContentDetail.ncode == nil ? @"nil" : self.NarouContentDetail.ncode}];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    //[[GlobalDataSingleton GetInstance] AddLogString:[[NSString alloc] initWithFormat:@"SpeechViewController viewDidLoad %@, reading_chapter: %d, currentReadingStory: %p", self.NarouContentDetail.title, [self.NarouContentDetail.reading_chapter intValue], self.NarouContentDetail.currentReadingStory]]; // NSLog
    
    [[GlobalDataSingleton GetInstance] AddSpeakRangeDelegate:self];
    
    m_SeekTimer = nil;
    m_bIsSeeking = false;
    
    // NavitationBar にボタンを配置します。
    NSString* speakText = NSLocalizedString(@"SpeechViewController_Speak", @"Speak");
    if ([[GlobalDataSingleton GetInstance] isSpeaking]) {
        speakText = NSLocalizedString(@"SpeechViewController_Stop", @"Stop");
    }
    NSMutableArray* buttonItemList = [NSMutableArray new];
    startStopButton = [[UIBarButtonItem alloc] initWithTitle:speakText style:UIBarButtonItemStylePlain target:self action:@selector(startStopButtonClick:)];
    [buttonItemList addObject:startStopButton];
    
    NSString* detailText;
    if ([self.NarouContentDetail isURLContent]){
        detailText = NSLocalizedString(@"SpeechViewController_Edit", @"編集");
    }else if ([self.NarouContentDetail isUserCreatedContent]) {
        detailText = NSLocalizedString(@"SpeechViewController_Edit", @"編集");
    }else{
        detailText = NSLocalizedString(@"SpeechViewController_Detail", @"詳細");
    }
    detailButton = [[UIBarButtonItem alloc] initWithTitle:detailText style:UIBarButtonItemStylePlain target:self action:@selector(detailButtonClick:)];
    [buttonItemList addObject:detailButton];
    if ([self.NarouContentDetail isUserCreatedContent] != true) {
        shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonClicked:)];
        [buttonItemList addObject:shareButton];
    }
    if ([self.NarouContentDetail isURLContent]) {
        UIBarButtonItem* refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(urlRefreshButtonClick:)];
        [buttonItemList addObject:refreshButton];
    }
    if ([self.NarouContentDetail isURLContent] || ![self.NarouContentDetail isUserCreatedContent]) {
        UIBarButtonItem* safariButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"earth"] style:UIBarButtonItemStylePlain target:self action:@selector(safariButtonClick:)];
        [buttonItemList addObject:safariButton];
    }
    [buttonItemList addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonClicked:)]];
    self.navigationItem.rightBarButtonItems = buttonItemList;
    self.navigationItem.title = self.NarouContentDetail.title;

    // 左右のスワイプを設定します。
    UISwipeGestureRecognizer* rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(RightSwipe:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipe];
    UISwipeGestureRecognizer* leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(LeftSwipe:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipe];

    [self updateChapterSlider];

    // フォントサイズを設定された値に変更します。
    [self loadAndSetFontSize];
    
    // フォントサイズ変更イベントを受け取るようにします。
    [self setNotificationReciver];

    // 読み上げ設定をloadします。
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    [globalData ReloadSpeechSetting];
    // 読み上げる文章を設定します。
    //[self SetCurrentReadingPointFromSavedData:self.NarouContentDetail.ncode];
    
    // textView で選択範囲が変えられた時のイベントハンドラに自分を登録します
    self.textView.delegate = self;

    // 読み替え辞書への直接登録メニューを追加します
    [self setNovelSpeakerMenu];

    // ページめくり音を読み込んで準備……すると(設定如何によって)別アプリでの音楽再生が止められるため、
    // 再生開始時までは先送りにします
    m_PageTurningSoundPlayer = nil;
    
    m_bIsSpeaking = NO;
}

- (void)dealloc
{
    [self removeNotificationReciver];
    [self SaveCurrentReadingPoint];
    [[GlobalDataSingleton GetInstance] DeleteSpeakRangeDelegate:self];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    
    [self ApplyCustomTheme];

    //[[GlobalDataSingleton GetInstance] AddLogString:[[NSString alloc] initWithFormat:@"SpeechViewController viewDidAppear %@", self.NarouContentDetail.title]]; // NSLog

    // なにやら登録が外れる事があるようなので、AddSpeakRangeDelegate をこのタイミングでも呼んでおきます。
    // AddSpeakRangeDelegate は複数回呼んでも大丈夫なように作ってあるはずです
    //[self SetCurrentReadingPointFromSavedData:self.NarouContentDetail.ncode];
    [globalData AddSpeakRangeDelegate:self];
    //[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self.textView becomeFirstResponder];
    [self enableMPRemoteCommandCenterEvents];

    // 読み上げる文章を改めて設定したいです
    // が、読み上げ中である場合には現在保存されている情報は古いため、
    // 読み上げを停止→現在の読み上げ位置を保存→読み上げ文章を改めてロード
    // という手順を踏む必要があります。
    if ([globalData isSpeaking]) {
        // [self stopSpeech] を呼んでしまうと、現在表示されているもので読み上げ位置を更新してしまうため、
        // globalData 側の StopSpeech を呼び出します。この時、globalData側 で読み上げ位置を保存していますので改めて保存の必要はありません。
        [globalData StopSpeech];
    }
    // 読み上げ位置の更新がDB本体に保存されるまで待って、読み上げ位置を改めて設定します
    // (間髪入れずに読み出そうとすると保存されていない古い情報を読む可能性が少しだけあるはずです)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self SetCurrentReadingPointFromSavedData:self.NarouContentDetail.ncode];
        if (self.NeedResumeSpeech) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(700 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                [self startSpeech:true];
            });
        }
    });
    
    // 読み上げ中かどうかが画面が表示されていない時に更新される場合があるので、表示を更新しておきます。
    if ([globalData isSpeaking]) {
        startStopButton.title = NSLocalizedString(@"SpeechViewController_Stop", @"Stop");
    }else{
        startStopButton.title = NSLocalizedString(@"SpeechViewController_Speak", @"Speak");
        [self setNovelSpeakerMenu];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self disableMPRemoteCommandCenterEvents];
    [self stopSpeech];
    //[[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    [self SaveCurrentReadingPoint];
    [[GlobalDataSingleton GetInstance] DeleteSpeakRangeDelegate:self];
    
    [self ResumeTheme];
    [super viewWillDisappear:animated];
}

- (void)setNovelSpeakerMenu {
    UIMenuController* menuController = [UIMenuController sharedMenuController];
    UIMenuItem* speechModMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"SpeechViewController_AddSpeechModSettings", @"読み替え辞書へ登録") action:@selector(setSpeechModSetting:)];
    [menuController setMenuItems:@[speechModMenuItem]];
}
- (void)clearNovelSpeakerMenu {
    UIMenuController* menuController = [UIMenuController sharedMenuController];
    [menuController setMenuItems:@[]];
}

- (DuplicateSoundPlayer*)GetPageTurningSoundPlayer {
    if (m_PageTurningSoundPlayer != nil) {
        return m_PageTurningSoundPlayer;
    }
    m_PageTurningSoundPlayer = [DuplicateSoundPlayer new];
    if (m_PageTurningSoundPlayer == nil || ![m_PageTurningSoundPlayer setMediaFileForResource:@"nc48625" ofType:@"m4a" maxDuplicateCount:1]){
        NSLog(@"load Page turning sound failed.");
    }
    return nil;
}

- (void)ApplyCustomTheme:(UIColor*)backgroundColor foregroundColor:(UIColor*)foregroundColor indicatorStyle:(UIScrollViewIndicatorStyle)indicatorStyle barStyle:(UIBarStyle)barStyle {

    self.view.backgroundColor = backgroundColor;
    self.textView.textColor = foregroundColor;
    self.textView.backgroundColor = backgroundColor;
    self.textView.indicatorStyle = indicatorStyle;
    self.NextChapterButton.backgroundColor = backgroundColor;
    self.PrevChapterButton.backgroundColor = backgroundColor;
    self.ChapterSlider.backgroundColor = backgroundColor;
    self.ChapterIndicatorLabel.backgroundColor = backgroundColor;
    self.ChapterIndicatorLabel.textColor = foregroundColor;
    self.tabBarController.tabBar.barTintColor = backgroundColor;
    //self.navigationController.navigationBar.tintColor = [[UIColor alloc] initWithRed:0.5 green:0.5 blue:1.0 alpha:1.0];
    self.navigationController.navigationBar.barTintColor = backgroundColor;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: foregroundColor};

    // ステータスバーの色を指定する
    if (self.navigationController != nil) {
        self.navigationController.navigationBar.barStyle = barStyle;
    }
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    UIColor* backgroundColor = [globalData GetReadingColorSettingForBackgroundColor];
    UIColor* foregroundColor = [globalData GetReadingColorSettingForForegroundColor];
    if (backgroundColor == nil || foregroundColor == nil) {
        return UIStatusBarStyleDefault;
    }
    CGFloat red, green, blue, alpha;
    [backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
    if (((red + green + blue) / 3.0) < 0.5) {
        return UIStatusBarStyleLightContent; // 白い字にする
    }else{
        if (@available(iOS 13.0, *)) {
            return UIStatusBarStyleDarkContent; // ダークモード だと Default では 白い字 にされてしまうので、明示的に DarkContent とする必要がある
        } else {
            return UIStatusBarStyleDefault;
        }
    }
    return UIStatusBarStyleDefault;
}

/// カスタム色設定を適用します
- (void)ApplyCustomTheme{
    UIColor* backgroundColor = UIColor.whiteColor;
    UIColor* foregroundColor = UIColor.blackColor;
    UIScrollViewIndicatorStyle indicatorStyle = UIScrollViewIndicatorStyleDefault;
    UIBarStyle barStyle = UIBarStyleDefault;
    
    if (@available(iOS 13.0, *)) {
        backgroundColor = UIColor.systemBackgroundColor;
        foregroundColor = UIColor.labelColor;
    }
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    UIColor* settingBackgroundColor = [globalData GetReadingColorSettingForBackgroundColor];
    UIColor* settingForegroundColor = [globalData GetReadingColorSettingForForegroundColor];

    if (settingBackgroundColor != nil && settingForegroundColor != nil) {
        backgroundColor = settingBackgroundColor;
        foregroundColor = settingForegroundColor;
    }

    CGFloat red, green, blue, alpha;
    [backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
    NSLog(@"RGB: %.2f, %.2f, %.2f", red, green, blue);
    if (((red + green + blue) / 3.0) < 0.5) {
        indicatorStyle = UIScrollViewIndicatorStyleWhite;
        barStyle = UIBarStyleBlack;
    }
    
    [self ApplyCustomTheme:
     backgroundColor
     foregroundColor:foregroundColor
     indicatorStyle:indicatorStyle
     barStyle:barStyle];
    [self setNeedsStatusBarAppearanceUpdate];
}

/// 設定した色設定を標準の色設定に戻します
- (void)ResumeTheme{
    UIColor* backgroundColor = UIColor.whiteColor;
    UIColor* foregroundColor = UIColor.blackColor;
    UIScrollViewIndicatorStyle indicatorStyle = UIScrollViewIndicatorStyleDefault;
    UIBarStyle barStyle = UIBarStyleDefault;
    
    if (@available(iOS 13.0, *)) {
        backgroundColor = UIColor.systemBackgroundColor;
        foregroundColor = UIColor.labelColor;
    }
    
    [self ApplyCustomTheme:
     backgroundColor
     foregroundColor:foregroundColor
     indicatorStyle:indicatorStyle
     barStyle:barStyle];
}

/// 背景の暗いテーマを適用します
- (void)ApplyDarkTheme{
    UIColor* backgroundColor = UIColor.blackColor;
    UIColor* foregroundColor = UIColor.whiteColor;
    
    self.view.backgroundColor = backgroundColor;
    self.textView.textColor = foregroundColor;
    self.textView.backgroundColor = backgroundColor;
    self.textView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.NextChapterButton.backgroundColor = backgroundColor;
    self.PrevChapterButton.backgroundColor = backgroundColor;
    self.ChapterSlider.backgroundColor = backgroundColor;
    self.ChapterIndicatorLabel.backgroundColor = backgroundColor;
    self.ChapterIndicatorLabel.textColor = foregroundColor;
    self.tabBarController.tabBar.barTintColor = backgroundColor;
    //self.navigationController.navigationBar.tintColor = [[UIColor alloc] initWithRed:0.5 green:0.5 blue:1.0 alpha:1.0];
    self.navigationController.navigationBar.barTintColor = backgroundColor;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: foregroundColor};

    // ステータスバーの色を指定する
    if (self.navigationController != nil) {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    }
}

/// 背景の明るいテーマを適用します
- (void)ApplyBrightTheme{
    UIColor* backgroundColor = UIColor.whiteColor;
    UIColor* foregroundColor = UIColor.blackColor;

    if (@available(iOS 13.0, *)) {
        backgroundColor = UIColor.systemBackgroundColor;
        foregroundColor = UIColor.labelColor;
    }

    self.view.backgroundColor = backgroundColor;
    self.textView.textColor = foregroundColor;
    self.textView.backgroundColor = backgroundColor;
    self.textView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    self.NextChapterButton.backgroundColor = backgroundColor;
    self.PrevChapterButton.backgroundColor = backgroundColor;
    self.ChapterSlider.backgroundColor = backgroundColor;
    self.ChapterIndicatorLabel.backgroundColor = backgroundColor;
    self.ChapterIndicatorLabel.textColor = foregroundColor;
    self.tabBarController.tabBar.barTintColor = backgroundColor;
    //self.navigationController.navigationBar.tintColor = UIColor.blueColor;
    self.navigationController.navigationBar.barTintColor = backgroundColor;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: foregroundColor};

    // ステータスバーの色を指定する
    if (self.navigationController != nil) {
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    }
}

/// 現在選択されている文字列を取得します
- (NSString*) GetCurrentSelectedString {
    UITextRange* range = [self.textView selectedTextRange];
    if ([range isEmpty]){
        return nil;
    }
    return [self.textView textInRange:range];
}

/// 読み替え辞書への登録イベントハンドラ
- (void) setSpeechModSetting:(id)sender {
    [self performSegueWithIdentifier:@"SpeechViewToSpeechModSetingsSegue" sender:self];
}

/// MPRemoteCommandCenter でのイベントを受け取るようにします。
- (void) enableMPRemoteCommandCenterEvents{
    MPRemoteCommandCenter* commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [commandCenter.togglePlayPauseCommand addTarget:self action:@selector(togglePlayPauseEvent:)];
    commandCenter.togglePlayPauseCommand.enabled = true;
    [commandCenter.playCommand addTarget:self action:@selector(playEvent:)];
    commandCenter.playCommand.enabled = true;
    [commandCenter.pauseCommand addTarget:self action:@selector(stopEvent:)];
    commandCenter.pauseCommand.enabled = true;
    [commandCenter.stopCommand addTarget:self action:@selector(stopEvent:)];
    commandCenter.stopCommand.enabled = true;
    [commandCenter.nextTrackCommand addTarget:self action:@selector(nextTrackEvent:)];
    commandCenter.nextTrackCommand.enabled = true;
    [commandCenter.previousTrackCommand addTarget:self action:@selector(previousTrackEvent:)];
    commandCenter.previousTrackCommand.enabled = true;
    if ([[GlobalDataSingleton GetInstance] IsShortSkipEnabled]) {
        [commandCenter.skipForwardCommand addTarget:self action:@selector(skipForwardEvent:)];
        commandCenter.skipForwardCommand.enabled = true;
        [commandCenter.skipBackwardCommand addTarget:self action:@selector(skipBackwardEvent:)];
        commandCenter.skipBackwardCommand.enabled = true;
    }
    [commandCenter.seekForwardCommand addTarget:self action:@selector(seekForwardEvent:)];
    commandCenter.seekForwardCommand.enabled = true;
    [commandCenter.seekBackwardCommand addTarget:self action:@selector(seekBackwardEvent:)];
    commandCenter.seekBackwardCommand.enabled = true;

    if ([[GlobalDataSingleton GetInstance] IsPlaybackDurationEnabled]) {
        [commandCenter.changePlaybackPositionCommand addTarget:self action:@selector(changePlaybackPositionEvent:)];
        commandCenter.changePlaybackPositionCommand.enabled = true;
    }
}
/// MPRemoteCommandCenter でのイベントを受け取るのをやめます
- (void) disableMPRemoteCommandCenterEvents{
    MPRemoteCommandCenter* commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [commandCenter.changePlaybackPositionCommand removeTarget:self];
    commandCenter.changePlaybackPositionCommand.enabled = false;
    [commandCenter.togglePlayPauseCommand removeTarget:self];
    commandCenter.togglePlayPauseCommand.enabled = false;
    [commandCenter.playCommand removeTarget:self];
    commandCenter.playCommand.enabled = false;
    [commandCenter.pauseCommand removeTarget:self];
    commandCenter.pauseCommand.enabled = false;
    [commandCenter.stopCommand removeTarget:self];
    commandCenter.stopCommand.enabled = false;
    [commandCenter.skipForwardCommand removeTarget:self];
    commandCenter.skipForwardCommand.enabled = false;
    [commandCenter.skipBackwardCommand removeTarget:self];
    commandCenter.skipBackwardCommand.enabled = false;
    [commandCenter.seekForwardCommand removeTarget:self];
    commandCenter.seekForwardCommand.enabled = false;
    [commandCenter.seekBackwardCommand removeTarget:self];
    commandCenter.seekBackwardCommand.enabled = false;
    [commandCenter.nextTrackCommand removeTarget:self];
    commandCenter.nextTrackCommand.enabled = false;
    [commandCenter.previousTrackCommand removeTarget:self];
    commandCenter.previousTrackCommand.enabled = false;
}

/// UITextField でカーソルの位置が変わった時に呼び出されるはずです。
- (void) textViewDidChangeSelection: (UITextView*) textView
{
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    if ([globalData isSpeaking]) {
        // 話し中であればこれはバンバン呼び出されるはずだし、勝手に NiftySpeaker側 で読み上げ位置の更新をしているはずなので無視して良いです。
        return;
    }
    NSRange range = self.textView.selectedRange;
    // 何故か起動時に表示範囲外の textViewDidChangeSelection が飛んでくるのでそれは無視するようにします。
    if (range.location >= [textView.text length]) {
        return;
    }
    //[[GlobalDataSingleton GetInstance] AddLogString:[[NSString alloc] initWithFormat:@"長押しにより読み上げ位置を更新します。%@ %ld %lu", self.NarouContentDetail.title, (unsigned long)range.location, (unsigned long)[textView.text length]]]; // NSLog
    m_CurrentReadingStory.readLocation = [[NSNumber alloc] initWithUnsignedLong:range.location];
    [self SaveCurrentReadingPoint];
}

/// 読み込みに失敗した旨を表示します。
- (void)SetReadingPointFailedMessage
{
    StoryCacheData* story = [StoryCacheData new];
    story.content = NSLocalizedString(@"SpeechViewController_ContentReadFailed", @"文書の読み込みに失敗しました。");
    story.readLocation = 0;
    [self setSpeechStory:story];
}

/// 保存されている読み上げ位置を元に、現在の文書を設定します。
- (BOOL)SetCurrentReadingPointFromSavedData:(NSString*)ncode
{
    if (ncode == nil) {
        [self SetReadingPointFailedMessage];
        return false;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
        // このタイミングでNarouContent自体を読み直します
        [self ReloadNarouContentDetail];
        NarouContentCacheData* content = self.NarouContentDetail;
        // 自分の content.currentReadingStory は昔のcacheなので現在の値を読み直します
        StoryCacheData* story = content.currentReadingStory;
        if (story == nil) {
            // なにやら設定されていないようなので、最初の章を読み込むことにします。
            // TODO: XXXX: 最新情報に更新した後にここに何故か来る事があるのをなんとかする
            [globalData AddLogString:[[NSString alloc] initWithFormat:@"SpeechViewController なにやら読み上げ用の章が設定されていないようなので、最初の章を読み込みます"]]; // NSLog
            story = [globalData SearchStory:content.ncode chapter_no:1];
            if (story == nil) {
                [self SetReadingPointFailedMessage];
                return;
            }
        }
        //NSLog(@"set currentreading story: %@ (content: %@ %@) location: %lu", story.chapter_number, content.ncode, content.title, [story.readLocation unsignedLongValue]);
        [self setSpeechStory:story];
        //[holder CloseAlert:false];
    });
   
    return true;
}

/// 現在の読み込み位置を保存します。
- (void)SaveCurrentReadingPoint
{
    if (m_CurrentReadingStory == nil) {
        return;
    }
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    NSUInteger location = self.textView.selectedRange.location;
    //NSLog(@"self.textView.selectedRange.location: %lu", (unsigned long)location);
    if (location <= 0) {
        NSRange readingRange = [globalData GetCurrentReadingPoint];
        location = readingRange.location;
    }
    m_CurrentReadingStory.readLocation = [[NSNumber alloc] initWithUnsignedLong:location];
    [globalData UpdateReadingPoint:self.NarouContentDetail story:m_CurrentReadingStory];
    [globalData saveContext];
}

- (NSRange)LoadCurrentReadingPoint
{
    if (m_CurrentReadingStory == nil) {
        return NSMakeRange(0, 0);
    }
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    StoryCacheData* story = [globalData SearchStory:m_CurrentReadingStory.ncode chapter_no:[m_CurrentReadingStory.chapter_number intValue]];
    if (story == nil) {
        return NSMakeRange(0, 0);
    }
    return NSMakeRange([story.readLocation unsignedIntegerValue], 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    //[self SaveCurrentReadingPoint];
}

/// ページめくり音を再生します
- (void)RingPageTurningSound{
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    if ([globalData IsPageTurningSoundEnabled] && [globalData isSpeaking]) {
        DuplicateSoundPlayer* player = [self GetPageTurningSoundPlayer];
        if (player != nil) {
            [player startPlay];
        }
    }
}

- (BOOL)SetPreviousChapter
{
    StoryCacheData* story = [[GlobalDataSingleton GetInstance] GetPreviousChapter:m_CurrentReadingStory];
    if (story == nil) {
        return false;
    }
    [self RingPageTurningSound];
    story.readLocation = [[NSNumber alloc] initWithInt:0];
    [self UpdateCurrentReadingStory:story];
    [NiftyUtilitySwift DispatchSyncMainQueueWithBlock:^{
        [self.textView select:self];
        self.textView.selectedRange = NSMakeRange(0, 0);
    }];
    //self.textView.selectedRange = NSMakeRange(0, 0);
    [self SaveCurrentReadingPoint];
    return true;
}

- (BOOL)SetNextChapter
{
    StoryCacheData* story = [[GlobalDataSingleton GetInstance] GetNextChapter:m_CurrentReadingStory];
    if (story == nil) {
        return false;
    }
    [self RingPageTurningSound];
    story.readLocation = [[NSNumber alloc] initWithInt:0];
    [self UpdateCurrentReadingStory:story];
    [NiftyUtilitySwift DispatchSyncMainQueueWithBlock:^{
        [self.textView select:self];
        self.textView.selectedRange = NSMakeRange(0, 0);
    }];
    //self.textView.selectedRange = NSMakeRange(0, 0);
    [self SaveCurrentReadingPoint];
    return true;
}

- (void)RightSwipe:(UISwipeGestureRecognizer *)sender
{
    [self stopSpeech];
    [self SetPreviousChapter];
}
- (void)LeftSwipe:(UISwipeGestureRecognizer *)sender
{
    [self stopSpeech];
    [self SetNextChapter];
}

/// 読み上げる文章の章を変更します。
- (BOOL)UpdateCurrentReadingStory:(StoryCacheData*)story
{
    if (story == nil || story.content == nil || [story.content length] <= 0) {
        [self SetReadingPointFailedMessage];
        self.PrevChapterButton.enabled = false;
        self.NextChapterButton.enabled = false;
        return false;
    }
    if ([story.content length] < [story.readLocation intValue])
    {
        [[GlobalDataSingleton GetInstance] AddLogString:[[NSString alloc] initWithFormat:@"SpeechViewController: Story に保存されている読み込み位置(%d)が Story の長さ(%lu)を超えています。0 に上書きします。", [story.readLocation intValue], (unsigned long)[story.content length]]]; // NSLog

        //NSLog(@"Story に保存されている読み込み位置(%d)が Story の長さ(%lu)を超えています。0 に上書きします。", [story.readLocation intValue], (unsigned long)[story.content length]);
        story.readLocation = [[NSNumber alloc] initWithInt:0];
    }


    if ([story.chapter_number intValue] <= 0) {
        self.PrevChapterButton.enabled = false;
    }else{
        self.PrevChapterButton.enabled = true;
    }
    self.NextChapterButton.enabled = true;
    
    [self setSpeechStory:story];
    self.ChapterSlider.value = [story.chapter_number floatValue];
    m_CurrentReadingStory = story;
    return true;
}

/// 読み上げる文章の章を変更します(chapter指定版)
- (BOOL)ChangeChapterWithLastestReadLocation:(int)chapter
{
    if (chapter <= 0 || chapter > [self.NarouContentDetail.general_all_no intValue]) {
        [[GlobalDataSingleton GetInstance] AddLogString:[[NSString alloc] initWithFormat:@"SpeechViewController: chapter に不正な値(%d)が指定されました。(1 から %@ の間である必要があります)指定された値は無視して 1 が指定されたものとして動作します。", chapter, self.NarouContentDetail.general_all_no]]; // NSLog
        //NSLog(@"chapter に不正な値(%d)が指定されました。(1 から %@ の間である必要があります)指定された値は無視して 1 が指定されたものとして動作します。", chapter, self.NarouContentDetail.general_all_no);
        chapter = 1;
    }
    
    StoryCacheData* story = [[GlobalDataSingleton GetInstance] SearchStory:self.NarouContentDetail.ncode chapter_no:chapter];
    return [self UpdateCurrentReadingStory:story];
}

/// 読み上げを開始します。
/// 読み上げ開始点(選択範囲)がなければ一番最初から読み上げを開始することにします
- (void)startSpeech:(BOOL)withMaxSpeechTimeReset{
    // 選択範囲を表示するようにします。
    [self.textView becomeFirstResponder];
    
    // 読み上げ位置を設定します
#if 0 // 読み上げ位置を textView から取ってくると、textView が消えている事があって、selectedRange が 0,0 を返す事があるので信用しないことにします
    [NiftyUtilitySwift DispatchSyncMainQueueWithBlock:^{
        [self.textView select:self];
        NSRange range = self.textView.selectedRange;
    }];
    [[GlobalDataSingleton GetInstance] SetSpeechRange:range];
    NSLog(@"SaveCurrentReadingPoint: %@", __func__);
    [self SaveCurrentReadingPoint];
#else // 今は textViewDidChangeSelection でセレクションが移動した時のイベントをとっていて、読み上げ中でなければそちらで読み上げ位置を移動したのを保存するようにしているので、GlobalData側 が読み上げ位置の管理を行っています。ということで GlobalData から読み上げ位置を読み出すことにします。
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    [globalData SetSpeechRange:[self LoadCurrentReadingPoint]];
#endif

    // 読み上げ開始位置以降の文字列について、読み上げを開始します。
    startStopButton.title = NSLocalizedString(@"SpeechViewController_Stop", @"Stop");
    
    // 読み上げ中に出るメニュー表示を消す準備に ことせかい 由来のメニューを消します。
    [self clearNovelSpeakerMenu];
    // 読み上げを開始します
    [[GlobalDataSingleton GetInstance] StartSpeech:withMaxSpeechTimeReset];
}

/// 読み上げを「バックグラウンド再生としては止めずに」読み上げ部分だけ停止します
- (void)stopSpeechWithoutDiactivate{
    [[GlobalDataSingleton GetInstance] StopSpeechWithoutDiactivate];
    
    startStopButton.title = NSLocalizedString(@"SpeechViewController_Speak", @"Speak");
    // 読み上げ中に出ないようにしていたメニュー表示を復活させます。(ことせかい 由来のものではないものは CustomUITextView:canPerformAction 側で制御しています)
    [self SaveCurrentReadingPoint];
}

/// 読み上げを停止します
- (void)stopSpeech{
    [[GlobalDataSingleton GetInstance] StopSpeech];
    [self setNovelSpeakerMenu];

    startStopButton.title = NSLocalizedString(@"SpeechViewController_Speak", @"Speak");
    [self SaveCurrentReadingPoint];
}

- (void)UpdateChapterIndicatorLabel:(int)current max:(int)max
{
    self.ChapterIndicatorLabel.text = [[NSString alloc] initWithFormat:@"%d/%d", current, max];
}

/// 読み上げ用の文字列を設定します。
/// 読み上げ中の場合は読み上げは停止されます。
/// 読み上げられるのは text で、range で指定されている点を読み上げ開始点として読み上げを開始します。
- (void)setSpeechStory:(StoryCacheData*)story {
    //[self stopSpeech];
    NSString* displayText = [[GlobalDataSingleton GetInstance] ConvertStoryContentToDisplayText:story];
    if (displayText == nil || [displayText length] <= 0) {
        displayText = NSLocalizedString(@"SpeechViewController_ContentReadFailed", @"文書の読み込みに失敗しました。「詳細」→「Download」を選択して再ダウンロードすることで解消するかもしれません。");
    }
    [self.textView setText:displayText];
    self.ChapterSlider.value = [story.chapter_number floatValue];
    [self UpdateChapterIndicatorLabel:[story.chapter_number intValue] max:(int)self.ChapterSlider.maximumValue];
    m_CurrentReadingStory = story;
    [[GlobalDataSingleton GetInstance] SetSpeechStory:story];
    [self updateChapterSlider];
    
    // TextView は使いまわされた時、selectedRange が前の値のままのようなので、このタイミングでTextView上の読み上げ位置を上書きします
    // 本来なら textViewDidChange を受けてから self.textView.text を参照する必要がありますが、
    // 色々面倒くさいのでちょっとまってからにします。
    __block int readLocation = [story.readLocation intValue]; // story は __block で定義できない？ぽいので block 内部で使う readLocation だけ __block にしてここで取り出しておきます。
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.textView.text length] > 0) {
            if ([self.textView.text length] <= readLocation) {
                readLocation = (int)[self.textView.text length] - 1;
                if (readLocation < 0) {
                    readLocation = 0;
                }
            }
            // 起動時などにセレクションメニュー(?選択範囲の上にでる「コピー」とかの奴)が出ないように select はしないでおきます
            //[self.textView select:self];
            self.textView.selectedRange = NSMakeRange(readLocation, 1);
            [self TextViewScrollTo:readLocation];
        }
    });
}

- (void)detailButtonClick:(id)sender {
    if ([self.NarouContentDetail isUserCreatedContent]) {
        [self performSegueWithIdentifier:@"EditUserTextSegue" sender:self];
        return;
    }
    [self performSegueWithIdentifier:@"speechToDetailSegue" sender:self];
}

- (void)shareButtonClicked:(id)sender {
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    NarouContentCacheData* content = [globalData SearchNarouContentFromNcode:m_CurrentReadingStory.ncode];
    if (content == nil) {
        return;
    }
    NSString* message = nil;
    if ([content.general_all_no intValue] == 1 && [content.end boolValue] == false) {
        message = [NSString stringWithFormat:NSLocalizedString(@"SpeechViewController_TweetMessage", @"%@ %@ #narou #ことせかい %@ %@"), content.title, content.writer, [[NSString alloc] initWithFormat:@"https://ncode.syosetu.com/%@/", [m_CurrentReadingStory.ncode lowercaseString]], @"https://itunes.apple.com/jp/app/kotosekai-xiao-shuo-jianinarou/id914344185"];
    }else{
        message = [NSString stringWithFormat:NSLocalizedString(@"SpeechViewController_TweetMessage", @"%@ %@ #narou #ことせかい %@ %@"), content.title, content.writer, [[NSString alloc] initWithFormat:@"https://ncode.syosetu.com/%@/%@/", [m_CurrentReadingStory.ncode lowercaseString], m_CurrentReadingStory.chapter_number], @"https://itunes.apple.com/jp/app/kotosekai-xiao-shuo-jianinarou/id914344185"];
    }
    [EasyShare ShareText:message viewController:self barButton:shareButton];
}

- (void)startStopButtonClick:(id)sender {
    if([startStopButton.title compare:NSLocalizedString(@"SpeechViewController_Speak", @"Speak")] == NSOrderedSame)
    {
        // 停止中だったので読み上げを開始します
        if (UIAccessibilityIsVoiceOverRunning()) {
            // VoiceOver が Enable であったので、警告を発します
            [NiftyUtilitySwift EasyDialogTwoButtonWithViewController:self
               title:NSLocalizedString(@"SpeechViewController_SpeakAlertVoiceOver", @"VoiceOverが有効になっています。このまま再生しますか？")
               message:NSLocalizedString(@"SpeechViewController_SpeakAlertVoiceOverMessage", @"そのまま再生すると二重に読み上げが発声する事になります。")
               button1Title:NSLocalizedString(@"Cancel_button", @"Cancel")
               button1Action:nil
               button2Title:NSLocalizedString(@"OK_button", @"OK")
               button2Action:^{
                   self->m_bIsSpeaking = YES;
                   [self startSpeech:YES];
               }];
            return;
        }

        m_bIsSpeaking = YES;
        [self startSpeech:YES];
    }
    else
    {
        m_bIsSpeaking = NO;
        [self stopSpeech];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // 次のビューをloadする前に呼び出してくれるらしいので、そこで検索結果を放り込みます。
    if ([[segue identifier] isEqualToString:@"speechToDetailSegue"]) {
        NarouSearchResultDetailViewControllerSwift* nextViewController = [segue destinationViewController];
        nextViewController.NarouContentDetail = self.NarouContentDetail;
    }
    
    // 読み替え辞書登録時の値を放り込みます
    if ([[segue identifier] isEqualToString:@"SpeechViewToSpeechModSetingsSegue"]) {
        CreateSpeechModSettingViewController* nextViewController = [segue destinationViewController];
        nextViewController.targetBeforeString = [self GetCurrentSelectedString];
    }
    
    // ユーザ作成のコンテンツだった場合
    if ([[segue identifier] isEqualToString:@"EditUserTextSegue"]) {
        EditUserBookViewController* nextViewController = [segue destinationViewController];
        nextViewController.NarouContentDetail = self.NarouContentDetail;
    }

}

// スライダーが変更されたとき。
- (IBAction)ChapterSliderChanged:(UISlider *)sender {
    [self stopSpeech];
    int chapter = (self.ChapterSlider.value + 0.5f);
    if([self ChangeChapterWithLastestReadLocation:chapter] != true)
    {
        [self SetReadingPointFailedMessage];
    }
}
- (IBAction)PrevChapterButtonClicked:(id)sender {
    [self stopSpeech];
    [self SetPreviousChapter];
}
- (IBAction)NextChapterButtonClicked:(id)sender {
    [self stopSpeech];
    [self SetNextChapter];
}

/// location の後ろに何行か開けた分が画面内に入るように UITextView:scrollRangeToVisible を呼ぶ
- (void)TextViewScrollTo:(NSUInteger)location {
    NSString* displayString = self.textView.text;
    NSUInteger textLength = [displayString length];
    
    if (textLength <= 0) {
        location = 0;
    }else if (location >= textLength) {
        location = textLength - 1;
    }
    
    NSRange range = NSMakeRange(location, 1);
    // 何行か後までの文字数をカウントして、scrollRangeToVisible ではその行が見えるようにスクロールさせる
    const NSUInteger lineCount = 5; // 5行分まで先を表示させる
    const NSUInteger minAppendLength = 15; // 改行が連続している場合(lineCount分だけ読んでもこの文字数以下である場合)は15文字位先までは先に飛ばして良いとする
    NSString* tmpString = [displayString substringFromIndex:range.location];
    NSArray<NSString*>* lineList = [tmpString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSUInteger appendLength = 0;
    for (int i = 0; (i < lineCount || appendLength < minAppendLength) && i < [lineList count]; i++) {
        NSString* lineString = lineList[i];
        appendLength += [lineString length];
    }
    // ここまでは単に改行を探しているだけなので、改行されずに長い文章が書かれていると、読み上げている部分が飛ばされてしまう可能性がある。なので、上限を入れておく
    if (appendLength > 120) {
        appendLength = 120;
    }
    
    if (appendLength + range.location > textLength) {
        appendLength = textLength - range.location;
    }
    range.length = appendLength;
    [self.textView scrollRangeToVisible:range];
}

/// 読み上げ位置が更新されたとき
- (void) willSpeakRange:(NSRange)range speakText:(NSString*)text
{
    //NSLog(@"SpeechViewController: willSpeakRange: %lu", (unsigned long)range.location);
    m_CurrentReadingStory.readLocation = [[NSNumber alloc] initWithUnsignedLong:range.location];
    
    [NiftyUtilitySwift DispatchSyncMainQueueWithBlock:^{
        [self.textView select:self];
        self.textView.selectedRange = range;
        [self TextViewScrollTo:range.location];
    }];
}

/// 指定された章の先頭に巻き戻します
- (BOOL)RewindTo:(int)chapterNumber {
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    StoryCacheData* story = [globalData SearchStory:m_CurrentReadingStory.ncode chapter_no:chapterNumber];
    NarouContentCacheData* content = [globalData SearchNarouContentFromNcode:m_CurrentReadingStory.ncode];
    BOOL result = false;
    if (story != nil && content != nil) {
        story.readLocation = [[NSNumber alloc] initWithInt:0];
        [globalData UpdateReadingPoint:content story:story];
        result = false;
    }
    [self ChangeChapterWithLastestReadLocation:chapterNumber];
    [NiftyUtilitySwift DispatchSyncMainQueueWithBlock:^{
        [self.textView select:self];
        self.textView.selectedRange = NSMakeRange(0, 0);
    }];
    [self SaveCurrentReadingPoint];
    return true;
}

/// 読み上げが停止したとき
- (void) finishSpeak
{
    if(![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self finishSpeak];
        });
        return;
    }
    // 一つの章を繰り返し再生するように設定されている場合はそのようにします。
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    RepeatSpeechType repeatType = [globalData GetRepeatSpeechType];
    if (repeatType == RepeatSpeechType_RewindToThisStory) {
        [self RewindTo:[m_CurrentReadingStory.chapter_number intValue]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startSpeech:NO];
        });
        return;
    }

    //[self stopSpeechWithoutDiactivate];
    if ([self SetNextChapter]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startSpeech:NO];
        });
    }else{
        // 最初の章から繰り返し再生するように設定されている場合はそのようにします。
        if (repeatType == RepeatSpeechType_RewindToFirstStory) {
            [self RewindTo:1];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self startSpeech:NO];
            });
            return;
        }
        [self stopSpeech];
        [[GlobalDataSingleton GetInstance] AnnounceBySpeech:NSLocalizedString(@"SpeechViewController_SpeechStopedByEnd", @"Speak")];
    }
}

/// リモートコントロールされたとき
- (void) remoteControlReceivedWithEvent: (UIEvent*)receivedEvent
{
    NSLog(@"remoteControl event got.");
    if (receivedEvent.type != UIEventTypeRemoteControl)
    {
        return;
    }
    
    switch (receivedEvent.subtype) {
        case UIEventSubtypeRemoteControlPlay:
            //NSLog(@"event: play");
            //[self startSpeech:YES];
            //break;
        case UIEventSubtypeRemoteControlPause:
            //NSLog(@"event: pause");
            //[self stopSpeech];
            //break;
        case UIEventSubtypeRemoteControlTogglePlayPause:
            NSLog(@"event: toggle");
            if ([[GlobalDataSingleton GetInstance] isSpeaking]) {
                [self stopSpeech];
            }else{
                [self startSpeech:YES];
            }
            break;
                
        case UIEventSubtypeRemoteControlPreviousTrack:
            NSLog(@"event: prev");
            [self stopSpeechWithoutDiactivate];
            if ([self SetPreviousChapter]) {
                [self startSpeech:YES];
            }
            break;
                
        case UIEventSubtypeRemoteControlNextTrack:
            NSLog(@"event: next");
            [self stopSpeechWithoutDiactivate];
            if ([self SetNextChapter]) {
                [self startSpeech:YES];
            }
            break;
        default:
            break;
    }
}

/// MPRemoteCommandCenter からの play イベントのイベントハンドラ
- (MPRemoteCommandHandlerStatus)playEvent:(id)sendor {
    [self startSpeech:YES];
    return MPRemoteCommandHandlerStatusSuccess;
}

/// MPRemoteCommandCenter からの stop イベントのイベントハンドラ
- (MPRemoteCommandHandlerStatus)stopEvent:(id)sendor {
    [self stopSpeech];
    return MPRemoteCommandHandlerStatusSuccess;
}

/// MPRemoteCommandCenter からの togglePlayPause イベントのイベントハンドラ
- (MPRemoteCommandHandlerStatus)togglePlayPauseEvent:(id)sendor {
    if ([[GlobalDataSingleton GetInstance] isSpeaking]) {
        NSLog(@"toggle stopSpeech");
        [self stopSpeech];
    }else{
        NSLog(@"toggle startSpeech");
        [self startSpeech:YES];
    }
    return MPRemoteCommandHandlerStatusSuccess;
}

/// MPRemoteCommandCenter からの nextTrack イベントのイベントハンドラ
- (MPRemoteCommandHandlerStatus)nextTrackEvent:(id)sendor {
    [self stopSpeechWithoutDiactivate];
    if ([self SetNextChapter]) {
        [self startSpeech:YES];
    }
    return MPRemoteCommandHandlerStatusSuccess;
}

/// MPRemoteCommandCenter からの previousTrack イベントのイベントハンドラ
- (MPRemoteCommandHandlerStatus)previousTrackEvent:(id)sendor {
    [self stopSpeechWithoutDiactivate];
    if ([self SetPreviousChapter]) {
        [self startSpeech:YES];
    }
    return MPRemoteCommandHandlerStatusSuccess;
}

/// MPRemoteCommandCenter からの skipForward イベントのイベントハンドラ
- (MPRemoteCommandHandlerStatus)skipForwardEvent:(id)sendor {
    //[self stopSpeechWithoutDiactivate];
    [[GlobalDataSingleton GetInstance] StopSpeechWithoutDiactivate];
    [self skipForward:100];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self startSpeech:YES];
    });
    return MPRemoteCommandHandlerStatusSuccess;
}
/// MPRemoteCommandCenter からの skipBackword イベントのイベントハンドラ
- (MPRemoteCommandHandlerStatus)skipBackwardEvent:(id)sendor {
    //[self stopSpeechWithoutDiactivate];
    [[GlobalDataSingleton GetInstance] StopSpeechWithoutDiactivate];
    [self skipBackward:100];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self startSpeech:YES];
    });
    return MPRemoteCommandHandlerStatusSuccess;
}

/// MPRemoteCommandCenter からの seekForward イベントのイベントハンドラ
- (MPRemoteCommandHandlerStatus)seekForwardEvent:(MPSeekCommandEvent *)event{
    if (event.type == MPSeekCommandEventTypeBeginSeeking) {
        [[GlobalDataSingleton GetInstance] AnnounceBySpeech:NSLocalizedString(@"SpeechViewController_AnnounceSeekForward", @"早送り")];
        m_bIsSeeking = true;
        [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:true block:^(NSTimer * _Nonnull timer) {
            if (!m_bIsSeeking) {
                [timer invalidate];
                return;
            }
            [[GlobalDataSingleton GetInstance] StopSpeechWithoutDiactivate];
            [self skipForward:50];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                [self startSpeech:YES];
            });
        }];
    }
    if (event.type == MPSeekCommandEventTypeEndSeeking) {
        m_bIsSeeking = false;
    }
    return MPRemoteCommandHandlerStatusSuccess;
}
/// MPRemoteCommandCenter からの seekBackward イベントのイベントハンドラ
- (MPRemoteCommandHandlerStatus)seekBackwardEvent:(MPSeekCommandEvent *)event{
    if (event.type == MPSeekCommandEventTypeBeginSeeking) {
        [[GlobalDataSingleton GetInstance] AnnounceBySpeech:NSLocalizedString(@"SpeechViewController_AnnounceSeekBackward", @"巻き戻し")];
        m_bIsSeeking = true;
        [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:true block:^(NSTimer * _Nonnull timer) {
            if (!m_bIsSeeking) {
                [timer invalidate];
                return;
            }
            [[GlobalDataSingleton GetInstance] StopSpeechWithoutDiactivate];
            [self skipBackward:50];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                [self startSpeech:YES];
            });
        }];
    }
    if (event.type == MPSeekCommandEventTypeEndSeeking) {
        m_bIsSeeking = false;
    }
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)changePlaybackPositionEvent:(MPChangePlaybackPositionCommandEvent*)event{
    NSLog(@"MPChangePlaybackPositionCommandEvent got: %f", event.positionTime);
    
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    NSUInteger newLocation = [globalData GuessSpeakLocationFromDulation:event.positionTime];
    NSUInteger textLength = [m_CurrentReadingStory.content length];
    if (newLocation > textLength) {
        newLocation = textLength;
    }
    if (newLocation <= 0) {
        newLocation = 0;
    }
    m_CurrentReadingStory.readLocation = [[NSNumber alloc] initWithUnsignedLong:newLocation];
    [globalData UpdateReadingPoint:self.NarouContentDetail story:m_CurrentReadingStory];
    [self SetCurrentReadingPointFromSavedData:self.NarouContentDetail.ncode];
    [globalData UpdatePlayingInfo:(m_CurrentReadingStory)];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self startSpeech:YES];
    });
    
    return MPRemoteCommandHandlerStatusSuccess;
}

/// 読み上げ位置を count文字分 だけ進めます。章を超えるような場合には単に次の章の先頭に移動させます。
- (void)skipForward:(NSUInteger)count {
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    NSRange currentReadingPoint = [globalData GetCurrentReadingPoint];
    NSString* currentText = self.textView.text;
    NSUInteger currentLocation = currentReadingPoint.location;
    if (currentLocation + count > [currentText length]) {
        if (![self SetNextChapter]) {
            return;
        }
    }else{
        m_CurrentReadingStory.readLocation = [[NSNumber alloc] initWithUnsignedLong:currentLocation + count];
        [globalData UpdateReadingPoint:self.NarouContentDetail story:m_CurrentReadingStory];
        [self SetCurrentReadingPointFromSavedData:self.NarouContentDetail.ncode];
    }
}

/// 読み上げ位置を count文字分 だけ戻します。章を超えるような場合には前の章の末尾から count 文字分戻った位置に移動させます。
/// その際、前の章が count文字 に満たない場合は前の章の先頭に移動させます。
- (void)skipBackward:(NSUInteger)count {
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    NSRange currentReadingPoint = [globalData GetCurrentReadingPoint];
    NSUInteger currentLocation = currentReadingPoint.location;
    NSUInteger targetLength = 0;
    if (currentLocation < count){
        if ([self SetPreviousChapter]) {
            NSString* chapterText = self.textView.text;
            NSUInteger chapterLength = [chapterText length];
            if (chapterLength > count) {
                targetLength = chapterLength - count;
            }
        }
    }else{
        targetLength = currentLocation - count;
    }
    m_CurrentReadingStory.readLocation = [[NSNumber alloc] initWithUnsignedLong:targetLength];
    [globalData UpdateReadingPoint:self.NarouContentDetail story:m_CurrentReadingStory];
    [self SetCurrentReadingPointFromSavedData:self.NarouContentDetail.ncode];
}

/// 表示用のフォントサイズを変更します
- (void)ChangeFontOnlySize:(float)fontSize
{
    UIFont* font = [UIFont systemFontOfSize:140.0];
    self.textView.font = [font fontWithSize:fontSize];
}

- (void)ChangeFontSize:(float)fontSize
{
    [self ChangeFont:[[GlobalDataSingleton GetInstance] GetDisplayFontName] fontSize:fontSize];
}

- (void)ChangeFont:(NSString*)fontName fontSize:(float)fontSize {
    if(fontName == nil) {
        [self ChangeFontOnlySize:fontSize];
        return;
    }
    UIFont* font = [UIFont fontWithName:fontName size:fontSize];
    self.textView.font = font;
}

/// フォントサイズを設定されている値にします。
- (void)loadAndSetFontSize
{
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    GlobalStateCacheData* globalState = [globalData GetGlobalState];
    double fontSize = [GlobalDataSingleton ConvertFontSizeValueToFontSize:[globalState.textSizeValue floatValue]];
    [self ChangeFontSize:fontSize];
}

/// NotificationCenter の受信者の設定をします。
- (void)setNotificationReciver
{
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self selector:@selector(FontSizeChanged:) name:@"StoryDisplayFontSizeChanged" object:nil];

    [notificationCenter addObserver:self selector:@selector(FontNameChanged:) name:@"FontNameChanged" object:nil];

    NSString* notificationName = [[NSString alloc] initWithFormat:@"NarouContentDownloadStatusChanged_%@", self.NarouContentDetail.ncode];
    [notificationCenter addObserver:self selector:@selector(NarouContentUpdatedDownload:) name:notificationName object:nil];
    
    notificationName = [[NSString alloc] initWithFormat:@"NarouContentNewStatusUp_%@", self.NarouContentDetail.ncode];
    [notificationCenter addObserver:self selector:@selector(NarouContentUpdatedNewStatus:) name:notificationName object:nil];
    
    [[GlobalDataSingleton GetInstance] AddDownloadEventHandler:self];
}

/// NotificationCenter の受信者の設定を解除します。
- (void)removeNotificationReciver
{
    [[GlobalDataSingleton GetInstance] DeleteDownloadEventHandler:self];
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self name:@"StoryDisplayFontSizeChanged" object:nil];
    
    NSString* notificationName = [[NSString alloc] initWithFormat:@"NarouContentDownloadStatusChanged_%@", self.NarouContentDetail.ncode];
    [notificationCenter removeObserver:self name:notificationName object:nil];

    notificationName = [[NSString alloc] initWithFormat:@"NarouContentNewStatusUp_%@", self.NarouContentDetail.ncode];
    [notificationCenter removeObserver:self name:notificationName object:nil];
}

/// フォントサイズ変更イベントの受信
/// NotificationCenter越しに呼び出されるイベントのイベントハンドラ
- (void)FontSizeChanged:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    if(userInfo == nil){
        return;
    }
    NSNumber* fontSizeValue = [userInfo objectForKey:@"fontSizeValue"];
    if (fontSizeValue == nil) {
        return;
    }
    float floatFontSizeValue = [fontSizeValue floatValue];
    [self ChangeFontSize:[GlobalDataSingleton ConvertFontSizeValueToFontSize:floatFontSizeValue]];
}

- (void)FontNameChanged:(NSNotification*)notification
{
    [self loadAndSetFontSize];
}

- (void)ReloadNarouContentDetail{
    NarouContentCacheData* content = [[GlobalDataSingleton GetInstance] SearchNarouContentFromNcode:self.NarouContentDetail.ncode];
    if (content == nil) {
        return;
    }
    self.NarouContentDetail = content;
    [self updateChapterSlider];
}

/// ダウンロード状態更新イベントの受信
- (void)NarouContentUpdatedDownload:(NSNotification*)notification
{
    [self ReloadNarouContentDetail];
    
    NSDictionary* args = [notification userInfo];
    NSNumber* isDownloading = [args objectForKey:@"isDownloading"];
    if (![isDownloading boolValue]) {
        // nothing to do!
    }else{
        NSNumber* currentPosition = [args objectForKey:@"currentPosition"];
        if ([m_CurrentReadingStory.chapter_number intValue] == [currentPosition intValue]) {
            StoryCacheData* story = [[GlobalDataSingleton GetInstance] SearchStory:m_CurrentReadingStory.ncode chapter_no:[m_CurrentReadingStory.chapter_number intValue]];
            if (story != nil) {
                m_CurrentReadingStory = story;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setSpeechStory:story];
                });
            }
        }
    }
}

/// NEWフラグ更新イベントの受信
- (void)NarouContentUpdatedNewStatus:(NSNotification*)notification
{
    [self ReloadNarouContentDetail];
}

/// 章のスライダを更新します
- (void)updateChapterSlider{
    dispatch_async(dispatch_get_main_queue(), ^{
        //NSLog(@"updateChapterSlider: %@ → %@/%@", self.NarouContentDetail.ncode,
        //      self->m_CurrentReadingStory.chapter_number,
        //      self.NarouContentDetail.general_all_no);
        self.ChapterSlider.minimumValue = 1;
        //self.ChapterSlider.maximumValue = [self.NarouContentDetail.general_all_no floatValue] + 0.01f;
        self.ChapterSlider.maximumValue = [[GlobalDataSingleton GetInstance] GetStoryCountForNcode:self.NarouContentDetail.ncode] + 0.01f;
        [self UpdateChapterIndicatorLabel:[self->m_CurrentReadingStory.chapter_number intValue] max:(int)self.ChapterSlider.maximumValue];
    });
}

// NarouDownloadQueueDelegate ハンドラ：個々の章のダウンロードが行われようとする度に呼び出されます。
- (void)DownloadStatusUpdate:(NarouContentCacheData*)content currentPosition:(int)currentPosition maxPosition:(int)maxPosition {
    if ([self.NarouContentDetail.ncode compare:content.ncode] != NSOrderedSame) {
        return;
    }
    if (maxPosition > 0) {
        self.NarouContentDetail.general_all_no = [[NSNumber alloc] initWithInt:maxPosition];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            [self updateChapterSlider];
        });
    }
}
// NarouDownloadQueueDelegate ハンドラ：全ての download queue がなくなった時に呼び出されます。
- (void)DownloadEnd {
    // この時点で情報を更新しても古い情報が手に入るっぽい(更新してない？)ので特に何もしません。
}

// URL の時にリフレッシュボタンを押したら再ダウンロードします
- (void)urlRefreshButtonClick:(id)sender
{
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    [globalData PushContentDownloadQueue:self.NarouContentDetail];
    // 再ダウンロードを指示したので一旦本棚へ戻します
    [self.navigationController popViewControllerAnimated:YES];
}

// 地球のアイコンをタップしたらその小説のURLをSafariで開きます
- (void)safariButtonClick:(id)sender{
    NSURL* url = nil;
    if ([self.NarouContentDetail isURLContent]) {
        NSString* urlString = self.NarouContentDetail.ncode;
        url = [[NSURL alloc] initWithString:urlString];
    }else if([self.NarouContentDetail isUserCreatedContent]){
        return;
    }else{
        NSString* urlString = [[NSString alloc] initWithFormat:@"https://ncode.syosetu.com/%@/", [self.NarouContentDetail.ncode lowercaseString]];
        url = [[NSURL alloc] initWithString:urlString];
    }
    if (url != nil) {
        NSUInteger targetTabIndex = 2; // XXXXX TODO: 謎の数字 2 が確認されている(WKWebViewのタブのindexなんだけれども)
        id targetViewController = [self.tabBarController.viewControllers objectAtIndex:targetTabIndex];
        if ([targetViewController isKindOfClass:[ImportFromWebPageViewController class]]) {
            ImportFromWebPageViewController* importFromWebPageViewController = (ImportFromWebPageViewController*)targetViewController;
            importFromWebPageViewController.openTargetUrl = url;
            [self.tabBarController setSelectedIndex:targetTabIndex];
        }else if ([UIApplication.sharedApplication canOpenURL:url]) {
            [UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
        }
    }
}
// 検索ボタン
- (void)searchButtonClicked:(id)sender
{
    [self stopSpeech];
    UIViewController* targetViewController = self;
    [NiftyUtilitySwift
     EasyDialogTextInput2ButtonWithViewController:targetViewController
     title:NSLocalizedString(@"SpeechViewController_SearchDialogTitle", @"検索")
     message:NSLocalizedString(@"SpeechViewController_SearchDialogMessage", @"本文中から文字列を検索します")
     textFieldText:nil
     placeHolder:NSLocalizedString(@"SpeechViewController_SearchDialogPlaceholderText", "空文字列で検索すると全ての章がリストされます")
     leftButtonText:NSLocalizedString(@"Cancel_button", "Cancel")
     rightButtonText:NSLocalizedString(@"SpeechViewController_SearchDialogTitle", @"検索")
     leftButtonAction:nil
     rightButtonAction:^(NSString * _Nonnull string) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NiftyUtilitySwift
                EasyDialogNoButtonWithViewController:targetViewController
                title:NSLocalizedString(@"SpeechViewController_NowSearchingTitle", @"検索中")
                  message:nil
                  completion:^(EasyDialog * _Nonnull progressDialog) {
                GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
                NSArray* storyArray = [globalData GeAllStoryForNcode:self.NarouContentDetail.ncode];
                NSMutableArray* hitListMutable = [NSMutableArray new];
                NSMutableArray* titleListMutable = [NSMutableArray new];
                NSString* firstSelectedString = nil;
                for (StoryCacheData* story in storyArray) {
                    if (story == nil || story.content == nil) {
                        continue;
                    }
                    if ([string length] <= 0 || [story.content containsString:string]) {
                        NSArray* lines = [[story.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                        NSString* firstLine = @"";
                        if ([lines count] > 0) {
                            firstLine = lines[0];
                        }
                        NSString* selectTitle = [[NSString alloc] initWithFormat:@"%@:%@", story.chapter_number, firstLine];
                        [titleListMutable addObject:selectTitle];
                        [hitListMutable addObject:story];
                        if ([story.chapter_number intValue] == [m_CurrentReadingStory.chapter_number intValue]) {
                            firstSelectedString = selectTitle;
                        }
                    }
                }
                NSArray* hitList = [[hitListMutable reverseObjectEnumerator] allObjects];
                NSArray* titleList = [[titleListMutable reverseObjectEnumerator] allObjects];
                [progressDialog dismissViewControllerAnimated:false completion:nil];
                if ([hitList count] <= 0) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [NiftyUtilitySwift EasyDialogOneButtonWithViewController:targetViewController
                   title:NSLocalizedString(@"SpeechViewController_SearchDialog_NotFoundTitle", @"指定された文字列は存在しませんでした。") message:nil buttonTitle:NSLocalizedString(@"OK_button", @"OK") buttonAction:nil];
                    });
                    return;
                }
                PickerViewDialog* picker = [PickerViewDialog createNewDialog:titleList firstSelectedString:firstSelectedString parentView:targetViewController.view resultReceiver:^(NSString* result){
                    NSArray* data = [result componentsSeparatedByString:@":"];
                    int chapterNumber = -1;
                    if ([data count] > 0) {
                        chapterNumber = [data[0] intValue];
                    }
                    if (chapterNumber > 0) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(01. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self stopSpeech];
                            [self ChangeChapterWithLastestReadLocation:chapterNumber];
                        });
                    }
                }];
                [picker popup:nil];
            }];
        });
    } shouldReturnIsRightButtonClicked:true];
}
@end
