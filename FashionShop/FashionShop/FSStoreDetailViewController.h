//
//  FSStoreDetailViewController.h
//  FashionShop
//
//  Created by gong yi on 1/4/13.
//  Copyright (c) 2013 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSStore.h"

@interface FSStoreDetailViewController : UIViewController<UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *mapView;

@property (strong, nonatomic) IBOutlet UIView *detailContainer;
@property (strong, nonatomic) FSStore *store;
@end
