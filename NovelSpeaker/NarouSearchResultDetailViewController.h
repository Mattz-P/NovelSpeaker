//
//  NarouSearchResultDetailViewController.h
//  NovelSpeaker
//
//  Created by 飯村卓司 on 2014/07/05.
//  Copyright (c) 2014年 IIMURA Takuji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NarouContentCacheData.h"
#import "EasyAlert.h"

@interface NarouSearchResultDetailViewController : UIViewController
{
    // alertView で OK されたときに前のページに戻るべき(true)か否(false)か。
    BOOL m_bNeedBack;
    
    // 作者での検索結果
    NSArray* m_SearchResult;
    
    dispatch_queue_t m_MainQueue;
    dispatch_queue_t m_SearchQueue;

    EasyAlert* m_EasyAlert;

    UIBarButtonItem* downloadButton;
    UIBarButtonItem* shareButton;
}
// 前のページから得られる表示するための情報
@property NarouContentCacheData* NarouContentDetail;
- (IBAction)WriterButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *WriterButton;
//@property (weak, nonatomic) IBOutlet UILabel *WriterLabel;
@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
//@property (weak, nonatomic) IBOutlet UILabel *GenreLabel;
@property (weak, nonatomic) IBOutlet UILabel *NovelupdatedAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *FavNovelCntLabel;
@property (weak, nonatomic) IBOutlet UILabel *GeneralAllNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *GlobalPointLabel;
@property (weak, nonatomic) IBOutlet UILabel *PointLabel;
@property (weak, nonatomic) IBOutlet UILabel *KeywordLabel;
@property (weak, nonatomic) IBOutlet UILabel *StoryTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *StoryInfoLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *PageScrollView;
@end
