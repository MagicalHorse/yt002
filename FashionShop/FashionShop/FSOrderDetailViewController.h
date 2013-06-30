//
//  FSOrderDetailViewController.h
//  FashionShop
//
//  Created by HeQingshan on 13-6-30.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSOrderDetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tbAction;
@property (nonatomic,strong) NSString *orderno;

@end
