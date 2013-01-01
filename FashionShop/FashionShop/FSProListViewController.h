//
//  FSProListViewController.h
//  FashionShop
//
//  Created by gong yi on 11/17/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestKit.h"
#import "FSLocationManager.h"
#import "UIViewController+Loading.h"
#import "FSProDetailViewController.h"
#import "FSRefreshableViewController.h"
#import "FSSegmentControl.h"

@interface FSProListViewController : FSRefreshableViewController <UITableViewDataSource, UITableViewDelegate,FSProDetailItemSourceProvider>

@property (strong, nonatomic) IBOutlet UITableView *contentView;

@property (strong, nonatomic) IBOutlet UILabel *lblTitle;

@property (strong, nonatomic) IBOutlet FSSegmentControl *segFilters;





@end
