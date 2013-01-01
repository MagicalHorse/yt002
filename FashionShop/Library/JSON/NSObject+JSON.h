//
//  NSObject+JSON.h
//  NeweggFramework
//
//  Created by Cheney Yan on 2/3/12.
//  Copyright (c) 2012 Fara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JSON)

+ (NSString *)toJSONString:(NSObject *)nsObject;
+ (NSObject *)toJSONObject:(NSObject *)nsObject;

+ (id)fromJSONString:(NSString *)jsonString;
+ (id)fromJSONString:(NSString *)jsonString inStore:(CoreDataStore *)customStore;

+ (id)fromJSONObject:(NSDictionary *)jsonObject;
+ (id)fromJSONObject:(NSDictionary *)jsonObject inStore:(CoreDataStore *)customStore;

+ (NSObject *)createObject:(Class) modelType inStore:(CoreDataStore *)customStore;

- (void) setJsonProperty:(NSString *)key JsonObject:(NSDictionary *)jsonObject modelClass:(Class)modelType thisInstance:(NSObject *)instance;
@end
