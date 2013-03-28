//
//  FSKeyword.m
//  FashionShop
//
//  Created by HeQingshan on 13-3-27.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSKeyword.h"
#import "FSBrand.h"

@implementation FSKeyword

@synthesize brandWords,keyWords;

+(RKObjectMapping *)getRelationDataMap
{
    RKObjectMapping *relationMap = [RKObjectMapping mappingForClass:[self class]];
    
    NSString *relationKeyPath = @"brandwords";
    RKObjectMapping *promRelationMap = [FSBrand getRelationDataMap];
    [relationMap mapKeyPath:relationKeyPath toRelationship:@"brandWords" withMapping:promRelationMap];
    
    NSString *relationpKeyPath = @"words";
//    RKObjectMapping *prodRelationMap = [FSBrand getRelationDataMap];
//    [relationMap mapKeyPath:relationpKeyPath toRelationship:@"keyWords" withMapping:prodRelationMap];
    
    [relationMap mapKeyPath:relationpKeyPath toAttribute:@"keyWords"];
    
    return relationMap;
}

@end
