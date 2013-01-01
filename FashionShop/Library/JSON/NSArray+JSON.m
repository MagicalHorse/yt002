//
//  NSArray+JSON.m
//  Monogram
//
//  Created by Cheney Yan on 1/30/12.
//  Copyright (c) 2012 Fara Inc. All rights reserved.
//

#import "NSArray+JSON.h"
#import "NSObject+JSON.h"
#import "JSONKit.h"

@implementation NSArray (JSON)

+ (NSString *)toJSONString:(NSArray *)nsArray
{
    NSArray *jsonObject = [NSArray toJSONObject:nsArray];
	
    NSError *error = nil;
    NSString *jsonString = [jsonObject JSONStringWithOptions:JKSerializeOptionNone error:&error];
    
    return jsonString;
}

+ (NSArray *)toJSONObject:(NSArray *)nsArray
{
    NSMutableArray *jsonArray = [[NSMutableArray alloc] initWithCapacity:nsArray.count];

	for (NSInteger i = 0; i < nsArray.count; i += 1)
	{
		[jsonArray addObject:[NSObject toJSONObject:[nsArray objectAtIndex:i]]];
	}
	
    return jsonArray;
}

@end
