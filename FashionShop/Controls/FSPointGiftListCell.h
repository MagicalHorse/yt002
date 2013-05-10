//
//  FSPointGiftListCell.h
//  FashionShop
//
//  Created by HeQingshan on 13-5-2.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"

@interface FSPointGiftListCell : UITableViewCell
@property (strong, nonatomic) IBOutlet RTLabel *titleView;
@property (strong, nonatomic) IBOutlet RTLabel *valideTime;
@property (strong, nonatomic) IBOutlet RTLabel *amountView;
@property (strong, nonatomic) IBOutlet RTLabel *giftNumber;
@property (nonatomic) int cellHeight;

@property (nonatomic, strong) id data;

@end
