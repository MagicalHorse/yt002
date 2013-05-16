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
#import "FSProDetailViewController.h"

@interface FSMyCommentController : FSRefreshableViewController<FSThumViewDelegate,FSProDetailItemSourceProvider>
@property (strong, nonatomic) IBOutlet UITableView *tbAction;

@end
