//
//  FSProNearestHeaderTableCell.m
//  FashionShop
//
//  Created by gong yi on 11/18/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSProNearestHeaderTableCell.h"
#import "FSConfiguration.h"
@interface FSProNearestHeaderTableCell(){
    NSString *_data;
}

@end


@implementation FSProNearestHeaderTableCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _lblTitle.font= [UIFont systemFontOfSize:PRO_LIST_NEAR_HEADER_FONTSZ];
        _lblTitle.textColor = PRO_LIST_NEAR_HEADER_COLOR;
    }
    return self;
}

-(NSString *)data{
    return _data;
}

-(void)setdata:(NSString *)source{
    _data = source;
    [_lblTitle setValue:_data forKey:@"text"];
}

@end
