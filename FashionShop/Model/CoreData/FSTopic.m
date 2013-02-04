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
@synthesize topicId;
@synthesize resources;

+(RKObjectMapping *)getRelationDataMap
{
    return [self getRelationDataMap:FALSE];
}

+(RKObjectMapping *)getRelationDataMap:(BOOL)isCollection
{
    RKObjectMapping *relationMap = [RKObjectMapping mappingForClass:[self class]];
    [relationMap mapKeyPath:@"isfavorited" toAttribute:@"isFavorited"];
    [relationMap mapKeyPath:@"id" toAttribute:@"topicId"];
    [relationMap mapKeyPath:@"createddate" toAttribute:@"createdDate"];
    [relationMap mapKeyPath:@"description" toAttribute:@"description"];
    [relationMap mapKeyPath:@"name" toAttribute:@"name"];
    [relationMap mapKeyPath:@"updateddate" toAttribute:@"updatedDate"];
    
    RKObjectMapping *resourceRelation = [FSResource getRelationDataMap];
    [relationMap mapKeyPath:@"resources" toRelationship:@"resources" withMapping:resourceRelation];
    
    return relationMap;
}

@end
