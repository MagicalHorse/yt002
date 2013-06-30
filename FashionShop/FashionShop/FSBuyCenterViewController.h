//
//  FSBuyCenterViewController.h
//  FashionShop
//
//  Created by HeQingshan on 13-6-27.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSImageSlideViewController.h"
#import "FSAddressManagerViewController.h"
#import "FSMyPickerView.h"

@protocol FSAddressManagerViewControllerDelegate;

@interface FSBuyCenterViewController : UIViewController<UIAlertViewDelegate,FSImageSlideDataSource,UITextFieldDelegate,FSMyPickerViewDatasource,FSMyPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tbAction;
@property (nonatomic) int productID;

@end
