//
//  FSTopic.m
//  FashionShop
//
//  Created by HeQingshan on 13-1-31.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSTopic.h"

@implementation FSTopic
@synthesize createdDate;
@synthesize updatedDate;
@synthesize description;
@synthesize name;
@synthesize isFavorited;
@synthesize id;
@synthesize resources;

+(RKObjectMapping *)getRelationDataMap
{
    return [self getRelationDataMap:NO];
}

+(RKObjectMapping *)getRelationDataMap:(BOOL)isCollection
{
    RKObjectMapping *relationMap = [RKObjectMapping mappingForClass:[self class]];
    [relationMap mapKeyPathsToAttributes:@"createddate", @"createdDate", @"updateddate", @"updatedDate", @"description", @"description", @"name", @"name", @"isfavorited", @"isfavorited", @"id", @"id", nil];
    
    [relationMap mapKeyPath:@"resources" toRelationship:@"resources" withMapping:[FSResource getRelationDataMap]];
    
    return relationMap;
}

@end
