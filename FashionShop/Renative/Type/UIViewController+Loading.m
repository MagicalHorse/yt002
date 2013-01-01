//
//  UIViewController+Loading.m
//  FashionShop
//
//  Created by gong yi on 11/23/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "UIViewController+Loading.h"
#import "MBProgressHUD.h"
#import "FSConfiguration.h"
#import "FSOverlayView.h"


#define UIVIEWCONTROLLER_CAT_LOADING_ID 10000
#define UIVIEWCONTROLLER_CAT_REPORT_ID 10001
#define UIVIEWCONTROLLER_CAT_PROGRESS_ID 10002
#define UIVIEWCONTROLLER_CAT_ENTER_VIEW 10003
#define UIVIEWCONTROLLER_NO_RESULT_ID 10004

@implementation UIViewController(loading)

-(void) prepareEnterView:(UIView *)container
{
    if (!container)
        container = self.view;
    UIView *emptyView = (UIView *)[container viewWithTag:UIVIEWCONTROLLER_CAT_ENTER_VIEW];
    if (!emptyView)
    {
        emptyView = [[UIView alloc] initWithFrame:container.frame];
        emptyView.backgroundColor = [UIColor whiteColor];
        UIActivityIndicatorView *refreshView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        refreshView.frame = CGRectMake(emptyView.frame.size.width/2-30,emptyView.frame.origin.y+50, 50, 50);
        [emptyView addSubview:refreshView];
        [refreshView startAnimating];

        emptyView.tag = UIVIEWCONTROLLER_CAT_ENTER_VIEW;
    }
    [container addSubview:emptyView];
    [container bringSubviewToFront:emptyView];

}

-(void) didEnterView:(UIView *)container
{
    if (!container)
        container = self.view;
    UIView *emptyView =(UIView *)[container viewWithTag:UIVIEWCONTROLLER_CAT_ENTER_VIEW];
    if (emptyView)
    {
        [emptyView removeFromSuperview];
    }

}

-(void) beginLoading:(UIView *)container
{
    if (!container)
        container = self.view;
    UIActivityIndicatorView *refreshView =(UIActivityIndicatorView *)[container viewWithTag:UIVIEWCONTROLLER_CAT_LOADING_ID];
    if(!refreshView)
    {
        refreshView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
      //  refreshView.center = self.view.center;
        refreshView.frame = CGRectMake(self.view.frame.size.width/2-30,self.view.frame.origin.y+50, 50, 50);
        refreshView.tag = UIVIEWCONTROLLER_CAT_LOADING_ID;
    }
    [refreshView startAnimating];
    [container addSubview:refreshView];
    [container bringSubviewToFront:refreshView];

}
-(void) endLoading:(UIView *)container
{
    if (!container)
        container = self.view;
    UIActivityIndicatorView *refreshView =(UIActivityIndicatorView *)[container viewWithTag:UIVIEWCONTROLLER_CAT_LOADING_ID];
    if (refreshView)
    {
        [refreshView stopAnimating];
        [refreshView removeFromSuperview];
    }
 
}


-(void) showNoResult:(UIView *)container withText:(NSString *)text
{
    [self showNoResult:container withText:text originOffset:0];
}
-(void) showNoResult:(UIView *)container withText:(NSString *)text originOffset:(CGFloat)height
{
    if (!container)
        container = self.view;
    UILabel *noResult =(UILabel *)[container viewWithTag:UIVIEWCONTROLLER_NO_RESULT_ID];
    if(!noResult)
    {
        noResult = [[UILabel alloc] init];
        noResult.text = text;
        noResult.font = ME_FONT(12);
        CGSize resultSize = [noResult.text sizeWithFont:ME_FONT(12)];
        noResult.frame = CGRectMake(self.view.frame.size.width/2-resultSize.width/2,self.view.frame.origin.y+height+10, resultSize.width, resultSize.height);
        noResult.tag = UIVIEWCONTROLLER_NO_RESULT_ID;
    }
    [container addSubview:noResult];
    [container bringSubviewToFront:noResult];

}
-(void) hideNoResult:(UIView *)container
{
    if (!container)
        container = self.view;
    UILabel *noResult =(UILabel *)[container viewWithTag:UIVIEWCONTROLLER_NO_RESULT_ID];
    if (noResult)
    {
        [noResult removeFromSuperview];
    }
    
}


-(void) reportError:(NSString *)message
{
    MBProgressHUD * statusReport =(MBProgressHUD *)[self.view viewWithTag:UIVIEWCONTROLLER_CAT_REPORT_ID];
    if(!statusReport)
    {
        statusReport = [[MBProgressHUD alloc] initWithView:self.view];
        statusReport.dimBackground = true;
        statusReport.mode = MBProgressHUDModeText;
    }
    [self.view addSubview:statusReport];
    statusReport.labelText = message;
    [statusReport show:true];
    [statusReport performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:2];

}


-(void) startProgress:(NSString *)message withExeBlock:(FSProgressExecBlock)block completeCallbck:(dispatch_block_t)callback
{
    MBProgressHUD * statusReport =(MBProgressHUD *)[self.view viewWithTag:UIVIEWCONTROLLER_CAT_PROGRESS_ID];
    if(!statusReport)
    {
        statusReport = [[MBProgressHUD alloc] initWithView:self.view];
        statusReport.tag = UIVIEWCONTROLLER_CAT_PROGRESS_ID;
    }
    [self.view addSubview:statusReport];
    statusReport.labelText = message;
    [statusReport show:true];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        block(callback);
    });
    

}

-(void) updateProgress:(NSString *) message 
{
    MBProgressHUD * statusReport =(MBProgressHUD *)[self.view viewWithTag:UIVIEWCONTROLLER_CAT_PROGRESS_ID];

    statusReport.labelText = message;
   
}

-(void) endProgress
{
    MBProgressHUD * statusReport =(MBProgressHUD *)[self.view viewWithTag:UIVIEWCONTROLLER_CAT_PROGRESS_ID];
    if (!statusReport)
        return;
    [statusReport performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.5];
}


-(void) setTransition:(NSString *)direction toController:(UIViewController *)controller
{
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFillModeForwards;
    
    animation.delegate = controller;
    animation.removedOnCompletion = YES;
    
    animation.type = kCATransitionFade;
    
    animation.subtype = direction;
    
    [controller.view.layer addAnimation:animation forKey:nil];
}


-(UIBarButtonItem *)createPlainBarButtonItem:(NSString *)imageName target:(id)targ action:(SEL)action
{
    UIImage *sheepImage = [UIImage imageNamed:imageName];
    UIButton *sheepButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sheepButton setImage:sheepImage forState:UIControlStateNormal];
    [sheepButton addTarget:targ action:action forControlEvents:UIControlEventTouchUpInside];
    [sheepButton setShowsTouchWhenHighlighted:YES];
    [sheepButton sizeToFit];
    
    return [[UIBarButtonItem alloc] initWithCustomView:sheepButton];
}

-(void)replaceBackItem
{
    UIImage *sheepImage = [UIImage imageNamed:@"goback_icon"];
    UIButton *sheepButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sheepButton setImage:sheepImage forState:UIControlStateNormal];
    [sheepButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [sheepButton setShowsTouchWhenHighlighted:YES];
    [sheepButton sizeToFit];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:sheepButton]];
   
}

-(void)goBack
{
     //[self dismissViewControllerAnimated:TRUE completion:nil];
    [self.navigationController popViewControllerAnimated:TRUE];
}

-(void)decorateOverlayToCamera:(UIImagePickerController *)camera
{
    
    if (camera &&
        camera.sourceType== UIImagePickerControllerSourceTypeCamera)
    {
        camera.showsCameraControls = NO;
        
        if ([[camera.cameraOverlayView subviews] count] == 0)
        {
            FSOverlayView *oView =[[[NSBundle mainBundle] loadNibNamed:@"FSOverlayView" owner:self options:nil] lastObject];
            CGRect overlayViewFrame = camera.cameraOverlayView.frame;
            CGRect newFrame = CGRectMake(0.0,
                                         CGRectGetHeight(overlayViewFrame) -
                                         oView.frame.size.height - 10.0,
                                         CGRectGetWidth(overlayViewFrame),
                                        oView.frame.size.height + 10.0);
            
            oView.frame = newFrame;
            [camera.cameraOverlayView addSubview:oView];
            [oView.btnCancel setTarget:self];
            [oView.btnCancel setAction:@selector(doCancelCamera:)];
            [oView.btnGoGalary setTarget: self];
            [oView.btnGoGalary setAction:@selector(doGoGalary:)];
            [oView.btnTakePhoto setTarget:self];
            [oView.btnTakePhoto setAction:@selector(doTakePhotoExtend:)];
        }
    }

}



-(void) doCancelCamera:(UIView *)sender
{
    UIImagePickerController *camera = [self inUserCamera];
    [(id<UIImagePickerControllerDelegate>)self imagePickerControllerDidCancel:camera];
}

-(void) doTakePhotoExtend:(UIView *)sender
{
    UIImagePickerController *camera = [self inUserCamera];
    [camera takePicture];
}
-(void) doGoGalary:(UIView *)sender
{
    UIImagePickerController *camera = [self inUserCamera];
    [camera dismissViewControllerAnimated:TRUE completion:^{
         [(id<UIImagePickerControllerDelegate>)self imagePickerControllerDidCancel:camera];
        UIImagePickerController *galary = [[UIImagePickerController alloc] init];
        galary.delegate = self;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            galary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            galary.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            galary.allowsEditing = false;
            [self presentViewController:galary animated:YES completion:nil];
            
        }

    }];
   
}

@end
