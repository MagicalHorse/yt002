//
//  WxpayOrder.h
//  FashionShop
//
//  Created by HeQingshan on 13-11-13.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

@interface WxpayOrder : NSObject<WXApiDelegate>

+ (BOOL)sendPay:(NSString*)productid;

@end
