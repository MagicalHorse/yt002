//
//  FSOrderSuccessViewController.h
//  FashionShop
//
//  Created by HeQingshan on 13-6-30.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSOrder.h"

@interface FSOrderSuccessViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tbAction;
@property (nonatomic,strong) FSOrderInfo *data;

@end
