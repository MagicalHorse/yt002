//
//  FSSuggestViewController.h
//  FashionShop
//
//  Created by gong yi on 11/14/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestKit.h"
@interface FSSuggestViewController : UIViewController<RKObjectLoaderDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnNewest;
- (IBAction)searchNewest:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnHotest;
- (IBAction)searchHotest:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnBrand;
- (IBAction)searchByBrand:(id)sender;
@property (strong, nonatomic) IBOutlet UICollectionView *contentView;

@end
