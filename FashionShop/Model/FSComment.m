//
//  FSComment.m
//  FashionShop
//
//  Created by gong yi on 12/9/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSComment.h"

@implementation FSComment

@synthesize   id;
@synthesize comment;
@synthesize indate;
@synthesize  inUser;

+(RKObjectMapping *) getRelationDataMap
{
    RKObjectMapping *relationMapping = [RKObjectMapping mappingForClass:[self class]];
    [relationMapping mapKeyPathsToAttributes:@"id",@"id",@"content",@"comment",@"createddate",@"indate",nil];
    RKObjectMapping *userRelationMap = [FSUser getRelationDataMap];
    [relationMapping mapKeyPath:@"customer" toRelationship:@"inUser" withMapping:userRelationMap];
     return relationMapping;
}


@end
