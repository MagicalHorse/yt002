//
//  FSTag.m
//  FashionShop
//
//  Created by gong yi on 12/10/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSTag.h"
#import "FSCoreTag.h"

@implementation FSTag

@synthesize   id;
@synthesize name;

+(RKObjectMapping *) getRelationDataMap
{
    RKObjectMapping *relationMapping = [RKObjectMapping mappingForClass:[self class]];
    [relationMapping mapKeyPathsToAttributes:@"id",@"id",@"name",@"name",nil];

    return relationMapping;
}

+(NSArray *) localTags
{
    return [FSCoreTag findAllSortedBy:@"name" ascending:TRUE];
}
@end
