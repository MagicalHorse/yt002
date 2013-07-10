//
//  FSMyLetter.m
//  FashionShop
//
//  Created by HeQingshan on 13-7-4.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSCoreMyLetter.h"

@implementation FSCoreMyLetter
@dynamic touser,fromuser,isauto,id,isvoice,msg,createdate;

+(RKObjectMapping *)getRelationDataMap:(Class)type withParentMap:(RKObjectMapping *)parentMap
{
    RKManagedObjectStore *objectStore = [FSModelManager sharedManager].objectStore;
    RKManagedObjectMapping *relationMapping = [RKManagedObjectMapping mappingForClass:[self class] inManagedObjectStore:objectStore];
    relationMapping.primaryKeyAttribute = @"id";
    [relationMapping mapKeyPath:@"id" toAttribute:@"id"];
    [relationMapping mapKeyPath:@"isauto" toAttribute:@"isauto"];
    [relationMapping mapKeyPath:@"isvoice" toAttribute:@"isvoice"];
    [relationMapping mapKeyPath:@"msg" toAttribute:@"msg"];
    [relationMapping mapKeyPath:@"createdate" toAttribute:@"createdate"];
    
    RKObjectMapping *map = [FSCoreUser getRelationDataMap:[FSCoreUser class] withParentMap:relationMapping];
    [relationMapping mapKeyPath:@"touser" toRelationship:@"touser" withMapping:map];
    [relationMapping mapKeyPath:@"fromuser" toRelationship:@"fromuser" withMapping:map];
    
    return relationMapping;
}

-(void)show
{
    NSLog(@"----------------------------------------------------------------------");
    NSLog(@"id:%d,msg:%@,fromuserid:%d,touserid:%d",self.id, self.msg,self.fromuser.uid,self.touser.uid);
    [self.fromuser show];
    [self.touser show];
    NSLog(@"----------------------------------------------------------------------");
}

+ (NSArray *) allLettersLocal
{
    return [self findAllSortedBy:@"id" ascending:TRUE];
}

+ (NSArray*) fetchData:(int)latestId one:(int)oneId two:(int)twoId length:(int)length ascending:(BOOL)flag
{
    NSArray *array = [self findAllSortedBy:@"id" ascending:TRUE];
    NSString *str = [NSString stringWithFormat:@"((fromuser.uid == %d AND touser.uid == %d) OR (fromuser.uid == %d AND touser.uid == %d)) AND (id < %d)", oneId, twoId, twoId, oneId, latestId];
    if (flag) {
        str = [NSString stringWithFormat:@"((fromuser.uid == %d AND touser.uid == %d) OR (fromuser.uid == %d AND touser.uid == %d)) AND (id > %d)", oneId, twoId, twoId, oneId, latestId];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:str];
    NSArray *array2 = [array filteredArrayUsingPredicate:predicate];
    if (array2.count <= length) {
        return array2;
    }
    NSArray *_toSub = [array2 subarrayWithRange:NSMakeRange(array2.count - length, length)];
    return _toSub;
}

+(NSArray*) fetchLatestLetters:(int)length one:(int)oneId two:(int)twoId{
    NSArray *array = [self findAllSortedBy:@"id" ascending:TRUE];
    NSString *str = [NSString stringWithFormat:@"(fromuser.uid == %d AND touser.uid == %d) OR (fromuser.uid == %d AND touser.uid == %d)", oneId, twoId, twoId, oneId];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:str];
    NSArray *array2 = [array filteredArrayUsingPredicate:predicate];
    if (array2.count <= length) {
        return array2;
    }
    NSArray *_toSub = [array2 subarrayWithRange:NSMakeRange(array2.count - length, length)];
    return _toSub;
}

+(int) lastConversationId:(int)oneId two:(int)twoId
{
    NSArray *array = [self findAllSortedBy:@"id" ascending:TRUE];
    NSString *str = [NSString stringWithFormat:@"(fromuser.uid == %d AND touser.uid == %d) OR (fromuser.uid == %d AND touser.uid == %d)", oneId, twoId, twoId, oneId];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:str];
    NSArray *array2 = [array filteredArrayUsingPredicate:predicate];
    FSCoreMyLetter *letter = array2[array2.count - 1];
    return letter.id;
}

+(FSCoreMyLetter*)findLetterByConversationId:(int)id
{
    NSArray *array = [self findAllSortedBy:@"id" ascending:TRUE];
    NSString *str = [NSString stringWithFormat:@"id == %d", id];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:str];
    NSArray *array2 = [array filteredArrayUsingPredicate:predicate];
    if(array2.count > 0) {
        return array2[0];
    }
    else{
        return nil;
    }
}

@end
