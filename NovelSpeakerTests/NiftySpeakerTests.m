//
//  NiftySpeakerTests.m
//  NovelSpeaker
//
//  Created by 飯村卓司 on 2014/08/13.
//  Copyright (c) 2014年 IIMURA Takuji. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NiftySpeaker.h"
#import "SpeechBlock.h"
#import "GlobalDataSingleton.h"

@interface SpeechBlockConverter : NSObject

@property NSString* text;
@property float delay;
@property float pitch;
@property float rate;

@end
@implementation SpeechBlockConverter
@end

@interface NiftySpeakerTests : XCTestCase
{
}
@end

@implementation NiftySpeakerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (SpeechBlockConverter*)AllocSpeechBlockConverter:(NSString*)text delay:(float)delay pitch:(float)pitch rate:(float)rate
{
    SpeechBlockConverter* conv = [SpeechBlockConverter new];
    conv.text = text;
    conv.delay = delay;
    conv.pitch = pitch;
    conv.rate = rate;
    return conv;
}

- (NSString*)SpeechBlockConverterToString:(SpeechBlockConverter*)converter {
    return [[NSString alloc] initWithFormat:@"%@, delay: %f, pitch: %f, rate: %f",
            converter.text, converter.delay, converter.pitch, converter.rate];
}

/// SpeechBlock への分割を確認する
- (void)testNiftySpeakerBlockSeparate
{
    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    NiftySpeaker* speaker = [NiftySpeaker new];
    
    SpeechConfig* defaultSpeechConfig = [SpeechConfig new];
    defaultSpeechConfig.pitch = 1.0f;
    defaultSpeechConfig.rate = 0.5f;
    defaultSpeechConfig.beforeDelay = 0.0f;
    [speaker SetDefaultSpeechConfig:defaultSpeechConfig];
    
    SpeechConfig* normalSpeakConfig = [SpeechConfig new];
    normalSpeakConfig.pitch = 1.5f;
    normalSpeakConfig.rate = 0.5f;
    SpeechConfig* specialSpeakConfig = [SpeechConfig new];
    specialSpeakConfig.pitch = 1.2f;
    specialSpeakConfig.rate = 0.5f;
    [speaker AddBlockStartSeparator:@"「" endString:@"」" speechConfig:normalSpeakConfig];
    [speaker AddBlockStartSeparator:@"『" endString:@"』" speechConfig:specialSpeakConfig];
    [speaker AddDelayBlockSeparator:@"\r\n\r\n" delay:0.5f];
    //[speaker AddDelayBlockSeparator:@"\n\n" delay:0.1f];
    [speaker AddDelayBlockSeparator:@"。" delay:1.0f];
    [speaker AddSpeechModText:@"異世界" to:@"イセカイ"];
    [speaker AddSpeechModText:@"術師" to:@"ジュツシ"];

    
    [speaker SetText:@""
#if 1
     @"異世界\r\n"
     @"\r\n"
     @"「行頭から会話文」\r\n"
     @"「続いて会話文」\r\n"
     @"通常の文章\r\n"
     @"通常の文章の中に「会話文」\r\n"
     @"\r\n"
     @"通常の文章の中に「複数の」「会話文が」紛れる\r\n"
     @"「会話文が『ネスト』する場合」\r\n"
     @"「会話文の中に\r\n\r\n改行が複数ある場合」\r\n"
     @"通常の文章"
     @"「会話文に読点。がある」"
     @"通常の文章"
#else
     @"「あ」\r\nいうえお\r\n\r\n異世界"
#endif
     ];
    
    NSArray* blockArray = [speaker GetGeneratedSpeechBlockArray_ForTest];

    NSArray* answerArray = @[
#if 0
                             [self AllocSpeechBlockConverter:@"「あ" delay:0.0f pitch:1.5f rate:0.5f]
                             , [self AllocSpeechBlockConverter:@"」\r\nいうえお" delay:0.0f pitch:1.0f rate:0.5f]
                             , [self AllocSpeechBlockConverter:@"\r\n\r\n異世界" delay:0.5f pitch:1.0f rate:0.5f]
#else
                             // 0
                             [self AllocSpeechBlockConverter:@"異世界" delay:0.0f pitch:1.0f rate:0.5f]
                             , [self AllocSpeechBlockConverter:@"\r\n\r\n" delay:0.5f pitch:1.0f rate:0.5f]
                             , [self AllocSpeechBlockConverter:@"「行頭から会話文" delay:0.0f pitch:1.5f rate:0.5f]
                             , [self AllocSpeechBlockConverter:@"」\r\n" delay:0.0f pitch:1.0f rate:0.5f]
                             , [self AllocSpeechBlockConverter:@"「続いて会話文" delay:0.0f pitch:1.5f rate:0.5f]
                             // 5
                             , [self AllocSpeechBlockConverter:@"」\r\n通常の文章\r\n通常の文章の中に" delay:0.0f pitch:1.0f rate:0.5f]
                             , [self AllocSpeechBlockConverter:@"「会話文" delay:0.0f pitch:1.5f rate:0.5f]
                             , [self AllocSpeechBlockConverter:@"」" delay:0.0f pitch:1.0f rate:0.5f]
                             , [self AllocSpeechBlockConverter:@"\r\n\r\n通常の文章の中に" delay:0.5f pitch:1.0f rate:0.5f]
                             , [self AllocSpeechBlockConverter:@"「複数の" delay:0.0f pitch:1.5f rate:0.5f]
                             // 10
                             , [self AllocSpeechBlockConverter:@"」" delay:0.0f pitch:1.0f rate:0.5f]
                             , [self AllocSpeechBlockConverter:@"「会話文が" delay:0.0f pitch:1.5f rate:0.5f]
                             , [self AllocSpeechBlockConverter:@"」紛れる\r\n" delay:0.0f pitch:1.0f rate:0.5f]
                             , [self AllocSpeechBlockConverter:@"「会話文が" delay:0.0f pitch:1.5f rate:0.5f]
                             , [self AllocSpeechBlockConverter:@"『ネスト" delay:0.0f pitch:1.2f rate:0.5f]
                             // 15
                             , [self AllocSpeechBlockConverter:@"』する場合" delay:0.0f pitch:1.5f rate:0.5f]
                             , [self AllocSpeechBlockConverter:@"」\r\n" delay:0.0f pitch:1.0f rate:0.5f]
                             , [self AllocSpeechBlockConverter:@"「会話文の中に" delay:0.0f pitch:1.5f rate:0.5f]
                             , [self AllocSpeechBlockConverter:@"\r\n\r\n改行が複数ある場合" delay:0.5f pitch:1.5f rate:0.5f]
                             , [self AllocSpeechBlockConverter:@"」\r\n通常の文章" delay:0.0f pitch:1.0f rate:0.5f]
                             // 20
                             , [self AllocSpeechBlockConverter:@"「会話文に読点" delay:0.0f pitch:1.5f rate:0.5f]
                             , [self AllocSpeechBlockConverter:@"。がある" delay:1.0f pitch:1.5f rate:0.5f]
                             , [self AllocSpeechBlockConverter:@"」通常の文章" delay:0.0f pitch:1.0f rate:0.5f]
#endif
                             ];
    
    XCTAssertEqual([blockArray count], [answerArray count]);
    
    for (int i = 0; i < [blockArray count]; i++) {
        SpeechBlock* block = [blockArray objectAtIndex:i];
        SpeechBlockConverter* answer = [answerArray objectAtIndex:i];
        NSString* displayText = [block GetDisplayText];
        XCTAssertTrue([displayText compare:answer.text] == NSOrderedSame, @"block %d not same: %@ <=> %@", i, displayText, answer.text);
        XCTAssertEqual(block.speechConfig.pitch, answer.pitch, @"block %d, pitch not match: %f <=> %f", i, block.speechConfig.pitch, answer.pitch);
        XCTAssertEqual(block.speechConfig.rate, answer.rate, @"block %d: rate not match: %f <=> %f", i, block.speechConfig.rate, answer.rate);
        XCTAssertEqual(block.speechConfig.beforeDelay, answer.delay, @"block %d: delay not match: %f <=> %f", i, block.speechConfig.beforeDelay, answer.delay);
    }
}

/// 登録されている読み替え辞書のリストを , @"..", @".." の形式で(そのまま source にコピペ出来る感じで)書き出します。
/// ただ、なにやら変なバグがあるのでそのままコピペすると残念なことになります。
/// 具体的には "ほ\222げ" みたいなのが出るとか、, @"..", @"..", @".." みたいな行(2つでなく3つある)とかが出て謎です。(´・ω・`)
- (void) testDumpSpeechModDictionary
{
    NSMutableString* strBuf = [NSMutableString new];
    [strBuf appendFormat:@"\n"];
    
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    NSArray* speechModArray = [globalData GetAllSpeechModSettings];
    for (SpeechModSettingCacheData* modSetting in speechModArray) {
        if (modSetting == nil || modSetting.beforeString == nil || modSetting.afterString == nil
            || [modSetting.beforeString length] <= 0
            || [modSetting.afterString length] <= 0) {
            continue;
        }
        [strBuf appendFormat:@", @\"%@\", @\"%@\"\n"
         , modSetting.beforeString
         , modSetting.afterString];
    }
    NSLog(@"%@", [NSString stringWithCString:[strBuf cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding]);
}

/// 現在登録されている読み替え辞書と、標準の読み替え辞書の差分を表示します
- (void) testSpeechModSettingDiff
{
    NSMutableString* strBuf = [NSMutableString new];
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    NSArray* speechModArray = [globalData GetAllSpeechModSettings];
    NSDictionary* defaultSpeechModDictionary = [globalData GetDefaultSpeechModConfig];
    for (SpeechModSettingCacheData* modSetting in speechModArray) {
        if (modSetting == nil || modSetting.beforeString == nil || modSetting.afterString == nil
            || [modSetting.beforeString length] <= 0
            || [modSetting.afterString length] <= 0) {
            continue;
        }
        if ([defaultSpeechModDictionary valueForKey:modSetting.beforeString] == nil) {
            [strBuf appendFormat:@", @\"%@\": @\"%@\"\n", modSetting.beforeString, modSetting.afterString];
        }
    }
    NSLog(@"%@", strBuf);
}

/*
 /// 登録されている読み替え辞書を全部消し飛ばします
- (void) testClearSpeechMod
{
    GlobalDataSingleton* globalData = [GlobalDataSingleton GetInstance];
    NSArray* speechModArray = [globalData GetAllSpeechModSettings];
    for (SpeechModSettingCacheData* modSetting in speechModArray) {
        [globalData DeleteSpeechModSetting:modSetting];
    }
}
 */

@end
