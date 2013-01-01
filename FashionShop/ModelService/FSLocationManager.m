//
//  FSLocationManager.m
//  FashionShop
//
//  Created by gong yi on 11/17/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSLocationManager.h"
#import <CoreLocation/CLGeocoder.h>
static FSLocationManager *_locationManager;

@interface FSLocationManager()
{
    CLLocationManager* _innerLocation;
}
@end

@implementation FSLocationManager
@synthesize currentCoord=_currentCoord, city=_city;

- (void) initLocationManager{
    // if location services are restricted do nothing
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        if (_locationDelegate)
        {
            
            [_locationDelegate performSelector:@selector(didLocationFailAwared:) withObject:self];
        }
        return;
    }
    
    // if locationManager does not currently exist, create it
    if (!_innerLocation)
    {
        _innerLocation = [[CLLocationManager alloc] init];
        [_innerLocation setDelegate:self];
        _innerLocation.distanceFilter = 10.0f;
    }
    
    [_innerLocation startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // if the location is older than 30s ignore
    if (fabs([newLocation.timestamp timeIntervalSinceDate:[NSDate date]]) > 30)
    {
        return;
    }

    _currentCoord = [newLocation coordinate];
    [self getCity];
    
    [_innerLocation stopUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    
    // stop updating
    [_innerLocation stopUpdatingLocation];

    
    // since we got an error, set selected location to invalid location
    _currentCoord = kCLLocationCoordinate2DInvalid;
    
}
-(void)cityAware:(NSArray *)placeMarks{
    if (placeMarks.count>0)
    {
        CLPlacemark *place = [placeMarks objectAtIndex:0];
        _city =place.administrativeArea;
        if (_locationDelegate)
        {
        
            [_locationDelegate performSelector:@selector(didLocationAwared:) withObject:self];
        }
    
    } else{
        if (_locationDelegate)
        {
            
            [_locationDelegate performSelector:@selector(didLocationFailAwared:) withObject:self];
        }

    }
}

- (void)getCity{

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];

    CLLocation *location = [[CLLocation alloc] initWithLatitude:_currentCoord.latitude longitude:_currentCoord.longitude];
    
    __block FSLocationManager *blockManager = self;
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        [blockManager cityAware:placemarks];
    }];
}

+ (FSLocationManager *)sharedLocationManager{
    
    if (_locationManager == nil){
        @synchronized(self)
        {
            if(_locationManager==nil)
            {
                _locationManager = [[FSLocationManager alloc] init];
                [_locationManager initLocationManager];

                
            }
            
        }
       
    }
   
    return _locationManager;

    
}

+ (NSString *) computeDistanceToCurrentLocation:(CLLocationCoordinate2D)where{
    

    CLLocationDegrees latitude, longitude;
    
    latitude = [FSLocationManager sharedLocationManager].currentCoord.latitude;
    longitude = [FSLocationManager sharedLocationManager].currentCoord.longitude;
    CLLocation *to = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    latitude = where.latitude;
    longitude = where.longitude;
    CLLocation *from = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    CLLocationDistance distance = [to distanceFromLocation:from];
    return [NSString stringWithFormat:@"%.f米",distance];
    
}
@end
