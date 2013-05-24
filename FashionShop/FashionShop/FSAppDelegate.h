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
#import "CL_VoiceEngine.h"
#import "FSStartViewController.h"
#import "FSCommon.h"


@class PKRevealController;
@protocol FSProDetailItemSourceProvider;

@interface FSAppDelegate : UIResponder <UIApplicationDelegate,FSProDetailItemSourceProvider> {
    FSStartViewController *_startController;
    NSDictionary    *_launch;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong,nonatomic) FSModelManager *modelManager;

@property (strong,nonatomic) FSLocationManager *locationManager;

@property (strong,nonatomic) NSMutableArray *allBrands;
@property (strong,nonatomic) CL_AudioRecorder* audioRecoder;
@property (strong,nonatomic) AVAudioPlayer *audioPlayer;
@property (strong,nonatomic) FSCommon *versionData;

@property (strong,nonatomic) UIViewController *root;

@property (nonatomic, strong, readwrite) PKRevealController *revealController;

+(FSAppDelegate *)app;
-(void)entryMain;
-(void)initAudioRecoder;

-(BOOL)writeFile:(NSString*)aString fileName:(NSString*)aFileName;
-(NSString*)readFromFile:(NSString *)aFileName;

- (void)registerDevicePushNotification;
-(void)removeCommentID:(NSString *)commentID;
-(void)removeCommentIDs:(NSArray *)ids;
-(int)newCommentCount;

@end
