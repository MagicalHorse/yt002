//
//  FSProdListViewController.h
//  FashionShop
//
//  Created by gong yi on 12/10/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpringboardLayout.h"
#import "EGORefreshTableHeaderView.h"
#import "FSProDetailViewController.h"
#import "FSRefreshableViewController.h"

@class FSSearchBar;
@protocol MySegmentValueChangedDelegate <NSObject>
@optional
-(void)segmentValueChanged:(UISegmentedControl*)seg;
@end

@interface FSSearchBar : UISearchBar {
    UIButton *cancel;
}
@property (nonatomic,assign) id<MySegmentValueChangedDelegate> segmentDelegate;

-(void)setCancelButtonEnable:(BOOL)_enable;

@end

@interface FSProdListViewController : FSRefreshableViewController<PSUICollectionViewDataSource,PSUICollectionViewDelegateFlowLayout,SpringboardLayoutDelegate,FSProDetailItemSourceProvider,UISearchBarDelegate, UISearchDisplayDelegate,UITableViewDataSource, UITableViewDelegate,MySegmentValueChangedDelegate>

@property (strong, nonatomic) IBOutlet PSUICollectionView *cvTags;
@property (strong, nonatomic) IBOutlet UIView *tagContainer;
@property (strong, nonatomic) IBOutlet UIView *contentContainer;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;

@property (strong, nonatomic) IBOutlet PSUICollectionView *cvContent;

@end
