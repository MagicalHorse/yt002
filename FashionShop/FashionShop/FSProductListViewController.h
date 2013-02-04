//
//  FSBrandItemsViewController.h
//  FashionShop
//
//  Created by gong yi on 12/31/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSBrand.h"
#import "SpringboardLayout.h"
#import "FSProDetailViewController.h"
#import "FSRefreshableViewController.h"

typedef enum {
    FSPageTypeAll = 0,
    FSPageTypeBrand = 1,
    FSPageTypeTopic = 2,
}FSPageType;

@interface FSProductListViewController : FSRefreshableViewController<PSUICollectionViewDataSource,PSUICollectionViewDelegateFlowLayout,SpringboardLayoutDelegate,FSProDetailItemSourceProvider>
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) FSBrand *brand;
@property (nonatomic) FSPageType pageType;
@end
