//
//  FSAnalysis.m
//  FashionShop
//
//  Created by gong yi on 12/10/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSAnalysis.h"
#import "Flurry.h"
#import "FSConfiguration.h"

static FSAnalysis *_instance;
@implementation FSAnalysis

-(id) init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

-(void) start
{
    [Flurry startSession:FLURRY_APP_KEY];
}


-(void) logError:(NSException *)exception fromWhere:(NSString *)category
{
    [Flurry logError:category message:exception.description exception:exception];
}

- (void) logEvent:(NSString *) 	eventName
          withParameters:(NSDictionary *) parameters
{
    [Flurry logEvent:eventName withParameters:parameters];
}

-(void) autoTrackPages:(UIViewController *)rootConroller
{
    [Flurry logAllPageViews:rootConroller];
}

+(FSAnalysis *) instance
{
    if (!_instance)
    {
        _instance = [[FSAnalysis alloc] init];
    }
    return _instance;
}

@end
