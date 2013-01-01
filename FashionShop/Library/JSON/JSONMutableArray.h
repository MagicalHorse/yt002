//
//  DataModelArray.h
//  Monogram
//
//  Created by Cheney Yan on 1/30/12.
//  Copyright (c) 2012 Fara Inc. All rights reserved.
//
#import "CoreDataStore.h"
@interface JSONMutableArray : NSMutableArray {
    NSMutableArray  *_data;
    Class           _modelType;
}

@property(nonatomic,assign) Class modelType;

+ (id)arrayWithModelType:(Class)modelType;

- (JSONMutableArray *)fromJSONObject:(NSArray *)nsArray;
- (JSONMutableArray *)fromJSONObject:(NSArray *)nsArray inStore:(CoreDataStore *)customStore;

@end
