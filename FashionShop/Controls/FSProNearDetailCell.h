//
//  FSProNearDetailCell.h
//  FashionShop
//
//  Created by gong yi on 12/11/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSProItemEntity.h"

@interface FSProNearDetailCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblSubTitle;

@property (strong, nonatomic) IBOutlet UILabel *lblTitle;

@property (strong, nonatomic) FSProItemEntity *data;


@end
