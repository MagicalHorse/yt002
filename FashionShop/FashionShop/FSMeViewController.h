//
//  FSMeViewController.h
//  FashionShop
//
//  Created by gong yi on 11/8/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaWeibo.h"
#import "RestKit.h"
#import "FSSettingViewController.h"
#import "FSProDetailViewController.h"
#import "FSFavorProCell.h"
#import "SpringboardLayout.h"

typedef void (^FSLoginCompleteDelegate) (BOOL isSuccess);

@interface FSMeViewController : UIViewController<SinaWeiboDelegate, SinaWeiboRequestDelegate,PSUICollectionViewDataSource,FSSettingCompleteDelegate,SpringboardLayoutDelegate, UIGestureRecognizerDelegate,FSProDetailItemSourceProvider,UIActionSheetDelegate,UIImagePickerControllerDelegate,FSThumViewDelegate>


@property (strong, nonatomic) IBOutlet FSThumView *thumbImg;

@property (strong, nonatomic) IBOutlet UIImageView *imgLevel;

@property (strong, nonatomic) IBOutlet UILabel *lblNickie;

@property (strong, nonatomic) IBOutlet UIButton *btnLike;
@property (strong, nonatomic) IBOutlet UIButton *btnFans;

@property (strong, nonatomic) IBOutlet UIButton *btnPoints;
@property (strong, nonatomic) IBOutlet UIButton *btnCoupons;
@property (strong, nonatomic) IBOutlet UIView *vLikeHeader;
@property (strong, nonatomic) IBOutlet UILabel *lblLikeHeader;
@property (strong, nonatomic) IBOutlet UIView *likeContainer;

@property (strong,nonatomic) FSLoginCompleteDelegate completeCallBack;
- (IBAction)doLogin:(id)sender;
- (IBAction)doSuggest:(id)sender;
- (IBAction)doLoginQQ:(id)sender;
- (IBAction)doLogOut:(id)sender;

- (IBAction)doShowLikes:(id)sender;
- (IBAction)doShowFans:(id)sender;
- (IBAction)doShowPoints:(id)sender;
- (IBAction)doShowCoupons:(id)sender;


@property (strong, nonatomic) IBOutlet UIButton *btnSuggest;


@property (strong, nonatomic) IBOutlet PSUICollectionView *likeView;


-(void) displayUserLogin;


@end
