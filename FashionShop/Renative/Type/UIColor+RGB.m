//
//  UIColor+RGB.m
//  FashionShop
//
//  Created by gong yi on 12/11/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "UIColor+RGB.h"

@implementation UIColor(RGB)

+(UIColor *) colorWithRed:(CGFloat)red green:(CGFloat)g blue:(CGFloat)b
{
    return [UIColor colorWithRed:red/255 green:g/255 blue:b/255 alpha:1];
}

+(UIColor *) colorWithRGB:(NSUInteger)color
{
    return [UIColor colorWithRed:((color >> 24) & 0xFF) / 255.0f
                           green:((color >> 16) & 0xFF) / 255.0f
                            blue:((color >> 8) & 0xFF) / 255.0f
                           alpha:((color) & 0xFF) / 255.0f];
}
@end
