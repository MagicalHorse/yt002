//
//  FSAppDelegate.m
//  FashionShop
//
//  Created by gong yi on 11/2/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//
//#define ENVIRONMENT_DEVELOPMENT 1
#import "FSAppDelegate.h"
#import "FSModelManager.h"
#import "FSLocationManager.h"
#import "WXApi.h"
#import "FSWeixinActivity.h"
#import "FSUser.h"
#import "FSDeviceRegisterRequest.h"
#import "FSAnalysis.h"
#import "SplashViewController.h"
#import "FSStoreMapViewController.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "FSAudioHelper.h"

#import "PKRevealController.h"
#import "LeftDemoViewController.h"

//UMTrack
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@interface FSAppDelegate(){
    NSString *localToken;
}

@end

void uncaughtExceptionHandler(NSException *exception)
{
    [[FSAnalysis instance] logError:exception fromWhere:@"unhandle"];
}

@implementation FSAppDelegate
@synthesize allBrands;

@synthesize modelManager,locationManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //SETUP RKModel Manager
    modelManager = [FSModelManager sharedModelManager];

    //setup LOCATION MANAGER
    locationManager = [FSLocationManager sharedLocationManager];
    //SETUP REMOTE NOTIFICATION
    [self registerPushNotification];
    
    //setup exception handler
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
#if defined ENVIRONMENT_STORE
    //setup analysis
    [self setupAnalys];
#endif
    
    FSAudioHelper *help = [[FSAudioHelper alloc] init];
    [help initSession];
    
    [self setGlobalLayout];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSString *content = [self readFromFile:@"hasLaunched"];
    if (!content || ![content isEqualToString:@"hasLaunched"]) {
		SplashViewController *SVCtrl = [[SplashViewController alloc] init];
        SVCtrl.view.alpha = 1.0f;
        self.window.backgroundColor = [UIColor whiteColor];
		self.window.rootViewController =  SVCtrl;
        [self.window makeKeyAndVisible];
	} else {
        [self entryMain];
	}

    return YES;
}

-(void)entryMain
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UITabBarController *root = [storyBoard instantiateInitialViewController];
    self.window.backgroundColor = [UIColor whiteColor];
    self.root = root;
    
    //添加背景色
    NSArray *array = [root.view subviews];
    UITabBar *_tabbar = [array objectAtIndex:1];
    UIImageView *_vImage = [[UIImageView alloc] init];
    _vImage.backgroundColor = [UIColor blackColor];
    _vImage.frame = CGRectMake(0, 0, 320, TAB_HIGH);
    [_tabbar insertSubview:_vImage atIndex:1];
    
    UIViewController *leftViewController = [[LeftDemoViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:leftViewController];
    self.revealController = [PKRevealController revealControllerWithFrontViewController:root
                                                                     leftViewController:nav
                                                                    rightViewController:nil
                                                                                options:nil];
    
    self.window.rootViewController = self.revealController;
    
    [[FSAnalysis instance] autoTrackPages:root];
    [self.window makeKeyAndVisible];
}

+(FSAppDelegate *)app{
    return (FSAppDelegate *)[UIApplication sharedApplication];
}

-(void) setGlobalLayout
{
    [[UINavigationBar appearance] setBackgroundImage: [UIImage imageNamed: @"top_title_bg"] forBarMetrics: UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeFont:[UIFont boldSystemFontOfSize:18],UITextAttributeTextColor:APP_NAV_TITLE_COLOR}];
        [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsDefault];
}

-(void) setupAnalys
{
    [[FSAnalysis instance] start];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSString *schema = url.scheme ;
    if ([schema hasPrefix:WEIXIN_API_APP_KEY])
    {
        return  [[FSWeixinActivity sharedInstance] handleOpenUrl:url];
    }
    if ([schema hasSuffix:QQ_CONNECT_APP_ID]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    return YES; 
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *schema = url.scheme ;
    if ([schema hasPrefix:WEIXIN_API_APP_KEY])
    {
      return  [[FSWeixinActivity sharedInstance] handleOpenUrl:url];
    }
    if ([schema hasSuffix:QQ_CONNECT_APP_ID]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    return YES;
}

#pragma mark - Push Notification
- (void)registerPushNotification
{
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound |UIRemoteNotificationTypeAlert)];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSString * token = [deviceToken description];
	if (token.length > 0 )
	{
		token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
		token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
		token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
	}
	NSString *localDevice = [FSUser localDeviceToken];
	if (localDevice && localDevice.length >0
        && [localDevice isEqualToString:token])
	{
		return;
	}
	if (token.length == 64)
	{
        localToken = token;
        if (locationManager.locationAwared)
        {
            [self registerDevicePushNotification:token];
        } else
        {
            [locationManager addObserver:self forKeyPath:@"locationAwared" options:NSKeyValueObservingOptionNew context:nil];
        }
	}

}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"locationAwared"])
    {
        [self registerDevicePushNotification:localToken];
        [locationManager removeObserver:self forKeyPath:@"locationAwared"];
    }
}

- (void)registerDevicePushNotification:(NSString *)token
{    
#if defined ENVIRONMENT_DEVELOPMENT
    return;
#endif
    
    [modelManager enqueueBackgroundBlock:^(void){
        FSDeviceRegisterRequest *request = [[FSDeviceRegisterRequest alloc] init];
        request.longit =[[NSNumber alloc] initWithDouble:[FSLocationManager sharedLocationManager].currentCoord.longitude];
        request.lantit = [[NSNumber alloc] initWithDouble:[FSLocationManager sharedLocationManager].currentCoord.latitude];
        request.deviceToken = token;
        request.userToken = [FSModelManager sharedModelManager].loginToken;
        [request send:[FSModelBase class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
            if (resp.isSuccess)
            {
                [FSUser saveDeviceToken:token];
            }
        }]; 
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)data
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //goto the badge page:todo
}

-(BOOL)writeFile:(NSString*)aString fileName:(NSString*)aFileName
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //NSString *path = NSTemporaryDirectory();
    NSString *fileName=[path stringByAppendingPathComponent:aFileName];
    return [aString writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(NSString*)readFromFile:(NSString *)aFileName
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //NSString *path = NSTemporaryDirectory();
    NSString *fileName=[path stringByAppendingPathComponent:aFileName];
    return [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
}

#pragma mark - Audio Method

-(void)initAudioRecoder
{
    if (!_audioRecoder) {
        [self initAudioProperty];
        _audioRecoder = [[CL_AudioRecorder alloc] initWithFinishRecordingBlock:^(CL_AudioRecorder *recorder, BOOL success) {
        } encodeErrorRecordingBlock:^(CL_AudioRecorder *recorder, NSError *error) {
            NSLog(@"%@",[error localizedDescription]);
        } receivedRecordingBlock:^(CL_AudioRecorder *recorder, float peakPower, float averagePower, float currentTime) {
            //NSLog(@"%f,%f,%f",peakPower,averagePower,currentTime);
        }];
    }
}

-(void)initAudioProperty
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone || UIUserInterfaceIdiomPad)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError *error;
        if ([audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
        {
            if ([audioSession setActive:YES error:&error])
            {
            }
            else
            {
                NSLog(@"Failed to set audio session category: %@", error);
            }
        }
        else
        {
            NSLog(@"Failed to set audio session category: %@", error);
        }
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof(audioRouteOverride),&audioRouteOverride);
    }
}

#pragma mark - UMTrack

-(void)initUMTrack
{
    NSString * appKey = @"ebfc9b31ddfaf25bc3d526cefd48758f";
    NSString * deviceName = [[[UIDevice currentDevice] name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * mac = [self macString];
    NSString * urlString = [NSString stringWithFormat:@"http://log.umtrack.com/ping/%@/?devicename=%@&mac=%@", appKey,deviceName,mac];
    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL: [NSURL URLWithString:urlString]] delegate:nil];
}

- (NSString * )macString{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *macString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return macString;
}

@end
