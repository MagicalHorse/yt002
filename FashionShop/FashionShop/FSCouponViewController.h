//
//  FSCouponViewController.h
//  FashionShop
//
//  Created by gong yi on 11/28/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSUser.h"
#import "FSDeviceRegisterRequest.h"
#import "FSRefreshableViewController.h"
#import "FSProDetailViewController.h"

@interface FSCouponViewController : FSRefreshableViewController<UITableViewDataSource, UITableViewDelegate,FSProDetailItemSourceProvider>

@property (strong, nonatomic) IBOutlet UITableView *contentView;

@property (strong,nonatomic) FSUser *currentUser;

@end
