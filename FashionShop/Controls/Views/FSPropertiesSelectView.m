//
//  FSPropertiesSelectView.m
//  FashionShop
//
//  Created by HeQingshan on 13-6-30.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSPropertiesSelectView.h"

@interface FSPropertiesSelectView()
{
    FSMyPickerView *myPickerView;
    UIButton *slectedButton;
}

@end

@implementation FSPropertiesSelectView
@synthesize data,uploadData;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(void)setData:(FSPurchasePropertiesItem *)aData upLoadData:(FSPurchaseForUpload *)aUpData
{
    if (!aData) {
        return;
    }
    data = aData;
    uploadData = aUpData;
    for (id item in self.subviews) {
        [item removeFromSuperview];
    }
    self.backgroundColor = [UIColor clearColor];
    self.tag = data.propertyid + 9999999;
    
    //add title
    UIFont *font = [UIFont systemFontOfSize:14];
    NSString *_title = [NSString stringWithFormat:@"%@ : ", data.propertyname];
    int _titleW = [_title sizeWithFont:font].width;
    if (_titleW > 225) {
        _titleW = 225;
    }
    UILabel *titleLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _titleW, 30)];
    titleLb.text = _title;
    titleLb.backgroundColor = [UIColor clearColor];
    titleLb.font = font;
    titleLb.textColor = [UIColor colorWithHexString:@"181818"];
    [self addSubview:titleLb];
    
    //add button
    if (!slectedButton) {
        slectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [slectedButton setBackgroundImage:[UIImage imageNamed:@"btn_property_normal.png"] forState:UIControlStateNormal];
    }
    slectedButton.frame = CGRectMake(titleLb.frame.size.width, 0, 72, 30);
    UIEdgeInsets edge = slectedButton.contentEdgeInsets;
    edge.right = 20;
    slectedButton.contentEdgeInsets = edge;
    [slectedButton.titleLabel setFont:font];
    slectedButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    slectedButton.titleLabel.minimumFontSize = 10;
    [slectedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:slectedButton];
    if (!myPickerView) {
        myPickerView = [[FSMyPickerView alloc] init];
        myPickerView.delegate = self;
        myPickerView.datasource = self;
    }
    NSString *title = nil;
    int index = [self getSelectIndex:&title];
    if (index == -1) {
        title = @"请选择";
    }
    else{
        [myPickerView.picker selectRow:index inComponent:0 animated:NO];
    }
    [slectedButton setTitle:title forState:UIControlStateNormal];
    [slectedButton addTarget:self action:@selector(clickSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.frame = CGRectMake(0, 0, titleLb.frame.size.width + slectedButton.frame.size.width, 30);
}

-(int)getSelectIndex:(NSString**)title
{
    for (int i = 0; i < uploadData.properies.count; i ++) {
        FSPurchasePropertiesItem *item = uploadData.properies[i];
        if (item.propertyid == data.propertyid) {
            for (int j = 0; j < data.values.count; j++) {
                FSPurchasePropertiesItem *subItem = data.values[j];
                if (subItem.valueid == item.valueid) {
                    *title = subItem.valuename;
                    return j;
                }
            }
        }
    }
    return -1;
}

-(void)clickSelectButton:(UIButton*)sender
{
    if (myPickerView.pickerIsShow) {
        [myPickerView hidenPickerView:YES];
    }
    else{
        NSString *title = nil;
        int index = [self getSelectIndex:&title];
        if (index == -1) {
            index = 0;
        }
        [myPickerView.picker selectRow:index inComponent:0 animated:NO];
        [myPickerView showPickerView];
        [theApp.window bringSubviewToFront:myPickerView];
    }
}

#pragma mark - FSMyPickerViewDatasource

- (NSInteger)numberOfComponentsInMyPickerView:(FSMyPickerView *)pickerView
{
    return 1;
}

- (NSInteger)myPickerView:(FSMyPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return data.values.count;
}

#pragma mark - FSMyPickerViewDelegate

- (void)didClickOkButton:(FSMyPickerView *)aMyPickerView
{
    int index = [myPickerView.picker selectedRowInComponent:0];
    FSPurchasePropertiesItem *aItem = data.values[index];
    for (int i = 0; i < uploadData.properies.count; i ++) {
        FSPurchasePropertiesItem *item = uploadData.properies[i];
        if (item.propertyid == data.propertyid) {
            item.valueid = aItem.valueid;
            item.valuename = aItem.valuename;
            [slectedButton setTitle:aItem.valuename forState:UIControlStateNormal];
            if (item.propertyid == Purchase_Count_Properties_Tag) {
                //发送请求数据通知
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestAmountData" object:[NSNumber numberWithInt:item.valueid]];
                uploadData.quantity = item.valueid;
            }
            break;
        }
    }
}

- (void)didClickCancelButton:(FSMyPickerView *)aMyPickerView
{
    //do nothing
}

- (NSString *)myPickerView:(FSMyPickerView *)aMyPickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    FSPurchasePropertiesItem *item = data.values[row];
    return item.valuename;
}

- (void)myPickerView:(FSMyPickerView *)aMyPickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //do　ｎｏｔｈｉｎｇ
}

@end
