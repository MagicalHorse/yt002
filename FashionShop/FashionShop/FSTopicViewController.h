//
//  FSTopicViewController.h
//  FashionShop
//
//  Created by HeQingshan on 13-1-25.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSRefreshableViewController.h"

@interface FSTopicViewController : FSRefreshableViewController<UITableViewDataSource,UITableViewDelegate> {
    
}
@property (strong, nonatomic) IBOutlet UITableView *tbAction;

@end
