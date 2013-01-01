//
//  FSProCommentInputView.m
//  FashionShop
//
//  Created by gong yi on 12/9/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSProCommentInputView.h"
#import "FSConfiguration.h"

@implementation FSProCommentInputView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareLayout];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) prepareLayout
{
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithRed:102 green:102 blue:102].CGColor;
}

@end
