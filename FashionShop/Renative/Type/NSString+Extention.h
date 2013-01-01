//
//  NSString+MD5.h
//  Fara
//
//  Created by Josh Chen on 11-10-12.
//  Copyright (c) 2011 Fara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extention)

- (NSString *)MD5;
- (NSString *)urlEncode;
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
- (BOOL) contains:(NSString *)value;
+ (BOOL)isNilOrEmpty:(NSString *)aNSString;

+(NSString *)stringMetersFromDouble:(double)input;
@end
