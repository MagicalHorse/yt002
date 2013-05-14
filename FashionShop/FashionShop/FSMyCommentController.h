//
//  FSMyCommentController.h
//  FashionShop
//
//  Created by HeQingshan on 13-5-14.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSRefreshableViewController.h"
#import "FSThumView.h"

@interface FSMyCommentController : FSRefreshableViewController<FSThumViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tbAction;

@end
