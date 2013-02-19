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
    //setup analysis
    [self setupAnalys];
    
    //set global layout
    [self setGlobalLayout];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    //goto splash
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

//HeQingshan
-(void)entryMain
{
    //launch story board
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UITabBarController *root = [storyBoard instantiateInitialViewController];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    //添加背景色
    NSArray *array = [root.view subviews];
    UITabBar *_tabbar = [array objectAtIndex:1];
    id item = [_tabbar.subviews objectAtIndex:0];
    [item removeFromSuperview];
    //UIImage *_image = [UIImage imageNamed:@"Toolbar_bg.png"];
    //UIImageView *_vImage = [[UIImageView alloc] initWithImage:_image];
    UIImageView *_vImage = [[UIImageView alloc] init];
    _vImage.backgroundColor = [UIColor blackColor];
    //_vImage.alpha = 0.95f;
    _vImage.frame = CGRectMake(0, 0, 320, TAB_HIGH);
    [_tabbar insertSubview:_vImage atIndex:0];
    
    self.window.rootViewController = root;
    [[FSAnalysis instance] autoTrackPages:root];
    for (UIViewController *item in root.viewControllers) {
        [[FSAnalysis instance] autoTrackPages:item];
    }
    [self.window makeKeyAndVisible];
}


+(FSAppDelegate *)app{
    return (FSAppDelegate *)[UIApplication sharedApplication];
}

-(void) setGlobalLayout
{
    [[UINavigationBar appearance] setBackgroundImage: [UIImage imageNamed: @"top_title_bg"] forBarMetrics: UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeFont:[UIFont systemFontOfSize:16],UITextAttributeTextColor:APP_NAV_TITLE_COLOR}];
        [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:4 forBarMetrics:UIBarMetricsDefault];
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
    return YES; 
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    NSString *schema = url.scheme ;
    if ([schema hasPrefix:WEIXIN_API_APP_KEY])
    {
      return  [[FSWeixinActivity sharedInstance] handleOpenUrl:url];
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

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	DLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)data
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //goto the badge page:todo
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL)writeFile:(NSString*)aString fileName:(NSString*)aFileName
{
    //NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = NSTemporaryDirectory();
    NSString *fileName=[path stringByAppendingPathComponent:aFileName];
    return [aString writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(NSString*)readFromFile:(NSString *)aFileName
{
    //NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = NSTemporaryDirectory();
    NSString *fileName=[path stringByAppendingPathComponent:aFileName];
    return [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
}

@end
