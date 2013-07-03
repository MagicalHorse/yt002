//
//  FSOrderRMASuccessViewController.h
//  FashionShop
//
//  Created by HeQingshan on 13-7-2.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSOrder.h"

@interface FSOrderRMASuccessViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *tbAction;
@property (nonatomic,strong) FSOrderRMAItem *data;
@end
