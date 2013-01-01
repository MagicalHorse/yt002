//
//  FSLocationManager.h
//  FashionShop
//
//  Created by gong yi on 11/17/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class FSLocationManager;
@protocol FSLocationAwaredDelegate <NSObject>

-(void) didLocationAwared:(FSLocationManager *)location;
-(void) didLocationFailAwared:(FSLocationManager *)location;

@end

@interface FSLocationManager : NSObject<CLLocationManagerDelegate>

- (void) initLocationManager;
@property(nonatomic,assign,readonly) CLLocationCoordinate2D currentCoord;
@property(nonatomic,strong) NSString *city;
@property(nonatomic,strong) id<FSLocationAwaredDelegate> locationDelegate;

+ (FSLocationManager *)sharedLocationManager;
+ (NSString *) computeDistanceFromCurrentLocation:(CLLocationCoordinate2D)from;
@end
