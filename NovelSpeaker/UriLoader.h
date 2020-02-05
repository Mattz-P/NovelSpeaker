//
//  UriLoader.h
//  novelspeaker
//
//  Created by 飯村卓司 on 2016/07/08.
//  Copyright © 2016年 IIMURA Takuji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HtmlStory.h"

/// URI からコンテンツ文字列を抽出します。
@interface UriLoader : NSObject
{
    dispatch_queue_t m_WebAccessQueue;
    int m_MaxDepth;
    float m_SleepTime;
    NSMutableArray* m_SiteInfoArray;
    NSMutableArray* m_CustomSiteInfoArray;
}
/// SiteInfo のJSONを内部データベースに追加します。
- (BOOL)AddSiteInfoFromData:(NSData*)siteInfo;

/// SiteInfo のJSON文字列を内部データベースに追加します。
- (BOOL)AddSiteInfoFromString:(NSString*)siteInfo;

/// SiteInfo をURLから内部データベースに追加します。
- (void)AddSiteInfoFromURL:(NSURL*)url successAction:(void(^)(void))successAction failedAction:(void(^)(NSURL* url))failedAction;

/// ことせかい用にカスタムされた SiteInfo (Autopagerize由来ではないSiteInfo) のJSONを内部データベースに追加します。
- (BOOL)AddCustomSiteInfoFromData:(NSData*)siteInfo;

/// URLを一つ読み込んで HtmlStroy に変換して返します
- (HtmlStory*)FetchStoryForURL:(NSURL*)targetUrl cookieStorage:(NSHTTPCookieStorage*)cookieStorage out_error:(NSMutableString*)out_errorString;

/// テスト用に一つのURLを取得します。
- (void)FetchOneUrl:(NSURL*)url cookieArray:(NSArray*)cookieArray successAction:(void(^)(HtmlStory* story))successAction failedAction:(void(^)(NSURL* url, NSString* errorString))failedAction;

/// URLを読み込んで、SiteInfo の情報から得た PageElement の情報を NSString に変換して取り出しつつ、
/// MaxDepth まで nextLink を辿ったものを、PageElement毎の配列として取り出します。
/// 該当する siteinfo が無い場合、a rel="next" であったり class="autopagerize_page_element" であるものを取り出そうとします。
- (void)LoadURL:(NSURL*)url cookieArray:(NSArray*)cookieArray startCount:(int)startCount successAction:(BOOL(^)(HtmlStory* story, NSURL* currentURL))successAction failedAction:(void(^)(NSURL* url))failedAction finishAction:(void(^)(NSURL* url))finishAction;

/// 最大何ページまで読み進むかを指定します
- (void)SetMaxDepth:(int)maxDepth;

/// 1ページ読み込み毎に待つ時間を秒で指定します
- (void)SetSleepTimeInSecond:(float)sleepTime;

// 指定された NSHTTPCookieStorage に入っている変なkeyになっている cookie項目 を削除します
// 変なkey: 行頭に空白が入っているもの
// 補足: この 変なkey があると、同じkeyが延々と追加されていってしまいには cookie header がでかくなりすぎて 400 を返すことになる(と思う)
+ (void)RemoveInvalidKeyDataFromCookieStorage:(NSHTTPCookieStorage*)storage;

/// 保存されている SiteInfo を開放します
- (void)ClearSiteInfoCache;

@end
