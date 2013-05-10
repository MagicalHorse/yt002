//
//  FSCommon.m
//  FashionShop
//
//  Created by HeQingshan on 13-5-10.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSCommon.h"

@implementation FSCommon

+(RKObjectMapping *) getRelationDataMap
{
    RKObjectMapping *relationMap = [RKObjectMapping mappingForClass:[self class]];
    [relationMap mapKeyPath:@"rangefrom" toAttribute:@"rangefrom"];
    [relationMap mapKeyPath:@"rangeto" toAttribute:@"rangeto"];
    [relationMap mapKeyPath:@"ratio" toAttribute:@"ratio"];
    
    [relationMap mapKeyPath:@"excludes" toAttribute:@"excludes"];
    [relationMap mapKeyPath:@"storeid" toAttribute:@"storeid"];
    [relationMap mapKeyPath:@"storename" toAttribute:@"storename"];
    
    return relationMap;
}

@end
