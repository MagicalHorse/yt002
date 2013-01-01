//
//  FSShareView.m
//  FashionShop
//
//  Created by gong yi on 11/21/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSShareView.h"
#import "FSTCWBActivity.h"
#import "FSWeiboActivity.h"
#import "FSWeixinActivity.h"


static FSShareView *_instance;

@interface FSShareView(){
    NSMutableArray *shareCells;
    NSMutableArray *shareItems;
    FSShareCompleteHandler shareCompleteaction;
    UIViewController *parentVC;
    FSUIActivity *activity ;
}
@end
@implementation FSShareView

+(FSShareView *)instance
{
    if (!_instance)
    {
        _instance = [FSShareView new];
    }
    return _instance;
}

-(void)shareBegin:(UIViewController *)vc withShareItems:(NSMutableArray *)items completeHander:(FSShareCompleteHandler)action
{
    if ([UIActivityViewController class])
    {
        UIActivityViewController *shareController =  [FSShareView shareViewController:items];
        shareController.completionHandler= action;
        [vc presentViewController:shareController animated:YES completion:nil];
        
    }
    else
    {
        parentVC = vc;
        shareItems = items;
        shareCompleteaction = action;
        [self configActionsIcon];
        AWActionSheet *sheet = [[AWActionSheet alloc] initWithIconSheetDelegate:self ItemCount:shareCells.count];
        [sheet showInView:vc.view];
    }
}

+(UIActivityViewController *)shareViewController:(NSMutableArray *)shareItems
{
    
    NSArray *excludeActivities = @[UIActivityTypePostToFacebook,UIActivityTypePostToTwitter,UIActivityTypePostToWeibo,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeMail,UIActivityTypeSaveToCameraRoll,UIActivityTypeAssignToContact];
    FSWeiboActivity *weibo = [[FSWeiboActivity alloc] init];

    FSWeixinActivity *weixin = [FSWeixinActivity sharedInstance];
    FSTCWBActivity *qqweibo = [[FSTCWBActivity alloc] init];
    NSArray *activities = @[weibo,weixin,qqweibo];
    
    UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:activities];

    shareController.excludedActivityTypes = excludeActivities;

    return shareController;
    
}

-(void) configActionsIcon
{
    if (!shareCells)
    {
        shareCells = [@[] mutableCopy];
        [self createActionCell:SHARE_WB_ICON withTitle:SHARE_WB_TITLE];
        [self createActionCell:SHARE_WX_ICON    withTitle:SHARE_WX_TITLE];
        [self createActionCell:SHARE_TC_ICON    withTitle:SHARE_TC_TITLE];
    }
}
-(void)createActionCell:(NSString *)icon withTitle:(NSString *)title
{
    AWActionSheetCell *wx = [[AWActionSheetCell alloc] init];
    wx.iconView.image = [UIImage imageNamed:icon];
    //[[wx titleLabel] setText:title];
    wx.index = shareCells.count;
    [shareCells addObject:wx];
}

#pragma ActionSheet delegate

-(int)numberOfItemsInActionSheet
{
    return shareCells.count;
}
-(AWActionSheetCell *)cellForActionAtIndex:(NSInteger)index
{
    return [shareCells objectAtIndex:index];
}

-(void)DidTapOnItemAtIndex:(NSInteger)index
{

    switch (index) {
        case 0:
        {
            activity = [[FSWeiboActivity alloc] init];
            break;
        }
        case 2:
        {
            activity = [[FSTCWBActivity alloc] init];
            break;
        }
        case 1:
        {
            activity = [FSWeixinActivity sharedInstance];
            break;
        }
        default:
            break;
    }
    if (!activity)
        return;
    activity.completeHandler = shareCompleteaction;
    [activity prepareWithActivityItems:shareItems];
    UIViewController *aVC = activity.activityViewController;
    if (!aVC)
    {
       [ activity performActivity];
    }
    else
    {
        [parentVC presentViewController:aVC animated:TRUE completion:nil];
       
    }
}


@end


@implementation FSUIActivity_

- (void)activityDidFinish:(BOOL)completed
{
    if (_completeHandler)
        _completeHandler(nil,completed);
}

__attribute__((constructor)) static void FSCreateUIActivityClasses(void) {
    @autoreleasepool {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

        if ([UIActivity class]) class_setSuperclass([FSUIActivity_ class], [UIActivity class]);
        else objc_registerClassPair(objc_allocateClassPair([FSUIActivity class], "UIActitity", 0));
        
	
      
    }
}

@end




