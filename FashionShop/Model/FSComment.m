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
@synthesize inUser;
@synthesize resources;
@synthesize replyUserID;
@synthesize replyUserName;

+(RKObjectMapping *) getRelationDataMap
{
    RKObjectMapping *relationMapping = [RKObjectMapping mappingForClass:[self class]];
    [relationMapping mapKeyPathsToAttributes:@"id",@"id",@"content",@"comment",@"createddate",@"indate",@"replycustomer_id",@"replyUserID",@"replycustomer_nickname",@"replyUserName",nil];
    [relationMapping mapKeyPath:@"commentid" toAttribute:@"commentid"];
    [relationMapping mapKeyPath:@"sourceid" toAttribute:@"sourceid"];
    [relationMapping mapKeyPath:@"sourcetype" toAttribute:@"sourcetype"];
    RKObjectMapping *relationMap = [FSUser getRelationDataMap];
    [relationMapping mapKeyPath:@"customer" toRelationship:@"inUser" withMapping:relationMap];
    [relationMapping mapKeyPath:@"replyuser" toRelationship:@"replyUser" withMapping:relationMap];
    relationMap = [FSResource getRelationDataMap];
    [relationMapping mapKeyPath:@"resources" toRelationship:@"resources" withMapping:relationMap];
    
    return relationMapping;
}


@end
