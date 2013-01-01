//
//  FSUserRequest.m
//  FashionShop
//
//  Created by gong yi on 11/13/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSUserRequest.h"

@implementation FSUserRequest

@synthesize accessToken;
@synthesize uID;
@synthesize thirdPartyProfile;

-(NSMutableDictionary *) toDictionary{
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	
	[info setValue:self.uID forKey:@"uid"];
    [info setValue:self.accessToken forKey:@"accessToken"];
    [info setValue:[self.thirdPartyProfile objectForKey:@"screen_name"] forKey:@"nickieName"];
    return info;
}
@end
