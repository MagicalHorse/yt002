//
//  FSTag.m
//  FashionShop
//
//  Created by gong yi on 11/29/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSCoreTag.h"
#import "FSModelManager.h"

@implementation FSCoreTag

@dynamic id;
@dynamic name;
@dynamic sort;



+(RKObjectMapping *)getRelationDataMap:(Class)class withParentMap:(RKObjectMapping *)parentMap
{
    RKManagedObjectStore *objectStore = [FSModelManager sharedManager].objectStore;
    RKManagedObjectMapping *relationMapping = [RKManagedObjectMapping mappingForClass:[self class] inManagedObjectStore:objectStore];
    relationMapping.primaryKeyAttribute = @"id";
    [relationMapping mapKeyPath:@"id" toAttribute:@"id"];
    [relationMapping mapKeyPath:@"name" toAttribute:@"name"];
    [relationMapping mapKeyPath:@"sort" toAttribute:@"sort"];
    return relationMapping;
}

@end
