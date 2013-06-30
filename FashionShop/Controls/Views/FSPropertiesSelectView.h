//
//  FSPropertiesSelectView.h
//  FashionShop
//
//  Created by HeQingshan on 13-6-30.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPurchase.h"
#import "FSMyPickerView.h"

@interface FSPropertiesSelectView : UIView<FSMyPickerViewDatasource,FSMyPickerViewDelegate>

@property (nonatomic,strong) FSPurchasePropertiesItem *data;
@property (nonatomic, strong) FSPurchaseForUpload *uploadData;

-(void)setData:(FSPurchasePropertiesItem *)aData upLoadData:(FSPurchaseForUpload *)aUpData;

@end
