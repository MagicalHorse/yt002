//
//  FSOrderListCell.h
//  FashionShop
//
//  Created by HeQingshan on 13-6-22.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSOrder.h"

@interface FSOrderListCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgPro;
@property (strong, nonatomic) IBOutlet UILabel *priceLb;
@property (strong, nonatomic) IBOutlet UILabel *orderNumber;
@property (strong, nonatomic) IBOutlet UILabel *crateDate;

@property (strong,nonatomic) FSOrder *data;

@end
