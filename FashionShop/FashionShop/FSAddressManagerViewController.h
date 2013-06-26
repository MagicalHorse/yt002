//
//  FSAddressManagerViewController.h
//  FashionShop
//
//  Created by HeQingshan on 13-6-24.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSRefreshableViewController.h"

@interface FSAddressManagerViewController : FSRefreshableViewController {
    NSIndexPath *lastIndexPath;
}

@property (strong, nonatomic) IBOutlet UITableView *contentView;

@property(nonatomic,assign) BOOL isNeedRefresh; //返回是否需要刷新
@property(nonatomic,assign) NSInteger pageFrom; //来源页面标识。pageFrom==1我的账户，pageFrom==2结算中心
@property(nonatomic,assign) NSInteger selectedIndex;    //如果来源于结算中心，则记录选中索引

@end
