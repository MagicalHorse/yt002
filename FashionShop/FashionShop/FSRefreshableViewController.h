//
//  FSRefreshableViewController.h
//  FashionShop
//
//  Created by gong yi on 12/27/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Loading.h"
#import "EGORefreshTableHeaderView.h"

@interface FSRefreshableViewController : UIViewController<EGORefreshTableHeaderDelegate,UIScrollViewDelegate>

-(void) prepareRefreshLayout:(UIScrollView *)container withRefreshAction:(UICallBackWith1Param)action ;

@property(nonatomic) BOOL isInRefresh;
@end
