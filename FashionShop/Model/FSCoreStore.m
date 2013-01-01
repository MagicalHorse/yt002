//
//  FSStore.m
//  FashionShop
//
//  Created by gong yi on 11/15/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSCoreStore.h"
#import "RestKit.h"
#import "FSModelManager.h"

@implementation FSCoreStore

@dynamic address;
@dynamic descrip;
@dynamic distance;
@dynamic id;
@dynamic lantit;
@dynamic longit;
@dynamic name;
@dynamic phone;

+(RKObjectMapping *)getRelationDataMap:(Class)class withParentMap:(RKObjectMapping *)parentMap
{
    RKManagedObjectStore *objectStore = [FSModelManager sharedManager].objectStore;
    RKManagedObjectMapping *relationMapping = [RKManagedObjectMapping mappingForClass:[self class] inManagedObjectStore:objectStore];
    relationMapping.primaryKeyAttribute = @"id";
    [relationMapping mapKeyPathsToAttributes:@"id",@"id",@"name",@"name",@"location",@"address",@"tel",@"phone",@"lng",@"longit",@"lat",@"lantit",@"distance",@"distance",@"description",@"descrip",nil];
    return relationMapping;
    
}

+ (NSArray *) allStoresLocal
{

    return [self findAllSortedBy:@"name" ascending:TRUE];
}
@end
