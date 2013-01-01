//
//  RESTfulResponse.m
//  Fara
//
//  Created by Junyu Chen on 12/9/11.
//  Copyright (c) 2011 Fara Inc. All rights reserved.
//

#import "RESTfulResponse.h"
#import "NSDictionary+Extention.h"
#import "BaseInfo.h"

@implementation RESTfulResponse : BaseInfo

@synthesize status 		= _status;
@synthesize message 	= _message;
@synthesize version 	= _version;
@synthesize sig			= _sig;
@synthesize timestamp 	= _timestamp;


@end
