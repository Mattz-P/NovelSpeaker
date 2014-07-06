//
//  NarouLoader.m
//  NovelSpeaker
//
//  Created by 飯村 卓司 on 2014/07/01.
//  Copyright (c) 2014年 IIMURA Takuji. All rights reserved.
//

#import "NarouLoader.h"
#import "NarouContent.h"
#import "GlobalDataSingleton.h"
#import "NarouContentAllData.h"

/// 小説家になろう の API 個を使って小説情報を読み出すclass。
/// SettingDataModel の NarouContent に追加するなどします。
@implementation NarouLoader

/// 小説家になろうで検索を行います。
/// searchString: 検索文字列
/// wname: 作者名を検索対象に含むか否か
/// title: タイトルを検索対象に含むか否か
/// keyword: キーワードを検索対象に含むか否か
/// ex: あらすじを検索対象に含むか否か
+ (NSMutableArray*)Search:(NSString*) searchString wname:(BOOL)wname title:(BOOL)title keyword:(BOOL)keyword ex:(BOOL)ex
{
    NSString* queryUrl = [[NSString alloc] initWithFormat:@"http://api.syosetu.com/novelapi/api/?out=json&of=t-n-u-w-s-k-e-ga-gp-f-r-a-ah-sa-nu&lim=500", nil];
    //NSString* queryUrl = [[NSString alloc] initWithFormat:@"http://ein.iimura/novelapi/api/?out=json&of=t-n-u-w-s-k-e-ga-gp-f-r-a-ah-sa-nu&lim=500", nil];
    
    if (searchString != nil) {
        queryUrl = [queryUrl stringByAppendingFormat:@"&word=%@", [self URIEncode:searchString]];
    }
    if (wname)
    {
        queryUrl = [queryUrl stringByAppendingString:@"&wname=1"];
    }
    if (title)
    {
        queryUrl = [queryUrl stringByAppendingString:@"&title=1"];
    }
    if (keyword)
    {
        queryUrl = [queryUrl stringByAppendingString:@"&keyword=1"];
    }
    if (ex)
    {
        queryUrl = [queryUrl stringByAppendingString:@"&ex=1"];
    }
    
    NSLog(@"search: %@", queryUrl);
    NSData* jsonData = [self HttpGetBinary:queryUrl];
    NSError* err = nil;
    
    // TODO: これ NSArray と NSDictionary のどっちが帰ってくるのが正しいのかわからない形式で呼んでる？
    NSArray* contentList = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&err];
    NSMutableArray* result = [NSMutableArray new];
    for(NSDictionary* jsonContent in contentList)
    {
        NarouContentAllData* content = [[NarouContentAllData alloc] initWithJsonData:jsonContent];
        if (content.ncode == nil || [content.ncode length] <= 0) {
            continue;
        }
        
        [result addObject:content];
    }

    return result;
}

/// NarouContent のリストを更新します。
/// 怪しく検索条件を内部で勝手に作ります。
- (BOOL)UpdateContentList
{
    NSMutableArray* searchResultList = [NarouLoader Search:nil wname:NO title:NO keyword:NO ex:NO];
    
    for(NarouContentAllData* remoteContent in searchResultList)
    {
        NSString* ncode = remoteContent.ncode;
        if (ncode == nil || [ncode length] <= 0) {
            continue;
        }
        
        NarouContent* content = [[GlobalDataSingleton GetInstance] SearchNarouContentFromNcode:ncode];
        
        if (content == nil) {
            NSLog(@"ncode: %@ %@ not found. adding.", ncode, remoteContent.title);
            content = [[GlobalDataSingleton GetInstance] CreateNewNarouContent];
        }

        content.title = remoteContent.title;
        content.ncode = ncode;
        content.userid = remoteContent.userid;
        content.story = remoteContent.story;
        content.writer = remoteContent.writer;
        content.novelupdated_at = remoteContent.novelupdated_at;
    }
    return true;
}

/// 文字列をURIエンコードします。
+ (NSString*) URIEncode:(NSString*)str
{
    NSString *encodedText = (__bridge_transfer NSString *)
    CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (__bridge CFStringRef)str, //元の文字列
                                            NULL,
                                            CFSTR("!*'();:@&=+$,/?%#[]"),
                                            CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return encodedText;
}

/// 小説家になろうでtextダウンロードを行うためのURLを取得します。
/// 失敗した場合は nil を返します。
/// 解説：
/// 小説家になろうでは ncode というもので個々のコンテンツを管理しているのですが、
/// テキストのダウンロードではこの ncode ではない別の code を使っているようです。
/// この code の取得方法はその小説のページのHTMLを読み込まないとわからないため、
/// ここではその小説のページのHTMLを読み込んで、ダウンロード用の FORM GET に渡すURLを生成します。
+ (NSString*)GetTextDownloadURL:(NSString*)ncode
{
    // まずは通常のHTMLを取得します。
    NSString* htmlURL = [[NSString alloc] initWithFormat:@"http://ncode.syosetu.com/%@/", ncode];
    NSString* html = [self HttpGet:htmlURL];
    // この html から、正規表現を使って
    // onclick="javascript:window.open('http://ncode.syosetu.com/txtdownload/top/ncode/562600/'
    // といった文字列の、562600 の部分を取得します。
    NSString* matchPattern = @"onclick=\"javascript:window.open\\('http://ncode.syosetu.com/txtdownload/top/ncode/([^/]*)/'";
    NSError* err = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:matchPattern options:NSRegularExpressionCaseInsensitive error:&err];
    if (err != nil) {
        NSLog(@"Regex create failed: %@, %@", err, [err userInfo]);
        return nil;
    }
    
    NSTextCheckingResult* checkResult = [regex firstMatchInString:html options:NSMatchingReportProgress range:NSMakeRange(0, [html length])];
    NSString* result = [html substringWithRange:[checkResult rangeAtIndex:1]];
    return [[NSString alloc] initWithFormat:@"http://ncode.syosetu.com/txtdownload/dlstart/ncode/%@/", result];
}

/// 小説家になろうでTextダウンロードを行います。
+ (NSString*)TextDownload:(NSString*)download_url count:(int)count
{
    NSString* url = [[NSString alloc] initWithFormat:@"%@?hankaku=0&code=utf-8&kaigyo=CRLF&no=%d", download_url, count];
    return [self HttpGet:url];
}

/// HTTP GET request for binary
+ (NSData*)HttpGetBinary:(NSString*)url {
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    return [NSURLConnection sendSynchronousRequest:request returningResponse: nil error:nil];
}
/// HTTP GET request
+ (NSString*)HttpGet:(NSString*)url {
    NSData* data = [self HttpGetBinary:url];
    NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

@end
