//
//  NSObject+JSON.m
//  NeweggFramework
//
//  Created by Cheney Yan on 2/3/12.
//  Copyright (c) 2012 Fara Inc. All rights reserved.
//

#import <objc/runtime.h>
#import "JSONKit.h"
#import "JSONMutableArray.h"
#import "NSArray+JSON.h"
#import "NSObject+JSON.h"
#import "NSDate+InnerBand.h"

@implementation NSObject (JSON)

static const NSString *S_VALUE_TYPES = @"cislqCISLQfdB";

+ (NSString *)toJSONString:(NSObject *)nsObject
{
    NSObject *jsonObject = [NSObject toJSONObject:nsObject];
	
	NSString *jsonString = @"{}";
	
	if ([jsonObject isKindOfClass:[NSDictionary class]])
	{
		jsonString = [(NSDictionary *)jsonObject JSONString];
	}
	
    return jsonString;
}


+ (NSObject *)toJSONObject:(NSObject *)nsObject
{
    Class class = [nsObject class];
	
	//DLog(@"TOJSONOBJECT CLASS: %@", class);
	
	if ([class isSubclassOfClass: [NSString class]] || 
		[class isSubclassOfClass: [NSDecimalNumber class]] ||
		[class isSubclassOfClass: [NSNumber class]] ||
		[class isSubclassOfClass: [NSNull class]] ||		
		[class isSubclassOfClass: [NSDictionary class]] ||
		nsObject == nil)
	{
		return nsObject;
	}
	
	if ([class isSubclassOfClass: [NSDate class]])
	{
		return [(NSDate *)nsObject formattedUTCDatePattern:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	}
	
	if ([class isSubclassOfClass: [NSArray class]])
	{
		return [NSArray toJSONObject: (NSArray *)nsObject];
	}	
	
	//rip all properties;
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    
	while (class != [NSObject class]) 
	{
	    uint count;
		
        objc_property_t *properties = class_copyPropertyList(class, &count);
		
        for (int i = 0; i < count; i++) 
		{
            NSString *key = [NSString stringWithCString:property_getName(properties[i]) encoding: NSUTF8StringEncoding];
			
			//DLog(@"TOJSONOBJECT KEY: %@", key);
			
            id value = [nsObject valueForKey:key];
            id newValue = [NSObject toJSONObject: value];
            
			//Add NSNull Object for nil value;
            if (newValue == nil) 
			{
                newValue = [NSNull null];
            }
            
            [jsonDictionary setObject:newValue forKey:key];
        }
        
		free(properties);
		
        class = class_getSuperclass(class);
    }
	
	nsObject = nil;
    
    return jsonDictionary;
}


///////////////////////////////////////////////////////////////////////////////////////
+ (id)fromJSONString:(NSString *)jsonString
{
	return [self fromJSONString:jsonString inStore:nil];
}

+ (id)fromJSONString:(NSString *)jsonString inStore:(CoreDataStore *)customStore
{
    NSError *error = nil;
    
    NSDictionary *jsonObject = [jsonString objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
	
    return [self fromJSONObject:jsonObject inStore:customStore];
}

+ (id)fromJSONObject:(NSDictionary *)jsonObject
{
	return [self fromJSONObject:jsonObject inStore:nil];
}

///overridable by child Object
- (void) setJsonProperty:(NSString *)key JsonObject:(NSDictionary *)jsonObject modelClass:(Class)modelType thisInstance:(NSObject *)instance{
    
    objc_property_t property = class_getProperty(modelType, [key UTF8String]);
    
    //skip nil property
    if (property == nil)
    {
        return;
    }
    
    //get attribute text;
    NSString *attribute = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
    
    //get attribute type
    NSRange range = NSMakeRange(1, [attribute rangeOfString:@","].location - 1);
    NSString *attrType = [attribute substringWithRange:range];
    
    //DLog(@"ATTRIBUTE: %@", attribute);
    
    id value = [jsonObject objectForKey:key];
    id newValue = nil;
    
    //check quotation marks
    if ([attrType hasPrefix:@"@\""])
    {
        attrType = [attrType substringWithRange:NSMakeRange(2, [attrType length] - 3)];
        
        //DLog(@"DATA MODEL ATTRIBUTE TYPE: %@", attrType);
        
        Class attrClass = NSClassFromString(attrType);
        
        if ([attrClass isSubclassOfClass:[NSDecimalNumber class]])
        {
            if ([value isKindOfClass:[NSDecimalNumber class]])
            {
                newValue = value;
            }
            else if ([value isKindOfClass:[NSNumber class]])
            {
                newValue = [NSDecimalNumber decimalNumberWithDecimal:[value decimalValue]];
            }
        }
        else if ([attrClass isSubclassOfClass:[NSNumber class]])
        {
            if ([value isKindOfClass:[NSNumber class]])
            {
                newValue = value;
            }
        }
        else if ([attrClass isSubclassOfClass:[NSString class]])
        {
            if ([value isKindOfClass:[NSString class]])
            {
                newValue = value;
            }
        }
        else if ([attrClass isSubclassOfClass:[NSDate class]])
        {
            //DLog(@"Value.Class: %@", [value class]);
            
            if ([value isKindOfClass:[NSString class]])
            {
                NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                [dateFormatter setTimeZone:gmt];
                
                newValue = [dateFormatter dateFromString: value];
                
                dateFormatter = nil;
                gmt = nil;
            }
            else if ([value isKindOfClass:[NSDate class]])
            {
                newValue = value;
            }
        }
        else if ([attrClass isSubclassOfClass:[NSDictionary class]])
        {
            if ([value isKindOfClass:[NSDictionary class]])
            {
                newValue = value;
            }
        }
        else if ([attrClass isSubclassOfClass:[NSArray class]])
        {
            newValue = [instance valueForKey:key];
			
            //DLog(@"VALUE TYPE: %d", [value isKindOfClass:[NSArray class]]);
            //DLog(@"NEW VALUE TYPE: %d", [newValue isKindOfClass:[DataModelArray class]]);
            
            if ([value isKindOfClass:[NSArray class]] && [attrClass isSubclassOfClass:[JSONMutableArray class]] && newValue)
            {
                newValue = [(JSONMutableArray *)newValue fromJSONObject:value inStore:nil];
            }
            else 
            {
                newValue = value;
            }
        } 
        else 
        {
            if ([value isKindOfClass:[NSDictionary class]]) 
            {						
                newValue = [attrClass fromJSONObject:value inStore:nil];
            }
        }
    } 
    else if ([S_VALUE_TYPES rangeOfString:attrType].location != NSNotFound) 
    {
        newValue = value;
    }
    
    //DLog(@"\nKEY: %@\nVAL: %@\n", key, newValue);
    
    if (![newValue isKindOfClass:[NSNull class]]) 
    {
        [instance setValue:newValue forKey:key];
    }
    
}

+ (id)fromJSONObject:(NSDictionary *)jsonObject inStore:(CoreDataStore *)customStore
{
	Class modelType = [self class];
	
	NSObject *instance = [NSObject createObject:modelType inStore:customStore];
	
	//DLog(@"SELF CLASS: %@", modelType);
	
    NSArray *keys = [jsonObject allKeys];
    
    for (NSString *key in keys) 
	{
        
        [self setJsonProperty:key JsonObject:jsonObject modelClass:modelType thisInstance:instance];
      
    }
	
	return instance;
}

+ (NSObject *)createObject:(Class)modelType inStore:(CoreDataStore *)customStore
{
	
		return [[modelType alloc] init];

}
@end
