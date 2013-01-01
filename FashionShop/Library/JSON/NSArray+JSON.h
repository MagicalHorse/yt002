//
//  NSArray+JSON.h
//  Monogram
//
//  Created by Cheney Yan on 1/30/12.
//  Copyright (c) 2012 Fara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (JSON)

+ (NSString *)toJSONString:(NSArray *)nsArray;
+ (NSArray *)toJSONObject:(NSArray *)nsArray;

@end
