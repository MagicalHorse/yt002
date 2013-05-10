
#import "FSStartViewController.h"
#import "FSCommonRequest.h"
#import "UIDevice+Extention.h"

@implementation FSStartViewController

- (void)loadView {
	CGRect appFrame = [[UIScreen mainScreen] bounds];
	UIView *lView = [[UIView alloc] initWithFrame:appFrame];
	self.view = lView;
    fileCache = [[FSFileCache alloc] initWithFileName:@"bootImages.dat"];
	[self showBootImage:NO];
    [self checkVersion];
}

//进行版本检测
-(void)checkVersion
{
    //请求网络数据，此处可更改为版本更新检查
    FSCommonRequest *request = [[FSCommonRequest alloc] init];
    [request setRouteResourcePath:RK_REQUEST_CHECK_VERSION];
    __block FSStartViewController *blockSelf = self;
    [request send:[FSModelBase class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
        if (resp.isSuccess)
        {
            //解析返回的数据
            /*
            id json = [jsonData JSONValue];
            result = [[json objectForKey:@"result"] intValue];
            message = [json objectForKey:@"prompt"];
            if (result != 0) {
                updateUrl = [[json objectForKey:@"url"] retain];
            }
             */
        }
        else
        {
        //    [blockSelf reportError:resp.errorDescrip];
        }
    }];
}

-(void)showBootImage:(BOOL)isLandscape{
    [splashImageView removeFromSuperview];
    NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"default_img_path"];
    if (!path) {
        if ([UIDevice isRunningOniPhone5]) {
            splashImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-568h.png"]];
        }
        else{
            splashImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
        }
    }
    else {
        NSData* imageData=(NSData*)[fileCache objectForKey:path];
        UIImage* image = nil;
        if(imageData!=nil){
            image=[UIImage imageWithData:imageData];
        }
        if (image) {
            splashImageView = [[UIImageView alloc] initWithImage:image];
        }
        else{   //既无新的默认启动图片又没有特殊实效启动图片，则显示本地默认的启动图片
            if ([UIDevice isRunningOniPhone5]) {
                splashImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-568h.png"]];
            }
            else{
                splashImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
            }
        }
    }
    splashImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HIGH);
    [self.view addSubview:splashImageView];	
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /*
    if (alertView.tag == 101 && result == 1) {
        if (buttonIndex == 1) {
            return;
        }
        else{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateUrl]];
        }
    }
    else if(alertView.tag == 102 && result == 2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateUrl]];
           [self exitApplication];
    }
     */
}

//退出应用程序（OK）
- (void)exitApplication {
    [UIView beginAnimations:@"exitApplication" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationCurveEaseOut forView:theApp.window cache:NO];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    theApp.window.bounds = CGRectMake(0, 0, 0, 0);
    [UIView commitAnimations];
}

- (void)animationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([animationID compare:@"exitApplication"] == 0) {
        exit(0);
    }
}

@end
