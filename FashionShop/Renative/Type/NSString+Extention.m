//
//  NSString+MD5.m
//  Fara
//
//  Created by Josh Chen on 11-10-12.
//  Copyright (c) 2011 Fara Inc. All rights reserved.
//

#import "NSString+Extention.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Extention)

- (NSString*)MD5 
{
    // Create pointer to the string as UTF8
    const char *ptr = [self UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) 
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

- (BOOL) contains:(NSString *) value
{
	NSRange range = [self rangeOfString: value];
	return ( range.location != NSNotFound );
}

-(NSString *)urlEncode {	
	return [self urlEncodeUsingEncoding:NSUTF8StringEncoding];	
}

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	
	//DLog(@"SELF: %@", self);
	
	CFStringRef buffer = CFURLCreateStringByAddingPercentEscapes(NULL,
															   (__bridge CFStringRef)self,
															   NULL,
															   (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
															   CFStringConvertNSStringEncodingToEncoding(encoding));
	
	//DLog(@"BUFFER: %@", buffer);
	NSString *output = [NSString stringWithFormat:@"%@", buffer];
	
	CFRelease(buffer);
	
	return output;
}

+ (BOOL)isNilOrEmpty:(NSString *)aNSString
{
	//DLog(@"isNilOrEmpty: %@", aNSString);
	
	if (aNSString == nil)
	{
		return YES;
	}
	
	if(aNSString.length == 0)
	{
		return YES;
	}
	
	return NO;
}

+(NSString *)stringMetersFromDouble:(double)input
{
    int kilos = 1000;
    int numberOfKilos = (int)input/kilos;
    if (input>=1)
        return [NSString stringWithFormat:NSLocalizedString(@"%dkiloes", nil),numberOfKilos];
    else
        return [NSString stringWithFormat:NSLocalizedString(@"%dmeters", nil),(int)input];
}

@end
