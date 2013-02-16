//
//  FSBrandItemsViewController.h
//  FashionShop
//
//  Created by gong yi on 12/31/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSBrand.h"
#import "FSTopic.h"
#import "SpringboardLayout.h"
#import "FSProDetailViewController.h"
#import "FSRefreshableViewController.h"

typedef enum {
    FSPageTypeAll = 0,
    FSPageTypeBrand = 1,
    FSPageTypeTopic = 2,
    FSPageTypeCommon = 3,
}FSPageType;

@interface FSProductListViewController : FSRefreshableViewController<PSUICollectionViewDataSource,PSUICollectionViewDelegateFlowLayout,SpringboardLayoutDelegate,FSProDetailItemSourceProvider>
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) FSBrand *brand;
@property (strong, nonatomic) FSTopic *topic;
@property (nonatomic, assign) NSInteger commonID;
@property (nonatomic, strong) NSString *titleName;
@property (nonatomic) FSPageType pageType;
@end
