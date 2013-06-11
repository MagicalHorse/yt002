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
#import "FSMyCommentController.h"
#import "FSProDetailViewController.h"
#import "NSString+SBJSON.h"
#import "FSContentViewController.h"
#import "FSMeViewController.h"

#import "PKRevealController.h"
#import "LeftDemoViewController.h"

//UMTrack
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@interface FSAppDelegate(){
    NSString *localToken;
    NSDictionary   *pushInfoDic;   //保存推送过来的消息对象
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
    
    //添加UmengTrack
    [self initUMTrack];
    
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
    
    //加载启动图
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _startController = [[FSStartViewController alloc] init];
    _startController.view.alpha = 1.0f;
    [UIView animateWithDuration:0.3 animations:^{
        _startController.view.alpha = 1.0f;
        [self.window addSubview:_startController.view];
        [self.window makeKeyAndVisible];
    } completion:^(BOOL finished) {}];
    _launch = launchOptions;
    //三秒钟后关闭
    [self performSelector:@selector(loadMainView) withObject:nil afterDelay:3];

    return YES;
}

-(void)loadMainView {
    [UIView animateWithDuration:0.3 animations:^{
        _startController.view.alpha = 0.8f;
    } completion:^(BOOL finished) {
        //删除_startController
        [_startController.view removeFromSuperview];
        
        //先判断是否是第一次使用
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
    }];
}

-(void)entryMain
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UITabBarController *root = [storyBoard instantiateInitialViewController];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = root;
    [[FSAnalysis instance] autoTrackPages:root];
    [self.window makeKeyAndVisible];
    
    UINavigationController *con = root.viewControllers[3];
    [[NSNotificationCenter defaultCenter] addObserver:con.topViewController selector:@selector(receivePushNotification:) name:@"ReceivePushNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceivePushNotification" object:nil];
    
    //添加背景色
    NSArray *array = [root.view subviews];
    UITabBar *_tabbar = [array objectAtIndex:1];
    UIImageView *_vImage = [[UIImageView alloc] init];
    _vImage.image = [UIImage imageNamed:@"Toolbar_bg.png"];
    _vImage.frame = CGRectMake(0, 0, 320, TAB_HIGH);
    [_tabbar insertSubview:_vImage atIndex:1];
    for (int i = 0; i < _tabbar.items.count; i++) {
        UITabBarItem *item = _tabbar.items[i];
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"tab_bar_%d.png", i + 1]];
        UIImage *img_sel = [UIImage imageNamed:[NSString stringWithFormat:@"tab_bar_%d_sel.png", i + 1]];
        [item setFinishedSelectedImage:img_sel withFinishedUnselectedImage:img];
        
        [item setTitlePositionAdjustment:UIOffsetMake(0, -3)];
        [item setImageInsets:UIEdgeInsetsMake(4, 0, -4, 0)];
    }
/*
    UIViewController *leftViewController = [[LeftDemoViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:leftViewController];
    self.revealController = [PKRevealController revealControllerWithFrontViewController:root
                                                                     leftViewController:nav
                                                                    rightViewController:nil
                                                                                options:nil];
    //侧边栏设置，暂时保留
    self.window.rootViewController = self.revealController;
*/
    
    //地下的这点代码应该是判断如果是完全推出状态下，push进来做的操作，如果是完全退出状态下的话，这样会在home里面进行插入操作。
    NSDictionary *userInfo = [_launch objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    if (userInfo) {
        pushInfoDic = userInfo;
        [self pushTo];
    }
}

+(FSAppDelegate *)app{
    return (FSAppDelegate *)[UIApplication sharedApplication];
}

-(void) setGlobalLayout
{
    UINavigationBar *nav = [UINavigationBar appearance];
    [nav setBackgroundImage: [UIImage imageNamed: @"top_title_bg"] forBarMetrics: UIBarMetricsDefault];
    [nav setTitleTextAttributes:@{UITextAttributeFont:[UIFont boldSystemFontOfSize:18],UITextAttributeTextColor:APP_NAV_TITLE_COLOR}];
    [nav setTitleVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsDefault];
    nav.tintColor = [UIColor blackColor];
    nav.backgroundColor = [UIColor blackColor];
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
     (UIRemoteNotificationTypeSound |UIRemoteNotificationTypeAlert)];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"My token error: %@", [error description]);
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
	if (token.length == 64)
	{
        localToken = token;
        if (locationManager.locationAwared)
        {
            [self registerDevicePushNotification];
        }
        else
        {
            [locationManager addObserver:self forKeyPath:@"locationAwared" options:NSKeyValueObservingOptionNew context:nil];
        }
	}
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"locationAwared"])
    {
        [self registerDevicePushNotification];
        [locationManager removeObserver:self forKeyPath:@"locationAwared"];
    }
}

- (void)registerDevicePushNotification
{    
#if defined ENVIRONMENT_DEVELOPMENT
    return;
#endif
    if (!localToken || [localToken isEqualToString:@""]) {
        localToken = [FSUser localDeviceToken];
        if (!localToken || [localToken isEqualToString:@""])
            return;
    }
    NSString *uId = [NSString stringWithFormat:@"%@", [FSModelManager sharedModelManager].localLoginUid];
    if (!uId || [uId isEqualToString:@""]) {
        return;
    }
    [modelManager enqueueBackgroundBlock:^(void){
        FSDeviceRegisterRequest *request = [[FSDeviceRegisterRequest alloc] init];
        request.longit =[[NSNumber alloc] initWithDouble:[FSLocationManager sharedLocationManager].currentCoord.longitude];
        request.lantit = [[NSNumber alloc] initWithDouble:[FSLocationManager sharedLocationManager].currentCoord.latitude];
        request.deviceToken = localToken;
        request.userToken = [FSModelManager sharedModelManager].loginToken;
        request.userId = uId;
        request.deviceName = [[[UIDevice currentDevice] name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [request send:[FSModelBase class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
            if (resp.isSuccess)
            {
                [FSUser saveDeviceToken:localToken];
            }
        }]; 
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    pushInfoDic = userInfo;
    //根据不同的key值跳转到不同的界面
    NSString * from = (NSString*)[pushInfoDic objectForKey:@"from"];
    NSDictionary *dic = [from JSONValue];
    int type = [[dic objectForKey:@"targettype"] intValue];
    if([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [self pushTo];
    }
    if (type == 3) {
        id value = [dic objectForKey:@"targetvalue"];
        [self addNewCommentID:value];
    }
}

-(void)addNewCommentID:(NSString *)commentID
{
    NSMutableArray *_array = nil;
    id temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"targetvalue"];
    if (temp && [temp isKindOfClass:[NSMutableArray class]]) {
        _array = [NSMutableArray arrayWithArray:temp];
    }
    else{
        _array = [[NSMutableArray alloc] initWithCapacity:1];
    }
    BOOL flag = NO;
    for (NSString *item in _array) {
        if ([item intValue] == [commentID intValue]) {
            flag = YES;
            break;
        }
    }
    if (!flag) {
        [_array addObject:commentID];
    }
    [[NSUserDefaults standardUserDefaults] setObject:_array forKey:@"targetvalue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceivePushNotification" object:nil];
}

-(void)removeCommentID:(NSString *)commentID
{
    [self removeCommentIDs:[NSArray arrayWithObject:commentID]];
}

-(void)removeCommentIDs:(NSArray *)ids
{
    if (!ids || ids.count <= 0) {
        return;
    }
    id temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"targetvalue"];
    NSMutableArray *_array = [NSMutableArray arrayWithArray:temp];
    if (!_array || _array.count <= 0) {
        return;
    }
    NSMutableArray *toDelArray = [NSMutableArray array];
    for (NSString *toDel in ids) {
        NSString *delString = nil;
        for (NSString *item in _array) {
            if ([item intValue] == [toDel intValue]) {
                delString = item;
                break;
            }
        }
        if (delString) {
            [toDelArray addObject:delString];
        }
    }
    if (toDelArray.count > 0) {
        [_array removeObjectsInArray:toDelArray];
        [[NSUserDefaults standardUserDefaults] setObject:_array forKey:@"targetvalue"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceivePushNotification" object:nil];
    }
}

-(int)newCommentCount
{
    NSMutableArray *_array = [[NSUserDefaults standardUserDefaults] objectForKey:@"targetvalue"];
    if (_array && _array.count > 0) {
        return _array.count;
    }
    return 0;
}

-(void)receivePushNotice:(NSNotification*)notification
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UITabBarController *root = [storyBoard instantiateInitialViewController];
    UINavigationController *con = root.viewControllers[3];
    if ([notification.object boolValue]) {
        con.tabBarItem.badgeValue = @"new";
    }
    else{
        con.tabBarItem.badgeValue = nil;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application NS_AVAILABLE_IOS(4_0)
{
    
}
- (void)applicationWillEnterForeground:(UIApplication *)application NS_AVAILABLE_IOS(4_0)
{
    //test
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//    UITabBarController *root = [storyBoard instantiateInitialViewController];
//    int index = root.selectedIndex;
//    UINavigationController *con = root.viewControllers[index];
//    [con reportError:@"Test"];
}

-(void)pushTo
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UITabBarController *root = [storyBoard instantiateInitialViewController];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = root;
    [self.window makeKeyAndVisible];
    
    UINavigationController *con = root.viewControllers[3];
    [[NSNotificationCenter defaultCenter] addObserver:con.topViewController selector:@selector(receivePushNotification:) name:@"ReceivePushNotification" object:nil];
    
    //添加背景色
    NSArray *array = [root.view subviews];
    UITabBar *_tabbar = [array objectAtIndex:1];
    UIImageView *_vImage = [[UIImageView alloc] init];
    _vImage.image = [UIImage imageNamed:@"Toolbar_bg.png"];
    _vImage.frame = CGRectMake(0, 0, 320, TAB_HIGH);
    [_tabbar insertSubview:_vImage atIndex:1];
    for (int i = 0; i < _tabbar.items.count; i++) {
        UITabBarItem *item = _tabbar.items[i];
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"tab_bar_%d.png", i + 1]];
        UIImage *img_sel = [UIImage imageNamed:[NSString stringWithFormat:@"tab_bar_%d_sel.png", i + 1]];
        [item setFinishedSelectedImage:img_sel withFinishedUnselectedImage:img];
        
        [item setTitlePositionAdjustment:UIOffsetMake(0, -3)];
        [item setImageInsets:UIEdgeInsetsMake(4, 0, -4, 0)];
    }
    
    /*
     "from"key对应的value为json字符串
     {“targettype”,"targetvalue"}
     targettype:
     0-首页
     1-商品详情
     2-促销详情
     3-我的评论
     4-URL
     
     返回形式：
     返回形式：
     {
     aps =     {
        alert = "\U65b0\U8bc4\U8bba...";
        badge = 1;
        sound = "sound.caf";
     };
     from = "{\"targettype\":3,\"targetvalue\":\"\"}";
     }
     */
    //根据不同的key值跳转到不同的界面
    NSString * from = (NSString*)[pushInfoDic objectForKey:@"from"];
    NSDictionary *dic = [from JSONValue];
    int type = [[dic objectForKey:@"targettype"] intValue];
    NSString *value = [dic objectForKey:@"targetvalue"];
    switch (type) {
        case 0://首页
        {
            root.selectedIndex = 0;
        }
            break;
        case 1://商品详情
        {
            root.selectedIndex = 1;
            UINavigationController *nav = (UINavigationController*)root.selectedViewController;
            FSProDetailViewController *detailView = [[FSProDetailViewController alloc] initWithNibName:@"FSProDetailViewController" bundle:nil];
            FSProItemEntity *item = [[FSProItemEntity alloc] init];
            item.id = [value intValue];
            detailView.navContext = [[NSMutableArray alloc] initWithObjects:item, nil];
            detailView.sourceType = FSSourceProduct;
            detailView.indexInContext = 0;
            detailView.dataProviderInContext = self;
            UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:detailView];
            [nav presentViewController:navControl animated:true completion:nil];
        }
            break;
        case 2://促销详情
        {
            root.selectedIndex = 1;
            UINavigationController *nav = (UINavigationController*)root.selectedViewController;
            FSProDetailViewController *detailView = [[FSProDetailViewController alloc] initWithNibName:@"FSProDetailViewController" bundle:nil];
            FSProdItemEntity *item = [[FSProdItemEntity alloc] init];
            item.id = [value intValue];
            detailView.navContext = [[NSMutableArray alloc] initWithObjects:item, nil];
            detailView.sourceType = FSSourcePromotion;
            detailView.indexInContext = 0;
            detailView.dataProviderInContext = self;
            UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:detailView];
            [nav presentViewController:navControl animated:true completion:nil];
        }
            break;
        case 3://我的评论
        {
            //导航到我的评论页
            root.selectedIndex = 3;
            UINavigationController *nav = (UINavigationController*)root.selectedViewController;
            //需要先判断是否登录
            bool isLogined = [[FSModelManager sharedModelManager] isLogined];
            if (!isLogined)
            {
                FSMeViewController *loginController = [storyBoard instantiateViewControllerWithIdentifier:@"userProfile"];
                __block FSMeViewController *blockMeController = loginController;
                loginController.completeCallBack=^(BOOL isSuccess){
                    
                    [blockMeController dismissViewControllerAnimated:true completion:^{
                        if (!isSuccess)
                        {
                            [nav reportError:NSLocalizedString(@"COMM_OPERATE_FAILED", nil)];
                        }
                        else
                        {
                            FSMyCommentController *controller = [[FSMyCommentController alloc] initWithNibName:@"FSMyCommentController" bundle:nil];
                            [nav pushViewController:controller animated:true];
                        }
                    }];
                };
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
                [nav presentViewController:navController animated:YES completion:nil];
                
            }
            else
            {
                FSMyCommentController *controller = [[FSMyCommentController alloc] initWithNibName:@"FSMyCommentController" bundle:nil];
                [nav pushViewController:controller animated:YES];
            }
        }
            break;
        case 4://URL
        {
            root.selectedIndex = 1;
            UINavigationController *nav = (UINavigationController*)root.selectedViewController;
            FSContentViewController *controller = [[FSContentViewController alloc] init];
            controller.fileName = value;
            controller.title = [[pushInfoDic objectForKey:@"aps"] objectForKey:@"alert"];
            [nav pushViewController:controller animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Write And Read File

-(BOOL)writeFile:(NSString*)aString fileName:(NSString*)aFileName
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName=[path stringByAppendingPathComponent:aFileName];
    return [aString writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(NSString*)readFromFile:(NSString *)aFileName
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName=[path stringByAppendingPathComponent:aFileName];
    return [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
}

#pragma mark - Audio Method

-(void)initAudioRecoder
{
    [self initAudioProperty];
    _audioRecoder = [[CL_AudioRecorder alloc] initWithFinishRecordingBlock:^(CL_AudioRecorder *recorder, BOOL success) {
    } encodeErrorRecordingBlock:^(CL_AudioRecorder *recorder, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    } receivedRecordingBlock:^(CL_AudioRecorder *recorder, float peakPower, float averagePower, float currentTime) {
    }];
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

#pragma mark - FSProDetailItemSourceProvider

-(FSSourceType)proDetailViewSourceTypeFromContext:(FSProDetailViewController *)view forIndex:(NSInteger)index
{
    return view.sourceType;
}

-(BOOL)proDetailViewNeedRefreshFromContext:(FSProDetailViewController *)view forIndex:(NSInteger)index
{
    return TRUE;
}

@end
