//
//  BookShelfTableViewController.m
//  NovelSpeaker
//
//  Created by 飯村卓司 on 2014/07/05.
//  Copyright (c) 2014年 IIMURA Takuji. All rights reserved.
//

#import "BookShelfTableViewController.h"
#import "NarouContent.h"
#import "GlobalDataSingleton.h"
#import "SpeechViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "BookShelfTableViewCell.h"
#import "PickerViewDialog.h"
#import "NovelSpeaker-Swift.h"

@interface BookShelfTableViewController ()

@end

@implementation BookShelfTableViewController

/// バージョンアップした時のアナウンスをします
- (void)ShowVersionUpNotice
{
    [NiftyUtilitySwift
     EasyDialogMessageDialogWithViewController:self
     title:NSLocalizedString(@"BookShelfTableViewController_AnnounceNewViersion", @"アップデートされました")
     message:NSLocalizedString(@"BookShelfTableViewController_AnnounceNewVersionMessage"
     , @"Version 1.1.2\r\n"
     @"- なろう検索で「検索開始」ボタンを押しやすくしました\r\n"
   @"\r\n現在までのアップデートについての詳しい情報は「設定」タブの「更新履歴」を参照してください。")
       completion:^{
        GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
        [globalData UpdateCurrentVersionSaveData];
        if(![globalData IsFirstPageShowed])
        {
            NarouContentCacheData* currentContent = [globalData GetCurrentReadingContent];
            if (currentContent != nil && [globalData IsOpenRecentNovelInStartTime]) {
                [self PushNextView:currentContent isNeedSpeech:false];
            }
        }
    }];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // custom init
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [BehaviorLogger AddLogWithDescription:@"BookShelfTableViewController viewDidLoad" data:@{}];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //[self.navigationController setNavigationBarHidden:FALSE animated:TRUE];

    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    
    m_SortType = [globalData GetBookSelfSortType];
    
    // 編集ボタンをつけます。
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem* refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonClick:)];
    
    UIBarButtonItem* sortTypeSelectButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BookShelfTableViewController_SortTypeSelectButton", @"sort") style:UIBarButtonItemStyleDone target:self action:@selector(sortTypeSelectButtonClick:)];

    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:self.editButtonItem, refreshButton, sortTypeSelectButton, nil];
    
    //UIBarButtonItem* searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonClick:)];
    m_SearchButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BookShelfTableViewController_SearchTitle", @"検索") style:UIBarButtonItemStyleDone target:self action:@selector(searchButtonClick:)];

    self.navigationItem.leftBarButtonItems = @[m_SearchButton];
    m_SearchString = nil;

    // カスタマイズしたセルをテーブルビューにセット
    UINib *nib = [UINib nibWithNibName:BookShelfTableViewCellID bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:BookShelfTableViewCellID];
    //[self.searchDisplayController.searchResultsTableView registerNib:nib forCellReuseIdentifier:BookShelfTableViewCellID];

    [self setNotificationReciver];
    //[[GlobalDataSingleton GetInstance] AddDownloadEventHandler:self];
    
    if (@available(iOS 10, *)) {
        m_UIRefreshControl = [UIRefreshControl new];
        self.tableView.refreshControl = m_UIRefreshControl;
        [m_UIRefreshControl addTarget:self action:@selector(refreshControlValueChangedEvent:) forControlEvents:(UIControlEventValueChanged)];
    }
    m_ResumeSpeechFloatingButton = nil;
    
    [NiftyUtilitySwift CheckNewImportantImformationWithHasNewInformationAlive:^(NSString * _Nonnull text) {
        if ([text length] > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // TODO: magic word 3!!!!
                self.tabBarController.tabBar.items[3].badgeValue = @"!";
            });
        }
    } hasNoNewInformation:^{
        // nothing to do!
    }];
    
    if ([globalData IsVersionUped]) {
        [self ShowVersionUpNotice];
    }
    
    if(![globalData IsFirstPageShowed])
    {
        NarouContentCacheData* currentContent = [globalData GetCurrentReadingContent];
        if (currentContent != nil && [globalData IsOpenRecentNovelInStartTime]) {
            [self PushNextView:currentContent isNeedSpeech:false];
        }
    }
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self ReloadAllTableViewDataAndScrollToCurrentReadingContent];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (m_ResumeSpeechFloatingButton != nil) {
        [m_ResumeSpeechFloatingButton hide];
        m_ResumeSpeechFloatingButton = nil;
    }
}

- (void)dealloc
{
    [self removeNotificationReciver];
    [[GlobalDataSingleton GetInstance] DeleteDownloadEventHandler:self];
}

/// 必要なら最後に開いていた小説の読み上げを再開させます
- (void)addPreviousNovelSpeakButtonIfNeeded{
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    if ([globalData IsOpenRecentNovelInStartTime]) {
        return;
    }
    
    NarouContentCacheData* currentContent = [globalData GetCurrentReadingContent];
    if (currentContent == nil || currentContent.currentReadingStory == nil) {
        return;
    }
    StoryCacheData* story = currentContent.currentReadingStory;
    if ([story.chapter_number integerValue] >= [currentContent.general_all_no integerValue]
        && ([story.readLocation unsignedIntegerValue] + 5) >= [story.content length]) {
        return;
    }
    if (m_ResumeSpeechFloatingButton != nil) {
        [m_ResumeSpeechFloatingButton hide];
    }
    m_ResumeSpeechFloatingButton = [FloatingButton createNewFloatingButton];
    [m_ResumeSpeechFloatingButton assignToViewWithView:self.tableView text:[[NSString alloc] initWithFormat: NSLocalizedString(@"BookShelfTableViewController_Resume:", @"再開:%@"), currentContent.title] animated:true buttonClicked:^{
        [self PushNextView:currentContent isNeedSpeech:true];
        [m_ResumeSpeechFloatingButton hideAnimate];
    }];
    [m_ResumeSpeechFloatingButton initScrollPositionWithPoint:self.tableView.contentOffset scrollHeight:100.0];
}

/// NotificationCenter の受信者の設定をします。
- (void)setNotificationReciver
{
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self selector:@selector(NarouContentListChanged:) name:@"NarouContentListChanged" object:nil];
}

/// NotificationCenter の受信者の設定を解除します。
- (void)removeNotificationReciver
{
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self name:@"NarouContentListChanged" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshButtonClick:(id)sender
{
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    [globalData ReDownloadAllContents];
}

- (NSDictionary*)GetDisplayStringToSortTypeDictionary {
    return @{
             NSLocalizedString(@"BookShelfTableViewController_SortTypeNcode", @"Ncode順"): @(NarouContentSortType_Ncode)
             , NSLocalizedString(@"BookShelfTableViewController_SortTypeWriter", @"作者名順"): @(NarouContentSortType_Writer)
             , NSLocalizedString(@"BookShelfTableViewController_SortTypeNovelName", @"小説名順"): @(NarouContentSortType_Title)
             , NSLocalizedString(@"BookShelfTableViewController_SortTypeUpdateDate", @"更新順"): @(NarouContentSortType_NovelUpdatedAt)
             };
}

- (NSString*)GetCurrentSortTypeDisplayString {
    NSDictionary* dic = [self GetDisplayStringToSortTypeDictionary];
    NarouContentSortType sortType = [[GlobalDataSingleton GetInstance] GetBookSelfSortType];
    for (NSString* key in [dic keyEnumerator]) {
        NSNumber* number = [dic valueForKey:key];
        if ([number intValue] == sortType) {
            return key;
        }
    }
    return nil;
}

- (NarouContentSortType)ConvertDisplayStringToSortType:(NSString*)key {
    if (key == nil) {
        return NarouContentSortType_NovelUpdatedAt;
    }
    NSDictionary* dic = [self GetDisplayStringToSortTypeDictionary];
    NSNumber* number = [dic objectForKey:key];
    if (number == nil) {
        return NarouContentSortType_NovelUpdatedAt;
    }
    return (NarouContentSortType)[number intValue];
}

- (void)sortTypeSelectButtonClick:(id)sender
{
    UIView* targetView = self.parentViewController.parentViewController.view;
    PickerViewDialog* dialog = [PickerViewDialog
        createNewDialog:@[
            NSLocalizedString(@"BookShelfTableViewController_SortTypeNcode", @"Ncode順")
            , NSLocalizedString(@"BookShelfTableViewController_SortTypeWriter", @"作者名順")
            , NSLocalizedString(@"BookShelfTableViewController_SortTypeNovelName", @"小説名順")
            , NSLocalizedString(@"BookShelfTableViewController_SortTypeUpdateDate", @"更新順")
        ]
        firstSelectedString:[self GetCurrentSortTypeDisplayString]
        parentView:targetView resultReceiver:^(NSString* selectedText){
            self->m_SortType = [self ConvertDisplayStringToSortType:selectedText];
            [[GlobalDataSingleton GetInstance] SetBookSelfSortType:self->m_SortType];
            [self ReloadAllTableViewData];
    }];
    [dialog popup:nil];
}

- (void)searchButtonClick:(id)sender
{
    UIViewController* targetViewContoller = self.parentViewController.parentViewController;
    void (^AssignSearchString)(NSString*) = ^(NSString* result){
        m_SearchString = result;
        if ([m_SearchString length] <= 0) {
            m_SearchString = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                self->m_SearchButton.title = NSLocalizedString(@"BookShelfTableViewController_SearchTitle", @"検索");
                [self ReloadAllTableViewData];
            });
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self->m_SearchButton.title = [[NSString alloc] initWithFormat:@"%@(%@)", NSLocalizedString(@"BookShelfTableViewController_SearchTitle", @"検索"), m_SearchString];
            [self ReloadAllTableViewData];
        });
    };
    [NiftyUtilitySwift EasyDialogTextInput2ButtonWithViewController:targetViewContoller
      title:NSLocalizedString(@"BookShelfTableViewController_SearchTitle", @"検索")
      message:NSLocalizedString(@"BookShelfTableViewController_SearchMessage", @"小説名 と 作者名 が対象となります")
      textFieldText:m_SearchString
      placeHolder:nil
      leftButtonText:NSLocalizedString(@"BookShelfTableViewController_SearchClear", @"クリア")
      rightButtonText:NSLocalizedString(@"OK_button", @"OK")
      leftButtonAction:^(NSString * _Nonnull str) {
          AssignSearchString(nil);
      }
      rightButtonAction:^(NSString * _Nonnull result) {
          AssignSearchString(result);
      }
      shouldReturnIsRightButtonClicked:true
    ];
}

// 検索やソート条件に従った上の NarouContent の配列を返します
- (NSArray*)getNarouContentArray{
    return [[GlobalDataSingleton GetInstance] SearchNarouContentWithString:m_SearchString sortType:m_SortType];
}

#pragma mark - Table view data source

// セクションの数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// セクション内部のセルの数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* contentList = [self getNarouContentArray];
    if (contentList == nil) {
        return 0;
    }
    //NSLog(@"numberOfRowsInSection called return %lu", (unsigned long)[contentList count]);
    return [contentList count];
}

// 個々のセルの取得
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 利用できる cell があるなら再利用します
    BookShelfTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:BookShelfTableViewCellID forIndexPath:indexPath];
    if(cell == nil)
    {
        // 無いようなので生成します。
        cell = [[BookShelfTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BookShelfTableViewCellID];
    }
    
    NSArray* contentList = [self getNarouContentArray];
    if(contentList == nil
       || [contentList count] <= indexPath.row)
    {
        NSLog(@"indexPath.row is out of range %lu <= %ld", (unsigned long)[contentList count], (long)indexPath.row);
        [cell setTitleLabel:@"unknown error" ncode:nil];
        return cell;
    }

    NarouContent* narouContent = (NarouContent*)contentList[indexPath.row];
    [cell setTitleLabel:narouContent.title ncode:narouContent.ncode];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIFont* font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    return [font lineHeight] + 16;
}

- (void)ReloadAllTableViewDataAndScrollToCurrentReadingContent{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            NarouContentCacheData* selectedContent = [[GlobalDataSingleton GetInstance] GetCurrentReadingContent];
            if (selectedContent == nil) {
                return;
            }
            
            NSArray* contentArray = [self getNarouContentArray];
            int index = 0;
            for (NarouContentCacheData* content in contentArray) {
                if (content != nil && [content.ncode compare:selectedContent.ncode] == NSOrderedSame) {
                    NSIndexPath* path = [NSIndexPath indexPathForRow:index inSection:0];
                    [UIView animateWithDuration:0.3 animations:^{
                        [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:false];
                    } completion:^(BOOL finished) {
                        // TableView のスクロールが終わったら、再開する奴があるかどうかを確認します。
                        // でないとこのスクロールのイベントを受けてボタンが消えてしまう……(´・ω・`)
                        [self addPreviousNovelSpeakButtonIfNeeded];
                    }];
                }
                index++;
            }
        });
    });
}

// 強引に(表示されている？)全ての cell について表示を更新します。
- (void)ReloadAllTableViewData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    });
    return;
}

// 次のビューに飛ばします。
- (void)PushNextView:(NarouContentCacheData*)narouContent isNeedSpeech:(BOOL)isNeedSpeech
{
    m_NextViewDetail = narouContent;
    m_isNextViewNeedResumeSpeech = isNeedSpeech;
    //NSLog(@"next view: %@ %@", narouContent.ncode, narouContent.title);
    [self performSegueWithIdentifier:@"bookShelfToReaderSegue" sender:self];
}

/// セルが選択された時
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* contentList = [self getNarouContentArray];
    if(contentList == nil
       || [contentList count] < indexPath.row)
    {
        NSLog(@"indexPath.row is out of range %lu < %ld", (unsigned long)[contentList count], (long)indexPath.row);
        return;
    }
    NarouContentCacheData* narouContent = (NarouContentCacheData*)contentList[indexPath.row];
    
    // 次のビューに飛ばします。
    [self PushNextView:narouContent isNeedSpeech:false];
}

// 編集できるか否かのYES/NOを返す。
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// 編集されるときに呼び出される。
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray* contentList = [self getNarouContentArray];
        if(contentList == nil
           || [contentList count] <= indexPath.row)
        {
            NSLog(@"indexPath.row is out of range %lu < %ld", (unsigned long)[contentList count], (long)indexPath.row);
            return;
        }
        NSLog(@"tableView row deleting. before content.length: %lu", (unsigned long)[contentList count]);
        NarouContentCacheData* content = contentList[indexPath.row];
        if ([[GlobalDataSingleton GetInstance] IsNeedConfirmDeleteBook]) {
            [NiftyUtilitySwift EasyDialogTwoButtonWithViewController:self title:NSLocalizedString(@"BookShelfTableViewController_WarningForDeleteBookTitle", @"本の削除") message:[[NSString alloc] initWithFormat:@"%@%@", NSLocalizedString(@"BookShelfTableViewController_WarningDeleteBookMessage", @"本を削除しますか？\n"), content.title] button1Title:nil button1Action:nil button2Title:NSLocalizedString(@"BookShelfTableViewController_WarningDeleteBookOKButtonTitle", @"削除") button2Action:^{
                // Contentを消すことによって Notification が飛んで変なことになるので一旦切ります。
                [self removeNotificationReciver];
                if([[GlobalDataSingleton GetInstance] DeleteContent:content] != true)
                {
                    NSLog(@"delete content failed ncode: %@ title: %@", content.ncode, content.title);
                }
                // NotificationReciver を復活させます
                [self setNotificationReciver];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                });
            }];
        }else{
            [self removeNotificationReciver];
            if([[GlobalDataSingleton GetInstance] DeleteContent:content] != true)
            {
                NSLog(@"delete content failed ncode: %@ title: %@", content.ncode, content.title);
            }
            // NotificationReciver を復活させます
            [self setNotificationReciver];
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            });
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (m_ResumeSpeechFloatingButton != nil) {
        BOOL isEnd = [m_ResumeSpeechFloatingButton scrollViewDidScroll:scrollView];
        if (isEnd) {
            m_ResumeSpeechFloatingButton = nil;
        }
    }
}

// 個々の章のダウンロードが行われようとする度に呼び出されます。
- (void)DownloadStatusUpdate:(NarouContentCacheData*)content currentPosition:(int)currentPosition maxPosition:(int)maxPosition
{
    [self ReloadAllTableViewData];
}
// 全ての download queue がなくなった時に呼び出されます。
- (void)DownloadEnd
{
    [self ReloadAllTableViewData];
}

/// NotificationCenter越しに呼び出されるイベントのイベントハンドラ
- (void)NarouContentListChanged:(NSNotification*)notification
{
    //NSLog(@"NarouContentListChanged notification got.");
    [self ReloadAllTableViewData];
}

/*
// Override to support rearranging the table view.
// 移動されたときに呼び出される。
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// 移動できるかどうかのYES/NOを返す。
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/// NavigationController で戻ってきた時とかに呼び出される
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	[viewController viewWillAppear:animated];
    
    NSLog(@"navigationController:willShowViewController (NavigationController で戻ってきた)");
    
    // 更新フラグとかを更新するために全部リロードしちゃいます
    [self ReloadAllTableViewData];
}

// UIRefreshControl で値が変わった時に呼ばれるイベントハンドラ(引っ張って更新のイベントハンドラ)
- (void)refreshControlValueChangedEvent:(id)sender {
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    [globalData ReDownloadAllContents];
    [m_UIRefreshControl endRefreshing];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"bookShelfToReaderSegue"]) {
        SpeechViewController* nextViewController = [segue destinationViewController];
        nextViewController.NarouContentDetail = m_NextViewDetail;
        nextViewController.NeedResumeSpeech = m_isNextViewNeedResumeSpeech;
    }
}


@end
