//
//  UITableViewCell+BG.m
//  FashionShop
//
//  Created by gong yi on 12/31/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "UITableViewCell+BG.h"

@implementation UITableViewCell(BG)

-(void)setBackgroundViewUniveral
{
    UIView *bg = [[UIView alloc] initWithFrame:self.frame];
    bg.backgroundColor =PRO_LIST_NEAR_CELL2_BGCOLOR;
    self.selectedBackgroundView =bg;
}

@end
