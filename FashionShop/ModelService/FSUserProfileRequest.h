//
//  FSUserProfileRequest.h
//  FashionShop
//
//  Created by gong yi on 11/23/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSEntityRequestBase.h"


#define RK_REQUEST_USER_PROFILE_DETAIL @"/customer/detail";
#define RK_REQUEST_USER_PROFILE_SAVE @"/customer/save";


@interface FSUserProfileRequest : FSEntityRequestBase

@property(nonatomic,strong) NSString *userToken;
@property(nonatomic,strong) NSString *nickie;
@property(nonatomic,strong) NSString *phone;

@end
