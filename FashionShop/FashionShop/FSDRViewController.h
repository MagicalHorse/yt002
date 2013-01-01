//
//  FSDRViewController.h
//  FashionShop
//
//  Created by gong yi on 12/21/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpringboardLayout.h"
#import "FSRefreshableViewController.h"
#import "FSProDetailViewController.h"
#import "FSThumView.h"

@interface FSDRViewController : FSRefreshableViewController<PSUICollectionViewDataSource,PSUICollectionViewDelegateFlowLayout,SpringboardLayoutDelegate,FSProDetailItemSourceProvider>


@property (strong, nonatomic) IBOutlet FSThumView *thumLogo;
- (IBAction)goLikeView:(id)sender;
- (IBAction)goFanView:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *lblNickie;

@property (strong, nonatomic) IBOutlet UIButton *btnLike;

@property (strong, nonatomic) IBOutlet UIButton *btnFans;
@property (strong, nonatomic) IBOutlet PSUICollectionView *itemsView;
@property (strong, nonatomic) IBOutlet UIView *itemsContainer;
@property (strong, nonatomic) IBOutlet UILabel *lblItemTitle;

@property (nonatomic) int userId;
@end
