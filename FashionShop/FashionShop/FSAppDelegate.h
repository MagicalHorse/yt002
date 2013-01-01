//
//  FSAppDelegate.h
//  FashionShop
//
//  Created by gong yi on 11/2/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSLocationManager.h"
#import "FSModelManager.h"

@interface FSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (strong,nonatomic) FSModelManager *modelManager;

@property (strong,nonatomic) FSLocationManager *locationManager;

+(FSAppDelegate *)app;
@end
