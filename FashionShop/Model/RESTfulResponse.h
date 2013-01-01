//
//  RESTfulResponse.h
//  Fara
//
//  Created by Junyu Chen on 12/9/11.
//  Copyright (c) 2011 Fara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseInfo.h"

@interface RESTfulResponse : BaseInfo

@property (nonatomic, assign) NSNumber *status;
@property (nonatomic, assign) NSNumber *version;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSString *sig;  

@end
