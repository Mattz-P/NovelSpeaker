//
//  GlobalDataSingleton.m
//  NovelSpeaker
//
//  Created by 飯村卓司 on 2014/06/30.
//  Copyright (c) 2014年 IIMURA Takuji. All rights reserved.
//

#import "GlobalDataSingleton.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <UserNotifications/UserNotifications.h>
#import "NarouLoader.h"
#import "NarouDownloadQueue.h"
#import "NSDataZlibExtension.h"
#import "NSStringExtension.h"
#import "NiftyUtility.h"
#import "NovelSpeaker-Swift.h"
#import "UIViewControllerExtension.h"
#import "NSDataDetectEncodingExtension.h"
#import "NovelSpeaker-Swift.h"
#import "UIImageExtension.h"

#define APP_GROUP_USER_DEFAULTS_SUITE_NAME @"group.com.limuraproducts.novelspeaker"
#define APP_GROUP_USER_DEFAULTS_URL_DOWNLOAD_QUEUE @"URLDownloadQueue"
#define APP_GROUP_USER_DEFAULTS_ADD_TEXT_QUEUE @"AddTextQueue"
#define COOKIE_ENCRYPT_SECRET_KEY @"謎のエラーです。これを確認できた人はご一報ください"
#define USER_DEFAULTS_BACKGROUND_FETCH_FETCHED_NOVEL_COUNT @"BackgroundFetchFetchedNovelCount"
#define NOT_RUBY_STRING_ARRAY @"・、  ？?！!"

@implementation GlobalDataSingleton

// Core Data 用
//@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
//@synthesize managedObjectModel = _managedObjectModel;
//@synthesize managedObjectContext = _managedObjectContext;

static GlobalDataSingleton* _singleton = nil;
static DummySoundLooper* dummySoundLooper = nil;

- (id)init
{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    m_LogStringArray = [NSMutableArray new];

    m_bIsFirstPageShowed = false;
    m_isMaxSpeechTimeExceeded = false;
    
    m_MainQueue = dispatch_get_main_queue();
    // CoreDataアクセス用の直列queueを作ります。
    m_CoreDataAccessQueue = dispatch_queue_create("com.limuraproducts.novelspeaker.coredataaccess", DISPATCH_QUEUE_SERIAL);

    m_DownloadQueue = [NarouDownloadQueue new];
    
    m_isNeedReloadSpeakSetting = false;
    
    m_ManagedObjectContextPerThreadDictionary = [NSMutableDictionary new];
    m_MainManagedObjectContextHolderThreadID = nil;
    
    m_CoreDataObjectHolder = [[CoreDataObjectHolder alloc] initWithModelName:@"SettingDataModel" fileName:@"SettingDataModel" folderType:DOCUMENTS_FOLDER_TYPE mergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];

    // NiftySpeaker は default config が必要ですが、これには core data の値を使いません。
    // (というか使わないでおかないとここで取得しようとした時にマイグレーションが発生してしまいます)
    SpeechConfig* speechConfig = [SpeechConfig new];
    speechConfig.pitch = 1.0f;
    speechConfig.rate = 1.0f;
    speechConfig.beforeDelay = 0.0f;
    speechConfig.voiceIdentifier = [self GetVoiceIdentifier]; // これは現状では UserDefaults です。
    m_NiftySpeaker = [[NiftySpeaker alloc] initWithSpeechConfig:speechConfig];

    [self audioSessionInit:NO];
    dummySoundLooper = [DummySoundLooper new];
    [dummySoundLooper setMediaFileForResource:@"Silent3sec" ofType:@"mp3"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionDidInterrupt:) name:AVAudioSessionInterruptionNotification object:nil];

    // オーディオのルートが変わったよイベントを受け取るようにする
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeAudioSessionRoute:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    return self;
}
    
- (void)dealloc
{
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

/// singleton が確保された時に一発だけ走る method
/// CoreData の初期化とかいろいろやります。
- (void) InitializeData
{
}

+ (GlobalDataSingleton*) GetInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleton = [GlobalDataSingleton new];
        [_singleton InitializeData];
    });
    return _singleton;
}

- (void)coreDataPerfomBlockAndWait:(void(^)(void))block {
    [m_CoreDataObjectHolder performBlockAndWait:block];
}

- (void)audioSessionInit:(BOOL)isActive {
    AVAudioSession* session = [AVAudioSession sharedInstance];
    NSError* err = nil;
    AVAudioSessionCategoryOptions option = 0;
    if ([self IsMixWithOthersEnabled]) {
        option = AVAudioSessionCategoryOptionMixWithOthers;
        if ([self IsDuckOthersEnabled]) {
            option |= AVAudioSessionCategoryOptionDuckOthers;
        }
    }
    [session setCategory:AVAudioSessionCategoryPlayback withOptions:option error:&err];
    if (err) {
        NSLog(@"AVAudioSessionCategoryPlayback set failed. %@ %@", err, err.userInfo);
    }
    [session setMode:AVAudioSessionModeDefault error:&err];
    if (err) {
        NSLog(@"AVAudioSessionModeDefault set failed. %@ %@", err, err.userInfo);
    }
    [session setActive:isActive error:nil];
}

- (void)audioSessionDidInterrupt:(NSNotification*)notification
{
    if (notification == nil) {
        return;
    }
    if (![self IsDummySilentSoundEnabled]) {
        return;
    }
    
    switch ([notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue]) {
        case AVAudioSessionInterruptionTypeBegan:
            //[self AddLogString:@"interrupt が発生したので一旦無音音声の再生を止めます"];
            [dummySoundLooper stopPlay];
            break;
        case AVAudioSessionInterruptionTypeEnded:
            //[self AddLogString:@"interrupt が解消したようなので無音音声の再生を再開します"];
            [dummySoundLooper startPlay];
            break;
        default:
            break;
    }
}

/// CoreData で保存している GlobalState object (一つしかないはず) を取得します
// 非公開インタフェースになりました。
- (GlobalState*) GetCoreDataGlobalStateThreadUnsafe
{
    NSError* err;
    // CoreData で読みだします
    NSArray* fetchResults = [m_CoreDataObjectHolder FetchAllEntity:@"GlobalState"];
    if(fetchResults == nil)
    {
        NSLog(@"fetch from CoreData failed. %@, %@", err, [err userInfo]);
        return nil;
    }
    if([fetchResults count] == 0)
    {
        // まだ登録されてなかったので新しく作ります。
        GlobalState* globalState = [m_CoreDataObjectHolder CreateNewEntity:@"GlobalState"];
        if(globalState == nil)
        {
            NSLog(@"GlobalState create failed.");
            return nil;
        }
        globalState.defaultRate = [[NSNumber alloc] initWithFloat:AVSpeechUtteranceDefaultSpeechRate];
        globalState.defaultPitch = [[NSNumber alloc] initWithFloat:1.0f];
        [m_CoreDataObjectHolder save];
        return globalState;
    }
    if([fetchResults count] > 1)
    {
        NSLog(@"GlobalData count is not 1: %lu", (unsigned long)[fetchResults count]);
        return nil;
    }
    return fetchResults[0];
}

/// CoreData で保存している GlobalState object (一つしかないはず) を取得します
- (GlobalStateCacheData*) GetGlobalState
{
    __block GlobalStateCacheData* stateCache = nil;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        GlobalState* state = [self GetCoreDataGlobalStateThreadUnsafe];
        stateCache = [[GlobalStateCacheData alloc] initWithCoreData:state];
    //});
    }];
    return stateCache;
}

/// GlobalState を更新します。
- (BOOL)UpdateGlobalState:(GlobalStateCacheData*)globalState
{
    __block BOOL result = false;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        GlobalState* state = [self GetCoreDataGlobalStateThreadUnsafe];

        // pitch か rate が変わってたら読み直し指示をします。
        if ([state.defaultPitch compare:globalState.defaultPitch] != NSOrderedSame
            || [state.defaultRate compare:globalState.defaultRate] != NSOrderedSame
            || [state.speechWaitSettingUseExperimentalWait boolValue] != [globalState.speechWaitSettingUseExperimentalWait boolValue]){
            self->m_isNeedReloadSpeakSetting = true;
        }
        state.defaultPitch = globalState.defaultPitch;
        state.defaultRate = globalState.defaultRate;
        state.textSizeValue = globalState.textSizeValue;
        state.maxSpeechTimeInSec = globalState.maxSpeechTimeInSec;
        state.speechWaitSettingUseExperimentalWait = globalState.speechWaitSettingUseExperimentalWait;
        
        if (globalState.currentReadingStory == nil) {
            state.currentReadingStory = nil;
            result = true;
            return;
        }
        
        GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
        NarouContent* content = [globalData SearchCoreDataNarouContentFromNcodeThreadUnsafe:globalState.currentReadingStory.ncode];
        if (content == nil) {
            state.currentReadingStory = nil;
            result = false;
            return;
        }
        Story* story = [self SearchCoreDataStoryThreadUnsafe:globalState.currentReadingStory.ncode chapter_no:[globalState.currentReadingStory.chapter_number intValue]];
        if (story == nil) {
            state.currentReadingStory = nil;
            content.currentReadingStory = nil;
        }else{
            story.readLocation = globalState.currentReadingStory.readLocation;
            state.currentReadingStory = story;
            content.currentReadingStory = story;
        }
        result = true;
    //});
    }];
    [m_CoreDataObjectHolder save];
    return result;
}


/// CoreData で保存している NarouContent のうち、Ncode で検索した結果
/// 得られた NovelContent を取得します。
/// 登録がなければ nil を返します
- (NarouContent*) SearchCoreDataNarouContentFromNcodeThreadUnsafe:(NSString*) ncode
{
    NSError* err;
    NSArray* fetchResults = [m_CoreDataObjectHolder
                             SearchEntity:@"NarouContent"
                             predicate:[NSPredicate predicateWithFormat:@"ncode == %@", ncode]];
    if(fetchResults == nil)
    {
        NSLog(@"fetch from CoreData failed. %@, %@", err, [err userInfo]);
        return nil;
    }
    if([fetchResults count] == 0)
    {
        // 何もなかった。
        return nil;
    }
    if([fetchResults count] > 1)
    {
        NSLog(@"duplicate ncode!!! %@ delete all content...", ncode);
        for (int i = 0; i < [fetchResults count]; i++) {
            NarouContent* targetContent = [fetchResults objectAtIndex:i];
            [m_CoreDataObjectHolder DeleteEntity:targetContent];
            [m_CoreDataObjectHolder save];
        }
        return nil;
    }
    return [fetchResults objectAtIndex:0];
}

/// CoreData で保存している NarouContent のうち、Ncode で検索した結果
/// 得られた NovelContent を取得します。
/// 登録がなければ nil を返します
- (NarouContentCacheData*) SearchNarouContentFromNcode:(NSString*) ncode
{
    __block NarouContentCacheData* result = nil;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        NarouContent* coreDataContent = [self SearchCoreDataNarouContentFromNcodeThreadUnsafe:ncode];
        if (coreDataContent != nil) {
            result = [[NarouContentCacheData alloc] initWithCoreData:coreDataContent];
        }
    //});
    }];
    /// TODO: 何故か nil が帰ってくるときは、duplicate ncode で消されてる可能性があるのでsaveしておきます。
    if (result == nil) {
        [self saveContext];
    }
    return result;
}


/// 指定されたNarouContentの情報を更新します。
/// CoreData側に登録されていなければ新規に作成し、
/// 既に登録済みであれば情報を更新します。
- (BOOL)UpdateNarouContent:(NarouContentCacheData*)content
{
    if (content == nil || content.ncode == nil) {
        return false;
    }
    __block BOOL result = false;
    __block BOOL isNeedContentListChangedAnnounce = false;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        NarouContent* coreDataContent = [self SearchCoreDataNarouContentFromNcodeThreadUnsafe:content.ncode];
        if (coreDataContent == nil) {
            coreDataContent = [self CreateNewNarouContentThreadUnsafe];
            isNeedContentListChangedAnnounce = true;
        }else if(coreDataContent.novelupdated_at != content.novelupdated_at){
            isNeedContentListChangedAnnounce = true;
        }
        result = [content AssignToCoreData:coreDataContent];
        [self->m_CoreDataObjectHolder save];
    //});
    }];
    if (isNeedContentListChangedAnnounce || true) {
        [self NarouContentListChangedAnnounce];
    }
    return result;
}


/// 新しい NarouContent を生成して返します。
- (NarouContent*) CreateNewNarouContentThreadUnsafe
{
    NarouContent* content = [m_CoreDataObjectHolder CreateNewEntity:@"NarouContent"];
    return content;
}

/// 保存されている NarouContent の数を取得します。
- (NSUInteger) GetNarouContentCount
{
    __block NSUInteger result = 0;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        result = [self->m_CoreDataObjectHolder CountEntity:@"NarouContent"];
    //});
    }];
    return result;
}

+ (NSString*)SortTypeToSortAttributeName:(NarouContentSortType)sortType
{
    NSString* sortAttributeName = @"novelupdated_at";
    switch (sortType) {
        case NarouContentSortType_NovelUpdatedAt:
            sortAttributeName = @"novelupdated_at";
            break;
        case NarouContentSortType_Title:
            sortAttributeName = @"title";
            break;
        case NarouContentSortType_Writer:
            sortAttributeName = @"writer";
            break;
        case NarouContentSortType_Ncode:
            sortAttributeName = @"ncode";
            break;
        default:
            sortAttributeName = @"novelupdated_at";
            break;
    }
    return sortAttributeName;
}

/// NarouContent の全てを NarouContentCacheData の NSArray で取得します
/// novelupdated_at で sort されて返されます。
- (NSArray*) GetAllNarouContent:(NarouContentSortType)sortType
{
    __block NSError* err;
    __block NSMutableArray* fetchResults = nil;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        NSString* sortAttributeName = [GlobalDataSingleton SortTypeToSortAttributeName:sortType];
        NSArray* results = [self->m_CoreDataObjectHolder FetchAllEntity:@"NarouContent" sortAttributeName:sortAttributeName ascending:NO];
        fetchResults = [[NSMutableArray alloc] initWithCapacity:[results count]];
        for (int i = 0; i < [results count]; i++) {
            fetchResults[i] = [[NarouContentCacheData alloc] initWithCoreData:results[i]];
        }
    //});
    }];
    if(err != nil)
    {
        NSLog(@"fetch failed. %@, %@", err, [err userInfo]);
        return nil;
    }
    return fetchResults;
}

/// 指定された文字列がタイトルか作者名に含まれる小説を取得します
- (NSArray*) SearchNarouContentWithString:(NSString*)string sortType:(NarouContentSortType)sortType
{
    if (string == nil || [string length] <= 0) {
        return [self GetAllNarouContent:sortType];
    }
    
    __block NSError* err;
    __block NSMutableArray* fetchResults = nil;
    [self coreDataPerfomBlockAndWait:^{
        //dispatch_sync(m_CoreDataAccessQueue, ^{
        NSString* sortAttributeName = [GlobalDataSingleton SortTypeToSortAttributeName:sortType];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[c] %@ OR writer CONTAINS[c] %@", string, string];
        NSArray* results = [self->m_CoreDataObjectHolder SearchEntity:@"NarouContent" predicate:predicate sortAttributeName:sortAttributeName ascending:NO];
        fetchResults = [[NSMutableArray alloc] initWithCapacity:[results count]];
        for (int i = 0; i < [results count]; i++) {
            fetchResults[i] = [[NarouContentCacheData alloc] initWithCoreData:results[i]];
        }
        //});
    }];
    if(err != nil)
    {
        NSLog(@"fetch failed. %@, %@", err, [err userInfo]);
        return nil;
    }
    return fetchResults;
}

/// 指定された ncode に登録されている全ての Story の内容(文章)を配列にして取得します
- (NSArray*)GetAllStoryTextForNcode:(NSString*)ncode{
    __block NSMutableArray* resultArray = nil;
    [self coreDataPerfomBlockAndWait:^{
        NSArray* fetchResults = [self->m_CoreDataObjectHolder SearchEntity:@"Story" predicate:[NSPredicate predicateWithFormat:@"ncode == %@", ncode]];
        for (Story* story in fetchResults) {
            if (resultArray == nil) {
                resultArray = [NSMutableArray new];
            }
            [resultArray addObject:story.content];
        }
    }];
    return resultArray;
}

/// ダウンロードqueueに追加しようとします
/// 追加した場合は nil を返します。
/// 追加できなかった場合はエラーメッセージを返します。
- (NSString*) AddDownloadQueueForNarou:(NarouContentCacheData*) content
{
    if(content == nil || content.ncode == nil || [content.ncode length] <= 0)
    {
        return NSLocalizedString(@"GlobalDataSingleton_CanNotGetValidNCODE", @"有効な NCODE を取得できませんでした。");
    }
    NSString* targetNcode = content.ncode;
    __block NarouContentCacheData* targetContentCacheData = [self SearchNarouContentFromNcode:targetNcode];
    if (targetContentCacheData == nil) {
        // 登録がないようなのでとりあえず NarouContent を登録します。
        __block BOOL isNarouContentCreated = false;
        [self coreDataPerfomBlockAndWait:^{
        //dispatch_sync(m_CoreDataAccessQueue, ^{
            NarouContent* targetContent = [self SearchCoreDataNarouContentFromNcodeThreadUnsafe:targetNcode];
            if (targetContent == nil) {
                targetContent = [self CreateNewNarouContentThreadUnsafe];
                isNarouContentCreated = true;
            }
            targetContent.title = content.title;
            targetContent.ncode = content.ncode;
            targetContent.userid = content.userid;
            targetContent.writer = content.writer;
            targetContent.story = content.story;
            targetContent.genre = content.genre;
            targetContent.keyword = content.keyword;
            targetContent.general_all_no = content.general_all_no;
            targetContent.end = content.end;
            targetContent.global_point = content.global_point;
            targetContent.fav_novel_cnt = content.fav_novel_cnt;
            targetContent.review_cnt = content.review_cnt;
            targetContent.all_point = content.all_point;
            targetContent.all_hyoka_cnt = content.all_hyoka_cnt;
            targetContent.sasie_cnt = content.sasie_cnt;
            targetContent.novelupdated_at = content.novelupdated_at;
            targetContentCacheData = [[NarouContentCacheData alloc] initWithCoreData:targetContent];
            // 新しく作ったので save して main thread と sync しておきます。
            [self->m_CoreDataObjectHolder save];
        //});
        }];
        if (isNarouContentCreated) {
            [self NarouContentListChangedAnnounce];
        }
    }
    
    /*
    if (targetContentCacheData != nil && ([targetContentCacheData.general_all_no intValue] <= [self CountContentChapter:targetContentCacheData]) ) {
        return NSLocalizedString(@"GlobalDataSingleton_AlreadyDownloaded", @"既にダウンロード済です。");
    }
     */
    
    // download queue に追加します。
    NSLog(@"add download queue.");
    [self PushContentDownloadQueue:content];
    
    return nil;
}

/// Ncode の指定でダウンロードqueueに追加します。
/// 追加できなかった場合はエラーメッセージを返します。
- (BOOL) AddDownloadQueueForNarouNcode:(NSString*)ncode
{
    return [m_DownloadQueue AddDownloadQueueForNcodeList:ncode];
}

/// download queue の最後に対象の content を追加します。
- (void)PushContentDownloadQueue:(NarouContentCacheData*)content
{
    [m_DownloadQueue AddDownloadQueue:content];
}

/// 現在ダウンロード中のコンテンツ情報を取得します。
- (NarouContentCacheData*)GetCurrentDownloadingInfo
{
    return [m_DownloadQueue GetCurrentDownloadingInfo];
}

/// 現在ダウンロード待ち中のコンテンツ情報のリストを取得します。
- (NSArray*) GetCurrentDownloadWaitingInfo
{
    return [m_DownloadQueue GetCurrentWaitingList];
}

/// ダウンロードイベントハンドラを設定します
- (BOOL)AddDownloadEventHandler:(id<NarouDownloadQueueDelegate>)delegate
{
    [m_DownloadQueue AddDownloadEventHandler:delegate];
    return true;
}


/// ダウンロードイベントハンドラから削除します。
- (BOOL)DeleteDownloadEventHandler:(id<NarouDownloadQueueDelegate>)delegate
{
    [m_DownloadQueue DelDownloadEventHandler:delegate];
    return true;
}

/// ダウンロード周りのイベントハンドラ用のdelegateに追加します。(ncode で絞り込む版)
- (BOOL)AddDownloadEventHandlerWithNcode:(NSString*)string handler:(id<NarouDownloadQueueDelegate>)handler
{
    return [m_DownloadQueue AddDownloadEventHandlerWithNcode:string handler:handler];
}
/// ダウンロード周りのイベントハンドラ用のdelegateから削除します。(ncode で絞り込む版)
- (BOOL)DeleteDownloadEventHandlerWithNcode:(NSString*)string
{
    return [m_DownloadQueue DelDownloadEventHandlerWithNcode:string];
}


/// 現在ダウンロード待ち中のものから、ncode を持つものをリストから外します。
- (BOOL)DeleteDownloadQueue:(NSString*)ncode
{
    return [m_DownloadQueue DeleteDownloadQueue:ncode];
}

/// CoreData で保存している Story のうち、Ncode と chapter_no で検索した結果
/// 得られた Story を取得します。
/// 登録がなければ nil を返します
- (Story*) SearchCoreDataStoryThreadUnsafe:(NSString*) ncode chapter_no:(int)chapter_number
{
    NSArray* fetchResults = [m_CoreDataObjectHolder SearchEntity:@"Story" predicate:[NSPredicate predicateWithFormat:@"ncode == %@ AND chapter_number == %d", ncode, chapter_number]];
    
    if(fetchResults == nil)
    {
        NSLog(@"fetch from CoreData failed.");
        return nil;
    }
    if([fetchResults count] == 0)
    {
        // 何もなかった。
        return nil;
    }
    if([fetchResults count] != 1)
    {
        NSLog(@"duplicate ncode+chapter_number!!! %@/%d", ncode, chapter_number);
        return nil;
    }
    return fetchResults[0];
}

/// Story を検索します。(公開用method)
- (StoryCacheData*) SearchStory:(NSString*)ncode chapter_no:(int)chapter_number
{
    __block StoryCacheData* result = nil;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        Story* story = [self SearchCoreDataStoryThreadUnsafe:ncode chapter_no:chapter_number];
        if (story != nil) {
            result = [[StoryCacheData alloc] initWithCoreData:story];
        }
    //});
    }];
    return result;
}

/// 指定された ncode の小説で、保存されている Story の chapter_no のみのリストを取得します(公開用method)
- (NSArray*)GetAllStoryForNcodeThreadUnsafe:(NSString*)ncode
{
    NSArray* fetchResults = [m_CoreDataObjectHolder SearchEntity:@"Story" predicate:[NSPredicate predicateWithFormat:@"ncode == %@", ncode] sortAttributeName:@"chapter_number" ascending:NO];
    
    if(fetchResults == nil)
    {
        NSLog(@"fetch from CoreData failed.");
        return @[];
    }
    NSMutableArray* resultArray = [[NSMutableArray alloc] initWithCapacity:[fetchResults count]];
    int i = 0;
    for (Story* story in fetchResults) {
        StoryCacheData* storyCacheData = [[StoryCacheData alloc] initWithCoreData:story];
        resultArray[i] = storyCacheData;
        i++;
    }
    return resultArray;
}

/// 指定された ncode の小説で、保存されている Story を全て取得します。
- (NSArray*)GeAllStoryForNcode:(NSString*)ncode
{
    __block NSArray* result = 0;
    [self coreDataPerfomBlockAndWait:^{
        result = [self GetAllStoryForNcodeThreadUnsafe:ncode];
    }];
    return result;
}

/// 指定された ncode の小説で、保存されている Story の個数を取得します
- (NSUInteger)GetStoryCountForNcodeThreadUnsafe:(NSString*)ncode
{
    NSUInteger result = [m_CoreDataObjectHolder CountEntity:@"Story" predicate:[NSPredicate predicateWithFormat:@"ncode == %@", ncode]];
    return result;
}

/// 指定された ncode の小説で、保存されている Story の個数を取得します
- (NSUInteger)GetStoryCountForNcode:(NSString*)ncode
{
    __block NSUInteger result = 0;
    [self coreDataPerfomBlockAndWait:^{
        result = [self GetStoryCountForNcodeThreadUnsafe:ncode];
    }];
    return result;
}

/// Story を新しく生成します。必要な情報をすべて指定する必要があります
- (Story*) CreateNewStoryThreadUnsafe:(NarouContent*)parentContent content:(NSString*)content chapter_number:(int)chapter_number;
{
    Story* story = [m_CoreDataObjectHolder CreateNewEntity:@"Story"];

    story.parentContent = parentContent;
    [parentContent addChildStoryObject:story];
        
    story.ncode = parentContent.ncode;
    story.chapter_number = [[NSNumber alloc] initWithInt:chapter_number];
    story.content = content;
    [m_CoreDataObjectHolder save];

    return story;
}

/// 指定されたStoryの情報を更新します。(dispatch_sync で囲っていない版)
/// CoreData側に登録されていなければ新規に作成し、
/// 既に登録済みであれば情報を更新します。
- (BOOL)UpdateStoryThreadUnsafe:(NSString*)content chapter_number:(int)chapter_number parentContent:(NarouContentCacheData *)parentContent
{
    if (parentContent == nil || content == nil) {
        return false;
    }
    
    BOOL result = false;
    NarouContent* parentCoreDataContent = [self SearchCoreDataNarouContentFromNcodeThreadUnsafe:parentContent.ncode];
    if (parentCoreDataContent == nil) {
        //NSLog(@"UpdateStoryThreadUnsafe failed. parenteCoreDataContent is nil");
        result = false;
    }else{
        Story* coreDataStory = [self SearchCoreDataStoryThreadUnsafe:parentContent.ncode chapter_no:chapter_number];
        if (coreDataStory == nil) {
            //NSLog(@"UpdateStoryThreadUnsafe: create new story for \"%@\" chapter: %d", parentContent.ncode, chapter_number);
            coreDataStory = [self CreateNewStoryThreadUnsafe:parentCoreDataContent content:content chapter_number: chapter_number];
        }
        coreDataStory.content = content;
        coreDataStory.parentContent = parentCoreDataContent;
        coreDataStory.chapter_number = [[NSNumber alloc] initWithInt:chapter_number];
        if(![m_CoreDataObjectHolder save]){
            //NSLog(@"UpdateStoryThreadUnsafe: m_CoreDataObjectHolder save failed.");
        }
        result = true;
    }

    return result;
}

/// 指定されたStoryの情報を更新します。
/// CoreData側に登録されていなければ新規に作成し、
/// 既に登録済みであれば情報を更新します。
- (BOOL)UpdateStory:(NSString*)content chapter_number:(int)chapter_number parentContent:(NarouContentCacheData *)parentContent
{
    if (parentContent == nil || content == nil) {
        return false;
    }
    
    __block BOOL result = false;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        result = [self UpdateStoryThreadUnsafe:content chapter_number:chapter_number parentContent:parentContent];
    //});
    }];
    
    return result;
}

- (void)NarouContentListChangedAnnounce
{
    //NSLog(@"NarouContentListChangedAnnounced.");
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    NSNotification* notification = [NSNotification notificationWithName:@"NarouContentListChanged" object:self];
    [notificationCenter postNotification:notification];
}

/// 小説を一つ削除します
- (BOOL)DeleteContent:(NarouContentCacheData*)content
{
    if (content == nil) {
        return false;
    }
    __block BOOL result = false;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        NarouContent* coreDataContent = [self SearchCoreDataNarouContentFromNcodeThreadUnsafe:content.ncode];
        if (coreDataContent != nil) {
            [self->m_CoreDataObjectHolder DeleteEntity:coreDataContent];
            [self->m_CoreDataObjectHolder save];
            result = true;
        }
    //});
    }];
    if (result) {
        [self NarouContentListChangedAnnounce];
    }
    return result;
}

/// 章を一つ削除します
- (BOOL)DeleteStory:(StoryCacheData *)story
{
    if (story == nil) {
        return false;
    }
    __block BOOL result = false;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        Story* coreDataStory = [self SearchCoreDataStoryThreadUnsafe:story.ncode chapter_no:[story.chapter_number intValue]];
        if (coreDataStory == nil) {
            result = false;
        }else{
            [self->m_CoreDataObjectHolder DeleteEntity:coreDataStory];
            [self->m_CoreDataObjectHolder save];
            result = true;
        }
    //});
    }];
    return result;
}

/// 対象の小説でCoreDataに保存されている章の数を取得します。
- (NSUInteger)CountContentChapter:(NarouContentCacheData*)content
{
    if (content == nil || content.ncode == nil) {
        return 0;
    }
    
    __block NSUInteger result = 0;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        result = [self->m_CoreDataObjectHolder CountEntity:@"Story" predicate:[NSPredicate predicateWithFormat:@"ncode == %@", content.ncode]];
    //});
    }];
    return result;
}

/// 最後に読んでいた小説を取得します
- (NarouContentCacheData*)GetCurrentReadingContent
{
    GlobalStateCacheData* globalState = [self GetGlobalState];
    if (globalState == nil) {
        return nil;
    }
    StoryCacheData* story = globalState.currentReadingStory;
    if (story == nil) {
        return nil;
    }
    return [self SearchNarouContentFromNcode:story.ncode];
}

/// 小説で読んでいた章を取得します
- (StoryCacheData*)GetReadingChapter:(NarouContentCacheData*)content
{
    if (content == nil) {
        return nil;
    }
    content = [self SearchNarouContentFromNcode:content.ncode];
    if (content.currentReadingStory != nil) {
        return content.currentReadingStory;
    }
    StoryCacheData* story = [self SearchStory:content.ncode chapter_no:[content.reading_chapter intValue]];
    if (story != nil) {
        //NSLog(@"story get from reading_chapter: %d", [content.reading_chapter intValue]);
        return story;
    }
    
    return nil;
}

/// 読み込み中の場所を指定された小説と章で更新します。
- (BOOL)UpdateReadingPoint:(NarouContentCacheData*)content story:(StoryCacheData*)story
{
    if (content == nil || story == nil
        || content.ncode == nil
        || ![content.ncode isEqual:story.ncode]) {
        NSLog(@"UpdateReadingPoint return false: nil");
        return false;
    }
    NSUInteger location = [story.readLocation integerValue];
    if (location == [story.content length] && [story.content length] > 0) {
        location = [story.content length] - 1;
    }
    //[self AddLogString:[[NSString alloc] initWithFormat:@"読み上げ位置を保存します。(%@) 章: %d 位置: %ld/%ld", content.title, [story.chapter_number intValue], (long)location, (unsigned long)[story.content length]]]; // NSLog

    __block BOOL result = false;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        NarouContent* coreDataContent = [self SearchCoreDataNarouContentFromNcodeThreadUnsafe:content.ncode];
        Story* coreDataStory = [self SearchCoreDataStoryThreadUnsafe:story.ncode chapter_no:[story.chapter_number intValue]];
        GlobalState* globalState = [self GetCoreDataGlobalStateThreadUnsafe];
        if (coreDataContent == nil || coreDataStory == nil || globalState == nil) {
            NSLog(@"UpdateReadingPoint failed: coreData* nil");
            result = false;
        }else{
            coreDataStory.readLocation = [[NSNumber alloc] initWithUnsignedInteger:location];
            coreDataContent.currentReadingStory = coreDataStory;
            coreDataContent.reading_chapter = coreDataStory.chapter_number;
            globalState.currentReadingStory = coreDataStory;
            [self->m_CoreDataObjectHolder save];
            result = true;
        }
    //});
    }];
    // 読み上げ位置が変わった Notification を飛ばします
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    NSString* notificationName = [[NSString alloc] initWithFormat:@"NarouContentReadingPointChanged_%@", content.ncode];
    NSNotification* notification = [NSNotification notificationWithName:notificationName object:self];
    [notificationCenter postNotification:notification];

    return result;
}

/// 次の章を読み出します。
/// 次の章がなければ nil を返します。
- (StoryCacheData*)GetNextChapter:(StoryCacheData*)story
{
    if (story == nil) {
        return nil;
    }
    int target_chapter_number = [story.chapter_number intValue] + 1;
    __block StoryCacheData* result = nil;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        Story* nextCoreDataStory = [self SearchCoreDataStoryThreadUnsafe:story.ncode chapter_no:target_chapter_number];
        if (nextCoreDataStory != nil) {
            //NSLog(@"chapter: %d is alive", target_chapter_number);
            result = [[StoryCacheData alloc] initWithCoreData:nextCoreDataStory];
        }else{
            NSLog(@"chapter: %d is NOT alive", target_chapter_number);
        }
    //});
    }];
    return result;
}

/// 前の章を読み出します。
/// 前の章がなければ nil を返します。
- (StoryCacheData*)GetPreviousChapter:(StoryCacheData*)story
{
    if (story == nil) {
        return nil;
    }
    int target_chapter_number = [story.chapter_number intValue] - 1;
    __block StoryCacheData* result = nil;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        Story* previousCoreDataStory = [self SearchCoreDataStoryThreadUnsafe:story.ncode chapter_no:target_chapter_number];
        if (previousCoreDataStory != nil) {
            result = [[StoryCacheData alloc] initWithCoreData:previousCoreDataStory];
        }
    //});
    }];
    return result;
}

/// Siri さんエンジンでの読み上げの rate から1秒間に読み上げられる文字数へ変換します。
/// 当然、当てずっぽうの値です。
+ (float)SpeechRateToCharCountInSecond:(float)rate {
    float rateNormalized = (rate - AVSpeechUtteranceMinimumSpeechRate) / (AVSpeechUtteranceMaximumSpeechRate - AVSpeechUtteranceMinimumSpeechRate);
    
    // 下に膨らんでる感じの補正をかける
    float rateCurved = powf(rateNormalized, 2.8);
    //NSLog(@"rateNormalized: %f -> %f", rateNormalized, rateCurved);
    // XXXX: ここ書かれている謎の値は
    // 単に rate を AVSpeechUtteranceMinimumSpeechRate(0.0) にした時と
    // AVSpeechUtteranceMaximumSpeechRate(1.0) にした時のそれぞれである程度の文字数を読み上げさせてみて、時間を測って出した値なのでまぁぶっちゃけ駄目。
    float charCount = rateCurved * 20.72f + 2.96f;
    return charCount;
}

+ (NSUInteger)GuessSpeakLocationFromDulationWithConfig:(SpeechConfig*)speechConfig dulation:(float)dulation {
    float rate = 0.5f;
    if (speechConfig != nil) {
        rate = speechConfig.rate;
    }
    float charCount = [GlobalDataSingleton SpeechRateToCharCountInSecond:rate];
    return (NSUInteger)(dulation * charCount);
}

+ (float)GuessSpeakDuration:(NSUInteger)textLength speechConfig:(SpeechConfig*)speechConfig {
    if (speechConfig == nil) {
        return 0.0f;
    }
    float charCount = [GlobalDataSingleton SpeechRateToCharCountInSecond:speechConfig.rate];
    return textLength / charCount;
}

/// 現在の読み上げ設定による、dulation(秒数)からの読み上げ位置を推測します
- (NSUInteger)GuessSpeakLocationFromDulation:(float)dulation {
    return [GlobalDataSingleton GuessSpeakLocationFromDulationWithConfig:[m_NiftySpeaker GetDefaultSpeechConfig] dulation:dulation];
}

- (void)UpdatePlayingInfo:(StoryCacheData*)story
{
    NSString* titleName = NSLocalizedString(@"GlobalDataSingleton_NoPlaing", @"再生していません");
    NSString* artist = @"-";
    
    if (story != nil) {
        NarouContentCacheData* content = [[GlobalDataSingleton GetInstance] SearchNarouContentFromNcode:story.ncode];
        if (content != nil) {
            if (content.writer != nil) {
                artist = content.writer;
            }
            titleName = [[NSString alloc] initWithFormat:@"%@ (%d/%d)", content.title, [story.chapter_number intValue], [content.general_all_no intValue]];
        }
    }
    
    NSMutableDictionary* songInfo = [NSMutableDictionary new];
    [songInfo setObject:titleName forKey:MPMediaItemPropertyTitle];
    [songInfo setObject:artist forKey:MPMediaItemPropertyArtist];
    if ([self IsPlaybackDurationEnabled]) {
        float playbackDuration = [GlobalDataSingleton GuessSpeakDuration:[story.content length] speechConfig:[m_NiftySpeaker GetDefaultSpeechConfig]];
        float currentPosition = [GlobalDataSingleton GuessSpeakDuration:[story.readLocation unsignedIntValue] speechConfig:[m_NiftySpeaker GetDefaultSpeechConfig]];
        [songInfo setObject:[[NSNumber alloc] initWithFloat:playbackDuration] forKey:MPMediaItemPropertyPlaybackDuration];
        [songInfo setObject:[[NSNumber alloc] initWithFloat:currentPosition] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        [songInfo setObject:@1.0f forKey:MPNowPlayingInfoPropertyPlaybackRate];
    }
    UIImage* artworkImage = [UIImage imageNamed:@"NovelSpeakerIcon-167px.png"];
    MPMediaItemArtwork* artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:[artworkImage size] requestHandler:^UIImage * _Nonnull(CGSize size) {
        return [artworkImage resize:size];
    }];
    [songInfo setObject:artwork forKey:MPMediaItemPropertyArtwork];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
}

- (void)InsertDefaultSpeakPitchConfig
{
    NSArray* speechConfigArray = [self GetAllSpeakPitchConfig];
    if (speechConfigArray == nil || [speechConfigArray count] <= 0) {
        // 設定が無いようなので勝手に作ります。
        SpeakPitchConfigCacheData* speakConfig = [SpeakPitchConfigCacheData new];
        speakConfig.title = NSLocalizedString(@"GlobalDataSingleton_Conversation1", @"会話文");
        speakConfig.pitch = [[NSNumber alloc] initWithFloat:1.5f];
        speakConfig.startText = @"「";
        speakConfig.endText = @"」";
        [self UpdateSpeakPitchConfig:speakConfig];
        speakConfig.title = NSLocalizedString(@"GlobalDataSingleton_Conversation2", @"会話文 2");
        speakConfig.pitch = [[NSNumber alloc] initWithFloat:1.2f];
        speakConfig.startText = @"『";
        speakConfig.endText = @"』";
        [self UpdateSpeakPitchConfig:speakConfig];
    }
}

/// 標準の読み上げ辞書のリストを取得します
- (NSDictionary*)GetDefaultSpeechModConfig {
    NSDictionary* dataDictionary = @{
        @"黒剣": @"コッケン"
        , @"黒尽くめ": @"黒づくめ"
        , @"黒剣": @"コッケン"
        , @"鶏ガラ": @"トリガラ"
        , @"魚醤": @"ギョショウ"
        , @"魔石": @"ませき"
        , @"魔獣": @"まじゅう"
        , @"魔導": @"まどう"
        , @"魔人": @"まじん"
        , @"駄弁る": @"だべる"
        , @"食い千切": @"くいちぎ"
        , @"飛翔体": @"ヒショウタイ"
        , @"飛来物": @"ヒライブツ"
        , @"願わくば": @"ねがわくば"
        , @"頑な": @"かたくな"
        , @"静寂": @"せいじゃく"
        , @"霊子": @"れいし"
        , @"霊体": @"れいたい"
        , @"集音": @"シュウオン"
        , @"闘術": @"闘じゅつ"
        , @"間髪": @"カンパツ"
        , @"金属片": @"金属ヘン"
        , @"金属板": @"キンゾクバン"
        , @"重装備": @"ジュウソウビ"
        , @"重火器": @"ジュウカキ"
        , @"重武装": @"ジュウブソウ"
        , @"重機関銃": @"ジュウキカンジュウ"
        , @"重低音": @"ジュウテイオン"
        , @"遮蔽物": @"シャヘイブツ"
        , @"遠まわし": @"とおまわし"
        , @"過去形": @"カコケイ"
        , @"火器": @"ジュウカキ"
        , @"造作もな": @"ゾウサもな"
        , @"通信手": @"ツウシンシュ"
        , @"轟炎": @"ゴウエン"
        , @"車列": @"シャレツ"
        , @"身分証": @"ミブンショウ"
        , @"身体能力": @"しんたい能力"
        , @"身体": @"からだ"
        , @"身を粉に": @"身をコに"
        , @"蹴散ら": @"ケチら"
        , @"踵を返": @"きびすを返"
        , @"貴船": @"キセン"
        , @"貧乳": @"ひんにゅう"
        , @"謁見の間": @"謁見のま"
        , @"解毒薬": @"ゲドクヤク"
        , @"規格外": @"キカクガイ"
        , @"要確認": @"ヨウ確認"
        , @"要救助者": @"ヨウ救助者"
        , @"複数人": @"複数ニン"
        , @"装甲板": @"装甲バン"
        , @"術者": @"ジュツシャ"
        , @"術式": @"ジュツシキ"
        , @"術師": @"ジュツシ"
        , @"行ってらっしゃい": @"いってらっしゃい"
        , @"行ってきます": @"いってきます"
        , @"行ったり来たり": @"いったりきたり"
        , @"血肉": @"チニク"
        , @"虫唾が走": @"ムシズが走"
        , @"薬師": @"くすし"
        , @"薬室": @"やくしつ"
        , @"薄明り": @"うすあかり"
        , @"薄ら": @"ウスラ"
        , @"荷馬車": @"ニバシャ"
        , @"艶めかし": @"なまめかし"
        , @"艶かし": @"なまめかし"
        , @"艦首": @"カンシュ"
        , @"艦影": @"カンエイ"
        , @"船外": @"センガイ"
        , @"脳筋": @"ノウキン"
        , @"聖骸布": @"セーガイフ"
        , @"聖骸": @"セーガイ"
        , @"聖騎士": @"セイキシ"
        , @"義体": @"ギタイ"
        , @"美男子": @"ビナンシ"
        , @"美味さ": @"ウマさ"
        , @"美味い": @"うまい"
        , @"美乳": @"びにゅう"
        , @"縞々": @"シマシマ"
        , @"緊急時": @"キンキュウジ"
        , @"絢十": @"あやと"
        , @"経験値": @"経験チ"
        , @"素体": @"そたい"
        , @"純心": @"ジュンシン"
        , @"精神波": @"セイシンハ"
        , @"米粒": @"コメツブ"
        , @"等間隔": @"トウカンカク"
        , @"笑い者": @"ワライモノ"
        , @"竜人": @"リュウジン"
        , @"空賊": @"クウゾク"
        , @"私掠船": @"シリャクセン"
        , @"神獣": @"シンジュウ"
        , @"祖父ちゃん": @"じいちゃん"
        , @"知性体": @"知性たい"
        , @"瞬殺": @"シュンサツ"
        , @"着艦": @"チャッカン"
        , @"真っ暗": @"まっくら"
        , @"真っ只中": @"マッタダナカ"
        , @"真っ二つ": @"まっぷたつ"
        , @"相も変わ": @"アイも変わ"
        , @"直継": @"ナオツグ"
        , @"発艦": @"ハッカン"
        , @"発射管": @"ハッシャカン"
        , @"発射口": @"ハッシャコウ"
        , @"異能": @"イノウ"
        , @"異空間": @"イクウカン"
        , @"異種族": @"いしゅぞく"
        , @"異界": @"イカイ"
        , @"異獣": @"いじゅう"
        , @"異次元": @"いじげん"
        , @"異世界": @"イセカイ"
        , @"男性器": @"ダンセイキ"
        , @"甜麺醤": @"テンメンジャン"
        , @"甘っちょろ": @"アマっちょろ"
        , @"環境下": @"環境か"
        , @"理想形": @"リソウケイ"
        , @"獣道": @"けものみち"
        , @"獣人": @"じゅうじん"
        , @"牛すじ": @"ギュウスジ"
        , @"爆発物": @"バクハツブツ"
        , @"爆炎": @"ばくえん"
        , @"熱波": @"ネッパ"
        , @"照ら": @"てら"
        , @"煎れ": @"いれ"
        , @"火星": @"カセイ"
        , @"火器": @"カキ"
        , @"漢探知": @"男探知"
        , @"漏ら": @"もら"
        , @"満タン": @"まんたん"
        , @"淹れ": @"いれ"
        , @"海賊船": @"海賊セン"
        , @"海兵隊": @"かいへいたい"
        , @"浮遊物": @"フユウブツ"
        , @"汝ら": @"なんじら"
        , @"氷のう": @"ヒョウノウ"
        , @"水場": @"水ば"
        , @"気弾": @"キダン"
        , @"気に食": @"きにく"
        , @"民間船": @"ミンカンセン"
        , @"殺人鬼": @"サツジンキ"
        , @"死に体": @"シニタイ"
        , @"機雷原": @"キライゲン"
        , @"構造物": @"コウゾウブツ"
        , @"極悪人": @"ゴクアクニン"
        , @"極々": @"ゴクゴク"
        , @"来いよ": @"こいよ"
        , @"木製": @"モクセイ"
        , @"望み薄": @"ノゾミウス"
        , @"月光神": @"ゲッコウシン"
        , @"最上階": @"さいじょうかい"
        , @"星間物質": @"セイカンブッシツ"
        , @"星系": @"セイケイ"
        , @"星域": @"セイイキ"
        , @"敵船": @"テキセン"
        , @"敵性体": @"敵性たい"
        , @"敵わない": @"かなわない"
        , @"数週間": @"スウシュウカン"
        , @"支配下": @"シハイカ"
        , @"擲弾": @"てきだん"
        , @"操船中": @"ソウセンチュウ"
        , @"操船": @"そうせん"
        , @"接敵": @"セッテキ"
        , @"排泄物": @"ハイセツブツ"
        , @"掌砲長": @"ショウホウチョウ"
        , @"掌砲手": @"ショウホウシュ"
        , @"掌打": @"しょうだ"
        , @"掌帆長": @"ショウハンチョウ"
        , @"指揮車": @"シキシャ"
        , @"拙い": @"マズイ"
        , @"技術者": @"ギジュツシャ"
        , @"手練れ": @"テダレ"
        , @"所狭し": @"トコロセマシ"
        , @"成程": @"なるほど"
        , @"慌ただし": @"あわただし"
        , @"愛国心": @"アイコクシン"
        , @"愛おし": @"いとおし"
        , @"悪趣味": @"あくしゅみ"
        , @"悪戯": @"いたずら"
        , @"急ごしらえ": @"キュウゴシラエ"
        , @"念話": @"ネンワ"
        , @"忠誠心": @"忠誠シン"
        , @"忌み子": @"イミコ"
        , @"心配性": @"シンパイショウ"
        , @"心拍": @"シンパク"
        , @"徹甲弾": @"テッコウダン"
        , @"微乳": @"びにゅう"
        , @"後がない": @"アトがない"
        , @"彷徨う": @"さまよう"
        , @"影響下": @"エイキョウカ"
        , @"弾着": @"ダンチャク"
        , @"弾倉": @"だんそう"
        , @"強張る": @"こわばる"
        , @"引きこもり": @"ひきこもり"
        , @"幻獣": @"ゲンジュウ"
        , @"幸か不幸": @"コウかフコウ"
        , @"年単位": @"ネンタンイ"
        , @"平常心": @"ヘイジョウシン"
        , @"席替え": @"セキガエ"
        , @"巨乳": @"きょにゅう"
        , @"小柄": @"こがら"
        , @"小型船": @"コガタセン"
        , @"小一時間": @"コ1時間"
        , @"対戦車": @"たいせんしゃ"
        , @"寝顔": @"ネガオ"
        , @"害獣": @"ガイジュウ"
        , @"安酒": @"ヤスザケ"
        , @"宇宙船乗り": @"ウチュウセンノリ"
        , @"宇宙暦": @"ウチュウレキ"
        , @"宇宙人": @"ウチュウジン"
        , @"孫子": @"ソンシ"
        , @"姫君": @"ヒメギミ"
        , @"姉上": @"アネウエ"
        , @"姉ぇ": @"ネエ"
        , @"妖艶": @"ようえん"
        , @"妖獣": @"ヨウジュウ"
        , @"妖人": @"ようじん"
        , @"奴ら": @"ヤツら"
        , @"女性器": @"ジョセイキ"
        , @"女子力": @"女子りょく"
        , @"太陽神": @"タイヨウシン"
        , @"太もも": @"フトモモ"
        , @"天晴れ": @"アッパレ"
        , @"大馬鹿": @"オオバカ"
        , @"大賢者": @"だいけんじゃ"
        , @"大津波": @"オオツナミ"
        , @"大泣き": @"オオナキ"
        , @"大所帯": @"オオジョタイ"
        , @"大慌て": @"おおあわて"
        , @"大怪我": @"オオ怪我"
        , @"大地人": @"だいちじん"
        , @"大嘘": @"オオウソ"
        , @"大人": @"おとな"
        , @"大っぴら": @"おおっぴら"
        , @"外殻": @"ガイカク"
        , @"外惑星": @"ガイワクセイ"
        , @"壊れ難": @"壊れにく"
        , @"墓所": @"ボショ"
        , @"地球外": @"チキュウガイ"
        , @"地底人": @"ちていじん"
        , @"回頭": @"カイトウ"
        , @"喰う": @"くう"
        , @"喜声": @"キセイ"
        , @"問題外": @"モンダイガイ"
        , @"問題児": @"問題じ"
        , @"商根たくまし": @"ショウコンたくまし"
        , @"呻り声": @"唸り声"
        , @"同じ様": @"同じヨウ"
        , @"可笑し": @"おかし"
        , @"召喚術": @"ショウカンジュツ"
        , @"召喚獣": @"ショウカンジュウ"
        , @"友軍艦": @"ユウグンカン"
        , @"去り際": @"サリギワ"
        , @"厨二": @"チュウニ"
        , @"厄介者": @"ヤッカイモノ"
        , @"南部": @"なんぶ"
        , @"千載一遇": @"センザイイチグウ"
        , @"千切れ": @"ちぎれ"
        , @"勝負所": @"勝負ドコロ"
        , @"力場": @"りきば"
        , @"創造神": @"ソウゾウシン"
        , @"剣鬼": @"ケンキ"
        , @"剣聖": @"ケンセイ"
        , @"剣神": @"ケンシン"
        , @"初見": @"しょけん"
        , @"初弾": @"ショダン"
        , @"分身": @"ぶんしん"
        , @"分は悪": @"ブは悪"
        , @"分が悪": @"ブが悪"
        , @"再戦": @"サイセン"
        , @"円筒形": @"円筒ケイ"
        , @"内容物": @"ナイヨウブツ"
        , @"入出口": @"ニュウシュツコウ"
        , @"兎に角": @"とにかく"
        , @"光秒": @"コウビョウ"
        , @"光時": @"コウジ"
        , @"光分": @"コウフン"
        , @"兄ちゃん": @"ニイチャン"
        , @"兄ぃ": @"にい"
        , @"健康体": @"健康タイ"
        , @"偏光": @"ヘンコウ"
        , @"俺達": @"おれたち"
        , @"何時の間": @"いつのま"
        , @"何？": @"なに？"
        , @"体育祭": @"タイイクサイ"
        , @"体当たり": @"たいあたり"
        , @"以ての外": @"モッテノホカ"
        , @"他ならぬ": @"ほかならぬ"
        , @"仔牛": @"コウシ"
        , @"今作戦": @"コン作戦"
        , @"人肉": @"じんにく"
        , @"人的資源": @"ジンテキシゲン"
        , @"人狼": @"じんろう"
        , @"人数分": @"ニンズウブン"
        , @"人工物": @"ジンコウブツ"
        , @"予定表": @"ヨテイヒョウ"
        , @"乱高下": @"ランコオゲ"
        , @"主機": @"シュキ"
        , @"主兵装": @"シュヘイソウ"
        , @"中破": @"チュウハ"
        , @"中年": @"ちゅうねん"
        , @"中の中": @"チュウのチュウ"
        , @"中の下": @"チュウのゲ"
        , @"中の上": @"チュウのジョウ"
        , @"世界樹": @"せかいじゅ"
        , @"不届き者": @"不届きモノ"
        , @"不味い": @"まずい"
        , @"下ネタ": @"シモネタ"
        , @"下の中": @"ゲのチュウ"
        , @"下の下": @"ゲのゲ"
        , @"下の上": @"ゲのジョウ"
        , @"上腕二頭筋": @"ジョウワンニトウキン"
        , @"上方修正": @"じょうほう修正"
        , @"上の中": @"ジョウのチュウ"
        , @"上の下": @"ジョウのゲ"
        , @"上の上": @"ジョウのジョウ"
        , @"三日三晩": @"ミッカミバン"
        , @"三国": @"サンゴク"
        , @"三々五々": @"さんさんごご"
        , @"万人": @"マンニン"
        , @"一級品": @"イッキュウヒン"
        , @"一目置": @"イチモク置"
        , @"一目惚れ": @"ヒトメボレ"
        , @"一派": @"イッパ"
        , @"一日の長": @"イチジツノチョウ"
        , @"一品物": @"イッピンモノ"
        , @"一分の隙": @"いちぶの隙"
        , @"ボクっ娘": @"ボクっ子"
        , @"ペルセウス腕": @"ペルセウスワン"
        , @"ペイント弾": @"ペイントダン"
        , @"ドジっ娘": @"ドジっ子"
        , @"シュミレー": @"シミュレー"
        , @"カレー粉": @"カレーコ"
        , @"カズ彦": @"カズヒコ"
        , @"よそ者": @"ヨソモノ"
        , @"ひと言": @"ヒトコト"
        , @"の宴": @"のうたげ"
        , @"にゃん太": @"ニャンタ"
        , @"そこら中": @"ソコラジュウ"
        , @"この上ない": @"このうえない"
        , @"お米": @"おこめ"
        , @"お祖父": @"おじい"
        , @"お姉": @"オネエ"
        , @"お兄様": @"おにいさま"
        , @"お兄さま": @"おにいさま"
        , @"お付き": @"おつき"
        , @"いつの間に": @"いつのまに"
        , @"ある種": @"あるしゅ"
        , @"あっという間": @"あっというま"
        
        // 2016/07/29 added.
        , @"～": @"ー"
        , @"麻婆豆腐": @"マーボードーフ"
        , @"麻婆": @"マーボー"
        , @"豆板醤": @"トーバンジャン"
        , @"言葉少な": @"言葉すくな"
        , @"聖印": @"セイイン"
        , @"籠城": @"ロウジョウ"
        , @"禁術": @"キンジュツ"
        , @"神兵": @"シンペイ"
        , @"着ぐるみ": @"キグルミ"
        , @"白狼": @"ハクロウ"
        , @"町人": @"チョウニン"
        , @"恐怖心": @"キョウフシン"
        , @"幼生体": @"幼生タイ"
        , @"天神": @"テンジン"
        , @"大皿": @"オオザラ"
        , @"大喧嘩": @"オオゲンカ"
        , @"味方": @"ミカタ"
        , @"吐瀉物": @"トシャブツ"
        , @"古井戸": @"フル井戸"
        , @"兄様": @"ニイサマ"
        , @"使用人": @"シヨウニン"
        , @"体術": @"タイジュツ"
        , @"住人": @"ジュウニン"
        , @"亜人": @"アジン"
        , @"二つ名": @"ふたつナ"
        , @"三角コーナー": @"サンカクコーナー"
        , @"メイド頭": @"メイドガシラ"
        , @"トン汁": @"トンジル"
        , @"カツ丼": @"カツドン"
        , @"お祖母": @"おばあ"
        
        // 2016/09/19 added.
        , @"魔光弾": @"マコーダン"
        , @"雄たけび": @"おたけび"
        , @"跳弾": @"チョウダン"
        , @"貴国": @"キコク"
        , @"豚の角煮": @"豚のカクニ"
        , @"血飛沫": @"血シブキ"
        , @"船速": @"センソク"
        , @"空対空": @"クウタイクウ"
        , @"秘密裏": @"秘密リ"
        , @"砲口": @"ホーコー"
        , @"異民族": @"イミンゾク"
        , @"理論上": @"理論ジョー"
        , @"滑腔砲": @"カッコウホウ"
        , @"洋ゲー": @"ヨウゲー"
        , @"武術家": @"ブジュツカ"
        , @"敵機影": @"敵キエイ"
        , @"敵機": @"テッキ"
        , @"拗らせ": @"こじらせ"
        , @"打撃力": @"ダゲキリョク"
        , @"心技体": @"シン、ギ、タイ"
        , @"後退翼": @"コウタイヨク"
        , @"弾薬": @"ダンヤク"
        , @"弾帯": @"ダンタイ"
        , @"小悪党": @"コアクトウ"
        , @"導力": @"ドウリョク"
        , @"安月給": @"ヤスゲッキュウ"
        , @"女王様": @"ジョオウサマ"
        , @"多脚": @"タキャク"
        
        // 2015/09/27 added.
        //, @"あ、": @"あぁ、"
        
        // 2018/07/25 added.
        , @"お守り": @"おまもり"
        
        // 2018/09/16 added.
        // 注："❗" 等の「元の文字のある絵文字」については、筆者による意図的なものの場合を考えて標準には入れない事にします
        //, @"❗": @"！"
        //, @"❓": @"？"

        , @"〜": @"ー"
        
        , @"α": @"アルファ"
        , @"Α": @"アルファ"
        , @"β": @"ベータ"
        , @"Β": @"ベータ"
        , @"γ": @"ガンマ"
        , @"Γ": @"ガンマ"
        , @"δ": @"デルタ"
        , @"Δ": @"デルタ"
        , @"ε": @"イプシロン"
        , @"Ε": @"イプシロン"
        , @"ζ": @"ゼータ"
        , @"Ζ": @"ゼータ"
        , @"η": @"エータ"
        , @"θ": @"シータ"
        , @"Θ": @"シータ"
        , @"ι": @"イオタ"
        , @"κ": @"カッパ"
        , @"λ": @"ラムダ"
        , @"μ": @"ミュー"
        , @"ν": @"ニュー"
        , @"ο": @"オミクロン"
        , @"π": @"パイ"
        , @"Π": @"パイ"
        , @"ρ": @"ロー"
        , @"σ": @"シグマ"
        , @"Σ": @"シグマ"
        , @"τ": @"タウ"
        , @"υ": @"ユプシロン"
        , @"φ": @"ファイ"
        , @"Φ": @"ファイ"
        , @"χ": @"カイ"
        , @"ψ": @"プサイ"
        , @"ω": @"オメガ"
        , @"Ω": @"オメガ"
        
        , @"Ⅰ": @"1"
        , @"Ⅱ": @"2"
        , @"Ⅲ": @"3"
        , @"Ⅳ": @"4"
        , @"Ⅴ": @"5"
        , @"Ⅵ": @"6"
        , @"Ⅶ": @"7"
        , @"Ⅷ": @"8"
        , @"Ⅸ": @"9"
        , @"Ⅹ": @"10"
        , @"ⅰ": @"1"
        , @"ⅱ": @"2"
        , @"ⅲ": @"3"
        , @"ⅳ": @"4"
        , @"ⅴ": @"5"
        , @"ⅵ": @"6"
        , @"ⅶ": @"7"
        , @"ⅷ": @"8"
        , @"ⅸ": @"9"
        , @"ⅹ": @"10"
        
        , @"※": @" "
        
        , @"Plant hwyaden": @"プラント・フロウデン"
        , @"Ｐｌａｎｔ　ｈｗｙａｄｅｎ": @"プラント・フロウデン"
        , @"VRMMORPG": @"VR MMORPG"
        , @"ＢＩＳＨＯＰ": @"ビショップ"
        , @"ＡＩ": @"エエアイ"
        };
    return dataDictionary;
}
    
- (NSDictionary*)GetDefaultSpeechModConfigForRegexp
{
    return @{
             //@"(\\P{Han})己(\\P{Han})": @"$1おのれ$2",
             //@"(\\P{Han})掌(\\P{Han})": @"$1てのひら$2",
             @"([0-9０-９零壱弐参肆伍陸漆捌玖拾什陌佰阡仟萬〇一二三四五六七八九十百千万億兆]+)\\s*[〜～]\\s*([0-9０-９零壱弐参肆伍陸漆捌玖拾什陌佰阡仟萬〇一二三四五六七八九十百千万億兆]+)": @"$1から$2", // 100〜200 → 100から200
             @"([0-9０-９零壱弐参肆伍陸漆捌玖拾什陌佰阡仟萬〇一二三四五六七八九十百千万億兆]+)\\s*話": @"$1は", // 29話 → 29は
    };
}

/// 標準の読み替え辞書を上書き追加します。
- (void)InsertDefaultSpeechModConfig
{
    NSDictionary* dataDictionary = [self GetDefaultSpeechModConfig];
    NSMutableArray* mutableArray = [NSMutableArray new];
    for (NSString* key in [dataDictionary keyEnumerator]) {
        SpeechModSettingCacheData* speechModSetting = [[SpeechModSettingCacheData alloc] initWithBeforeString:key afterString:[dataDictionary objectForKey:key] type:SpeechModSettingConvertType_JustMatch];
        [mutableArray addObject:speechModSetting];
    }
    dataDictionary = [self GetDefaultSpeechModConfigForRegexp];
    for (NSString* key in [dataDictionary keyEnumerator]) {
        SpeechModSettingCacheData* speechModSetting = [[SpeechModSettingCacheData alloc] initWithBeforeString:key afterString:[dataDictionary objectForKey:key] type:SpeechModSettingConvertType_Regexp];
        [mutableArray addObject:speechModSetting];
    }
    [self UpdateSpeechModSettingMultiple:mutableArray];
}

- (void)InsertDefaultSpeechWaitConfig
{
    NSArray* currentSpeechWaitSettingList = [self GetAllSpeechWaitConfig];
    if (currentSpeechWaitSettingList != nil && [currentSpeechWaitSettingList count] > 0) {
        // 何かあるなら追加しません。
        return;
    }
    {
        // 改行2つは 0.5秒待たせます
        SpeechWaitConfigCacheData* waitConfig = [SpeechWaitConfigCacheData new];
        waitConfig.targetText = @"\r\n\r\n";
        waitConfig.delayTimeInSec = [[NSNumber alloc] initWithFloat:0.5f];
        [[GlobalDataSingleton GetInstance] AddSpeechWaitSetting:waitConfig];
    }
    NSArray* defaultSpeechWaitTargets = [[NSArray alloc] initWithObjects:
                                         @"……"
                                         , @"、"
                                         , @"。"
                                         , @"・"
                                         , nil];
    
    for (NSString* targetString in defaultSpeechWaitTargets) {
        SpeechWaitConfigCacheData* waitConfig = [SpeechWaitConfigCacheData new];
        waitConfig.targetText = targetString;
        waitConfig.delayTimeInSec = [[NSNumber alloc] initWithFloat:0.0f];
        [[GlobalDataSingleton GetInstance] AddSpeechWaitSetting:waitConfig];
    }
}

/// 何も設定されていなければ標準のデータを追加します。
- (void)InsertDefaultSetting
{
    [self InsertDefaultSpeakPitchConfig];
    NSArray* speechModConfigArray = [self GetAllSpeechModSettings];
    if (speechModConfigArray == nil || [speechModConfigArray count] <= 0) {
        // これも無いようなので勝手に作ります。
        [self InsertDefaultSpeechModConfig];
    }
    [self InsertDefaultSpeechWaitConfig];
}

/// NiftySpeaker に現在の標準設定を登録します
- (void)ApplyDefaultSpeechconfig:(NiftySpeaker*)niftySpeaker
{
    GlobalStateCacheData* globalState = [self GetGlobalState];
    SpeechConfig* defaultSetting = [SpeechConfig new];
    defaultSetting.pitch = [globalState.defaultPitch floatValue];
    defaultSetting.rate = [globalState.defaultRate floatValue];
    defaultSetting.beforeDelay = 0.0f;
    defaultSetting.voiceIdentifier = [self GetVoiceIdentifier];
    [niftySpeaker SetDefaultSpeechConfig:defaultSetting];
}

/// NiftySpeakerに現在の読み上げの声質の設定を登録します
- (void)ApplySpeakPitchConfig:(NiftySpeaker*) niftySpeaker
{
    GlobalStateCacheData* globalState = [self GetGlobalState];
    
    NSArray* speechConfigArray = [self GetAllSpeakPitchConfig];
    if (speechConfigArray != nil) {
        for (SpeakPitchConfigCacheData* pitchConfig in speechConfigArray) {
            SpeechConfig* speechConfig = [SpeechConfig new];
            speechConfig.pitch = [pitchConfig.pitch floatValue];
            speechConfig.rate = [globalState.defaultRate floatValue];
            speechConfig.beforeDelay = 0.0f;
            speechConfig.voiceIdentifier = [self GetVoiceIdentifier];
            [niftySpeaker AddBlockStartSeparator:pitchConfig.startText endString:pitchConfig.endText speechConfig:speechConfig];
        }
    }
}

/// NiftySpeakerに現在の読みの「間」の設定を登録します
- (void)ApplySpeechWaitConfig:(NiftySpeaker*) niftySpeaker
{
    GlobalStateCacheData* globalState = [self GetGlobalState];
    
    NSArray* speechWaitConfigList = [self GetAllSpeechWaitConfig];
    if (speechWaitConfigList != nil) {
        for (SpeechWaitConfigCacheData* speechWaitConfigCache in speechWaitConfigList) {
            float delay = [speechWaitConfigCache.delayTimeInSec floatValue];
            if (delay > 0.0f) {
                if ([globalState.speechWaitSettingUseExperimentalWait boolValue]) {
                    NSMutableString* waitString = [[NSMutableString alloc] initWithString:@"。"];
                    for (float x = 0.0f; x < delay; x += 0.1f) {
                        [waitString appendString:@"_。"];
                    }
                    NSRange enterRange = [speechWaitConfigCache.targetText rangeOfString:@"\r\n"];
                    if (enterRange.location != NSNotFound) {
                        NSString* otherEnterText = [speechWaitConfigCache.targetText stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
                        [niftySpeaker AddSpeechModText:otherEnterText to:waitString];
                        otherEnterText = [speechWaitConfigCache.targetText stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\r"];
                        [niftySpeaker AddSpeechModText:otherEnterText to:waitString];
                    }
                    [niftySpeaker AddSpeechModText:speechWaitConfigCache.targetText to:waitString];
                }else{
                    [niftySpeaker AddDelayBlockSeparator:speechWaitConfigCache.targetText delay:delay];
                }
            }
        }
    }
}

/// 指定された文字列から、ルビが振られているものを取り出して読み替え辞書に登録します。
- (void)ApplyRubyModConfigWithText:(NiftySpeaker*)niftySpeaker text:(NSString*)text {
    NSDictionary* rubyDictionary = [StringSubstituter FindNarouRubyNotation:text notRubyString:[self GetNotRubyCharactorStringArray]];
    for (NSString* from in [rubyDictionary keyEnumerator]) {
        NSString* to = [rubyDictionary valueForKey:from];
        if (to != nil) {
            [niftySpeaker AddSpeechModText:from to:to];
        }
    }
}

/// NiftySpeaker に保存されている文字列から、ルビが振られているものを取り出して読み替え辞書に登録します。
- (void)ApplyRubyModConfig:(NiftySpeaker*)niftySpeaker
{
    [self ApplyRubyModConfigWithText:niftySpeaker text:[niftySpeaker GetText]];
}

/// 指定された文字列から、URIのような文字列を取り出して読み上げられないように読み替え辞書に登録します。
- (void)ApplyRemoveURIModConfigWithText:(NiftySpeaker*)niftySpeaker text:(NSString*)text {
    NSArray* URIStringArray = [StringSubstituter FindURIStrings:text];
    for (NSString* URIString in URIStringArray) {
        NSString* toString = @" ";
        [niftySpeaker AddSpeechModText:URIString to:toString];
    }
}

/// NiftySpeaker に保存されている文字列から、URIのようなものを取り出して読み上げられないように読み替え辞書に登録します。
- (void)ApplyRemoveURIModConfig:(NiftySpeaker*)niftySpeaker{
    [self ApplyRemoveURIModConfigWithText:niftySpeaker text:[niftySpeaker GetText]];
}
    
/// NiftySpeakerに現在の読み替え設定を登録します
- (void)ApplySpeechModConfig:(NiftySpeaker*)niftySpeaker
{
    NSArray* speechModConfigArray = [self GetAllSpeechModSettings];
    if (speechModConfigArray != nil) {
        for (SpeechModSettingCacheData* speechModSetting in speechModConfigArray) {
            if (![speechModSetting isJustMatchType]) {
                continue;
            }
            [niftySpeaker AddSpeechModText:speechModSetting.beforeString to:speechModSetting.afterString];
        }
    }
}

/// NiftySpeaker に正規表現での読み替え設定を登録します。
- (void)ApplySpeechModConfigForRegexp:(NiftySpeaker*)niftySpeaker targetText:(NSString*)targetText
{
    NSArray* speechModConfigArray = [self GetAllSpeechModSettings];
    if(speechModConfigArray == nil){
        return;
    }
    for (SpeechModSettingCacheData* speechModSetting in speechModConfigArray) {
        if (![speechModSetting isRegexpType]) {
            continue;
        }
        NSArray* regexpModConfigArray = [StringSubstituter FindRegexpSpeechModConfigs:targetText pattern:speechModSetting.beforeString to:speechModSetting.afterString];
        for (SpeechModSettingCacheData* modSetting in regexpModConfigArray) {
            [niftySpeaker AddSpeechModText:modSetting.beforeString to:modSetting.afterString];
        }
    }
}

- (void)ApplySpeechModConfigForSpeechRecognizerBugEscape:(NiftySpeaker*)niftySpeaker targetText:(NSString*)targetText {
    if (![self IsEscapeAboutSpeechPositionDisplayBugOniOS12Enabled]) {
        return;
    }
    NSDictionary* regexpTable = @{
        @"[\\t\\f\\p{Z}]+": @"α"
    };
    for (NSString* before in [regexpTable keyEnumerator]) {
        NSString* after = [regexpTable objectForKey:before];
        if (before == nil || after == nil) {
            continue;
        }
        NSArray* regexpModConfigArray = [StringSubstituter FindRegexpSpeechModConfigs:targetText pattern:before to:after];
        for (SpeechModSettingCacheData* modSetting in regexpModConfigArray) {
            [niftySpeaker AddSpeechModText:modSetting.beforeString to:modSetting.afterString];
        }
    }
}

/// 読み上げ設定を読み直します。
- (BOOL)ReloadSpeechSetting
{
    [m_NiftySpeaker ClearSpeakSettings];
    [self ApplyDefaultSpeechconfig:m_NiftySpeaker];
    [self ApplySpeakPitchConfig:m_NiftySpeaker];
    [self ApplySpeechWaitConfig:m_NiftySpeaker];
    if ([self GetOverrideRubyIsEnabled]) {
        [self ApplyRubyModConfig:m_NiftySpeaker];
    }
    if ([self GetIsIgnoreURIStringSpeechEnabled]) {
        [self ApplyRemoveURIModConfig:m_NiftySpeaker];
    }
    [self ApplySpeechModConfig:m_NiftySpeaker];
    return true;
}

/// ncode の new flag を落とします。
- (void)DropNewFlag:(NSString*)ncode
{
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        NarouContent* content = [self SearchCoreDataNarouContentFromNcodeThreadUnsafe:ncode];
        if ([content.is_new_flug boolValue] == true) {
            NSLog(@"new flag drop: %@", ncode);
            content.is_new_flug = [[NSNumber alloc] initWithBool:false];
            [self->m_CoreDataObjectHolder save];
        
        }
    //});
    }];
    // drop の Notification を飛ばします
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    NSString* notificationName = [[NSString alloc] initWithFormat:@"NarouContentNewStatusDown_%@", ncode];
    NSNotification* notification = [NSNotification notificationWithName:notificationName object:self];
    [notificationCenter postNotification:notification];
}

/// &amp; を & とかに変換します
- (NSString*)UnescapeHTMLEntities:(NSString*)str
{
    NSString *returnStr = nil;
    
    if(str == nil)
    {
        return nil;
    }
    returnStr = [str stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    returnStr = [returnStr stringByReplacingOccurrencesOfString:@"&#x27;" withString:@"'"];
    returnStr = [returnStr stringByReplacingOccurrencesOfString:@"&#x39;" withString:@"'"];
    returnStr = [returnStr stringByReplacingOccurrencesOfString:@"&#x92;" withString:@"'"];
    returnStr = [returnStr stringByReplacingOccurrencesOfString:@"&#x96;" withString:@"'"];
    returnStr = [returnStr stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    returnStr = [returnStr stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    returnStr = [returnStr stringByReplacingOccurrencesOfString:@"&amp;" withString: @"&"];

    // 小説家になろうのタグ
    // http://syosetu.com/man/tag/
    returnStr = [returnStr stringByReplacingOccurrencesOfString:@"<PBR>" withString: @"\r\n"]; // PCでの改行
    returnStr = [returnStr stringByReplacingOccurrencesOfString:@"<KBR>" withString: @""]; // 携帯での改行
    returnStr = [returnStr stringByReplacingOccurrencesOfString:@"【改ページ】" withString: @""]; // 携帯での改ページ
    returnStr = [[NSString alloc] initWithString:returnStr];

    return returnStr;
}

/// story の文章を表示用の文字列に変換します。
- (NSString*)ConvertStoryContentToDisplayText:(StoryCacheData*)story
{
    if (story == nil) {
        return nil;
    }
    return [self UnescapeHTMLEntities:story.content];
}

/// 読み上げる文書を設定します。
- (BOOL)SetSpeechStory:(StoryCacheData *)story
{
    [BehaviorLogger AddLogWithDescription:@"SetSpeechStory" data:@{
       @"novelID": story.ncode == nil ? @"nil" : story.ncode,
       @"chapterNumber": story.chapter_number == nil ? @"nil" : [story.chapter_number stringValue],
       @"readLocation": story.readLocation == nil ? @"nil" : [story.readLocation stringValue]
       }];
    if ([self GetOverrideRubyIsEnabled]) {
        [self ApplyRubyModConfigWithText:m_NiftySpeaker text:story.content];
    }
    if ([self GetIsIgnoreURIStringSpeechEnabled]) {
        [self ApplyRemoveURIModConfigWithText:m_NiftySpeaker text:story.content];
    }
    [self ApplySpeechModConfigForRegexp:m_NiftySpeaker targetText:story.content];
    //[self ApplySpeechModConfigForSpeechRecognizerBugEscape:m_NiftySpeaker targetText:story.content];
    
    if(![m_NiftySpeaker SetText:[self ConvertStoryContentToDisplayText:story]])
    {
        return false;
    }
    [self UpdatePlayingInfo:story];
    [self DropNewFlag:story.ncode];
    NarouContentCacheData* content = [self SearchNarouContentFromNcode:story.ncode];
    if (content != nil) {
        content.reading_chapter = story.chapter_number;
        [self UpdateNarouContent:content];
    }
    NSRange range = NSMakeRange([story.readLocation unsignedLongValue], 0);
    return [m_NiftySpeaker UpdateCurrentReadingPoint:range];
}

/// 読み上げ位置を設定します。
- (BOOL)SetSpeechRange:(NSRange)range
{
    return [m_NiftySpeaker UpdateCurrentReadingPoint:range];
}

/// 現在の読み上げ位置を取り出します
- (NSRange)GetCurrentReadingPoint
{
    return [m_NiftySpeaker GetCurrentReadingPoint];
}

/// 読み上げ停止のタイマーを開始します
- (void)StartMaxSpeechTimeInSecTimer
{
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    NSNumber* maxSpeechTimeInSec = [globalData GetGlobalState].maxSpeechTimeInSec;
    if (maxSpeechTimeInSec == nil) {
        return;
    }
    [self StopMaxSpeechTimeInSecTimer];
    m_isMaxSpeechTimeExceeded = false;

    NSLog(@"StartMaxSpeechTimeInSecTimer: %@", maxSpeechTimeInSec);
    m_MaxSpeechTimeInSecTimer = [NSTimer scheduledTimerWithTimeInterval:[maxSpeechTimeInSec intValue] target:self selector:@selector(MaxSpeechTimeInSecEventHandler:) userInfo:nil repeats:NO];
    //[m_MaxSpeechTimeInSecTimer fire]; // fire すると時間経過に関係なくすぐにイベントが発生するっぽいです。単にタイマーを作った時点でもう時間計測は開始している模様
}

/// 読み上げ停止のタイマーを停止します
- (void)StopMaxSpeechTimeInSecTimer
{
    if (m_MaxSpeechTimeInSecTimer != nil && [m_MaxSpeechTimeInSecTimer isValid]) {
        [m_MaxSpeechTimeInSecTimer invalidate];
    }
    m_MaxSpeechTimeInSecTimer = nil;
}

/// 読み上げ停止のタイマー呼び出しのイベントハンドラ
- (void)MaxSpeechTimeInSecEventHandler:(NSTimer*)timer
{
    if (m_MaxSpeechTimeInSecTimer != nil) {
        if (m_MaxSpeechTimeInSecTimer != timer) {
            [[GlobalDataSingleton GetInstance] AddLogString:[[NSString alloc] initWithFormat:@"MaxSpeechTimeInSecEventHandler が呼び出されたけれど、Timer のポインタが違ったので読み上げは停止しません。(timer: %p, m_MaxSpeechTimeInSecTimer: %p", timer, m_MaxSpeechTimeInSecTimer]]; // NSLog
        }else{
            m_isMaxSpeechTimeExceeded = true;
            [[GlobalDataSingleton GetInstance] AddLogString:@"MaxSpeechTimeInSecEventHandler が呼び出されたので読み上げを止めます。"]; // NSLog
            [self StopSpeech];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self AnnounceBySpeech:NSLocalizedString(@"GlobalDataSingleton_AnnounceStopedByTimer", @"最大連続再生時間を超えたので、読み上げを停止します。")];
            });
        }
    }else{
        [[GlobalDataSingleton GetInstance] AddLogString:@"MaxSpeechTimeInSecEventHandler が呼び出されたけれど、m_MaxSpeechTimeInSecTimer が nil でした。"]; // NSLog
    }
}

/// 読み上げを開始します。
- (BOOL)StartSpeech:(BOOL)withMaxSpeechTimeReset
{
    if (m_isMaxSpeechTimeExceeded && (!withMaxSpeechTimeReset)) {
        return false;
    }
    GlobalStateCacheData* state = [self GetGlobalState];
    StoryCacheData* story = state.currentReadingStory;
    if (m_isNeedReloadSpeakSetting) {
        NSLog(@"読み上げ設定を読み直します。");
        [self ReloadSpeechSetting];
        // 読み直された読み上げ設定で発音情報を再定義させます。
        if (story != nil) {
            NSLog(@"発音情報を更新します。");
            [self SetSpeechStory:story];
        }
        m_isNeedReloadSpeakSetting = false;
    }

    AVAudioSession* session = [AVAudioSession sharedInstance];
    NSError* err = nil;
    //NSLog(@"setActive YES.");
    [session setActive:YES error:&err];
    if (err != nil) {
        NSLog(@"setActive error: %@ %@", err, err.userInfo);
    }
    if ([self IsDummySilentSoundEnabled]) {
        //[self AddLogString:@"無音音声の再生を開始します。"];
        [dummySoundLooper startPlay];
    }
    
    if (story != nil) {
        [self UpdatePlayingInfo:story];
    }
    if (withMaxSpeechTimeReset) {
        [self StartMaxSpeechTimeInSecTimer];
    }
    [BehaviorLogger AddLogWithDescription:@"StartSpeech" data:@{}];
    return [m_NiftySpeaker StartSpeech];
}

/// 読み上げを「バックグラウンド再生としては止めずに」読み上げ部分だけ停止します
- (BOOL)StopSpeechWithoutDiactivate
{
    // ここで読み上げ停止タイマーを停止しちゃうと次のページに移った時とかに呼ばれた読み上げ停止に引っかかってしまうので、読み上げ停止タイマーはここでは触りません
    // 読み上げ停止タイマーは、「連続読み上げ時間」のタイマーなので、読み上げ開始時にタイマーをリセットするだけでいいはずです
    //[self StopMaxSpeechTimeInSecTimer];
    if([m_NiftySpeaker StopSpeech] == false)
    {
        return false;
    }
    return true;
}

/// 現在の読み上げ位置で GlobalState を更新して保存します
- (BOOL)SaveCurrentReadingPoint
{
    GlobalStateCacheData* globalState = [self GetGlobalState];
    if (globalState == nil || globalState.currentReadingStory == nil) {
        return false;
    }
    NarouContentCacheData* content = [self SearchNarouContentFromNcode:globalState.currentReadingStory.ncode];
    if (content == nil) {
        return false;
    }
    NSRange currentReadingPoint = [m_NiftySpeaker GetCurrentReadingPoint];
    NSUInteger storyLength = [globalState.currentReadingStory.content length];
    NSUInteger readingPointLocation = currentReadingPoint.location;
    if(storyLength <= readingPointLocation) {
        return false;
    }
    globalState.currentReadingStory.readLocation = [[NSNumber alloc] initWithUnsignedLong:readingPointLocation];
    //NSLog(@"save readLocation: %lu", (unsigned long)readingPointLocation);
    return [self UpdateReadingPoint:content story:globalState.currentReadingStory];
}

/// 現在の読み上げ位置を少し戻します(ページの最初以上には戻しません)
- (void)RewindCurrentReadingPoint:(NSUInteger)count
{
    GlobalStateCacheData* globalState = [self GetGlobalState];
    if (globalState == nil || globalState.currentReadingStory == nil || globalState.currentReadingStory.content == nil) {
        return;
    }

    NSRange currentReadingPoint = [m_NiftySpeaker GetCurrentReadingPoint];
    
    long pos = currentReadingPoint.location;
    pos -= count;
    if(pos < 0) {
        pos = 0;
    }
    //NSLog(@"update currentReadingPoint: %lu -> %ld", (unsigned long)currentReadingPoint.location, pos);
    currentReadingPoint.location = pos;
    [m_NiftySpeaker UpdateCurrentReadingPoint:currentReadingPoint];
}

/// 読み上げを停止します。
- (BOOL)StopSpeech
{
    AVAudioSession* session = [AVAudioSession sharedInstance];
    bool result = [self StopSpeechWithoutDiactivate];
    [self StopMaxSpeechTimeInSecTimer];
    [self SaveCurrentReadingPoint];
    //NSLog(@"setActive NO.");
    [session setActive:NO error:nil];
    if ([self IsDummySilentSoundEnabled]) {
        //[self AddLogString:@"無音音声の再生を停止します。"];
        [dummySoundLooper stopPlay];
    }
    return result;
}

/// 読み上げ時のイベントハンドラを追加します。
- (BOOL)AddSpeakRangeDelegate:(id<SpeakRangeDelegate>)delegate
{
    //NSLog(@"AddSpeakRangeDelegate");
    return [m_NiftySpeaker AddSpeakRangeDelegate:delegate];
}

/// 読み上げ時のイベントハンドラを削除します。
- (void)DeleteSpeakRangeDelegate:(id<SpeakRangeDelegate>)delegate
{
    //NSLog(@"delete speak range delegate.");
    return [m_NiftySpeaker DeleteSpeakRangeDelegate:delegate];
}

/// 読み上げ中か否かを取得します
- (BOOL)isSpeaking
{
    return [m_NiftySpeaker isSpeaking];
}


/// 保存されているコンテンツの再読み込みを開始します。
- (BOOL)ReloadBookShelfContents
{
    return true;
}

- (void)saveContext
{
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        [self->m_CoreDataObjectHolder save];
    //});
    }];
    NSLog(@"CoreData saved.");
}

/// 読み上げの会話文の音程設定を全て読み出します。
/// NSArray の中身は SpeakPitchConfigCacheData で、title でsortされた値が取得されます。
- (NSArray*)GetAllSpeakPitchConfig
{
    __block NSMutableArray* fetchResults = nil;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        NSArray* results = [self->m_CoreDataObjectHolder FetchAllEntity:@"SpeakPitchConfig" sortAttributeName:@"title" ascending:NO];
        fetchResults = [[NSMutableArray alloc] initWithCapacity:[results count]];
        for (int i = 0; i < [results count]; i++) {
            fetchResults[i] = [[SpeakPitchConfigCacheData alloc] initWithCoreData:results[i]];
        }
    //});
    }];
    return fetchResults;
}

/// 読み上げの会話文の音程設定をタイトル指定で読み出します。(内部版)
- (SpeakPitchConfig*)GetSpeakPitchConfigWithTitleThreadUnsafe:(NSString*)title
{
    NSArray* fetchResults = [m_CoreDataObjectHolder SearchEntity:@"SpeakPitchConfig" predicate:[NSPredicate predicateWithFormat:@"title == %@", title]];
    
    if(fetchResults == nil)
    {
        NSLog(@"fetch from CoreData failed.");
        return nil;
    }
    if([fetchResults count] == 0)
    {
        // 何もなかった。
        return nil;
    }
    if([fetchResults count] != 1)
    {
        NSLog(@"duplicate title!!! %@", title);
        return nil;
    }
    return fetchResults[0];
}

/// 読み上げの会話文の音程設定をタイトル指定で読み出します。
- (SpeakPitchConfigCacheData*)GetSpeakPitchConfigWithTitle:(NSString*)title
{
    __block SpeakPitchConfigCacheData* result = nil;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        SpeakPitchConfig* coreDataConfig = [self GetSpeakPitchConfigWithTitleThreadUnsafe:title];
        if (coreDataConfig != nil) {
            result = [[SpeakPitchConfigCacheData alloc] initWithCoreData:coreDataConfig];
        }
    //});
    }];
    return result;
}

/// 読み上げの会話文の音程設定を追加します。
- (SpeakPitchConfig*) CreateNewSpeakPitchConfigThreadUnsafe:(SpeakPitchConfigCacheData*)data
{
    SpeakPitchConfig* config = [m_CoreDataObjectHolder CreateNewEntity:@"SpeakPitchConfig"];
    if (config == nil) {
        return nil;
    }
    [data AssignToCoreData:config];
    [m_CoreDataObjectHolder save];
    return config;
}

/// 読み上げの会話文の音程設定を更新します。
- (BOOL)UpdateSpeakPitchConfig:(SpeakPitchConfigCacheData*)config
{
    if (config == nil) {
        return false;
    }
    __block BOOL result = false;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        SpeakPitchConfig* coreDataConfig = [self GetSpeakPitchConfigWithTitleThreadUnsafe:config.title];
        if (coreDataConfig == nil) {
            coreDataConfig = [self CreateNewSpeakPitchConfigThreadUnsafe:config];
        }
        if (coreDataConfig != nil) {
            result = [config AssignToCoreData:coreDataConfig];
            [self->m_CoreDataObjectHolder save];
        }
    //});
    }];
    if (result) {
        //NSLog(@"isNeedReloadSpeakSetting = true (pitch)");
        m_isNeedReloadSpeakSetting = true;
    }
    return result;
}

/// 読み上げの会話文の音声設定を削除します。
- (BOOL)DeleteSpeakPitchConfig:(SpeakPitchConfigCacheData*)config
{
    __block BOOL result = false;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        SpeakPitchConfig* coreDataConfig = [self GetSpeakPitchConfigWithTitleThreadUnsafe:config.title];
        if (coreDataConfig == nil) {
            result = false;
        }else{
            [self->m_CoreDataObjectHolder DeleteEntity:coreDataConfig];
            [self->m_CoreDataObjectHolder save];
            result = true;
        }
    //});
    }];
    if (result) {
        m_isNeedReloadSpeakSetting = true;
    }
    return result;
}


/// 読み上げ時の読み替え設定を全て読み出します。
/// NSArray の中身は SpeechModSettingCacheData で、beforeString で sort された値が取得されます。
- (NSArray*)GetAllSpeechModSettings
{
    __block NSMutableArray* fetchResults = nil;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        NSArray* results = [self->m_CoreDataObjectHolder FetchAllEntity:@"SpeechModSetting" sortAttributeName:@"beforeString" ascending:NO];
        fetchResults = [[NSMutableArray alloc] initWithCapacity:[results count]];
        for (int i = 0; i < [results count]; i++) {
            fetchResults[i] = [[SpeechModSettingCacheData alloc] initWithCoreData:results[i]];
        }
    //});
    }];
    return fetchResults;
}

/// 読み上げ時の読み替え設定を beforeString指定 で読み出します(内部版)
- (SpeechModSetting*)GetSpeechModSettingWithBeforeStringThreadUnsafe:(NSString*)beforeString
{
    NSArray* fetchResults = [m_CoreDataObjectHolder SearchEntity:@"SpeechModSetting" predicate:[NSPredicate predicateWithFormat:@"beforeString == %@", beforeString]];
    if(fetchResults == nil)
    {
        NSLog(@"fetch from CoreData failed.");
        return nil;
    }
    if([fetchResults count] == 0)
    {
        // 何もなかった。
        return nil;
    }
    if([fetchResults count] != 1)
    {
        NSLog(@"duplicate beforeString!!! %@", beforeString);
        return nil;
    }
    return fetchResults[0];
}

/// 読み上げ時の読み替え設定を beforeString指定 で読み出します
- (SpeechModSettingCacheData*)GetSpeechModSettingWithBeforeString:(NSString*)beforeString
{
    __block SpeechModSettingCacheData* result = nil;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        SpeechModSetting* coreDataSetting = [self GetSpeechModSettingWithBeforeStringThreadUnsafe:beforeString];
        if (coreDataSetting != nil) {
            result = [[SpeechModSettingCacheData alloc] initWithCoreData:coreDataSetting];
        }
    //});
    }];
    return result;
}

/// 読み上げ時の読み替え設定を追加します。
- (SpeechModSetting*) CreateNewSpeechModSettingThreadUnsafe:(SpeechModSettingCacheData*)data
{
    SpeechModSetting* setting = [m_CoreDataObjectHolder CreateNewEntity:@"SpeechModSetting"];
    [data AssignToCoreData:setting];
    [m_CoreDataObjectHolder save];
    return setting;
}

/// 読み上げ時の読み替え設定をリストで受け取り、上書き更新します。
- (BOOL)UpdateSpeechModSettingMultiple:(NSArray*)modSettingArray {
    if (modSettingArray == nil) {
        return false;
    }
    __block BOOL result = true;
    [self coreDataPerfomBlockAndWait:^{
        for (SpeechModSettingCacheData* modSetting in modSettingArray) {
            SpeechModSetting* coreDataConfig = [self GetSpeechModSettingWithBeforeStringThreadUnsafe:[modSetting GetBeforeStringForCoreDataSearch]];
            if (coreDataConfig == nil) {
                coreDataConfig = [self CreateNewSpeechModSettingThreadUnsafe:modSetting];
            }
            if (coreDataConfig != nil) {
                if (![modSetting AssignToCoreData:coreDataConfig]) {
                    result = false;
                }
            }
        }
        [self->m_CoreDataObjectHolder save];
    }];
    if (result) {
        m_isNeedReloadSpeakSetting = true;
    }
    return result;
}

/// 読み上げ時の読み替え設定を更新します。無ければ新しく登録されます。
- (BOOL)UpdateSpeechModSetting:(SpeechModSettingCacheData*)modSetting
{
    if (modSetting == nil) {
        return false;
    }
    __block BOOL result = false;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        SpeechModSetting* coreDataConfig = [self GetSpeechModSettingWithBeforeStringThreadUnsafe:[modSetting GetBeforeStringForCoreDataSearch]];
        if (coreDataConfig == nil) {
            coreDataConfig = [self CreateNewSpeechModSettingThreadUnsafe:modSetting];
        }
        if (coreDataConfig != nil) {
            result = [modSetting AssignToCoreData:coreDataConfig];
            [self->m_CoreDataObjectHolder save];
        }
    //});
    }];
    if (result) {
        //NSLog(@"isNeedReloadSpeakSetting = true (speechMod)");
        m_isNeedReloadSpeakSetting = true;
    }
    return result;
}

/// 読み上げ時の読み替え設定を削除します。
- (BOOL)DeleteSpeechModSetting:(SpeechModSettingCacheData*)modSetting
{
    __block BOOL result = false;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        SpeechModSetting* coreDataConfig = [self GetSpeechModSettingWithBeforeStringThreadUnsafe:[modSetting GetBeforeStringForCoreDataSearch]];
        if (coreDataConfig == nil) {
            result = false;
        }else{
            [self->m_CoreDataObjectHolder DeleteEntity:coreDataConfig];
            [self->m_CoreDataObjectHolder save];
            result = true;
        }
    //});
    }];
    if (result) {
        m_isNeedReloadSpeakSetting = true;
    }
    return result;
}

/// 読み上げ時の「間」の設定を targetText指定 で読み出します(内部版)
- (SpeechWaitConfig*)GetSpeechWaitSettingWithTargetTextThreadUnsafe:(NSString*)targetText
{
    NSArray* fetchResults = [m_CoreDataObjectHolder SearchEntity:@"SpeechWaitConfig" predicate:[NSPredicate predicateWithFormat:@"targetText == %@", targetText]];
    if(fetchResults == nil)
    {
        NSLog(@"fetch from CoreData failed.");
        return nil;
    }
    if([fetchResults count] == 0)
    {
        // 何もなかった。
        return nil;
    }
    if([fetchResults count] != 1)
    {
        NSLog(@"duplicate SpeechWaitConfig.targetText!!! %@", targetText);
        return nil;
    }
    return fetchResults[0];
}

/// 読み上げ時の「間」の設定を追加します。(内部版)
- (SpeechWaitConfig*) CreateNewSpeechWaitConfigThreadUnsafe:(SpeechWaitConfigCacheData*)data
{
    SpeechWaitConfig* config = [m_CoreDataObjectHolder CreateNewEntity:@"SpeechWaitConfig"];
    [data AssignToCoreData:config];
    [m_CoreDataObjectHolder save];
    return config;
}

/// 読み上げ時の「間」の設定を全て読み出します。
- (NSArray*)GetAllSpeechWaitConfig
{
    __block NSMutableArray* fetchResults = nil;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        NSArray* results = [self->m_CoreDataObjectHolder FetchAllEntity:@"SpeechWaitConfig" sortAttributeName:@"targetText" ascending:YES];
        fetchResults = [[NSMutableArray alloc] initWithCapacity:[results count]];
        for (int i = 0; i < [results count]; i++) {
            fetchResults[i] = [[SpeechWaitConfigCacheData alloc] initWithCoreData:results[i]];
        }
    //});
    }];
    return fetchResults;
}

/// 読み上げ時の「間」の設定を追加します。
/// 既に同じ key (targetText) のものがあれば上書きになります。
- (BOOL)AddSpeechWaitSetting:(SpeechWaitConfigCacheData*)waitConfigCacheData
{
    __block BOOL result = false;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        SpeechWaitConfig* coreDataConfig = [self GetSpeechWaitSettingWithTargetTextThreadUnsafe:waitConfigCacheData.targetText];
        if (coreDataConfig == nil) {
            [self CreateNewSpeechWaitConfigThreadUnsafe:waitConfigCacheData];
            result = true;
        }else{
            // float で == の比較がどれだけ意味があるのかわからんけれど、多分 0.0f には効くんじゃないかなぁ……
            if (coreDataConfig.delayTimeInSec != waitConfigCacheData.delayTimeInSec) {
                coreDataConfig.delayTimeInSec = waitConfigCacheData.delayTimeInSec;
                [self->m_CoreDataObjectHolder save];
                result = true;
            }
        }
    //});
    }];
    if (result) {
        m_isNeedReloadSpeakSetting = true;
    }
    return result;
    
}

/// 読み上げ時の「間」の設定を削除します。
- (BOOL)DeleteSpeechWaitSetting:(NSString*)targetString
{
    __block BOOL result = false;
    [self coreDataPerfomBlockAndWait:^{
    //dispatch_sync(m_CoreDataAccessQueue, ^{
        SpeechWaitConfig* coreDataConfig = [self GetSpeechWaitSettingWithTargetTextThreadUnsafe:targetString];
        if (coreDataConfig == nil) {
            result = false;
        }else{
            [self->m_CoreDataObjectHolder DeleteEntity:coreDataConfig];
            [self->m_CoreDataObjectHolder save];
            result = true;
        }
    //});
    }];
    if (result) {
        m_isNeedReloadSpeakSetting = true;
    }
    return result;
}


/// CoreData のマイグレーションが必要かどうかを確認します。
- (BOOL)isRequiredCoreDataMigration
{
    return [m_CoreDataObjectHolder isNeedMigration];
}

/// CoreData のマイグレーションを実行します。
- (void)doCoreDataMigration
{
    [m_CoreDataObjectHolder doMigration];
}

/// CoreData のデータファイルが存在するかどうかを取得します
- (BOOL)isAliveCoreDataSaveFile
{
    //NSLog(@"isAliveCoreDataSaveFile");
    return [m_CoreDataObjectHolder isAliveSaveDataFile];
}

- (BOOL)isAliveOLDSaveDataFile{
    //NSLog(@"isAliveOLDSaveDataFile");
    return [m_CoreDataObjectHolder isAliveOLDSaveDataFile];
}

- (BOOL)moveOLDSaveDataFileToNewLocation{
    //NSLog(@"moveOLDSaveDataFileToNewLocation");
    return [m_CoreDataObjectHolder moveOLDSaveDataFileToNewLocation];
}

/// フォントサイズ値を実際のフォントのサイズに変換します。
/// 1 〜 100 までの float で、50 だと 14(default値)、1 だと 1、100 だと200 位になるような曲線でフォントサイズを計算します。
+ (double)ConvertFontSizeValueToFontSize:(float)value
{
    if (value < 1.0f) {
        value = 50.0f;
    }else if(value > 100.0f){
        value = 100.0f;
    }
    double num = pow(1.05, value);
    num += 1.0f;
    return num;
}

/// 指定された文字列を読み上げでアナウンスします。
/// ただし、読み上げを行っていない場合に限ります。
/// 読み上げを行った場合には true を返します。
- (BOOL)AnnounceBySpeech:(NSString*)speechString
{
    // m_NiftySpeaker を使ってしまうと読み上げ位置更新イベントが伝達されてしまうため、新たに Speaker Object を生成してそちらで鳴らします。
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        Speaker* speaker = [Speaker new];
        SpeechConfig* config = [self->m_NiftySpeaker GetDefaultSpeechConfig];
        [speaker SetPitch:config.pitch];
        [speaker SetRate:config.rate];
        [speaker SetVoiceWithIdentifier:config.voiceIdentifier];
        [speaker Speech:speechString];
    });
    return true;
}

/// 最初のページを表示したかどうかのbool値を取得します。
- (BOOL)IsFirstPageShowed
{
    return m_bIsFirstPageShowed;
}

/// 最初のページを表示した事を設定します。
- (void)SetFirstPageShowed
{
    m_bIsFirstPageShowed = true;
}


/// URLスキームで呼び出された時の downloadncode について対応します。
/// 受け取る引数は @"ncode-ncode-ncode..." という文字列です
- (BOOL)ProcessURLScemeDownloadNcode:(NSString*)targetListString
{
    if (targetListString == nil) {
        return false;
    }
    return [m_DownloadQueue AddDownloadQueueForNcodeList:targetListString];
}

/// URLで呼び出された時の反応をします。
- (BOOL)ProcessURL:(NSURL*)url{
    NSString* scheme = [url scheme];
    if ([scheme isEqualToString:@"novelspeaker"]){
        return [self ProcessURLSceme:url];
    }
    return [self ProcessCustomFileUTI:url];
}

/// URLスキームで呼び出された時の反応をします。
/// 反応する URL は、
/// novelspeaker://downloadncode/ncode-ncode-ncode...
/// と
/// novelspeaker://downloadurl/https?://...
/// です。
- (BOOL)ProcessURLSceme:(NSURL*)url
{
    if (url == nil) {
        return false;
    }
    NSString* scheme = [url scheme];
    NSString* controller = [url host];
    if ([scheme isEqualToString:@"novelspeaker"]
        || [scheme isEqualToString:@"limuraproducts.novelspeaker"]) {
        if ([controller isEqualToString:@"downloadncode"]) {
            NSString* ncodeListString = [url lastPathComponent];
            return [self ProcessURLScemeDownloadNcode:ncodeListString];
        }else if ([controller isEqualToString:@"downloadurl"]) {
            NSString* path = [url path];
            if (path == nil || [path length] <= 1) {
                return false;
            }
            // "novelspeaker://downloadurl/" までを読み飛ばしたものがURL
            NSUInteger prefixLength = [@"novelspeaker://downloadurl/" length];
            NSString* allUrlString = [url absoluteString];
            if ([allUrlString length] <= prefixLength) {
                NSLog(@"prefix too short: %@", allUrlString);
                return false;
            }
            NSString* urlString = [allUrlString substringFromIndex:prefixLength];
            NSURL* targetURL = nil;
            NSRange range = [urlString rangeOfString:@"#"];
            if (range.location != NSNotFound) {
                NSString* tmpURLString = [urlString substringToIndex:range.location];
                targetURL = [NSURL URLWithString:[tmpURLString stringByRemovingPercentEncoding]];
            }else{
                targetURL = [NSURL URLWithString:[urlString stringByRemovingPercentEncoding]];
            }
            NSString* scheme = [targetURL scheme];
            if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
                return [self AddDownloadQueueForURLString:urlString] == nil;
            }
        }
    }
    return false;
}

// log用
- (NSString*)GetLogString
{
    NSMutableString* string = [[NSMutableString alloc] init];
    for (NSString* str in m_LogStringArray) {
        [string appendFormat:@"%@\r\n", str];
    }
    return string;
}
- (void)AddLogString:(NSString*)string
{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH:mm:ss"];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    NSString* logString = [[NSString alloc] initWithFormat:@"%@ %@", [formatter stringFromDate:date], string];
    NSLog(@"%p, %@", m_LogStringArray, logString);
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_LogStringArray addObject:logString];
        while ([m_LogStringArray count] > 1024) {
            [m_LogStringArray removeObjectAtIndex:0];
        }
    });
}
- (void)ClearLogString{
    m_LogStringArray = [NSMutableArray new];
}
- (NSArray*)GetLogStringArray{
    return m_LogStringArray;
}

#define USER_DEFAULTS_PREVIOUS_TIME_VERSION @"PreviousTimeVersion"
#define USER_DEFAULTS_PREVIOUS_TIME_BUILD   @"PreviousTimeBuild"
#define USER_DEFAULTS_DEFAULT_VOICE_IDENTIFIER @"DefaultVoiceIdentifier"
#define USER_DEFAULTS_BOOKSELF_SORT_TYPE @"BookSelfSortType"
#define USER_DEFAULTS_BACKGROUND_FETCHED_NOVEL_ID_LIST @"BackgroundFetchedNovelIDList"
#define USER_DEFAULTS_BACKGROUND_NOVEL_FETCH_MODE @"BackgroundNovelFetchMode"
#define USER_DEFAULTS_AUTOPAGERIZE_SITEINFO_CACHE_SAVED_DATE @"AutoPagerizeSiteInfoCacheSavedDate"
#define USER_DEFAULTS_CUSTOM_AUTOPAGERIZE_SITEINFO_CACHE_SAVED_DATE @"CustomAutoPagerizeSiteInfoCacheSavedDate"
#define USER_DEFAULTES_MENU_ITEM_IS_ADD_SPEECH_MOD_SETTINGS_ONLY @"MenuItemIsAddSpeechModSettingOnly"
#define USER_DEFAULTS_OVERRIDE_RUBY_IS_ENABLED @"OverrideRubyIsEnabled"
#define USER_DEFAULTS_NOT_RUBY_CHARACTOR_STRING_ARRAY @"NotRubyCharactorStringArray"
#define USER_DEFAULTS_FORCE_SITEINFO_RELOAD_IS_ENABLED @"ForceSiteInfoReloadIsEnabled"
#define USER_DEFAULTS_READING_PROGRESS_DISPLAY_IS_ENABLED @"ReadingProgressDisplayIsEnabled"
#define USER_DEFAULTS_DISPLAY_FONT_NAME @"DisplayFontName"
#define USER_DEFAULTS_SHORT_SKIP_IS_ENABLED @"ShortSkipIsEnabled"
#define USER_DEFAULTS_PLAYBACK_DURATION_IS_ENABLED @"PlaybackDurationIsEnabled"
#define USER_DEFAULTS_DARK_THEME_IS_ENABLED @"DarkThemeIsEnabled"
#define USER_DEFAULTS_PAGE_TURNING_SOUND_IS_ENABLED @"PageTurningSoundIsEnabled"
#define USER_DEFAULTS_IGNORE_URI_SPEECH_IS_ENABLED @"IgnoreURISpeechIsEnabled"
#define USER_DEFAULTS_WEB_IMPORT_BOOKMARK_ARRAY @"WebImportBookmarkArray"
#define USER_DEFAULTS_IS_LICENSE_FILE_READED @"IsLICENSEFileIsReaded"
#define USER_DEFAULTS_CURRENT_READED_PRIVACY_POLICY @"CurrentReadedPrivacyPolicy"
#define USER_DEFAULTS_REPEAT_SPEECH_TYPE @"RepeatSpeechType"
#define USER_DEFAULTS_IS_ESCAPE_ABOUT_SPEECH_POSITION_DISPLAY_BUG_ON_IOS12 @"IsEscapeAboutSpeechPositionDisplayBugOniOS12_New01"
#define USER_DEFAULTS_IS_DUMMY_SILENT_SOUND_ENABLED @"DummySilentSoundEnabled"
#define USER_DEFAULTS_IS_MIX_WITH_OTHERS_ENABLED @"MixWithOthersEnabled"
#define USER_DEFAULTS_IS_DUCK_OTHERS_ENABLED @"DuckOthersEnabled"
#define USER_DEFAULTS_IS_OPEN_RECENT_NOVEL_IN_START_TIME @"IsOpenRecentNovelInStartTime"
#define USER_DEFAULTS_IS_DISALLOW_CELLULAR_ACCESS @"IsDisallowCellarAccess"
#define USER_DEFAULTS_IS_NEED_CONFIRM_DELETE_BOOK @"IsNeedConfirmDeleteBook"
#define USER_DEFAULTS_READING_COLOR_SETTING_FOR_BACKGROUND_COLOR @"ReadingColorSettingForBackgroundColor"
#define USER_DEFAULTS_READING_COLOR_SETTING_FOR_FOREGROUND_COLOR @"ReadingColorSettingForForegroundColor"

/// 前回実行時とくらべてビルド番号が変わっているか否かを取得します
- (BOOL)IsVersionUped
{
    // NSUserDefaults を使います
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* version = [userDefaults stringForKey:USER_DEFAULTS_PREVIOUS_TIME_VERSION];
    NSString* build = [userDefaults stringForKey:USER_DEFAULTS_PREVIOUS_TIME_BUILD];
    NSString* versionBuild = @"unknown";
    if (version != nil && build != nil) {
        versionBuild = [[NSString alloc] initWithFormat:@"%@-%@", version, build];
    }
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString* currentVersionBuild = [[NSString alloc]
                                     initWithFormat:@"%@-%@"
                                     , [infoDictionary objectForKey:@"CFBundleShortVersionString"]
                                     , [infoDictionary objectForKey:@"CFBundleVersion"]
                                     ];
    if ([versionBuild isEqualToString:currentVersionBuild]) {
        return NO;
    }
    return YES;
}

/// 今回起動した時のバージョン番号を保存します。
- (void)UpdateCurrentVersionSaveData
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString* build = [infoDictionary objectForKey:@"CFBundleVersion"];
    [userDefaults setObject:version forKey:USER_DEFAULTS_PREVIOUS_TIME_VERSION];
    [userDefaults setObject:build forKey:USER_DEFAULTS_PREVIOUS_TIME_BUILD];
    [userDefaults synchronize];
}

/// 新しくユーザ定義の本を追加します。ncode に "_n" で始まるユーザ定義用の code が使われ、
/// それ以外の項目は未設定のものが生成されます。
/// 生成に失敗すると nil を返します。
/// 生成しただけでまだDBには登録されていないので、内容を更新した上で UpdateNarouContent で登録してください。
- (NarouContentCacheData*)CreateNewUserBook
{
    NSString* tmpNcode = nil;
    NarouContentCacheData* content = nil;
    int n = arc4random_uniform(0x7fffffff);
    for (int i = 0; i < 1000; i++) {
        tmpNcode = [[NSString alloc] initWithFormat:@"_u%08x", n + i];
        content = [self SearchNarouContentFromNcode:tmpNcode];
        if (content == nil) {
            break;
        }
    }
    if (tmpNcode == nil || content != nil) {
        return nil;
    }
    content = [NarouContentCacheData new];
    content.title = NSLocalizedString(@"GlobalDataSingleton_NewUserBookTitle", @"新規ユーザ小説");
    content.ncode = tmpNcode;
    content.userid = @"";
    content.writer = @"";
    content.story = @"";
    content.genre = [[NSNumber alloc] initWithInt:0];
    content.keyword = @"";
    content.general_all_no = [[NSNumber alloc] initWithInt:1];
    content.end = [[NSNumber alloc] initWithBool:false];
    content.global_point = [[NSNumber alloc] initWithInt:0];
    content.fav_novel_cnt = [[NSNumber alloc] initWithInt:0];
    content.review_cnt = [[NSNumber alloc] initWithInt:0];
    content.all_point = [[NSNumber alloc] initWithInt:0];
    content.all_hyoka_cnt = [[NSNumber alloc] initWithInt:0];
    content.sasie_cnt = [[NSNumber alloc] initWithInt:0];
    content.novelupdated_at = [NSDate date];
    content.reading_chapter = [[NSNumber alloc] initWithInt:1];
    content.is_new_flug = [[NSNumber alloc] initWithBool:false];
    
    content.currentReadingStory = nil;
    
    return content;
}

/// 新しくユーザ定義の本を追加します。基本的には CreateNewUserBook と同じですが、NarouContent は保存され、さらに空の章を追加されている所が違います。
- (NarouContentCacheData*)CreateNewUserBookWithSaved{
    NarouContentCacheData* content = [self CreateNewUserBook];
    
    [self UpdateNarouContent:content];
    [self UpdateStory:@"" chapter_number:1 parentContent:content];
    
    return content;
}


/// NarouContentCacheData の中から、ncode(小説家になろうのncode)のものだけを取り出して、その ncode を ncode-ncode-ncode... の形式の文字列にして返します。
- (NSString*)createNcodeListString:(NSArray*)contentArray {
    NSMutableString* result = [NSMutableString new];
    for (NarouContentCacheData* content in contentArray) {
        if ([content isURLContent] || [content isUserCreatedContent]) {
            continue;
        }
        if ([result length] > 0) {
            [result appendString:@"-"];
        }
        [result appendString:content.ncode];
    }
    return result;
}

/// 全てのコンテンツを再度ダウンロードしようとします。
- (void)ReDownloadAllContents{
    NSArray* contentList = [self GetAllNarouContent:NarouContentSortType_NovelUpdatedAt];
    if (contentList == nil) {
        return;
    }
    NSString* ncodeListString = [self createNcodeListString:contentList];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* searchResult = [NarouLoader SearchNcode:ncodeListString];
        for (NarouContentCacheData* content in contentList) {
            BOOL needSkip = false;
            for (NarouContentCacheData* searchContent in searchResult) {
                if ([searchContent.ncode compare:content.ncode] == NSOrderedSame
                    && [searchContent.general_all_no isEqualToNumber:content.general_all_no]) {
                    needSkip = true;
                    break;
                }
            }
            if (needSkip) {
                continue;
            }
            [self PushContentDownloadQueue:content];
        }
    });
}

/// 現在の Download queue を全て削除します
- (void)ClearDownloadQueue{
    NSArray* contentList = [self GetAllNarouContent:NarouContentSortType_NovelUpdatedAt];
    if (contentList == nil) {
        return;
    }
    for (NarouContentCacheData* content in contentList) {
        if (content != nil && content.ncode != nil && [content.ncode length] > 0) {
            [self DeleteDownloadQueue:content.ncode];
        }
    }
}


/// 現在の新規ダウンロード数をクリアします
- (void)ClearNewDownloadCount{
    [m_DownloadQueue ClearNewDownloadCount];
}

/// 現在の新規ダウンロード数を取得します
- (int)GetNewDownloadCount{
    return [m_DownloadQueue GetNewDownloadCount];
}

/// 現在の新規ダウンロード小説名のリストをクリアします
- (void)ClearNewDownloadNovelNameArray {
    [m_DownloadQueue ClearNewDownloadNovelNameArray];
}

/// 現在の新規ダウンロード小説名のリストを取得します
- (NSArray*)GetNewDownloadNovelNameArray {
    return [m_DownloadQueue GetNewDownloadNovelNameArray];
}

/// BackgroundFetch でダウンロードを行った(過去形)ncode(やURL)のリストを取得します
- (NSArray*) GetAlreadyFetchedNovelIDList{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray* backgroundFetchedNovelIDList = [userDefaults arrayForKey:USER_DEFAULTS_BACKGROUND_FETCHED_NOVEL_ID_LIST];
    return backgroundFetchedNovelIDList;
}

/// BackgroundFetch でダウンロードを行った(過去形)ncode(やURL)のリストに新しいIDを追加します
- (void)AddAlreadyFetchedNovelID:(NSString*)novelID {
    NSArray* backgroundFetchedNovelIDList = [self GetAlreadyFetchedNovelIDList];
    NSMutableArray* newArray = [[NSMutableArray alloc] initWithArray:backgroundFetchedNovelIDList];
    [newArray addObject:novelID];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:newArray forKey:USER_DEFAULTS_BACKGROUND_FETCHED_NOVEL_ID_LIST];
    [userDefaults synchronize];
}

/// BackgroundFetch でダウンロードを行ったNovelIDのリストを消します
- (void)ClearAlreadyFetchedNovelIDList{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:USER_DEFAULTS_BACKGROUND_FETCHED_NOVEL_ID_LIST];
    [userDefaults synchronize];
}

// Background fetch イベントを処理します
- (void)HandleBackgroundFetch:(UIApplication *)application
performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler{
    // 30秒以内に終了しないと怒られるので時間を測ります
    NSDate* startTime = [NSDate date];

    // 既に download queue が走っていれば何もしません
    NSArray* downloadInfo = [self GetCurrentDownloadWaitingInfo];
    NarouContentCacheData* nowDownloadContent = [self GetCurrentDownloadingInfo];
    if ([downloadInfo count] > 0 || nowDownloadContent != nil) {
        if (completionHandler != nil) {
            completionHandler(UIBackgroundFetchResultNoData);
        }
        return;
    }

    // UI起動中であれば特に何もしません
    UIApplicationState applicationState =  [application applicationState];
    NSLog(@"START: applicationState: %@", applicationState == UIApplicationStateInactive ? @"Inactive"
          : applicationState == UIApplicationStateBackground ? @"Background"
          : applicationState == UIApplicationStateActive ? @"Active"
          : @"Unknown");
    if (applicationState == UIApplicationStateActive) {
        if (completionHandler != nil) {
            completionHandler(UIBackgroundFetchResultNoData);
        }
        return;
    }
    // background で再生中であっても何もしません
    if (applicationState == UIApplicationStateBackground && [self isSpeaking]) {
        if (completionHandler != nil) {
            completionHandler(UIBackgroundFetchResultNoData);
        }
        return;
    }
    
    // BackgroundFetchで既にトライしたダウンロード先を排除したダウンロードリストを作ります。
    NSArray* alreadyFetchedNovelIDArray = [self GetAlreadyFetchedNovelIDList];
    NSArray* contentArray = [self GetAllNarouContent:NarouContentSortType_Ncode];
    NSMutableArray* downloadTargetNovelIDArray = [NSMutableArray new];
    for (NarouContentCacheData* content in contentArray) {
        if ([content isUserCreatedContent] && (![content isURLContent])) {
            continue;
        }
        BOOL hit = false;
        for (NSString* novelID in alreadyFetchedNovelIDArray) {
            // TODO: 外部URLであったら ncode と比べても意味が無い
            if ([content.ncode compare:novelID] == NSOrderedSame) {
                hit = true;
                break;
            }
        }
        if (!hit) {
            // TODO: 外部URLであったら ncode を追加しても意味がない
            [downloadTargetNovelIDArray addObject:content.ncode];
        }
    }
    // ダウンロード先が無い場合はダウンロード済みリストをクリアして、何もなかったと報告して終わります。
    if ([downloadTargetNovelIDArray count] <= 0) {
        [self ClearAlreadyFetchedNovelIDList];
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    
    // ダウンロードが行われた数をクリアしておきます
    [self ClearNewDownloadCount];
    [self ClearNewDownloadNovelNameArray];

    // ダウンロードqueueに追加します。
    for (NSString* novelID in downloadTargetNovelIDArray) {
        // ncode 以外のものでも novelID でqueueに入れます
        NarouContentCacheData* content = [self SearchNarouContentFromNcode:novelID];
        [self PushContentDownloadQueue:content];
        NSLog(@"Background Fetch: add download queue: %@", content.ncode);
    }

    // 30秒以内に終わるようにダウンロードの終了を待ちます
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    while (TRUE) {
        NSArray* downloadInfo = [self GetCurrentDownloadWaitingInfo];
        NarouContentCacheData* content = [self GetCurrentDownloadingInfo];
        if ([downloadInfo count] <= 0 && content == nil) {
            NSLog(@"Background Fetch: [downloadInfo count] <= 0 && content == nil. break. (%lu, %p)", (unsigned long)[downloadInfo count], content);
            break;
        }
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        NSTimeInterval interval = [startTime timeIntervalSinceNow];
        if (interval < -28.0) {
            // 30秒以上かかりそうならやめます
            NSLog(@"Background Fetch: interval < -28.0 break.");
            break;
        }
        if ([self isSpeaking]) {
            NSLog(@"Background Fetch: [self isSpeaking] break.");
            break;
        }
    }
    
    // 残っているダウンロードqueueを削除します
    {
        NSArray* downloadQueueArray = [self GetCurrentDownloadWaitingInfo];
        NarouContentCacheData* downloadingContent = [self GetCurrentDownloadingInfo];
        
        NSMutableArray* notDownloadNovelIDArray = [NSMutableArray new];
        if (downloadingContent != nil && downloadingContent.ncode != nil) {
            [notDownloadNovelIDArray addObject:downloadingContent.ncode];
        }
        for (NarouContentCacheData* content in downloadQueueArray) {
            if (content != nil && content.ncode != nil) {
                [notDownloadNovelIDArray addObject:content.ncode];
            }
        }
        for (NSString* novelID in downloadTargetNovelIDArray) {
            BOOL hit = false;
            for (NSString* notDownloadNovelID in notDownloadNovelIDArray) {
                if ([novelID compare:notDownloadNovelID] == NSOrderedSame) {
                    hit = true;
                }
            }
            if (!hit) {
                [self AddAlreadyFetchedNovelID:novelID];
            }
            [self DeleteDownloadQueue:novelID];
        }
    }

    int downloadCount = [self GetNewDownloadCount];
    NSLog(@"Background Fetch DONE: downloadCount: %d", downloadCount);
    if (downloadCount > 0) {
        NSInteger appendCount = [self GetBackgroundFetchedNovelCount];
        application.applicationIconBadgeNumber = downloadCount + appendCount;
        
        NSArray* updateNovelNameArray = [self GetNewDownloadNovelNameArray];
        [NiftyUtility InvokeNotificationNow:[[NSString alloc] initWithFormat:NSLocalizedString(@"GlobalDataSingleton_NovelUpdateAlertBody", @"%d個の更新があります。"), downloadCount] message:[updateNovelNameArray componentsJoinedByString:@"\n"] badgeNumber:downloadCount + appendCount];
        [self UpdateBackgroundFetchedNovelCount:downloadCount + appendCount];
        NSLog(@"update alert: %@", [[NSString alloc] initWithFormat:NSLocalizedString(@"GlobalDataSingleton_NovelUpdateAlertBody", @"以下の%d個の更新があります。\n%@"), downloadCount, [updateNovelNameArray componentsJoinedByString:@", "]]);
        
        completionHandler(UIBackgroundFetchResultNewData);
    }else{
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

// 設定されている読み上げに使う音声の identifier を取得します
// XXX TODO: 本来なら core data 側でなんとかすべきです
- (NSString*)GetVoiceIdentifier {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* voiceIdentifier = [userDefaults stringForKey:USER_DEFAULTS_DEFAULT_VOICE_IDENTIFIER];
    // 未設定であれば怪しく現在利用可能な話者の中から推奨の話者を選択しておきます
    if (voiceIdentifier == nil) {
        NSArray* recomendIdArray = @[
         @"com.apple.ttsbundle.siri_female_ja-JP_premium", // O-ren premium
         @"com.apple.ttsbundle.siri_female_ja-JP_compact", // O-ren
         @"com.apple.ttsbundle.siri_male_ja-JP_compact", // hattori
         @"com.apple.ttsbundle.Otoya-premium", // otoya premium
         ];
        NSArray* voiceArray = [NiftySpeaker getSupportedSpeaker:@"ja-JP"];
        if (voiceArray != nil) {
            for (NSString* recomendId in recomendIdArray) {
                for (AVSpeechSynthesisVoice* voice in voiceArray) {
                    if ([voice.identifier compare:recomendId] == NSOrderedSame) {
                        voiceIdentifier = voice.identifier;
                        [self SetVoiceIdentifier:voiceIdentifier];
                        return voiceIdentifier;
                    }
                }
            }
        }
    }
    return voiceIdentifier;
}

// 読み上げに使う音声の identifier を保存します。
// XXX TODO: 本来なら core data 側でなんとかすべきです
- (void)SetVoiceIdentifier:(NSString*)identifier {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:identifier forKey:USER_DEFAULTS_DEFAULT_VOICE_IDENTIFIER];
    [userDefaults synchronize];
    m_isNeedReloadSpeakSetting = true;
}

- (void)DeleteVoiceIdentifier{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:USER_DEFAULTS_DEFAULT_VOICE_IDENTIFIER];
    [userDefaults synchronize];
    m_isNeedReloadSpeakSetting = true;
}

/// 本棚のソートタイプを取得します
- (NarouContentSortType)GetBookSelfSortType {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_BOOKSELF_SORT_TYPE: [[NSNumber alloc] initWithInteger: NarouContentSortType_Title]}];
    NSInteger sortTypeInteger = [userDefaults integerForKey:USER_DEFAULTS_BOOKSELF_SORT_TYPE];
    NarouContentSortType sortType = sortTypeInteger;
    return sortType;
}

/// 本棚のソートタイプを保存します
- (void)SetBookSelfSortType:(NarouContentSortType)sortType{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger integer = sortType;
    [userDefaults setInteger:integer forKey:USER_DEFAULTS_BOOKSELF_SORT_TYPE];
    [userDefaults synchronize];
}

/// 新規小説の自動ダウンロード機能のON/OFF状態を取得します
- (BOOL)GetBackgroundNovelFetchEnabled{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_BACKGROUND_NOVEL_FETCH_MODE: @false}];
    return [userDefaults boolForKey:USER_DEFAULTS_BACKGROUND_NOVEL_FETCH_MODE];
}

/// 新規小説の自動ダウンロード機能のON/OFFを切り替えます
- (void)UpdateBackgroundNovelFetchMode:(BOOL)isEnabled{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isEnabled forKey:USER_DEFAULTS_BACKGROUND_NOVEL_FETCH_MODE];
    [userDefaults synchronize];
    if (isEnabled) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self RegisterUserNotification];
            [self StartBackgroundFetch];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self StopBackgroundFetch];
        });
    }
}

/// AutoPagerize の SiteInfo を保存した日付を取得します
- (NSDate*)GetAutoPagerizeCacheSavedDate {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_AUTOPAGERIZE_SITEINFO_CACHE_SAVED_DATE: [[NSDate alloc] initWithTimeIntervalSince1970:0]}];
    return [userDefaults objectForKey:USER_DEFAULTS_AUTOPAGERIZE_SITEINFO_CACHE_SAVED_DATE];
}

/// AutoPagerize の SiteInfo を保存した日付を保存します
- (void)UpdateAutoPagerizeCacheSavedDate:(NSDate*)date {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:date forKey:USER_DEFAULTS_AUTOPAGERIZE_SITEINFO_CACHE_SAVED_DATE];
    [userDefaults synchronize];
}

/// カスタムAutoPagerize の SiteInfo を保存した日付を取得します
- (NSDate*)GetCustomAutoPagerizeCacheSavedDate {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_CUSTOM_AUTOPAGERIZE_SITEINFO_CACHE_SAVED_DATE: [[NSDate alloc] initWithTimeIntervalSince1970:0]}];
    return [userDefaults objectForKey:USER_DEFAULTS_CUSTOM_AUTOPAGERIZE_SITEINFO_CACHE_SAVED_DATE];
}

/// カスタムAutoPagerize の SiteInfo を保存した日付を保存します
- (void)UpdateCustomAutoPagerizeCacheSavedDate:(NSDate*)date {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:date forKey:USER_DEFAULTS_CUSTOM_AUTOPAGERIZE_SITEINFO_CACHE_SAVED_DATE];
    [userDefaults synchronize];
}

#define CACHE_FILE_NAME_AUTOPAGERLIZE_SITEINFO @"AutoPagerizeSiteInfo.deflate"
#define AUTOPAGERIZE_SITEINFO_URL @"http://wedata.net/databases/AutoPagerize/items.json"
#define CACHE_FILE_NAME_CUSTOM_AUTOPAGERLIZE_SITEINFO @"CustomAutoPagerizeSiteInfo.deflate"
#define CUSTOM_AUTOPAGERIZE_SITEINFO_URL @"http://wedata.net/databases/%E3%81%93%E3%81%A8%E3%81%9B%E3%81%8B%E3%81%84Web%E3%83%9A%E3%83%BC%E3%82%B8%E8%AA%AD%E3%81%BF%E8%BE%BC%E3%81%BF%E7%94%A8%E6%83%85%E5%A0%B1/items.json"

/// 内部キャッシュフォルダへのパスを取得します
- (NSString*)GetCacheFilePath:(NSString*)fileName {
    NSArray* pathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachesPath = [pathArray objectAtIndex:0];
    if (cachesPath == nil) {
        return nil;
    }
    NSString* filePath = [cachesPath stringByAppendingPathComponent:fileName];
    //[[NSString alloc] initWithFormat:@"%@/%@", cachesPath, fileName];
    return filePath;
}

/// NSData を内部キャッシュフォルダの指定されたファイル名に上書き保存します
- (void)SaveDataToCacheFile:(NSData*)data fileName:(NSString*)fileName {
    NSString* filePath = [self GetCacheFilePath:fileName];
    [data writeToFile:filePath atomically:true];
}

/// URLからダウンロードしたデータを deflate で圧縮して指定されたファイル名でキャッシュフォルダに上書き保存します
/// これはブロッキングします
- (BOOL)UpdateCachedAndZipedFileFromURL:(NSURL*)url fileName:(NSString*)fileName {
    SyncHttpSession* httpSession = [SyncHttpSession new];
    [httpSession Initialize];
    NSData* data = [httpSession GetBinaryWithUrlString:[url absoluteString]];
    if (data == nil) {
        return false;
    }
    NSData* zipedData = [data deflate:9];
    [self SaveDataToCacheFile:zipedData fileName:fileName];
    return true;
}

/// キャッシュフォルダに保存してある deflate で圧縮されたファイルの中身を解凍し、NSData とてして取り出します。
- (NSData*)GetCachedAndZipedFileData:(NSString*)fileName {
    NSString* filePath = [self GetCacheFilePath:fileName];
    NSData* dataDeflate = [NSData dataWithContentsOfFile:filePath];
    return [dataDeflate inflate];
}

/// AutoPagerize の SiteInfo を保存するファイルへのパスを取得します
- (NSString*)GetAutoPagerizeSiteInfoCacheFilePath {
    return [self GetCacheFilePath:CACHE_FILE_NAME_AUTOPAGERLIZE_SITEINFO];
}

/// AutoPagerize の SiteInfo を内部に保存します
- (void)SaveAutoPagerizeSiteInfoData:(NSData*)data {
    [self SaveDataToCacheFile:data fileName:CACHE_FILE_NAME_AUTOPAGERLIZE_SITEINFO];
}

/// 内部に保存してある AutoPagerize の SiteInfo を最新版に更新します
/// これはネットワークアクセスを行う動作になります
- (BOOL)UpdateCachedAutoPagerizeSiteInfoData {
    SyncHttpSession* httpSession = [SyncHttpSession new];
    [httpSession Initialize];
    NSData* data = [httpSession GetBinaryWithUrlString:AUTOPAGERIZE_SITEINFO_URL];
    if (data == nil) {
        return false;
    }
    NSData* zipedData = [data deflate:9];
    //NSLog(@"data: %p(%lu[bytes]), zipedData: %p(%lu[bytes])", data, (unsigned long)[data length], zipedData, (unsigned long)[zipedData length]);
    [self SaveAutoPagerizeSiteInfoData:zipedData];
    return true;
}

/// 内部に保存してある AutoPagerize の カスタムSiteInfo を最新版に更新します
/// これはネットワークアクセスを行う動作になります
- (BOOL)UpdateCachedCustomAutoPagerizeSiteInfoData {
    SyncHttpSession* httpSession = [SyncHttpSession new];
    [httpSession Initialize];
    NSData* data = [httpSession GetBinaryWithUrlString:CUSTOM_AUTOPAGERIZE_SITEINFO_URL];
    if (data == nil) {
        return false;
    }
    NSData* zipedData = [data deflate:9];
    [self SaveDataToCacheFile:zipedData fileName:CACHE_FILE_NAME_CUSTOM_AUTOPAGERLIZE_SITEINFO];
    return true;
}

/// 内部に保存してある AutoPagerize の SiteInfo を取り出します
- (NSData*)GetCachedAutoPagerizeSiteInfoData {
    NSDate* lastUpdateDate = [self GetAutoPagerizeCacheSavedDate];
    if ([lastUpdateDate timeIntervalSinceNow] < -24*60*60 // 24時間以上経っているか、
        || [self GetForceSiteInfoReloadIsEnabled]) { // 強制的にreloadするべきとされていたらキャッシュを更新する
        [self UpdateCachedAutoPagerizeSiteInfoData];
    }
    
    NSString* filePath = [self GetAutoPagerizeSiteInfoCacheFilePath];
    NSData* siteInfoDeflate = [NSData dataWithContentsOfFile:filePath];
    NSData* infratedSiteInfo = nil;
    if(siteInfoDeflate != nil) {
        infratedSiteInfo = [siteInfoDeflate inflate];
    }
    if (siteInfoDeflate == nil || infratedSiteInfo == nil) {
        // 読み出しに失敗したらネットワーク経由で取得しようとします。
        if ([self UpdateCachedAutoPagerizeSiteInfoData]) {
            return [self GetCachedAutoPagerizeSiteInfoData];
        };
        return nil;
    }
    return infratedSiteInfo;
}

/// 内部に保存してある AutoPagerize の カスタムSiteInfo を取り出します
- (NSData*)GetCachedCustomAutoPagerizeSiteInfoData {
    NSDate* lastUpdateDate = [self GetCustomAutoPagerizeCacheSavedDate];
    if ([lastUpdateDate timeIntervalSinceNow] < -24*60*60 // 24時間以上経っているか、
        || [self GetForceSiteInfoReloadIsEnabled]) { // 強制的にreloadするべきとされていたらキャッシュを更新する
        [self UpdateCachedCustomAutoPagerizeSiteInfoData];
    }

    NSData* siteInfo = [self GetCachedAndZipedFileData:CACHE_FILE_NAME_CUSTOM_AUTOPAGERLIZE_SITEINFO];
    if (siteInfo == nil) {
        // 読み出しに失敗したらネットワーク経由で取得しようとします。
        if ([self UpdateCachedCustomAutoPagerizeSiteInfoData]) {
            return [self GetCachedCustomAutoPagerizeSiteInfoData];
        };
        return nil;
    }
    return siteInfo;
}

/// http://...#cookie の形式の文字列を受け取り、ダウンロードqueueに追加します。
- (NSString*)AddDownloadQueueForURLString:(NSString*)urlWithCookieString{
    NSRange range = [urlWithCookieString rangeOfString:@"#"];
    NSString* urlString = urlWithCookieString;
    NSString* cookieString = nil;
    if (range.location != NSNotFound) {
        urlString = [urlWithCookieString substringToIndex:range.location];
        if ((range.location + 1) < [urlWithCookieString length]) {
            cookieString = [urlWithCookieString substringFromIndex:(range.location+1)];
        }
    }
    
    return [self AddDownloadQueueForURL:[urlString stringByRemovingPercentEncoding] cookieParameter:[cookieString stringByRemovingPercentEncoding]];
}

/// ダウンロードqueueに追加しようとします
/// 追加した場合は nil を返します。
/// 追加できなかった場合はエラーメッセージを返します。
- (NSString*) AddDownloadQueueForURL:(NSString*)urlString cookieParameter:(NSString*)cookieParameter
{
    if(urlString == nil)
    {
        return NSLocalizedString(@"GlobalDataSingleton_CanNotGetValidNCODE", @"有効な URL を取得できませんでした。");
    }
    NSURL* url = [[NSURL alloc] initWithString:urlString];
    NSArray<NSString*>* cookieArray = @[];
    if (cookieParameter != nil && [cookieParameter length] > 0) {
        cookieArray = [cookieParameter componentsSeparatedByString:@";"];
    }
    __block UIViewController* rootViewController = nil;
    [NiftyUtilitySwift DispatchSyncMainQueueWithBlock:^{
        rootViewController = [UIViewController toplevelViewController];
    }];
    [NiftyUtilitySwift checkUrlAndConifirmToUserWithViewController:rootViewController url:url cookieArray:cookieArray depth:0];
    return nil;
}

- (void)AddDirectoryDownloadQueueForURL:(NSString *)urlString cookieParameter:(NSString *)cookieParameter author:(NSString*)author title:(NSString*)title {
    NarouContentCacheData* targetContentCacheData = [self SearchNarouContentFromNcode:urlString];
    if (targetContentCacheData != nil) {
        // 既に本棚には登録されているのでタイトル名等だけ上書きして終わりにします。
        if (author != nil) {
            targetContentCacheData.writer = author;
        }
        if (title != nil) {
            targetContentCacheData.title = title;
        }
        [self UpdateNarouContent:targetContentCacheData];
        return;
    }
    
    UriLoader* uriLoader = [UriLoader new];
    [uriLoader AddCustomSiteInfoFromData:[self GetCachedCustomAutoPagerizeSiteInfoData]];
    [uriLoader AddSiteInfoFromData:[self GetCachedAutoPagerizeSiteInfoData]];
    NSURL* url = [[NSURL alloc] initWithString:urlString];
    [uriLoader FetchOneUrl:url cookieArray:[cookieParameter componentsSeparatedByString:@";"] successAction:^(HtmlStory *story) {
        NSString* setTitle = title;
        if (title == nil || [title length] <= 0) {
            setTitle = story.title;
        }
        NSString* setAuthor = author;
        if (author == nil || [author length] <= 0) {
            setAuthor = story.author;
        }
        [self AddNewContentForURL:url nextUrl:story.nextUrl cookieParameter:cookieParameter title:setTitle author:setAuthor firstContent:story.content viewController:nil];
    } failedAction:^(NSURL *url, NSString *errorString) {
        NSLog(@"FetchOneUrl failed: %@ %@", [url absoluteString], errorString);
    }];
    [uriLoader ClearSiteInfoCache];
}

/// 始めの章の内容やタイトルが確定しているURLについて、新規登録をしてダウンロードqueueに追加しようとします
- (void)AddNewContentForURL:(NSURL*)url nextUrl:(NSURL*)nextUrl cookieParameter:(NSString*)cookieParameter title:(NSString*)title author:(NSString*)author firstContent:(NSString*)firstContent viewController:(UIViewController*)viewController {
    [BehaviorLogger AddLogWithDescription:@"GlobalDataSingleton AddNewContentForURL called" data:@{
        @"url": url == nil ? @"nil" : [url absoluteString],
        @"nextUrl": nextUrl == nil ? @"nil" : [nextUrl absoluteString],
        @"cookie": cookieParameter == nil ? @"nil" : cookieParameter,
        @"title": title == nil ? @"nil" : title,
        @"author": author == nil ? @"nil" : author,
        @"firstContent": firstContent == nil ? @"nil" : firstContent
        }];
    NarouContentCacheData* targetContentCacheData = [self SearchNarouContentFromNcode:[url absoluteString]];
    if (targetContentCacheData != nil) {
        NSLog(@"url: %@ is already downloaded. skip.", [url absoluteString]);
        if (viewController != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NiftyUtilitySwift EasyDialogOneButtonWithViewController:viewController title:nil message:NSLocalizedString(@"GlobalDataSingleton_URLisAlreadyDownload", @"既に本棚に登録されているURLでした。") buttonTitle:NSLocalizedString(@"OK_button", @"OK") buttonAction:nil];
            });
        }
        return;
    }
    targetContentCacheData = [self CreateNewUserBook];
    // XXXXX TODO: 怪しく ncode には URLを、keyword には cookieパラメタ を、userid には最後にダウンロードしたURLを入れているのをなんとかしないと……(´・ω・`)
    targetContentCacheData.title = title;
    targetContentCacheData.writer = author;
    targetContentCacheData.ncode = [url absoluteString];
    targetContentCacheData.userid = [url absoluteString];
    targetContentCacheData.keyword = cookieParameter;
    targetContentCacheData.general_all_no = [[NSNumber alloc] initWithInt:1];
    [self UpdateNarouContent:targetContentCacheData];
    [self UpdateStory:firstContent chapter_number:1 parentContent:targetContentCacheData];
    
    // 新しいcontentが追加されたのでアナウンスします
    //[self NarouContentListChangedAnnounce:NarouContentListChangedAnnounce_Add ncode:targetContentCacheData.ncode];
    [self NarouContentListChangedAnnounce];
    
    // download queue に追加します。
    NSLog(@"add download queue: %@", [url absoluteString]);
    [self PushContentDownloadQueue:targetContentCacheData];
}

/// オーディオのルートが変わったよイベントのイベントハンドラ
/// from: http://qiita.com/naonya3/items/433b3daaad75accf156b
- (void)didChangeAudioSessionRoute:(NSNotification *)notification
{
    // ヘッドホンorイヤホンが刺さっていたか取得
    BOOL (^isJointHeadphone)(NSArray *) = ^(NSArray *outputs){
        for (AVAudioSessionPortDescription *desc in outputs) {
            if ([desc.portType isEqual:AVAudioSessionPortHeadphones] ||
                [desc.portType isEqual:AVAudioSessionPortBluetoothA2DP]) {
                return YES;
            }
        }
        return NO;
    };
    
    // 直前の状態を取得
    AVAudioSessionRouteDescription *prevDesc = notification.userInfo[AVAudioSessionRouteChangePreviousRouteKey];
    
    if (isJointHeadphone([[[AVAudioSession sharedInstance] currentRoute] outputs])) {
        if (!isJointHeadphone(prevDesc.outputs)) {
            //NSLog(@"ヘッドフォンが刺さった");
        }
    } else {
        if(isJointHeadphone(prevDesc.outputs)) {
            //NSLog(@"ヘッドフォンが抜かれた");
            [self StopSpeech];
            [self RewindCurrentReadingPoint:25];
            [self SaveCurrentReadingPoint];
        }
    }
}


/// 小説内部での範囲選択時に出てくるメニューを「読み替え辞書に登録」だけにする(YES)か否(NO)かの設定値を取り出します
- (BOOL)GetMenuItemIsAddSpeechModSettingOnly {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTES_MENU_ITEM_IS_ADD_SPEECH_MOD_SETTINGS_ONLY: @false}];
    return [userDefaults boolForKey:USER_DEFAULTES_MENU_ITEM_IS_ADD_SPEECH_MOD_SETTINGS_ONLY];
}

/// 小説内部での範囲選択時に出てくるメニューを「読み替え辞書に登録」だけにする(YES)か否(NO)かの設定値を保存します
- (void)SetMenuItemIsAddSpeechModSettingOnly:(BOOL)yesNo {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:yesNo forKey:USER_DEFAULTES_MENU_ITEM_IS_ADD_SPEECH_MOD_SETTINGS_ONLY];
    [userDefaults synchronize];
}


/// ことせかい 関連の AppGroup に属する UserDefaults を取得します。
- (NSUserDefaults*)getNovelSpeakerAppGroupUserDefaults
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_USER_DEFAULTS_SUITE_NAME];
    return defaults;
}

/// ことせかい 関連の AppGroup に属する UserDefaults から文字列を格納した NSArray* を取り出します。
- (NSArray*)getAppGroup_UserDefaults_StringArrayDataForKey:(NSString*)key {
    NSUserDefaults* userDefaults = [self getNovelSpeakerAppGroupUserDefaults];
    NSArray* currentArray = [userDefaults stringArrayForKey:key];
    return currentArray;
}

/// ことせかい 関連の AppGroup に属する UserDefaults に格納されている文字列を格納した NSArray から、指定された文字列を含むものを排除します
- (BOOL)deleteTextFromAppGroup_UserDefaults_StringArrayDataForKey:(NSString*)key text:(NSString*)text {
    NSArray* currentArray = [self getAppGroup_UserDefaults_StringArrayDataForKey:key];
    if (currentArray == nil) {
        return true;
    }
    NSMutableArray* newArray = [NSMutableArray new];
    for (NSString* obj in currentArray) {
        if (obj == nil || [obj isEqualToString:text] == NSOrderedSame) {
            continue;
        }
        [newArray addObject:obj];
    }
    if ([newArray count] <= 0) {
        newArray = nil;
    }
    NSUserDefaults* userDefaults = [self getNovelSpeakerAppGroupUserDefaults];
    if (userDefaults == nil) {
        return false;
    }
    [userDefaults setObject:newArray forKey:key];
    [userDefaults synchronize];
    return true;
}

/// AppGroupで外部プロセスから指示されたURLのダウンロードを指示したqueueを取り出します。
- (NSArray*)getAppGroupURLDownloadQueue{
    return [self getAppGroup_UserDefaults_StringArrayDataForKey:APP_GROUP_USER_DEFAULTS_URL_DOWNLOAD_QUEUE];
}

/// AppGroup で指示されているURLダウンロードのリストから指定されたURLのものを取り除きます。
- (BOOL)deleteAppGroupQueueForURLDownload:(NSString*)urlString {
    return [self deleteTextFromAppGroup_UserDefaults_StringArrayDataForKey:APP_GROUP_USER_DEFAULTS_URL_DOWNLOAD_QUEUE text:urlString];
}

/// textの追加を指示したqueueを取り出します。
- (NSArray*)getAppGroupAddTextQueue{
    return [self getAppGroup_UserDefaults_StringArrayDataForKey:APP_GROUP_USER_DEFAULTS_ADD_TEXT_QUEUE];
}

/// AppGroup で指示されているtext追加のリストから指定されたtextのものを取り除きます。
- (BOOL)deleteAppGroupQueueForText:(NSString*)text {
    return [self deleteTextFromAppGroup_UserDefaults_StringArrayDataForKey:APP_GROUP_USER_DEFAULTS_ADD_TEXT_QUEUE text:text];
}

/// 起動されるまでの間に新規にダウンロードされた小説の数を取得します
- (NSInteger)GetBackgroundFetchedNovelCount {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:USER_DEFAULTS_BACKGROUND_FETCH_FETCHED_NOVEL_COUNT];
}

/// 起動されるまでの間に新規にダウンロードされた小説の数を更新します
- (void)UpdateBackgroundFetchedNovelCount:(NSInteger)count {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:count forKey:USER_DEFAULTS_BACKGROUND_FETCH_FETCHED_NOVEL_COUNT];
    [userDefaults synchronize];
}



/// ことせかい 関連の AppGroup に属する UserDefaults の key に対して、文字列を格納した NSArray のつもりで text を追加します
- (void)addStringQueueToNovelSpeakerAppGroupUserDefaults:(NSString*)key text:(NSString*)text {
    NSUserDefaults* userDefaults = [self getNovelSpeakerAppGroupUserDefaults];
    NSArray* currentArray = [userDefaults stringArrayForKey:key];
    NSMutableArray* newArray = nil;
    if (currentArray == nil) {
        newArray = [NSMutableArray new];
    }else{
        newArray = [[NSMutableArray alloc] initWithArray:currentArray];
    }
    [newArray addObject:text];
    [userDefaults setObject:newArray forKey:key];
    [userDefaults synchronize];
}

/// URLのダウンロードを指示するqueueにurlを追加します
- (void)addURLDownloadQueueToAppGroupUserDefaults:(NSURL*)url {
    [self addStringQueueToNovelSpeakerAppGroupUserDefaults:APP_GROUP_USER_DEFAULTS_URL_DOWNLOAD_QUEUE text:[url absoluteString]];
}

/// text を新規ユーザ小説として追加します
- (void)AddNewContentForText:(NSString*)text
{
    NarouContentCacheData* content = [self CreateNewUserBook];
    NSString* firstLine = [text getFirstContentLine];
    if (firstLine != nil) {
        content.title = firstLine;
    }
    content.general_all_no = [[NSNumber alloc] initWithInt:1];
    [self UpdateNarouContent:content];
    NSLog(@"addContent: %@\n-> %@", content.title, text);
    [self UpdateStory:text chapter_number:1 parentContent:content];
    [self saveContext];
}

/// AppGroup で指示されたqueueを処理します
- (void)HandleAppGroupQueue{
    return;
    NSArray* UrlDownloadQueueArray = [self getAppGroupURLDownloadQueue];
    if (UrlDownloadQueueArray != nil) {
        for (NSString* urlString in UrlDownloadQueueArray) {
            [self AddDownloadQueueForURLString:urlString];
            [self deleteAppGroupQueueForURLDownload:urlString];
        }
    }
    NSArray* AddTextQueueArray = [self getAppGroupAddTextQueue];
    if (AddTextQueueArray != nil) {
        for (NSString* text in AddTextQueueArray) {
            [self AddNewContentForText:text];
            [self deleteAppGroupQueueForText:text];
        }
    }
}

/// 通知をONにしようとします
- (void)RegisterUserNotification {
    UNUserNotificationCenter* center = UNUserNotificationCenter.currentNotificationCenter;
    [center requestAuthorizationWithOptions:
      UNAuthorizationOptionAlert | UNAuthorizationOptionBadge
      completionHandler:^(BOOL granted, NSError * _Nullable error) {
          ;
      }];
}

/// BackgroundFetch を有効化します
- (void)StartBackgroundFetch{
    NSTimeInterval hour = 60*60;
    if (hour < UIApplicationBackgroundFetchIntervalMinimum) {
        hour = UIApplicationBackgroundFetchIntervalMinimum;
    }
    UIApplication* application = [UIApplication sharedApplication];
    [application setMinimumBackgroundFetchInterval:hour];
}

/// BackgroundFetch を無効化します
- (void)StopBackgroundFetch{
    UIApplication* application = [UIApplication sharedApplication];
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
}

/// ルビがふられた物について、ルビの部分だけを読むか否かの設定を取得します
- (BOOL)GetOverrideRubyIsEnabled {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:USER_DEFAULTS_OVERRIDE_RUBY_IS_ENABLED];
}

/// ルビがふられた物について、ルビの部分だけを読むか否かの設定を保存します
- (void)SetOverrideRubyIsEnabled:(BOOL)yesNo {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:yesNo forKey:USER_DEFAULTS_OVERRIDE_RUBY_IS_ENABLED];
    [userDefaults synchronize];
    m_isNeedReloadSpeakSetting = true;
}

/// 読み上げられないため、ルビとしては認識しない文字集合を取得します
- (NSString*)GetNotRubyCharactorStringArray{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_NOT_RUBY_CHARACTOR_STRING_ARRAY: NOT_RUBY_STRING_ARRAY}];
    return [userDefaults stringForKey:USER_DEFAULTS_NOT_RUBY_CHARACTOR_STRING_ARRAY];
}

/// 読み上げられないため、ルビとしては認識しない文字集合を設定します
- (void)SetNotRubyCharactorStringArray:(NSString*)data{
    if (data == nil) {
        return;
    }
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:data forKey:USER_DEFAULTS_NOT_RUBY_CHARACTOR_STRING_ARRAY];
    [userDefaults synchronize];
    m_isNeedReloadSpeakSetting = true;
}

/// 読み上げられないため、ルビとしては認識しない文字集合について、過去の標準設定のものの場合、強制的に最新のものに上書きします。
- (void)UpdateNotRubyChacactorStringArrayFromOldDefaultSetting{
    NSArray* oldDefaultSttings = @[
       @"・", @"・、", @"・、 　"
    ];
    NSString* currentSetting = [self GetNotRubyCharactorStringArray];
    for (NSString* target in oldDefaultSttings) {
        if ([currentSetting compare:target] == NSOrderedSame) {
            [self SetNotRubyCharactorStringArray:NOT_RUBY_STRING_ARRAY];
            return;
        }
    }
}

/// SiteInfo デバッグ用に、毎回 SiteInfo の読み直しを行うか否かの設定を取得します
- (BOOL)GetForceSiteInfoReloadIsEnabled {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_FORCE_SITEINFO_RELOAD_IS_ENABLED: @false}];
    return [userDefaults boolForKey:USER_DEFAULTS_FORCE_SITEINFO_RELOAD_IS_ENABLED];
}

/// SiteInfo デバッグ用に、毎回 SiteInfo の読み直しを行うか否かの設定を保存します
- (void)SetForceSiteInfoReloadIsEnabled:(BOOL)yesNo {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:yesNo forKey:USER_DEFAULTS_FORCE_SITEINFO_RELOAD_IS_ENABLED];
    [userDefaults synchronize];
}

/// 読んでいるゲージを表示するか否かを取得します
- (BOOL)IsReadingProgressDisplayEnabled{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_READING_PROGRESS_DISPLAY_IS_ENABLED: @false}];
    return [userDefaults boolForKey:USER_DEFAULTS_READING_PROGRESS_DISPLAY_IS_ENABLED];
}
/// 読んでいるゲージを表示する(true)か否(false)かを設定します
- (void)SetReadingProgressDisplayEnabled:(BOOL)yesNo{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:yesNo forKey:USER_DEFAULTS_READING_PROGRESS_DISPLAY_IS_ENABLED];
    [userDefaults synchronize];
}

/// コントロールセンターの「前の章へ戻る/次の章へ進む」ボタンを「少し戻る/少し進む」ボタンに変更するか否かを取得します
- (BOOL)IsShortSkipEnabled{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_SHORT_SKIP_IS_ENABLED: @false}];
    return [userDefaults boolForKey:USER_DEFAULTS_SHORT_SKIP_IS_ENABLED];
}
/// コントロールセンターの「前の章へ戻る/次の章へ進む」ボタンを「少し戻る/少し進む」ボタンに変更するか否かを設定します
- (void)SetShortSkipEnabled:(BOOL)isEnabled{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isEnabled forKey:USER_DEFAULTS_SHORT_SKIP_IS_ENABLED];
    [userDefaults synchronize];
}

/// コントロールセンターの再生時間ゲージを有効にするか否かを取得します
- (BOOL)IsPlaybackDurationEnabled{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_PLAYBACK_DURATION_IS_ENABLED: @false}];
    return [userDefaults boolForKey:USER_DEFAULTS_PLAYBACK_DURATION_IS_ENABLED];
}

/// コントロールセンターの再生時間ゲージを有効にするか否かを設定します
- (void)SetPlaybackDurationIsEnabled:(BOOL)isEnabled{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isEnabled forKey:USER_DEFAULTS_PLAYBACK_DURATION_IS_ENABLED];
    [userDefaults synchronize];
}

/*
/// 暗い色調にするか否かを取得します
- (BOOL)IsDarkThemeEnabled{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_DARK_THEME_IS_ENABLED: @false}];
    return [userDefaults boolForKey:USER_DEFAULTS_DARK_THEME_IS_ENABLED];
}
/// 暗い色調にするか否かを設定します
- (void)SetDarkThemeIsEnabled:(BOOL)isEnabled{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isEnabled forKey:USER_DEFAULTS_DARK_THEME_IS_ENABLED];
    [userDefaults synchronize];
}
 */

/// ページめくり音を発生させるか否かを取得します
- (BOOL)IsPageTurningSoundEnabled{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_PAGE_TURNING_SOUND_IS_ENABLED: @false}];
    return [userDefaults boolForKey:USER_DEFAULTS_PAGE_TURNING_SOUND_IS_ENABLED];
}
/// ページめくり音を発生させるか否かを設定します
- (void)SetPageTurningSoundIsEnabled:(BOOL)isEnabled{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isEnabled forKey:USER_DEFAULTS_PAGE_TURNING_SOUND_IS_ENABLED];
    [userDefaults synchronize];
}

/// URIを読み上げないようにするか否かを取得します
- (BOOL)GetIsIgnoreURIStringSpeechEnabled{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_IGNORE_URI_SPEECH_IS_ENABLED: @false}];
    return [userDefaults boolForKey:USER_DEFAULTS_IGNORE_URI_SPEECH_IS_ENABLED];
}
/// URIを読み上げないようにするか否かを設定します
- (void)SetIgnoreURIStringSpeechIsEnabled:(BOOL)isEnabled{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isEnabled forKey:USER_DEFAULTS_IGNORE_URI_SPEECH_IS_ENABLED];
    [userDefaults synchronize];
    m_isNeedReloadSpeakSetting = true;
}


/// 小説の表示に使用するフォント名を取得します
- (NSString*)GetDisplayFontName{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_DISPLAY_FONT_NAME: @""}];
    NSString* fontName = [userDefaults stringForKey:USER_DEFAULTS_DISPLAY_FONT_NAME];
    if ([fontName compare:@""] == NSOrderedSame) {
        return nil;
    }
    return fontName;
}
/// 小説の表示に使用するフォント名を設定します
- (void)SetDisplayFontName:(NSString*)fontName{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:fontName forKey:USER_DEFAULTS_DISPLAY_FONT_NAME];
    [userDefaults synchronize];
}
    
    
/// iOS 12 からの読み上げ中の読み上げ位置がずれる問題への対応で、空白文字をαに置き換える設定のEnable/Disableを取得します
- (BOOL)IsEscapeAboutSpeechPositionDisplayBugOniOS12Enabled{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_IS_ESCAPE_ABOUT_SPEECH_POSITION_DISPLAY_BUG_ON_IOS12: @false}];
    return [userDefaults boolForKey:USER_DEFAULTS_IS_ESCAPE_ABOUT_SPEECH_POSITION_DISPLAY_BUG_ON_IOS12];
}
/// iOS 12 からの読み上げ中の読み上げ位置がずれる問題への対応で、空白文字をαに置き換える設定のEnable/Disableを設定します
- (void)SetEscapeAboutSpeechPositionDisplayBugOniOS12Enabled:(BOOL)isEnabled{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isEnabled forKey:USER_DEFAULTS_IS_ESCAPE_ABOUT_SPEECH_POSITION_DISPLAY_BUG_ON_IOS12];
    [userDefaults synchronize];
    m_isNeedReloadSpeakSetting = true;
}

/// 読み上げ時に無音の音を再生し続けるか否かを取得します
- (BOOL)IsDummySilentSoundEnabled{
    return true;
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_IS_DUMMY_SILENT_SOUND_ENABLED: @false}];
    return [userDefaults boolForKey:USER_DEFAULTS_IS_DUMMY_SILENT_SOUND_ENABLED];
}
/// 読み上げ時に無音の音を再生し続けるか否かを設定します
- (void)SetIsDummySilentSoundEnabled:(BOOL)isEnabled{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isEnabled forKey:USER_DEFAULTS_IS_DUMMY_SILENT_SOUND_ENABLED];
    [userDefaults synchronize];
}

/// 読み上げ時に他のアプリと共存して鳴らせるようにするか否かを取得します
- (BOOL)IsMixWithOthersEnabled{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_IS_MIX_WITH_OTHERS_ENABLED: @false}];
    return [userDefaults boolForKey:USER_DEFAULTS_IS_MIX_WITH_OTHERS_ENABLED];
}
/// 読み上げ時に他のアプリと共存して鳴らせるようにするか否かを設定します
- (void)SetIsMixWithOthersEnabled:(BOOL)isEnabled{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isEnabled forKey:USER_DEFAULTS_IS_MIX_WITH_OTHERS_ENABLED];
    [userDefaults synchronize];
    [self audioSessionInit:NO];
}

/// 読み上げ時に他のアプリと共存して鳴らせる場合、他アプリ側の音を小さくするか否かを取得します
- (BOOL)IsDuckOthersEnabled{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_IS_DUCK_OTHERS_ENABLED: @true}];
    return [userDefaults boolForKey:USER_DEFAULTS_IS_DUCK_OTHERS_ENABLED];
}
/// 読み上げ時に他のアプリと共存して鳴らせるようにするか否かを設定します
- (void)SetIsDuckOthersEnabled:(BOOL)isEnabled{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isEnabled forKey:USER_DEFAULTS_IS_DUCK_OTHERS_ENABLED];
    [userDefaults synchronize];
    [self audioSessionInit:NO];
}

/// 利用許諾を読んだか否かを取得します
- (BOOL)IsLicenseReaded{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_IS_LICENSE_FILE_READED: @false}];
    return [userDefaults boolForKey:USER_DEFAULTS_IS_LICENSE_FILE_READED];
}
/// 利用許諾を読んだことにします
- (void)SetLicenseIsReaded{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:true forKey:USER_DEFAULTS_IS_LICENSE_FILE_READED];
    [userDefaults synchronize];
}

/// リピート再生の設定を取得します
- (RepeatSpeechType)GetRepeatSpeechType{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_REPEAT_SPEECH_TYPE: [[NSNumber alloc] initWithInt:RepeatSpeechType_NoRepeat]}];
    NSInteger type = [userDefaults integerForKey:USER_DEFAULTS_REPEAT_SPEECH_TYPE];
    if (type != RepeatSpeechType_NoRepeat
        && type != RepeatSpeechType_RewindToFirstStory
        && type != RepeatSpeechType_RewindToThisStory) {
        type = RepeatSpeechType_NoRepeat;
    }
    return type;
}
/// リピート再生の設定を上書きします。
- (void)SetRepeatSpeechType:(RepeatSpeechType)type{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if (type != RepeatSpeechType_NoRepeat
        && type != RepeatSpeechType_RewindToFirstStory
        && type != RepeatSpeechType_RewindToThisStory) {
        type = RepeatSpeechType_NoRepeat;
    }
    [userDefaults setInteger:type forKey:USER_DEFAULTS_REPEAT_SPEECH_TYPE];
    [userDefaults synchronize];
}

/// 起動時に前回開いていた小説を開くか否かの設定を取得します
- (BOOL)IsOpenRecentNovelInStartTime{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_IS_OPEN_RECENT_NOVEL_IN_START_TIME: @true}];
    return [userDefaults boolForKey:USER_DEFAULTS_IS_OPEN_RECENT_NOVEL_IN_START_TIME];
}
/// 起動時に前回開いていた小説を開くか否かの設定を設定します
- (void)SetIsOpenRecentNovelInStartTime:(BOOL)isOpen{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isOpen forKey:USER_DEFAULTS_IS_OPEN_RECENT_NOVEL_IN_START_TIME];
    [userDefaults synchronize];
}

/// ダウンロード時に携帯電話回線を禁じるか否かの設定を取得します
- (BOOL)IsDisallowsCellularAccess{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_IS_DISALLOW_CELLULAR_ACCESS: @false}];
    return [userDefaults boolForKey:USER_DEFAULTS_IS_DISALLOW_CELLULAR_ACCESS];
}
/// ダウンロード時に携帯電話回線を禁じるか否かの設定を設定します
- (void)SetIsDisallowsCellularAccess:(BOOL)isAllow{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isAllow forKey:USER_DEFAULTS_IS_DISALLOW_CELLULAR_ACCESS];
    [userDefaults synchronize];
}

/// 本棚で小説を削除する時に確認するか否かを取得します
- (BOOL)IsNeedConfirmDeleteBook{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_IS_NEED_CONFIRM_DELETE_BOOK: @false}];
    return [userDefaults boolForKey:USER_DEFAULTS_IS_NEED_CONFIRM_DELETE_BOOK];
}
/// 本棚で小説を削除する時に確認するか否かを設定します
- (void)SetIsNeedConfirmDeleteBook:(BOOL)isNeedConfirm{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isNeedConfirm forKey:USER_DEFAULTS_IS_NEED_CONFIRM_DELETE_BOOK];
    [userDefaults synchronize];
}


/// 小説を読む部分での表示色設定を読み出します(背景色分)。標準設定の場合は nil が返ります。
- (UIColor*)GetReadingColorSettingForBackgroundColor{
    // 標準では JSON を入れておかずに JSON からの変換に失敗させます。
    NSString* defaultColorSettingJson = @"ERROR STRING";
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_READING_COLOR_SETTING_FOR_BACKGROUND_COLOR: defaultColorSettingJson}];
    NSString* colorSettingJson = [userDefaults stringForKey:USER_DEFAULTS_READING_COLOR_SETTING_FOR_BACKGROUND_COLOR];
    NSError* error = nil;
    NSDictionary* settingDictionary = [NSJSONSerialization JSONObjectWithData:[colorSettingJson dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (settingDictionary == nil || error != nil) {
        return nil;
    }
    CGFloat red, green, blue, alpha;
    red = green = blue = alpha = -1.0;
    typedef float (^GetColorFunc)(NSDictionary* dic, NSString* name);
    GetColorFunc getColorFunc = ^(NSDictionary* dic, NSString* name) {
        float colorValue = -1.0;
        id colorObj = [dic valueForKey:name];
        if ([colorObj isKindOfClass:[NSNumber class]]) {
            NSNumber* color = colorObj;
            return [color floatValue];
        }
        return colorValue;
    };
    red = getColorFunc(settingDictionary, @"red");
    green = getColorFunc(settingDictionary, @"green");
    blue = getColorFunc(settingDictionary, @"blue");
    alpha = getColorFunc(settingDictionary, @"alpha");
    if (red < 0.0 || green < 0.0 || blue < 0.0 || alpha < 0.0
        || red > 1.0 || green > 1.0 || blue > 1.0 || alpha > 1.0) {
        return nil;
    }
    return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
}
/// 小説を読む部分での表示色設定を設定します(背景色分)。標準設定に戻す場合は nil を指定します。
- (void)SetReadingColorSettingForBackgroundColor:(UIColor*)color{
    NSString* colorString = nil;
    if (color != nil) {
        NSMutableDictionary* dic = [NSMutableDictionary new];
        CGFloat red, green, blue, alpha;
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        [dic setValue:[[NSNumber alloc] initWithDouble:red] forKey:@"red"];
        [dic setValue:[[NSNumber alloc] initWithDouble:green] forKey:@"green"];
        [dic setValue:[[NSNumber alloc] initWithDouble:blue] forKey:@"blue"];
        [dic setValue:[[NSNumber alloc] initWithDouble:alpha] forKey:@"alpha"];
        NSError* error = nil;
        NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
        if (data != nil && error == nil) {
            colorString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if (colorString != nil) {
        [userDefaults setObject:colorString forKey:USER_DEFAULTS_READING_COLOR_SETTING_FOR_BACKGROUND_COLOR];
    }else{
        [userDefaults removeObjectForKey:USER_DEFAULTS_READING_COLOR_SETTING_FOR_BACKGROUND_COLOR];
    }
    [userDefaults synchronize];
}
/// 小説を読む部分での表示色設定を読み出します(文字色分)。標準設定の場合は nil が返ります。
- (UIColor*)GetReadingColorSettingForForegroundColor{
    // 標準では JSON を入れておかずに JSON からの変換に失敗させます。
    NSString* defaultColorSettingJson = @"ERROR STRING";
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_READING_COLOR_SETTING_FOR_FOREGROUND_COLOR: defaultColorSettingJson}];
    NSString* colorSettingJson = [userDefaults stringForKey:USER_DEFAULTS_READING_COLOR_SETTING_FOR_FOREGROUND_COLOR];
    NSError* error = nil;
    NSDictionary* settingDictionary = [NSJSONSerialization JSONObjectWithData:[colorSettingJson dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (settingDictionary == nil || error != nil) {
        return nil;
    }
    CGFloat red, green, blue, alpha;
    red = green = blue = alpha = -1.0;
    typedef float (^GetColorFunc)(NSDictionary* dic, NSString* name);
    GetColorFunc getColorFunc = ^(NSDictionary* dic, NSString* name) {
        float colorValue = -1.0;
        id colorObj = [dic valueForKey:name];
        if ([colorObj isKindOfClass:[NSNumber class]]) {
            NSNumber* color = colorObj;
            return [color floatValue];
        }
        return colorValue;
    };
    red = getColorFunc(settingDictionary, @"red");
    green = getColorFunc(settingDictionary, @"green");
    blue = getColorFunc(settingDictionary, @"blue");
    alpha = getColorFunc(settingDictionary, @"alpha");
    if (red < 0.0 || green < 0.0 || blue < 0.0 || alpha < 0.0
        || red > 1.0 || green > 1.0 || blue > 1.0 || alpha > 1.0) {
        return nil;
    }
    return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
}
/// 小説を読む部分での表示色設定を設定します(背景色分)。標準設定に戻す場合は nil を指定します。
- (void)SetReadingColorSettingForForegroundColor:(UIColor*)color{
    NSString* colorString = nil;
    if (color != nil) {
        NSMutableDictionary* dic = [NSMutableDictionary new];
        CGFloat red, green, blue, alpha;
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        [dic setValue:[[NSNumber alloc] initWithDouble:red] forKey:@"red"];
        [dic setValue:[[NSNumber alloc] initWithDouble:green] forKey:@"green"];
        [dic setValue:[[NSNumber alloc] initWithDouble:blue] forKey:@"blue"];
        [dic setValue:[[NSNumber alloc] initWithDouble:alpha] forKey:@"alpha"];
        NSError* error = nil;
        NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
        if (data != nil && error == nil) {
            colorString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if (colorString != nil) {
        [userDefaults setObject:colorString forKey:USER_DEFAULTS_READING_COLOR_SETTING_FOR_FOREGROUND_COLOR];
    }else{
        [userDefaults removeObjectForKey:USER_DEFAULTS_READING_COLOR_SETTING_FOR_FOREGROUND_COLOR];
    }
    [userDefaults synchronize];
}


/// 最新のプライバシーポリシーのURLを取得します
- (NSURL*)GetPrivacyPolicyURL {
    return [[NSURL alloc] initWithString:@"https://raw.githubusercontent.com/limura/NovelSpeaker/master/PrivacyPolicy.txt"];
}
/// 一度読んだ事のあるプライバシーポリシーを取得します(読んだことがなければ @"" が取得されます)
- (NSString*)GetReadedPrivacyPolicy{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{USER_DEFAULTS_CURRENT_READED_PRIVACY_POLICY: @""}];
    return [userDefaults stringForKey:USER_DEFAULTS_CURRENT_READED_PRIVACY_POLICY];
}
/// 引数で表される利用許諾を読んだとして保存します
- (void)SetPrivacyPolicyIsReaded:(NSString*)privacyPolicy{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:privacyPolicy forKey:USER_DEFAULTS_CURRENT_READED_PRIVACY_POLICY];
    [userDefaults synchronize];
}

/// Web取り込み用のBookmarkを取得します
- (NSArray*)GetWebImportBookmarks{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    // 怪しく「名前」と「URL」を"\n"で区切って保存します。(´・ω・`)
    [userDefaults registerDefaults:@{USER_DEFAULTS_WEB_IMPORT_BOOKMARK_ARRAY: @[
        //@"Google\nhttps://www.google.co.jp",
        @"小説家になろう\nhttps://syosetu.com/",
        @"青空文庫\nhttps://www.aozora.gr.jp/",
        //@"コンプリート・シャーロック・ホームズ\nhttp://www.221b.jp/", // 1秒おきに見に行かせると 403 になるっぽい？
        @"ハーメルン\nhttps://syosetu.org/",
        @"暁\nhttps://www.akatsuki-novels.com/",
        @"カクヨム\nhttps://kakuyomu.jp/",
        //@"アルファポリス\nhttps://www.alphapolis.co.jp/novel/",
        //@"pixiv/ノベル\nhttps://www.pixiv.net/novel/",
        @"星空文庫\nhttps://slib.net/",
        //@"FC2小説\nhttps://novel.fc2.com/",
        //@"novelist.jp\nhttp://novelist.jp/",
        //@"eエブリスタ\nhttps://estar.jp/",
        //@"魔法のiランドノベル\nhttps://novel.maho.jp/",
        //@"ベリーズ・カフェ\nhttps://www.berrys-cafe.jp/",
        //@"星の砂\nhttp://hoshi-suna.jp/",
        //@"小説カキコ\nhttp://www.kakiko.cc/",
        //@"のべぷろ\nhttp://www.novepro.jp/",
        //@"野いちご\nhttps://www.no-ichigo.jp/",
        //@"小説&まんが投稿屋\nhttp://works.bookstudio.com/",
        //@"シルフェニア\nhttp://www.silufenia.com/main.php",
        //@"ぱろしょ\nhttp://paro.guttari.info/",
        //@"おりおん\nhttp://de-view.net/",
        //@"ドリームライブ\nhttp://www.dreamtribe.jp/",
        //@"短編\nhttp://tanpen.jp/",
        //@"ライトノベル作法研究所\nhttp://www.raitonoveru.jp/",
        ]}];
    // 2018/10/20 アルファポリスがJavaScriptによる遅延読み込みになったため、
    // 標準ブックマークとして保存されいていたアルファポリスについては非対応という表示を追加することにした
    NSArray* bookmarkArray = [userDefaults arrayForKey:USER_DEFAULTS_WEB_IMPORT_BOOKMARK_ARRAY];
    NSMutableArray* modifiedArray = [NSMutableArray new];
    for (NSString* str in bookmarkArray) {
        if ([str compare:@"アルファポリス\nhttps://www.alphapolis.co.jp/novel/"] == NSOrderedSame) {
            [modifiedArray addObject:@"アルファポリス(Web取込 非対応サイトになりました。詳細はサポートサイト下部にありますQ&Aを御覧ください)\nhttps://www.alphapolis.co.jp/novel/"];
        }else{
            [modifiedArray addObject:str];
        }
    }
    return modifiedArray;
}

/// Web取り込み用のBookmarkに追加します。
- (void)AddWebImportBookmarkForName:(NSString*)name url:(NSURL*)url {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray* bookmarks = [userDefaults arrayForKey:USER_DEFAULTS_WEB_IMPORT_BOOKMARK_ARRAY];
    NSString* newBookmarkString = [[NSString alloc] initWithFormat:@"%@\n%@", name, [url absoluteString]];
    NSMutableArray* newArray = [NSMutableArray new];
    for (NSString* data in bookmarks) {
        if ([data compare:newBookmarkString] == NSOrderedSame) {
            // 既にBookmarkに存在していたので無視します
            return;
        }
        [newArray addObject:data];
    }
    [newArray addObject:newBookmarkString];
    [userDefaults setObject:newArray forKey:USER_DEFAULTS_WEB_IMPORT_BOOKMARK_ARRAY];
    [userDefaults synchronize];
}

/// Web取り込み用のBookmarkから削除します
- (void)DelURLFromWebImportBookmark:(NSURL*)url {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray* bookmarks = [userDefaults arrayForKey:USER_DEFAULTS_WEB_IMPORT_BOOKMARK_ARRAY];
    NSMutableArray* newArray = [NSMutableArray new];
    for (NSString* nameAndURL in bookmarks) {
        NSArray* nameURLArray = [nameAndURL componentsSeparatedByString:@"\n"];
        if ([nameURLArray count] != 2) {
            continue;
        }
        NSString* URLString = nameURLArray[1];
        if ([URLString compare:[url absoluteString]] == NSOrderedSame) {
            continue;
        }
        [newArray addObject:nameAndURL];
    }
    [userDefaults setObject:newArray forKey:USER_DEFAULTS_WEB_IMPORT_BOOKMARK_ARRAY];
    [userDefaults synchronize];
}

/// Web取り込み用のBookmarkを全て消し去ります
- (void)ClearWebImportBookmarks{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@[]forKey:USER_DEFAULTS_WEB_IMPORT_BOOKMARK_ARRAY];
    [userDefaults synchronize];
}


// 本棚に入っている物をバックアップするためのJSONに変換する(ためのNSArray*にする)
- (NSArray*)CreateBookselfBackupForJSONArray{
    NSArray* contentArray = [self GetAllNarouContent:NarouContentSortType_Ncode];
    NSMutableArray* resultArray = [NSMutableArray new];
    for (NarouContentCacheData* content in contentArray) {
        // ncode に入ってる文字列で三種類に分かれている(2017/10/10現在)
        // nXXXXX: 小説家になろうの ncode
        // _XXXXX: 自作小説
        // https?XXX: URL
        // URLであった場合、keyword に secret が入っている。
        // ncode や URL は再度ダウンロードすると良さそうだが、自作小説の場合はタイトルと本文を保存しておかないと復活できない。
        NSMutableDictionary* obj = [NSMutableDictionary new];
        if ([content isURLContent]) {
            if (content.ncode == nil) {
                continue;
            }
            [obj setObject:@"url" forKey:@"type"];
            [obj setObject:content.ncode forKey:@"url"];
            if (content.writer != nil && [content.writer length] > 0) {
                [obj setObject:content.writer forKey:@"author"];
            }
            if (content.title != nil && [content.title length] > 0) {
                [obj setObject:content.title forKey:@"title"];
            }else{
                [obj setObject:@"(不明なタイトル)" forKey:@"title"];
            }
            if (content.keyword != nil && [content.keyword length] > 0) {
                [obj setObject: [NiftyUtility stringEncrypt:content.keyword key:content.ncode] forKey:@"secret"];
            }
            if (content.novelupdated_at != nil) {
                [obj setObject:[NiftyUtilitySwift Date2ISO8601StringWithDate:content.novelupdated_at] forKey:@"novelupdated_at"];
            }
            if (content.currentReadingStory != nil) {
                if (content.currentReadingStory.chapter_number != nil) {
                    [obj setObject:content.currentReadingStory.chapter_number forKey:@"current_reading_chapter_number"];
                }
                if (content.currentReadingStory.readLocation != nil) {
                    [obj setObject:content.currentReadingStory.readLocation forKey:@"current_reading_chapter_read_location"];
                }
            }
            if (content.userid != nil && [content.userid length] > 0) {
                [obj setObject:content.userid forKey:@"last_download_url"];
            }
        }else if ([content isUserCreatedContent]) {
            if (content.title == nil || content.ncode == nil) {
                continue;
            }
            [obj setObject:@"user" forKey:@"type"];
            [obj setObject:content.title forKey:@"title"];
            [obj setObject:content.ncode forKey:@"id"];
            NSArray* storyTextArray = [self GetAllStoryTextForNcode:content.ncode];
            if (storyTextArray == nil) {
                NSLog(@"storyTextArray is nil.");
                continue;
            }
            [obj setObject:storyTextArray forKey:@"storys"];
        }else{
            if (content.ncode == nil) {
                continue;
            }
            [obj setObject:@"ncode" forKey:@"type"];
            [obj setObject:content.ncode forKey:@"ncode"];
#define SET_OBJECT_TARGET(target, key) \
            if (target != nil) { \
                [obj setObject:target forKey:key];\
            }
            SET_OBJECT_TARGET(content.all_hyoka_cnt, @"all_hyoka_cnt")
            SET_OBJECT_TARGET(content.all_point, @"all_point")
            SET_OBJECT_TARGET(content.end, @"end")
            SET_OBJECT_TARGET(content.fav_novel_cnt, @"fav_novel_cnt")
            SET_OBJECT_TARGET(content.genre, @"genre")
            SET_OBJECT_TARGET(content.global_point, @"global_point")
            SET_OBJECT_TARGET(content.is_new_flug, @"is_new_flug")
            SET_OBJECT_TARGET(content.keyword, @"keyword")
            SET_OBJECT_TARGET(content.review_cnt, @"review_cnt")
            SET_OBJECT_TARGET(content.sasie_cnt, @"sasie_cnt")
            SET_OBJECT_TARGET(content.story, @"story")
            SET_OBJECT_TARGET(content.title, @"title")
            SET_OBJECT_TARGET(content.userid, @"userid")
            SET_OBJECT_TARGET(content.writer, @"writer")
#undef SET_OBJECT_TARGET
            if (content.novelupdated_at != nil) {
                [obj setObject:[NiftyUtilitySwift Date2ISO8601StringWithDate:content.novelupdated_at] forKey:@"novelupdated_at"];
            }
            if (content.currentReadingStory != nil) {
                if (content.currentReadingStory.chapter_number != nil) {
                    [obj setObject:content.currentReadingStory.chapter_number forKey:@"current_reading_chapter_number"];
                }
                if (content.currentReadingStory.readLocation != nil) {
                    [obj setObject:content.currentReadingStory.readLocation forKey:@"current_reading_chapter_read_location"];
                }
            }
        }
        [resultArray addObject:obj];
    }
    return resultArray;
}

// 読み替え辞書をバックアップ用途用のJSON(用のNSDictionary*)に変換して取得します
- (NSDictionary*)CreateSpeechModifierSettingDictionaryForJSON{
    NSArray* array = [self GetAllSpeechModSettings];
    NSMutableDictionary* resultDictionary = [NSMutableDictionary new];
    for (SpeechModSettingCacheData* speechMod in array) {
        [resultDictionary setObject:@{
          @"afterString": speechMod.afterString,
          @"type": [[NSNumber alloc] initWithUnsignedInt:(unsigned int)speechMod.convertType],
          } forKey:speechMod.beforeString];
    }
    return resultDictionary;
}

// Web読み込み用のブックマークをバックアップ用途用のJSON(用のNSArray*)に変換して取得します
- (NSArray*)CreateWebImportBookmarkSettingArrayForJSON{
    NSArray* bookmarks = [self GetWebImportBookmarks];
    NSMutableArray* resultArray = [NSMutableArray new];
    for (NSString* nameAndURL in bookmarks) {
        NSArray* nameURLArray = [nameAndURL componentsSeparatedByString:@"\n"];
        if ([nameURLArray count] != 2) {
            continue;
        }
        NSString* nameString = nameURLArray[0];
        NSString* URLString = nameURLArray[1];
        [resultArray addObject:@{nameString: URLString}];
    }
    return resultArray;
}

// 声質の設定などの情報をJSON(用のNSDictionary*)に変換して取得します。
- (NSDictionary*)CreateSpeakPitchConfigDictionaryForJSON{
    NSMutableDictionary* result = [NSMutableDictionary new];

    GlobalStateCacheData* globalState = [self GetGlobalState];
    [result setObject:@{
        @"pitch": globalState.defaultPitch,
        @"rate": globalState.defaultRate
    } forKey:@"default"];

    NSArray* speakPitchArray = [self GetAllSpeakPitchConfig];
    NSMutableArray* otherSettingArray = [NSMutableArray new];
    for (SpeakPitchConfigCacheData* pitchConfig in speakPitchArray) {
        NSMutableDictionary* pitchDictionary = [NSMutableDictionary new];
        [pitchDictionary setObject:pitchConfig.title forKey:@"title"];
        [pitchDictionary setObject:pitchConfig.startText forKey:@"start_text"];
        [pitchDictionary setObject:pitchConfig.endText forKey:@"end_text"];
        [pitchDictionary setObject:pitchConfig.pitch forKey:@"pitch"];
        [otherSettingArray addObject:pitchDictionary];
    }
    [result setObject:otherSettingArray forKey:@"others"];
    return result;
}

// 読み上げの間の設定をJSON(用のNSDictionary*)に変換して取得します。
- (NSArray*)CreateSpeechWaitConfigArrayForJSON{
    NSMutableArray* result = [NSMutableArray new];
    NSArray* waitConfigArray = [self GetAllSpeechWaitConfig];
    for (SpeechWaitConfigCacheData* waitConfig in waitConfigArray) {
        NSDictionary* dic = @{
            @"target_text": waitConfig.targetText,
            @"delay_time_in_sec": waitConfig.delayTimeInSec,
        };
        [result addObject:dic];
    }
    
    return result;
}

// GlobalData に入っているような情報をJSON(用のNSDictionary*)に変換して取得します
- (NSDictionary*)CreateMiscSettingsDictionaryForJSON{
    NSMutableDictionary* result = [NSMutableDictionary new];
    
    GlobalStateCacheData* globalState = [self GetGlobalState];
    [NiftyUtility addIntValueForJSONNSDictionary:result key:@"max_speech_time_in_sec" number:globalState.maxSpeechTimeInSec];
    [NiftyUtility addFloatValueForJSONNSDictionary:result key:@"text_size_value" number:globalState.textSizeValue];
    [NiftyUtility addBoolValueForJSONNSDictionary:result key:@"speech_wait_setting_use_experimental_wait" number:globalState.speechWaitSettingUseExperimentalWait];
    [NiftyUtility addStringForJSONNSDictionary:result key:@"default_voice_identifier" string:[self GetVoiceIdentifier]];
    [NiftyUtility addIntValueForJSONNSDictionary:result key:@"content_sort_type" number:[[NSNumber alloc] initWithInt:(int)[self GetBookSelfSortType]]];
    [NiftyUtility addBoolValueForJSONNSDictionary:result key:@"menuitem_is_add_speech_mod_setting_only" number:[[NSNumber alloc] initWithBool:[self GetMenuItemIsAddSpeechModSettingOnly]]];
    [NiftyUtility addBoolValueForJSONNSDictionary:result key:@"override_ruby_is_enabled" number:[[NSNumber alloc] initWithBool:[self GetOverrideRubyIsEnabled]]];
    [NiftyUtility addBoolValueForJSONNSDictionary:result key:@"is_ignore_url_speech_enabled" number:[[NSNumber alloc] initWithBool:[self GetIsIgnoreURIStringSpeechEnabled]]];
    [NiftyUtility addStringForJSONNSDictionary:result key:@"not_ruby_charactor_array" string:[self GetNotRubyCharactorStringArray]];
    [NiftyUtility addBoolValueForJSONNSDictionary:result key:@"force_siteinfo_reload_is_enabled" number:[[NSNumber alloc] initWithBool:[self GetForceSiteInfoReloadIsEnabled]]];
    [NiftyUtility addBoolValueForJSONNSDictionary:result key:@"is_reading_progress_display_enabled" number:[[NSNumber alloc] initWithBool:[self IsReadingProgressDisplayEnabled]]];
    [NiftyUtility addBoolValueForJSONNSDictionary:result key:@"is_short_skip_enabled" number:[[NSNumber alloc] initWithBool:[self IsShortSkipEnabled]]];
    [NiftyUtility addBoolValueForJSONNSDictionary:result key:@"is_playback_duration_enabled" number:[[NSNumber alloc] initWithBool:[self IsPlaybackDurationEnabled]]];
    [NiftyUtility addBoolValueForJSONNSDictionary:result key:@"is_page_turning_sound_enabled" number:[[NSNumber alloc] initWithBool:[self IsPageTurningSoundEnabled]]];
    [NiftyUtility addBoolValueForJSONNSDictionary:result key:@"is_escape_about_speech_position_display_bug_on_ios12_enabled" number:[[NSNumber alloc] initWithBool:[self IsEscapeAboutSpeechPositionDisplayBugOniOS12Enabled]]];
    [NiftyUtility addStringForJSONNSDictionary:result key:@"display_font_name" string:[self GetDisplayFontName]];
    [NiftyUtility addIntValueForJSONNSDictionary:result key:@"repeat_speech_type" number:[[NSNumber alloc] initWithInteger:[self GetRepeatSpeechType]]];
    [NiftyUtility addBoolValueForJSONNSDictionary:result key:@"is_mix_with_others_enabled" number:[[NSNumber alloc] initWithBool:[self IsMixWithOthersEnabled]]];
    [NiftyUtility addBoolValueForJSONNSDictionary:result key:@"is_duck_others_enabled" number:[[NSNumber alloc] initWithBool:[self IsDuckOthersEnabled]]];
    [NiftyUtility addBoolValueForJSONNSDictionary:result key:@"is_open_recent_novel_in_start_time_enabled" number:[[NSNumber alloc] initWithBool:[self IsOpenRecentNovelInStartTime]]];
    [NiftyUtility addBoolValueForJSONNSDictionary:result key:@"is_disallows_cellular_access" number:[[NSNumber alloc] initWithBool:[self IsDisallowsCellularAccess]]];
    [NiftyUtility addBoolValueForJSONNSDictionary:result key:@"is_need_confirm_delete_book" number:[[NSNumber alloc] initWithBool:[self IsNeedConfirmDeleteBook]]];
    UIColor* backgroundColor = [self GetReadingColorSettingForBackgroundColor];
    UIColor* foregroundColor = [self GetReadingColorSettingForForegroundColor];
    if (backgroundColor != nil && foregroundColor != nil) {
        NSMutableDictionary* colorSettingDictionary = [NSMutableDictionary new];
        CGFloat red, blue, green, alpha;
        NSMutableDictionary* colorDictionary = [NSMutableDictionary new];
        [backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
        [colorDictionary setValue:[[NSNumber alloc] initWithFloat:red] forKey:@"red"];
        [colorDictionary setValue:[[NSNumber alloc] initWithFloat:green] forKey:@"green"];
        [colorDictionary setValue:[[NSNumber alloc] initWithFloat:blue] forKey:@"blue"];
        [colorDictionary setValue:[[NSNumber alloc] initWithFloat:alpha] forKey:@"alpha"];
        [colorSettingDictionary setValue:colorDictionary forKey:@"background"];
        colorDictionary = [NSMutableDictionary new];
        [foregroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
        [colorDictionary setValue:[[NSNumber alloc] initWithFloat:red] forKey:@"red"];
        [colorDictionary setValue:[[NSNumber alloc] initWithFloat:green] forKey:@"green"];
        [colorDictionary setValue:[[NSNumber alloc] initWithFloat:blue] forKey:@"blue"];
        [colorDictionary setValue:[[NSNumber alloc] initWithFloat:alpha] forKey:@"alpha"];
        [colorSettingDictionary setValue:colorDictionary forKey:@"foreground"];
        [result setValue:colorSettingDictionary forKey:@"display_color_settings"];
    }
    NarouContentCacheData* currentReadingContent = [self GetCurrentReadingContent];
    if (currentReadingContent != nil) {
        [NiftyUtility addStringForJSONNSDictionary:result key:@"current_reading_content" string:currentReadingContent.ncode];
    }
    
    return result;
}

/// バックアップに使う情報を NSDictionary にして返します
- (NSDictionary*)CreateBackupDataDictionary{
    NSArray* bookselfArray = [self CreateBookselfBackupForJSONArray];
    NSDictionary* speechModDictionary = [self CreateSpeechModifierSettingDictionaryForJSON];
    NSArray* webImportBookmarkArray = [self CreateWebImportBookmarkSettingArrayForJSON];
    NSDictionary* speakPitchConfigDictionary = [self CreateSpeakPitchConfigDictionaryForJSON];
    NSArray* speechWaitConfigArray = [self CreateSpeechWaitConfigArrayForJSON];
    NSDictionary* miscSettingsDictionary = [self CreateMiscSettingsDictionaryForJSON];
    NSDictionary* backupData = @{
         @"data_version": @"1.1.0",
         @"bookshelf": bookselfArray,
         @"word_replacement_dictionary": speechModDictionary,
         @"web_import_bookmarks": webImportBookmarkArray,
         @"speak_pitch_config": speakPitchConfigDictionary,
         @"speech_wait_config": speechWaitConfigArray,
         @"misc_settings": miscSettingsDictionary,
    };
    return backupData;
}

// バックアップ用のデータを JSON に encode したものを生成して取得します
- (NSData*)CreateBackupJSONData{
    NSDictionary* backupData = [self CreateBackupDataDictionary];
    NSError* err = nil;
    NSData* resultData = [NSJSONSerialization dataWithJSONObject:backupData options:NSJSONWritingPrettyPrinted error:&err];
    if (err != nil) {
        NSLog(@"CreateBackupJSONData failed. %@", err);
        return nil;
    }
    return resultData;
}

// 指定された directory に保存されているファイルを個々の章として読み込みます
// 返り値として、読み込んだ最後の章番号(general_all_no)を返します。
// エラーの場合は負の数を返します。
- (long)LoadStoryText:(NarouContentCacheData*)content dataDirectory:(NSURL*)dataDirectory current_reading_chapter_number:(NSNumber*)current_reading_chapter_number current_reading_chapter_read_location:(NSNumber*)current_reading_chapter_read_location{
    if (dataDirectory == nil) {
        return -1;
    }
    NSError* error = nil;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray* fileURLArray = [fileManager contentsOfDirectoryAtURL:dataDirectory includingPropertiesForKeys:nil options:(NSDirectoryEnumerationSkipsHiddenFiles) error:&error];
    if (fileURLArray == nil || error != nil) {
        NSLog(@"directory file list read failed. %@ %@", [dataDirectory absoluteString], error);
        return false;
    }
    long fileNum = 0;
    long maxStoryNum = 0;
    for (NSURL* fileURL in fileURLArray) {
        NSString* lastPathComponent = [fileURL lastPathComponent];
        NSRange extensionLocation = [lastPathComponent rangeOfString:@".txt"];
        if (extensionLocation.location == NSNotFound) {
            NSLog(@"\".txt\" not found: %@", [fileURL absoluteString]);
            return false;
        }
        NSString* chapterNumberString = [lastPathComponent substringToIndex:extensionLocation.location];
        long chapterNumber = [chapterNumberString integerValue];
        if (chapterNumber <= 0) {
            NSLog(@"invalid fileNumber: %ld (%@)", chapterNumber, [fileURL absoluteString]);
            return false;
        }
        if (maxStoryNum < chapterNumber) {
            maxStoryNum = chapterNumber;
        }
        
        NSError* error = nil;
        NSString* story = [[NSString alloc] initWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:&error];
        if (error != nil) {
            NSLog(@"file read error: %@", error);
            return false;
        }
        [NiftyUtilitySwift DispatchSyncMainQueueWithBlock:^{
            [self UpdateStory:story chapter_number:(int)chapterNumber parentContent:content];
        }];

        fileNum += 1;
    }
    content.general_all_no = [[NSNumber alloc] initWithLong:maxStoryNum];
    [self UpdateNarouContent:content];
    
    StoryCacheData* storyCacheData = [self SearchStory:content.ncode chapter_no:[current_reading_chapter_number intValue]];
    if (storyCacheData != nil) {
        if (current_reading_chapter_read_location != nil) {
            storyCacheData.readLocation = current_reading_chapter_read_location;
        }
        BOOL result = [self UpdateReadingPoint:content story:storyCacheData];
        if (result == false) {
            NSLog(@"UpdateReadingPoint failed.");
        }
    }else{
        NSLog(@"can not find story: %@, chapter: %@", content.ncode, current_reading_chapter_number);
    }

    return maxStoryNum;
}

- (BOOL)LoadBookshelfURLType_V1_0_0:(NSDictionary*)bookshelfDictionary dataDirectory:(NSURL*)dataDirectory requestedURLHosts:(NSMutableDictionary*)requestedURLHosts{
    NSString* url = [NiftyUtility validateNSDictionaryForString:bookshelfDictionary key:@"url"];
    NSString* secret = [NiftyUtility validateNSDictionaryForString:bookshelfDictionary key:@"secret"];
    NSString* last_download_url = [NiftyUtility validateNSDictionaryForString:bookshelfDictionary key:@"last_download_url"];
    //NSLog(@"url: %@", url);
    //NSLog(@"secret: %@", secret);
    if (url == nil) {
        return false;
    }
    NSURL* urlObj = [NSURL URLWithString:url];
    if (urlObj == nil) {
        return false;
    }
    NSNumber* current_reading_chapter_number = [NiftyUtility validateNSDictionaryForNumber:bookshelfDictionary key:@"current_reading_chapter_number"];
    NSNumber* current_reading_chapter_read_location = [NiftyUtility validateNSDictionaryForNumber:bookshelfDictionary key:@"current_reading_chapter_read_location"];
    NSString* cookie = [NiftyUtility stringDecrypt:secret key:url];
    NSString* author = [NiftyUtility validateNSDictionaryForString:bookshelfDictionary key:@"author"];
    NSString* title = [NiftyUtility validateNSDictionaryForString:bookshelfDictionary key:@"title"];
    NSString* novelupdated_at_string = [NiftyUtility validateNSDictionaryForString:bookshelfDictionary key:@"novelupdated_at"];
    if (novelupdated_at_string == nil) {
        novelupdated_at_string = @"1970-01-01T00:00:00Z";
    }
    NSDate* novelupdated_at = [NiftyUtilitySwift ISO8601String2DateWithIso8601String:novelupdated_at_string];
    if (novelupdated_at == nil) {
        novelupdated_at = [[NSDate alloc] initWithTimeIntervalSince1970:0];
    }
    // とりあえずここまでの情報で NarouContent としてDBにエントリを作成しておく
    NarouContentCacheData* content = [NarouContentCacheData new];
    content.all_hyoka_cnt = [[NSNumber alloc] initWithInt:0];
    content.all_point = [[NSNumber alloc] initWithInt:0];
    content.end = [[NSNumber alloc] initWithBool:false];
    content.fav_novel_cnt = [[NSNumber alloc] initWithInt:0];
    content.general_all_no = [[NSNumber alloc] initWithInt:1];
    content.genre = [[NSNumber alloc] initWithInt:0];
    content.global_point = [[NSNumber alloc] initWithInt:0];
    content.is_new_flug = [[NSNumber alloc] initWithBool:false];
    content.keyword = cookie;
    content.ncode = url;
    content.novelupdated_at = novelupdated_at;
    content.reading_chapter = [[NSNumber alloc] initWithInt:0];
    content.review_cnt = [[NSNumber alloc] initWithInt:0];
    content.sasie_cnt = [[NSNumber alloc] initWithInt:0];
    content.story = @"";
    content.title = title;
    if (dataDirectory != nil) {
        content.userid = last_download_url;
    }else{
        content.userid = nil;
    }
    content.writer = author;
    content.current_download_complete_count = 0;
    
    NarouContentCacheData* targetContentCacheData = [self SearchNarouContentFromNcode:url];
    if (targetContentCacheData != nil) {
        // 既に登録済み情報があった場合はダウンロードに関する情報については登録済みの情報を優先する
        content.general_all_no = targetContentCacheData.general_all_no;
        content.userid = targetContentCacheData.userid;
    }
    [NiftyUtilitySwift DispatchSyncMainQueueWithBlock:^{
        [self UpdateNarouContent:content];
    }];
    
    // dataDirectory が指定されていて、content_directory に値が入っているならば、
    // そちらのデータで復元を試みる
    NSString* contentDirectory = [NiftyUtility validateNSDictionaryForString:bookshelfDictionary key:@"content_directory"];
    long general_all_no = 0;
    if (dataDirectory != nil && contentDirectory != nil &&
        (general_all_no = [self LoadStoryText:content dataDirectory:[dataDirectory URLByAppendingPathComponent:contentDirectory isDirectory:true] current_reading_chapter_number:current_reading_chapter_number current_reading_chapter_read_location:current_reading_chapter_read_location]) > 0){
        // それで正しく復元できたのであればダウンロードキューに入れることはせずに終了
        return true;
    }
    // テキストファイルからの復元はされなかったようなのでダウンロードキューに入れる
    [NiftyUtilitySwift DispatchSyncMainQueueWithBlock:^{
        //[self AddDirectoryDownloadQueueForURL:url cookieParameter:cookie author:author title:title];
        [self AddDownloadQueueForNarou:content];
    }];

    return true;
}

- (BOOL)LoadBookshelfNcodeType_V1_0_0:(NSDictionary*)bookshelfDictionary dataDirectory:(NSURL*)dataDirectory{
    NSString* ncode = [NiftyUtility validateNSDictionaryForString:bookshelfDictionary key:@"ncode"];
    //NSLog(@"ncode: %@", ncode);
    if ([ncode length] <= 0) {
        return false;
    }
    NarouContentCacheData* content = [NarouContentCacheData new];
    content.ncode = ncode;
#define LOAD_NUMBER_DATA(target, keyString) \
    { \
        NSNumber* tmpNumber = [NiftyUtility validateNSDictionaryForNumber:bookshelfDictionary key: keyString ]; \
        if (tmpNumber != nil) { \
            target = tmpNumber; \
        }else{ \
            target = [[NSNumber alloc] initWithInt:0]; \
        } \
    }
    LOAD_NUMBER_DATA(content.all_hyoka_cnt, @"all_hyoka_cnt")
    LOAD_NUMBER_DATA(content.all_point, @"all_point")
    LOAD_NUMBER_DATA(content.end, @"end")
    LOAD_NUMBER_DATA(content.fav_novel_cnt, @"fav_novel_cnt")
    LOAD_NUMBER_DATA(content.general_all_no, @"general_all_no")
    LOAD_NUMBER_DATA(content.genre, @"genre")
    LOAD_NUMBER_DATA(content.global_point, @"global_point")
    LOAD_NUMBER_DATA(content.is_new_flug, @"is_new_flug")
    LOAD_NUMBER_DATA(content.reading_chapter, @"reading_chapter")
    LOAD_NUMBER_DATA(content.review_cnt, @"review_cnt")
    LOAD_NUMBER_DATA(content.sasie_cnt, @"sasie_cnt")
#undef LOAD_NUMBER_DATA

#define LOAD_STRING_DATA(target, keyString) \
    { \
        NSString* tmpString = [NiftyUtility validateNSDictionaryForString:bookshelfDictionary key: keyString ]; \
        if (tmpString != nil) { \
            target = tmpString; \
        }else{ \
            target = @"";\
        } \
    }
    LOAD_STRING_DATA(content.keyword, @"keyword")
    LOAD_STRING_DATA(content.story, @"story")
    LOAD_STRING_DATA(content.title, @"title")
    LOAD_STRING_DATA(content.userid, @"userid")
    LOAD_STRING_DATA(content.writer, @"writer")
#undef LOAD_STRING_DATA
    NSString* novelupdated_at_string = [NiftyUtility validateNSDictionaryForString:bookshelfDictionary key:@"novelupdated_at"];
    if (novelupdated_at_string == nil) {
        novelupdated_at_string = @"1970-01-01T00:00:00Z";
    }
    content.novelupdated_at = [NiftyUtilitySwift ISO8601String2DateWithIso8601String:novelupdated_at_string];
    if (content.novelupdated_at == nil) {
        content.novelupdated_at = [[NSDate alloc] initWithTimeIntervalSince1970:0];
    }

    [NiftyUtilitySwift DispatchSyncMainQueueWithBlock:^{
        [self UpdateNarouContent:content];
    }];
    
    NSNumber* current_reading_chapter_number = [NiftyUtility validateNSDictionaryForNumber:bookshelfDictionary key:@"current_reading_chapter_number"];
    NSNumber* current_reading_chapter_read_location = [NiftyUtility validateNSDictionaryForNumber:bookshelfDictionary key:@"current_reading_chapter_read_location"];

    // dataDirectory が指定されていて、content_directory に値が入っているならば、
    // そちらのデータで復元を試みる
    NSString* contentDirectory = [NiftyUtility validateNSDictionaryForString:bookshelfDictionary key:@"content_directory"];
    long general_all_no = 0;
    if (dataDirectory != nil && contentDirectory != nil &&
        (general_all_no = [self LoadStoryText:content dataDirectory:[dataDirectory URLByAppendingPathComponent:contentDirectory isDirectory:true] current_reading_chapter_number:current_reading_chapter_number current_reading_chapter_read_location:current_reading_chapter_read_location]) > 0){
        [NiftyUtilitySwift DispatchSyncMainQueueWithBlock:^{
            content.general_all_no = [[NSNumber alloc] initWithLong:general_all_no];
            [self UpdateNarouContent:content];
        }];
        // それで正しく復元できたのであればダウンロードキューに入れることはせずに終了
        return true;
    }
    
    [NiftyUtilitySwift DispatchSyncMainQueueWithBlock:^{
        [self AddDownloadQueueForNarouNcode:ncode];
    }];
    
    return true;
}

- (void)RestoreBackupFromBookshelfDataArray_V1_0_0:(NSArray*)bookshelfDataArray dataDirectory:(NSURL*)dataDirectory progress:(void (^)(NSString*))progress{
    // 一時的に小説のダウンロードを止めておきます
    [m_DownloadQueue PauseDownload];
    NSMutableDictionary* requestedURLHosts = [NSMutableDictionary new];
    int n = 0;
    for (id obj in bookshelfDataArray) {
        n += 1;
        if (progress != nil) {
            progress([[NSString alloc] initWithFormat:@"%@ (%d/%lu)"
                      , NSLocalizedString(@"GlobalDataSingleton_RestoreingBookProgress", @"小説の復元中")
                      , n, (unsigned long)[bookshelfDataArray count]]);
        }
        if (![obj isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSDictionary* bookshelfDictionary = obj;
        NSString* type = [NiftyUtility validateNSDictionaryForString:bookshelfDictionary key:@"type"];
        //NSLog(@"type: %@", type);
        if ([type compare:@"ncode"] == NSOrderedSame) {
            [self LoadBookshelfNcodeType_V1_0_0:bookshelfDictionary dataDirectory:dataDirectory];
        }else if([type compare:@"url"] == NSOrderedSame) {
            [self LoadBookshelfURLType_V1_0_0:bookshelfDictionary dataDirectory:dataDirectory requestedURLHosts:requestedURLHosts];
        }else if([type compare:@"user"] == NSOrderedSame) {
            NSString* title = [NiftyUtility validateNSDictionaryForString:bookshelfDictionary key:@"title"];
            NSString* ncode = [NiftyUtility validateNSDictionaryForString:bookshelfDictionary key:@"id"];
            NSArray* storyArray = [NiftyUtility validateNSDictionaryForArray:bookshelfDictionary key:@"storys"];
            //NSLog(@"title: %@", title);
            //NSLog(@"ncode: %@", ncode);
            if (title == nil) {
                title = NSLocalizedString(@"GlobalDataSingleton_NewUserBookTitle", @"新規ユーザ小説");
            }
            if (ncode == nil || [ncode length] != 10) {
                NSLog(@"ユーザ小説で、不正な ncode　が指定されているため無視します。");
                continue;
            }
            if (storyArray == nil || [storyArray count] <= 0) {
                continue;
            }
            NarouContentCacheData* content = [self CreateNewUserBook]; // で作った奴の ncode を上書きすれば良い
            content.ncode = ncode;
            content.title = title;
            content.general_all_no = [[NSNumber alloc] initWithUnsignedInteger:[storyArray count]];
            [NiftyUtilitySwift DispatchSyncMainQueueWithBlock:^{
                [self UpdateNarouContent:content];
            }];
            int chapterNumber = 1;
            for (id storyObj in storyArray) {
                if (![storyObj isKindOfClass:[NSString class]]) {
                    continue;
                }
                NSString* story = storyObj;
                [NiftyUtilitySwift DispatchSyncMainQueueWithBlock:^{
                    [self UpdateStory:story chapter_number:chapterNumber parentContent:content];
                }];
                chapterNumber += 1;
            }
        }
    }
    // 停止していたダウンロードを再開させます
    [m_DownloadQueue ResumeDownload];
}

- (void)RestoreBackupFromSpeechModDictionary_V1_0_0:speechModDictionary{
    NSMutableArray* mutableArray = [NSMutableArray new];
    for (id keyObj in [speechModDictionary keyEnumerator]) {
        if (![keyObj isKindOfClass:[NSString class]]) {
            continue;
        }
        NSString* key = keyObj;
        NSString* value = [NiftyUtility validateNSDictionaryForString:speechModDictionary key:keyObj];
        if (value == nil) {
            continue;
        }
        SpeechModSettingCacheData* speechModSetting = [[SpeechModSettingCacheData alloc] initWithBeforeString:key afterString:value type:SpeechModSettingConvertType_JustMatch];
        [mutableArray addObject:speechModSetting];
    }
    [self UpdateSpeechModSettingMultiple:mutableArray];
}

- (void)RestoreBackupFromSpeechModDictionary_V1_1_0:speechModDictionary{
    NSMutableArray* mutableArray = [NSMutableArray new];
    for (id keyObj in [speechModDictionary keyEnumerator]) {
        if (![keyObj isKindOfClass:[NSString class]]) {
            continue;
        }
        NSString* key = keyObj;
        NSDictionary* data = [NiftyUtility validateNSDictionaryForDictionary:speechModDictionary key:key];
        if(data == nil){
            continue;
        }
        NSString* value = [NiftyUtility validateNSDictionaryForString:data key:@"afterString"];
        if (value == nil) {
            continue;
        }
        NSNumber* typeNumber = [NiftyUtility validateNSDictionaryForNumber:data key:@"type"];
        if (typeNumber == nil) {
            continue;
        }
        NSUInteger type = [typeNumber unsignedIntegerValue];
        if(type != SpeechModSettingConvertType_JustMatch
           && type != SpeechModSettingConvertType_Regexp){
            continue;
        }
        SpeechModSettingCacheData* speechModSetting = [[SpeechModSettingCacheData alloc] initWithBeforeString:key afterString:value type:type];
        [mutableArray addObject:speechModSetting];
    }
    [self UpdateSpeechModSettingMultiple:mutableArray];
}

- (void)RestoreBackupFromWebImportBookmarkArray_V1_0_0:(NSArray*)bookmarks{
    //[self ClearWebImportBookmarks];
    for (id obj in bookmarks) {
        if (![obj isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSDictionary* nameURLDictionary = obj;
        for (NSString* nameString in [nameURLDictionary keyEnumerator]) {
            if (nameString == nil || [nameString length] <= 0) {
                continue;
            }
            id urlId = [nameURLDictionary objectForKey:nameString];
            if (![urlId isKindOfClass:[NSString class]]) {
                continue;
            }
            NSString* urlString = urlId;
            NSURL* url = [[NSURL alloc] initWithString:urlString];
            if (url == nil) {
                continue;
            }
            [self AddWebImportBookmarkForName:nameString url:url];
        }
    }
}

- (void)RestoreBackupFromSpeakPitchConfigDictionary_V1_0_0:(NSDictionary*)configDictionary{
    NSDictionary* defaultSetting = [NiftyUtility validateNSDictionaryForDictionary:configDictionary key:@"default"];
    
    if (defaultSetting != nil) {
        GlobalStateCacheData* globalState = [self GetGlobalState];
        BOOL isOverride = false;
        NSNumber* pitch = [NiftyUtility validateNSDictionaryForNumber:defaultSetting key:@"pitch"];
        if (pitch != nil) {
            float pitchFloat = [pitch floatValue];
            if (pitchFloat >= 0.5f && pitchFloat <= 2.0f) {
                globalState.defaultPitch = pitch;
                isOverride = true;
            }
        }
        NSNumber* rate = [NiftyUtility validateNSDictionaryForNumber:defaultSetting key:@"rate"];
        if (rate != nil) {
            float rateFloat = [rate floatValue];
            if (rateFloat >= AVSpeechUtteranceMinimumSpeechRate && rateFloat <= AVSpeechUtteranceMaximumSpeechRate) {
                globalState.defaultRate = rate;
                isOverride = true;
            }
        }
        if (isOverride) {
            [self UpdateGlobalState:globalState];
        }
    }

    NSArray* otherSettingArray = [NiftyUtility validateNSDictionaryForArray:configDictionary key:@"others"];
    if (otherSettingArray != nil) {
        for (id obj in otherSettingArray) {
            if (obj != nil && [obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary* dic = (NSDictionary*)obj;
                NSString* title = [NiftyUtility validateNSDictionaryForString:dic key:@"title"];
                NSString* startText = [NiftyUtility validateNSDictionaryForString:dic key:@"start_text"];
                NSString* endText = [NiftyUtility validateNSDictionaryForString:dic key:@"end_text"];
                NSNumber* pitch = [NiftyUtility validateNSDictionaryForNumber:dic key:@"pitch"];
                float pitchFloat = [pitch floatValue];
                if (title != nil && [title length] > 0
                    && startText != nil && [startText length] > 0
                    && endText != nil && [endText length] > 0
                    && pitchFloat >= 0.5f && pitchFloat <= 2.0f) {
                    SpeakPitchConfigCacheData* pitchConfig = [SpeakPitchConfigCacheData new];
                    pitchConfig.title = title;
                    pitchConfig.startText = startText;
                    pitchConfig.endText = endText;
                    pitchConfig.pitch = pitch;
                    [self UpdateSpeakPitchConfig:pitchConfig];
                }
            }
        }
    }
}

- (void)RestoreBackupFromSpeechWaitConfigArray_V1_0_0:(NSArray*)speechWaitConfigArray{
    for (id obj in speechWaitConfigArray) {
        if (obj != nil && [obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dic = (NSDictionary*)obj;
            NSString* target_text = [NiftyUtility validateNSDictionaryForString:dic key:@"target_text"];
            NSNumber* delay_time_in_sec = [NiftyUtility validateNSDictionaryForNumber:dic key:@"delay_time_in_sec"];
            if (target_text != nil && [target_text length] > 0 && delay_time_in_sec != nil) {
                SpeechWaitConfigCacheData* waitConfig = [SpeechWaitConfigCacheData new];
                waitConfig.targetText = target_text;
                waitConfig.delayTimeInSec = delay_time_in_sec;
                [self AddSpeechWaitSetting:waitConfig];
            }
        }
    }
}

- (NSString*)RestoreBackupFromMiscSettingsDictionary_V1_0_0:(NSDictionary*)miscSettingsDictionary {
    GlobalStateCacheData* globalState = [self GetGlobalState];
    
    BOOL isUpdated = false;
    NSNumber* max_speech_time_in_sec = [NiftyUtility validateNSDictionaryForNumber:miscSettingsDictionary key:@"max_speech_time_in_sec"];
    if (max_speech_time_in_sec != nil) {
        globalState.maxSpeechTimeInSec = max_speech_time_in_sec;
        isUpdated = true;
    }
    NSNumber* text_size_value = [NiftyUtility validateNSDictionaryForNumber:miscSettingsDictionary key:@"text_size_value"];
    if (text_size_value != nil) {
        globalState.textSizeValue = text_size_value;
        isUpdated = true;
    }
    NSNumber* speech_wait_setting_use_experimental_wait = [NiftyUtility validateNSDictionaryForNumber:miscSettingsDictionary key:@"speech_wait_setting_use_experimental_wait"];
    if (speech_wait_setting_use_experimental_wait != nil) {
        globalState.speechWaitSettingUseExperimentalWait = speech_wait_setting_use_experimental_wait;
        isUpdated = true;
    }
    if (isUpdated) {
        [self UpdateGlobalState:globalState];
    }
    
    NSString* default_voice_identifier = [NiftyUtility validateNSDictionaryForString:miscSettingsDictionary key:@"default_voice_identifier"];
    if (default_voice_identifier != nil && [default_voice_identifier length] > 0 && [NiftySpeaker isValidVoiceIdentifier:default_voice_identifier]) {
        [self SetVoiceIdentifier:default_voice_identifier];
    }
    NSNumber* content_sort_type = [NiftyUtility validateNSDictionaryForNumber:miscSettingsDictionary key:@"content_sort_type"];
    if (content_sort_type != nil) {
        NSUInteger uint = [content_sort_type unsignedIntegerValue];
        if (uint == NarouContentSortType_Ncode
            || uint == NarouContentSortType_Title
            || uint == NarouContentSortType_Writer
            || uint == NarouContentSortType_NovelUpdatedAt
            ) {
            [self SetBookSelfSortType:uint];
        }
    }
    NSNumber* menuitem_is_add_speech_mod_setting_only = [NiftyUtility validateNSDictionaryForNumber:miscSettingsDictionary key:@"menuitem_is_add_speech_mod_setting_only"];
    if (menuitem_is_add_speech_mod_setting_only != nil) {
        [self SetMenuItemIsAddSpeechModSettingOnly:[menuitem_is_add_speech_mod_setting_only boolValue]];
    }
    NSNumber* override_ruby_is_enabled = [NiftyUtility validateNSDictionaryForNumber:miscSettingsDictionary key:@"override_ruby_is_enabled"];
    if (override_ruby_is_enabled != nil) {
        [self SetOverrideRubyIsEnabled:[override_ruby_is_enabled boolValue]];
    }
    NSNumber* is_ignore_url_speech_enabled = [NiftyUtility validateNSDictionaryForNumber:miscSettingsDictionary key:@"is_ignore_url_speech_enabled"];
    if (is_ignore_url_speech_enabled != nil) {
        [self SetIgnoreURIStringSpeechIsEnabled:[is_ignore_url_speech_enabled boolValue]];
    }
    NSString* not_ruby_charactor_array = [NiftyUtility validateNSDictionaryForString:miscSettingsDictionary key:@"not_ruby_charactor_array"];
    if (not_ruby_charactor_array != nil) {
        [self SetNotRubyCharactorStringArray:not_ruby_charactor_array];
    }
    NSNumber* force_siteinfo_reload_is_enabled = [NiftyUtility validateNSDictionaryForNumber:miscSettingsDictionary key:@"force_siteinfo_reload_is_enabled"];
    if (force_siteinfo_reload_is_enabled != nil) {
        [self SetForceSiteInfoReloadIsEnabled:[force_siteinfo_reload_is_enabled boolValue]];
    }
    NSNumber* is_reading_progress_display_enabled = [NiftyUtility validateNSDictionaryForNumber:miscSettingsDictionary key:@"is_reading_progress_display_enabled"];
    if (is_reading_progress_display_enabled != nil) {
        [self SetReadingProgressDisplayEnabled:[is_reading_progress_display_enabled boolValue]];
    }
    NSNumber* is_short_skip_enabled = [NiftyUtility validateNSDictionaryForNumber:miscSettingsDictionary key:@"is_short_skip_enabled"];
    if (is_short_skip_enabled != nil) {
        [self SetShortSkipEnabled:[is_short_skip_enabled boolValue]];
    }
    NSNumber* is_playback_duration_enabled = [NiftyUtility validateNSDictionaryForNumber:miscSettingsDictionary key:@"is_playback_duration_enabled"];
    if (is_playback_duration_enabled != nil) {
        [self SetPlaybackDurationIsEnabled:[is_playback_duration_enabled boolValue]];
    }
    NSNumber* is_page_turning_sound_enabled = [NiftyUtility validateNSDictionaryForNumber:miscSettingsDictionary key:@"is_page_turning_sound_enabled"];
    if (is_page_turning_sound_enabled != nil) {
        [self SetPageTurningSoundIsEnabled:[is_page_turning_sound_enabled boolValue]];
    }
    NSString* display_font_name = [NiftyUtility validateNSDictionaryForString:miscSettingsDictionary key:@"display_font_name"];
    if (display_font_name != nil && [display_font_name length] > 0 && [NiftyUtilitySwift isValidFontNameWithFontName:display_font_name]) {
        [self SetDisplayFontName:display_font_name];
    }
    NSNumber* repeat_speech_type = [NiftyUtility validateNSDictionaryForNumber:miscSettingsDictionary key:@"repeat_speech_type"];
    if (repeat_speech_type != nil) {
        [self SetRepeatSpeechType:[repeat_speech_type integerValue]];
    }
    /*
    NSNumber* is_escape_about_speech_position_display_bug_on_ios12_enabled = [NiftyUtility validateNSDictionaryForNumber:miscSettingsDictionary key:@"is_escape_about_speech_position_display_bug_on_ios12_enabled"];
    if (is_escape_about_speech_position_display_bug_on_ios12_enabled != nil) {
        [self SetEscapeAboutSpeechPositionDisplayBugOniOS12Enabled:[is_escape_about_speech_position_display_bug_on_ios12_enabled boolValue]];
    }
     */
    NSNumber* is_mix_with_others_enabled = [NiftyUtility validateNSDictionaryForNumber:miscSettingsDictionary key:@"is_mix_with_others_enabled"];
    if (is_mix_with_others_enabled != nil) {
        [self SetIsMixWithOthersEnabled:[is_mix_with_others_enabled boolValue]];
    }
    NSNumber* is_duck_others_enabled = [NiftyUtility validateNSDictionaryForNumber:miscSettingsDictionary key:@"is_duck_others_enabled"];
    if (is_duck_others_enabled != nil) {
        [self SetIsDuckOthersEnabled:[is_duck_others_enabled boolValue]];
    }
    NSNumber* is_open_recent_novel_in_start_time_enabled = [NiftyUtility validateNSDictionaryForNumber:miscSettingsDictionary key:@"is_open_recent_novel_in_start_time_enabled"];
    if (is_open_recent_novel_in_start_time_enabled != nil) {
        [self SetIsOpenRecentNovelInStartTime:[is_open_recent_novel_in_start_time_enabled boolValue]];
    }
    NSNumber* is_disallows_cellular_access = [NiftyUtility validateNSDictionaryForNumber:miscSettingsDictionary key:@"is_disallows_cellular_access"];
    if (is_disallows_cellular_access != nil) {
        [self SetIsDisallowsCellularAccess:[is_disallows_cellular_access boolValue]];
    }
    NSNumber* is_need_confirm_delete_book = [NiftyUtility validateNSDictionaryForNumber:miscSettingsDictionary key:@"is_need_confirm_delete_book"];
    if (is_need_confirm_delete_book != nil) {
        [self SetIsNeedConfirmDeleteBook:[is_need_confirm_delete_book boolValue]];
    }
    NSDictionary* display_color_settings = [NiftyUtility validateNSDictionaryForDictionary:miscSettingsDictionary key:@"display_color_settings"];
    if (display_color_settings != nil) {
        NSLog(@"display_color_settings: != nil");
        NSDictionary* backgroundColorSetting = [NiftyUtility validateNSDictionaryForDictionary:display_color_settings key:@"background"];
        NSDictionary* foregroundColorSetting = [NiftyUtility validateNSDictionaryForDictionary:display_color_settings key:@"foreground"];
        UIColor* backgroundColor = nil;
        UIColor* foregroundColor = nil;
        if (backgroundColorSetting != nil) {
            CGFloat red, green, blue, alpha;
            red = green = blue = alpha = -1.0;
            NSNumber* color = nil;
            if ((color = [NiftyUtility validateNSDictionaryForNumber:backgroundColorSetting key:@"red"]) != nil) {
                red = [color floatValue];
            }
            if ((color = [NiftyUtility validateNSDictionaryForNumber:backgroundColorSetting key:@"green"]) != nil) {
                green = [color floatValue];
            }
            if ((color = [NiftyUtility validateNSDictionaryForNumber:backgroundColorSetting key:@"blue"]) != nil) {
                blue = [color floatValue];
            }
            if ((color = [NiftyUtility validateNSDictionaryForNumber:backgroundColorSetting key:@"alpha"]) != nil) {
                alpha = [color floatValue];
            }
            NSLog(@"display_color_settings: bgColor RGBA: %.2f, %.2f, %.2f, %.2f", red, green, blue, alpha);
            if (!(red < 0.0 || green < 0.0 || blue < 0.0 || alpha < 0.0
                || red > 1.0 || green > 1.0 || blue > 1.0 || alpha > 1.0)) {
                backgroundColor = [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
            }
        }
        if (foregroundColorSetting != nil) {
            CGFloat red, green, blue, alpha;
            red = green = blue = alpha = -1.0;
            NSNumber* color = nil;
            if ((color = [NiftyUtility validateNSDictionaryForNumber:foregroundColorSetting key:@"red"]) != nil) {
                red = [color floatValue];
            }
            if ((color = [NiftyUtility validateNSDictionaryForNumber:foregroundColorSetting key:@"green"]) != nil) {
                green = [color floatValue];
            }
            if ((color = [NiftyUtility validateNSDictionaryForNumber:foregroundColorSetting key:@"blue"]) != nil) {
                blue = [color floatValue];
            }
            if ((color = [NiftyUtility validateNSDictionaryForNumber:foregroundColorSetting key:@"alpha"]) != nil) {
                alpha = [color floatValue];
            }
            NSLog(@"display_color_settings: fgColor RGBA: %.2f, %.2f, %.2f, %.2f", red, green, blue, alpha);
            if (!(red < 0.0 || green < 0.0 || blue < 0.0 || alpha < 0.0
                || red > 1.0 || green > 1.0 || blue > 1.0 || alpha > 1.0)) {
                foregroundColor = [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
            }
        }
        NSLog(@"display_color_settings: bgColor: %p, fgColor: %p", backgroundColor, foregroundColor);
        if (backgroundColor != nil && foregroundColor != nil) {
            NSLog(@"display_color_settings: set color.");
            [self SetReadingColorSettingForBackgroundColor:backgroundColor];
            [self SetReadingColorSettingForForegroundColor:foregroundColor];
        }
    }
    NSString* current_reading_content = [NiftyUtility validateNSDictionaryForString:miscSettingsDictionary key:@"current_reading_content"];
    return current_reading_content;
}

- (void)RestoreBackupFromJSONData_V1_0_0:(NSDictionary*)toplevelDictionary dataDirectory:(NSURL*)dataDirectory progress:(void (^)(NSString*))progress{
    if (progress != nil) {
        progress(NSLocalizedString(@"GlobalDataSingleton_RestoreBackupFromJSONProgress_RestoreSettings", @"工程 1\r\n設定の復元中"));
    }
    NSDictionary* speechModDictionary = [NiftyUtility validateNSDictionaryForDictionary:toplevelDictionary key:@"word_replacement_dictionary"];
    if (speechModDictionary != nil) {
        [self RestoreBackupFromSpeechModDictionary_V1_0_0:speechModDictionary];
    }
    NSArray* webImportBookmarkDataArray = [NiftyUtility validateNSDictionaryForArray:toplevelDictionary key:@"web_import_bookmarks"];
    if (webImportBookmarkDataArray != nil) {
        [self RestoreBackupFromWebImportBookmarkArray_V1_0_0:webImportBookmarkDataArray];
    }
    NSDictionary* pitchConfigDictionary = [NiftyUtility validateNSDictionaryForDictionary:toplevelDictionary key:@"speak_pitch_config"];
    if (pitchConfigDictionary != nil) {
        [self RestoreBackupFromSpeakPitchConfigDictionary_V1_0_0:pitchConfigDictionary];
    }
    NSArray* speechWaitConfigArray = [NiftyUtility validateNSDictionaryForArray:toplevelDictionary key:@"speech_wait_config"];
    if (speechWaitConfigArray != nil) {
        [self RestoreBackupFromSpeechWaitConfigArray_V1_0_0:speechWaitConfigArray];
    }
    NSString* currentReadingNcode = nil;
    NSDictionary* miscSettingsDictionary = [NiftyUtility validateNSDictionaryForDictionary:toplevelDictionary key:@"misc_settings"];
    if (miscSettingsDictionary != nil) {
        currentReadingNcode = [self RestoreBackupFromMiscSettingsDictionary_V1_0_0:miscSettingsDictionary];
    }
    // 本棚は最後に読み込むようにします。
    NSArray* bookshelfDataArray = [NiftyUtility validateNSDictionaryForArray:toplevelDictionary key:@"bookshelf"];
    if (bookshelfDataArray != nil) {
        [self RestoreBackupFromBookshelfDataArray_V1_0_0:bookshelfDataArray dataDirectory:dataDirectory progress:progress];
    }
    // 最後に読んでいたコンテンツを上書きしておきます(本棚を読み込んだ時に上書きされているので)
    if (currentReadingNcode != nil) {
        NarouContentCacheData* content = [self SearchNarouContentFromNcode:currentReadingNcode];
        if (content != nil && content.currentReadingStory != nil) {
            [self UpdateReadingPoint:content story:content.currentReadingStory];
        }
    }
    
    // config が書き換わったことをアナウンスする
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    NSNotification* notification = [NSNotification notificationWithName:@"ConfigReloaded_DisplayUpdateNeeded" object:self userInfo:nil];
    [notificationCenter postNotification:notification];
}

- (void)RestoreBackupFromJSONData_V1_1_0:(NSDictionary*)toplevelDictionary dataDirectory:(NSURL*)dataDirectory progress:(void (^)(NSString*))progress{
    if (progress != nil) {
        progress(NSLocalizedString(@"GlobalDataSingleton_RestoreBackupFromJSONProgress_RestoreSettings", @"工程 1\r\n設定の復元中"));
    }
    NSDictionary* speechModDictionary = [NiftyUtility validateNSDictionaryForDictionary:toplevelDictionary key:@"word_replacement_dictionary"];
    if (speechModDictionary != nil) {
        [self RestoreBackupFromSpeechModDictionary_V1_1_0:speechModDictionary];
    }
    NSArray* webImportBookmarkDataArray = [NiftyUtility validateNSDictionaryForArray:toplevelDictionary key:@"web_import_bookmarks"];
    if (webImportBookmarkDataArray != nil) {
        [self RestoreBackupFromWebImportBookmarkArray_V1_0_0:webImportBookmarkDataArray];
    }
    NSDictionary* pitchConfigDictionary = [NiftyUtility validateNSDictionaryForDictionary:toplevelDictionary key:@"speak_pitch_config"];
    if (pitchConfigDictionary != nil) {
        [self RestoreBackupFromSpeakPitchConfigDictionary_V1_0_0:pitchConfigDictionary];
    }
    NSArray* speechWaitConfigArray = [NiftyUtility validateNSDictionaryForArray:toplevelDictionary key:@"speech_wait_config"];
    if (speechWaitConfigArray != nil) {
        [self RestoreBackupFromSpeechWaitConfigArray_V1_0_0:speechWaitConfigArray];
    }
    NSString* currentReadingNcode = nil;
    NSDictionary* miscSettingsDictionary = [NiftyUtility validateNSDictionaryForDictionary:toplevelDictionary key:@"misc_settings"];
    if (miscSettingsDictionary != nil) {
        currentReadingNcode = [self RestoreBackupFromMiscSettingsDictionary_V1_0_0:miscSettingsDictionary];
    }
    // 本棚は最後に読み込むようにします。
    NSArray* bookshelfDataArray = [NiftyUtility validateNSDictionaryForArray:toplevelDictionary key:@"bookshelf"];
    if (bookshelfDataArray != nil) {
        [self RestoreBackupFromBookshelfDataArray_V1_0_0:bookshelfDataArray dataDirectory:dataDirectory progress:progress];
    }
    // 最後に読んでいたコンテンツを上書きしておきます(本棚を読み込んだ時に上書きされているので)
    if (currentReadingNcode != nil) {
        NarouContentCacheData* content = [self SearchNarouContentFromNcode:currentReadingNcode];
        if (content != nil && content.currentReadingStory != nil) {
            [self UpdateReadingPoint:content story:content.currentReadingStory];
        }
    }
    
    // config が書き換わったことをアナウンスする
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    NSNotification* notification = [NSNotification notificationWithName:@"ConfigReloaded_DisplayUpdateNeeded" object:self userInfo:nil];
    [notificationCenter postNotification:notification];
}
    
/// JSONData に入っているバックアップを書き戻します。
/// dataDirectory が指示されていて、かつ、本棚データに content_directory が存在した場合は
/// ダウンロードせずにそのディレクトリにあるファイル群を章のデータとして読み込みます。
- (BOOL)RestoreBackupFromJSONData:(NSData*)jsonData dataDirectory:(NSURL*)dataDirectory progress:(void (^)(NSString*))progress {
    NSError* err = nil;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&err];
    if (err != nil || jsonObj == nil) {
        NSLog(@"RestoreBackupFromJSONData: JSONObjectWithData failed. %@", err);
        return false;
    }
    if (![jsonObj isKindOfClass:[NSDictionary class]]) {
        NSLog(@"RestoreBackupFromJSONData: toplevel isMemberObClass NSDictionary fail.");
        return false;
    }
    NSDictionary* toplevelDictionary = (NSDictionary*)jsonObj;
    NSString* dataVersion = [NiftyUtility validateNSDictionaryForString:toplevelDictionary key:@"data_version"];
    if (dataVersion == nil) {
        return false;
    }
    
    if ([dataVersion compare:@"1.0.0"] == NSOrderedSame) {
        [self RestoreBackupFromJSONData_V1_0_0:toplevelDictionary dataDirectory:dataDirectory progress:progress];
    }else if ([dataVersion compare:@"1.1.0"] == NSOrderedSame){
        [self RestoreBackupFromJSONData_V1_1_0:toplevelDictionary dataDirectory:dataDirectory progress:progress];
    }

    return true;
}

/// JSONData に入っているバックアップを書き戻します。
- (BOOL)RestoreBackupFromZIPData:(NSURL*)filePath finally:(void(^)(BOOL))finally {
    if (filePath == nil) {
        if (finally != nil) {
            finally(false);
        }
        return false;
    }
    __block UIViewController* toplevelViewController = nil;
    __block BOOL result = false;
    [NiftyUtilitySwift DispatchSyncMainQueueWithBlock:^{
        toplevelViewController = [UIViewController toplevelViewController];
        result = [NovelSpeakerBackup parseBackupFileWithUrl:filePath toplevelViewController:toplevelViewController finally:^(BOOL finalResult) {
            if (finally != nil) {
                finally(finalResult);
            }
        }];
    }];
    return result;
}

/// 指定されたファイルを自作小説として読み込む
/// とりあえずはベタな plain text ファイルを一つの章として取り込みます
- (BOOL)ImportNovelFromFile:(NSURL*)url{
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSString* text = [[NSString alloc] initWithData:data encoding:[data detectEncoding]];
    if (text == nil) {
        return false;
    }
    NSString* fileName = [url lastPathComponent];
    if (fileName == nil) {
        fileName = @"unknown.txt";
    }
    NSString* title = [fileName stringByDeletingPathExtension];
    if (title == nil) {
        title = @"unknown title";
    }
    __block UIViewController* rootViewController = nil;
    [NiftyUtilitySwift DispatchSyncMainQueueWithBlock:^{
        rootViewController = [UIViewController toplevelViewController];
    }];
    [NiftyUtilitySwift checkTextImportConifirmToUserWithViewController:rootViewController title:title content:text hintString:nil];
    return true;
}

- (BOOL)ImportNovelFromPDFFile:(NSURL*)url{
    NSString* text = [NiftyUtilitySwift FilePDFToStringWithUrl:url];
    __block UIViewController* toplevelViewController = nil;
    [NiftyUtilitySwift DispatchSyncMainQueueWithBlock:^{
        toplevelViewController = [UIViewController toplevelViewController];
    }];
    if (text == nil) {
        [NiftyUtilitySwift EasyDialogOneButtonWithViewController:toplevelViewController title:NSLocalizedString(@"GlobalDataSingleton_PDFToStringFailed_Title", @"PDFのテキスト読み込みに失敗") message:NSLocalizedString(@"GlobalDataSingleton_PDFToStringFailed_Body", @"PDFファイルからの文字列読み込みに失敗しました。\nPDFファイルによっては文字列を読み込めない場合があります。また、iOS11より前のiOSではPDF読み込み機能は動作しません。") buttonTitle:nil buttonAction:nil];
        return false;
    }
    NSString* fileName = [url lastPathComponent];
    if (fileName == nil) {
        fileName = @"unknown.txt";
    }
    NSString* title = [fileName stringByDeletingPathExtension];
    if (title == nil) {
        title = @"unknown title";
    }
    [NiftyUtilitySwift checkTextImportConifirmToUserWithViewController:toplevelViewController title:title content:text hintString:nil];
    return true;
}

- (BOOL)ImportNovelFromRTFFile:(NSURL*)url{
    NSAttributedString* text = [NiftyUtilitySwift FileRTFToAttributedStringWithUrl:url];
    __block UIViewController* toplevelViewController = nil;
    [NiftyUtilitySwift DispatchSyncMainQueueWithBlock:^{
        toplevelViewController = [UIViewController toplevelViewController];
    }];
    if (text == nil) {
        
        [NiftyUtilitySwift EasyDialogOneButtonWithViewController:toplevelViewController title:nil message:NSLocalizedString(@"GlobalDataSingleton_RTFToStringFailed_Title", @"RTFのテキスト読み込みに失敗")  buttonTitle:nil buttonAction:nil];
        return false;
    }
    NSString* fileName = [url lastPathComponent];
    if (fileName == nil) {
        fileName = @"unknown.txt";
    }
    NSString* title = [fileName stringByDeletingPathExtension];
    if (title == nil) {
        title = @"unknown title";
    }
    [NiftyUtilitySwift checkTextImportConifirmToUserWithViewController:toplevelViewController title:title content:[text string] hintString:nil];
    return false;
}
- (BOOL)ImportNovelFromRTFDFile:(NSURL*)url{
    NSAttributedString* text = [NiftyUtilitySwift FileRTFDToAttributedStringWithUrl:url];
    __block UIViewController* toplevelViewController = nil;
    [NiftyUtilitySwift DispatchSyncMainQueueWithBlock:^{
        toplevelViewController = [UIViewController toplevelViewController];
    }];
    if (text == nil) {
        [NiftyUtilitySwift EasyDialogOneButtonWithViewController:toplevelViewController title:nil message:NSLocalizedString(@"GlobalDataSingleton_RTFToStringFailed_Title", @"RTFのテキスト読み込みに失敗")  buttonTitle:nil buttonAction:nil];
        return false;
    }
    NSString* fileName = [url lastPathComponent];
    if (fileName == nil) {
        fileName = @"unknown.txt";
    }
    NSString* title = [fileName stringByDeletingPathExtension];
    if (title == nil) {
        title = @"unknown title";
    }
    [NiftyUtilitySwift checkTextImportConifirmToUserWithViewController:toplevelViewController title:title content:[text string] hintString:nil];
    return false;
}

/// UTI(ファイル拡張子？)で呼び出された時の反応をします。
/// 反応する拡張子は
/// .novelspeaker-backup-json
/// .txt
/// .pdf
/// です。
- (BOOL)ProcessCustomFileUTI:(NSURL*)url{
    NSLog(@"ProcessCustomFileUTI in. %@", url);
    BOOL isSecurityScopeURL = [url startAccessingSecurityScopedResource];
    NSLog(@"isSecurityScopeURL: %@", isSecurityScopeURL ? @"yes" : @"no");
    {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:[url path]]) {
            NSLog(@"%@ is alive.", url);
        }else{
            NSLog(@"%@ is NOT alive.", url);
        }
    }
    [BehaviorLogger AddLogWithDescription:@"GobalDataSingleton ProcessCustomFileUTI" data:@{@"url": url == nil ? @"nil": [url absoluteString]}];
    __block UIViewController* toplevelViewController = nil;
    [NiftyUtilitySwift DispatchSyncMainQueueWithBlock:^{
        toplevelViewController = [UIViewController toplevelViewController];
    }];
    if ([[url pathExtension] isEqualToString:@"novelspeaker-backup-json"]
        | [[url pathExtension] isEqualToString:@"novelspeaker-backup+json"]) {
        NSData* data = [NSData dataWithContentsOfURL:url];
        if (data == nil){
            if (isSecurityScopeURL) { [url stopAccessingSecurityScopedResource]; }
            return false;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [NiftyUtilitySwift RestoreBackupFromJSONWithProgressDialogWithJsonData:data dataDirectory:nil rootViewController:toplevelViewController];
        });
        if (isSecurityScopeURL) { [url stopAccessingSecurityScopedResource]; }
        return true;
    }
    if ([[url pathExtension] isEqualToString:@"novelspeaker-backup+zip"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self RestoreBackupFromZIPData:url finally:^(BOOL finalResult) {
                if (finalResult) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NiftyUtilitySwift EasyDialogOneButtonWithViewController:toplevelViewController title:nil message:NSLocalizedString(@"GlobalDataSingleton_RestoreFullBackupEnd", @"バックアップデータからの復元を完了しました。") buttonTitle:NSLocalizedString(@"OK_button", @"OK") buttonAction:nil];
                    });
                    if (isSecurityScopeURL) { [url stopAccessingSecurityScopedResource]; }
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NiftyUtilitySwift EasyDialogOneButtonWithViewController:toplevelViewController title:nil message:NSLocalizedString(@"GlobalDataSingleton_RestoreBackupDataFailed", @"バックアップデータの読み込みに失敗しました。") buttonTitle:NSLocalizedString(@"OK_button", @"OK") buttonAction:nil];
                    if (isSecurityScopeURL) { [url stopAccessingSecurityScopedResource]; }
                });
            }];
        });
        return true;
    }
    if ([[[url pathExtension] lowercaseString] isEqualToString:@"pdf"]) {
        BOOL result = [self ImportNovelFromPDFFile:url];
        if (isSecurityScopeURL) { [url stopAccessingSecurityScopedResource]; }
        return result;
    }
    if ([[[url pathExtension] lowercaseString] isEqualToString:@"rtf"]) {
        BOOL result = [self ImportNovelFromRTFFile:url];
        if (isSecurityScopeURL) { [url stopAccessingSecurityScopedResource]; }
        return result;
    }
    if ([[[url pathExtension] lowercaseString] isEqualToString:@"rtfd"]) {
        BOOL result = [self ImportNovelFromRTFDFile:url];
        if (isSecurityScopeURL) { [url stopAccessingSecurityScopedResource]; }
        return result;
    }
    // 上記色々と調べた拡張子以外であれば plain-text として読み込む
    BOOL result = [self ImportNovelFromFile:url];
    if (isSecurityScopeURL) { [url stopAccessingSecurityScopedResource]; }
    return result;
}

/// 読み上げ時にハングするような文字を読み上げ時にハングしない文字に変換するようにする読み替え辞書を強制的に登録します
- (void)ForceOverrideHungSpeakStringToSpeechModSettings{
    NSDictionary* targetStrings = @{
        @"*": @" " // "*" が連続しているのを読み上げさせると落ちる
        };
    
    for (NSString* key in [targetStrings keyEnumerator]) {
        // 既に読み替え辞書に登録されているのなら何もしない
        /* 2018/05/10 読み替え辞書に登録されていてもハングする人が居るようなので、書き換えは強制にします
        SpeechModSettingCacheData* setting = [self GetSpeechModSettingWithBeforeString:key];
        if (setting != nil) {
            continue;
        }
         */
        NSString* after = [targetStrings objectForKey:key];
        SpeechModSettingCacheData* speechModSetting = [[SpeechModSettingCacheData alloc] initWithBeforeString:key afterString:after type:SpeechModSettingConvertType_JustMatch];
        [self UpdateSpeechModSetting:speechModSetting];
    }
}

@end
