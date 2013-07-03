//
//  FSOrderDetailViewController.h
//  FashionShop
//
//  Created by HeQingshan on 13-6-30.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FSOrderRMARequestViewControllerDelegate;

@interface FSOrderDetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tbAction;
@property (nonatomic,strong) NSString *orderno;

@end
