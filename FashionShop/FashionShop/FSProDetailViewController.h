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

@class FSProDetailViewController;
@protocol FSProDetailItemSourceProvider <NSObject>

-(FSSourceType)proDetailViewSourceTypeFromContext:(FSProDetailViewController *)view forIndex:(NSInteger)index  ;

-(void)proDetailViewDataFromContext:(FSProDetailViewController *)view forIndex:(NSInteger)index  completeCallback:(UICallBackWith1Param)block errorCallback:(dispatch_block_t)errorBlock;

-(BOOL)proDetailViewNeedRefreshFromContext:(FSProDetailViewController *)view forIndex:(NSInteger)index ;

@end

@interface FSProDetailViewController : SYPaginatorViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,FSThumViewDelegate>
- (IBAction)doBack:(id)sender;
- (IBAction)doComment:(id)sender;

- (IBAction)doGetCoupon:(id)sender;
- (IBAction)doShare:(id)sender;
- (IBAction)showBrand:(id)sender;

@property (strong, nonatomic) IBOutlet FSThumView *_thumView;

- (IBAction)doFavor:(id)sender;
@property (strong,nonatomic) id<FSProDetailItemSourceProvider> dataProviderInContext;
@property (strong,nonatomic) NSMutableArray *navContext;
@property (assign,nonatomic) int indexInContext;
@property (nonatomic) FSSourceType sourceType;

@end
