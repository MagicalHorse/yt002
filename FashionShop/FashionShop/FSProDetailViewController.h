//
//  FSProDetailViewController.h
//  FashionShop
//
//  Created by gong yi on 11/20/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSProItemEntity.h"
#import "FSProdItemEntity.h"
#import "MBProgressHUD.h"
#import "RestKit.h"
#import "SYPaginator.h"
#import "UIViewController+Loading.h"
#import "FSThumView.h"
#import "FSImageSlideViewController.h"
#import "FSAudioButton.h"

@class FSProDetailViewController;

@protocol FSProDetailItemSourceProvider <NSObject>

-(FSSourceType)proDetailViewSourceTypeFromContext:(FSProDetailViewController *)view forIndex:(NSInteger)index  ;

-(void)proDetailViewDataFromContext:(FSProDetailViewController *)view forIndex:(NSInteger)index  completeCallback:(UICallBackWith1Param)block errorCallback:(dispatch_block_t)errorBlock;

-(BOOL)proDetailViewNeedRefreshFromContext:(FSProDetailViewController *)view forIndex:(NSInteger)index ;
@optional
-(BOOL)proDetailViewShouldPostNotification:(FSProDetailViewController *)view;

@end

@interface FSProDetailViewController : SYPaginatorViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate,FSThumViewDelegate,FSImageSlideDataSource,FSProDetailItemSourceProvider,FSAudioDelegate>

- (IBAction)doBack:(id)sender;
- (IBAction)doComment:(id)sender;
- (IBAction)doGetCoupon:(id)sender;
- (IBAction)doShare:(id)sender;
- (IBAction)showBrand:(id)sender;
- (IBAction)goStore:(id)sender;
- (IBAction)doFavor:(id)sender;

-(void)stopAllAudio;

@property (strong, nonatomic) IBOutlet FSThumView *_thumView;
@property (strong, nonatomic) IBOutlet UIImageView *arrowLeft;
@property (strong, nonatomic) IBOutlet UIImageView *arrowRight;
@property (strong,nonatomic) id<FSProDetailItemSourceProvider> dataProviderInContext;
@property (strong,nonatomic) NSMutableArray *navContext;
@property (assign,nonatomic) int indexInContext;
@property (nonatomic) FSSourceType sourceType;
@property (strong, nonatomic) NSString *recordFileName;//记录录音文件名称
@property (assign, nonatomic) BOOL fromBanner;//从banner条点击进入标识。为了区分id使用

@end
