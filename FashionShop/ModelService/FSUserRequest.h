//
//  FSUserRequest.h
//  FashionShop
//
//  Created by gong yi on 11/13/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSBaseRequest.h"

@interface FSUserRequest :FSBaseRequest

@property(nonatomic,strong) NSString *accessToken;
@property(nonatomic,strong) NSString *uID;
@property(nonatomic, strong) NSMutableDictionary *thirdPartyProfile;
@end
