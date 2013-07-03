//
//  FSPurchaseProdCell.m
//  FashionShop
//
//  Created by HeQingshan on 13-6-28.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSPurchaseProdCell.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+Extention.h"
#import "FSPropertiesSelectView.h"

@implementation FSPurchaseProdCell
@synthesize data,uploadData;

-(void)setData:(FSPurchase *)aData upLoadData:(FSPurchaseForUpload *)aUpData
{
    if (!aData) {
        return;
    }
    data = aData;
    uploadData = aUpData;
    int yGap = 8;
    _cellHeight = 10;
    
    BOOL flag =  NO;
    if (data.originprice && data.originprice > 0.000001) {
        flag = YES;
    }
    
    //productImage
    [_productImage setImageWithURL:[data.productImage absoluteUrl120] placeholderImage:[UIImage imageNamed:@"default_icon120.png"]];
    _productImage.layer.borderWidth = 1;
    _productImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
    float pWidth = _productImage.frame.size.width;
    float pHeight = data.productImage.height * pWidth / data.productImage.width;
    CGRect rect = _productImage.frame;
    rect.size.height = pHeight;
    _productImage.frame = rect;
    
    rect = _productName.frame;
    UIFont *font = [UIFont systemFontOfSize:14];
    //productName
    _productName.text = data.name;
    _productName.numberOfLines = 0;
    _productName.lineBreakMode = NSLineBreakByCharWrapping;
    _productName.textColor = [UIColor colorWithHexString:@"181818"];
    int height = [data.name sizeWithFont:font constrainedToSize:CGSizeMake(rect.size.width, 1000) lineBreakMode:NSLineBreakByCharWrapping].height;
    rect.origin.y = _cellHeight;
    rect.size.height = height;
    _productName.frame = rect;
    _cellHeight += rect.size.height + yGap;
    
    //productDesc
    rect = _productDesc.frame;
    _productDesc.text = data.description;
    _productDesc.numberOfLines = 0;
    _productDesc.lineBreakMode = NSLineBreakByTruncatingTail;
    _productDesc.textColor = [UIColor colorWithHexString:@"181818"];
    height = [data.description sizeWithFont:font constrainedToSize:CGSizeMake(rect.size.width, 1000) lineBreakMode:NSLineBreakByCharWrapping].height;
    if (height > 40) {
        height = 40;
    }
    rect.origin.y = _cellHeight;
    rect.size.height = height;
    _productDesc.frame = rect;
    _cellHeight += height + yGap;
    
    //prodPrice
    rect = _prodPrice.frame;
    _prodPrice.text = [NSString stringWithFormat:@"标牌价：￥%.2f元", data.price];
    _prodPrice.textColor = [UIColor colorWithHexString:@"e5004f"];
    height = [_prodPrice.text sizeWithFont:font constrainedToSize:CGSizeMake(rect.size.width, 1000) lineBreakMode:NSLineBreakByCharWrapping].height;
    rect.origin.y = _cellHeight;
    rect.size.height = height;
    _prodPrice.frame = rect;
    _cellHeight += height + yGap;
    
    //prodOriginalPrice
    if (flag) {
        rect = _prodOriginalPrice.frame;
        _prodOriginalPrice.text = [NSString stringWithFormat:@"原价：￥%.2f元", data.originprice];
        _prodOriginalPrice.textColor = [UIColor colorWithHexString:@"181818"];
        height = [_prodOriginalPrice.text sizeWithFont:font constrainedToSize:CGSizeMake(rect.size.width, 1000) lineBreakMode:NSLineBreakByCharWrapping].height;
        rect.origin.y = _cellHeight;
        rect.size.height = height;
        _prodOriginalPrice.frame = rect;
        _cellHeight += height + yGap;
    }
    else{
        _prodOriginalPrice.hidden = YES;
    }
    _cellHeight += 10;
    
    if (_cellHeight < pHeight + 20) {
        _cellHeight = pHeight + 20;
    }
    
    [self initProperties];
    
    //lines
    rect = _lines.frame;
    if (rect.origin.y < 0) {
        rect.origin.y = _cellHeight - 2;
    }
    _lines.frame = rect;
}

-(void)initProperties
{
    //添加属性
    int xOffset = 10;
    if (data.properties.count > 0) {
        for (int i = 0; i < data.properties.count; i++) {
            FSPurchasePropertiesItem *item = [data.properties objectAtIndex:i];
            id last = [self viewWithTag:item.propertyid + 9999999];
            UIView *view = [self propertiesView:item];
            if (xOffset + view.frame.size.width > 310) {
                _cellHeight += 45;
                xOffset = 10;
                CGRect _rect = view.frame;
                _rect.origin.y = _cellHeight;
                _rect.origin.x = xOffset;
                view.frame = _rect;
                if (!last) {
                    [self addSubview:view];
                }
            }
            else{
                CGRect _rect = view.frame;
                _rect.origin.y = _cellHeight;
                _rect.origin.x = xOffset;
                view.frame = _rect;
                if (!last) {
                    [self addSubview:view];
                }
                xOffset += view.frame.size.width + 25;
            }
            if (i == data.properties.count - 1) {
                _cellHeight += 45;
            }
        }
    }
    
    //添加数量选择
    FSPurchasePropertiesItem *item = [[FSPurchasePropertiesItem alloc] init];
    item.propertyid = Purchase_Count_Properties_Tag;
    id last = [self viewWithTag:item.propertyid + 9999999];
    if (!last) {
        item.propertyname = @"数量";
        item.values = [NSMutableArray arrayWithCapacity:5];
        for (int i = 1; i < 6; i ++) {
            FSPurchasePropertiesItem *_item = [[FSPurchasePropertiesItem alloc] init];
            _item.valueid = i;
            _item.valuename = [NSString stringWithFormat:@"%d", i];
            [item.values addObject:_item];
        }
        UIView *view = [self propertiesView:item];
        CGRect _rect = view.frame;
        _rect.origin.y = _cellHeight;
        _rect.origin.x = 10;
        view.frame = _rect;
        [self addSubview:view];
    }
    
    _cellHeight += 45;
}

-(FSPropertiesSelectView *)propertiesView:(FSPurchasePropertiesItem*)item
{
    FSPropertiesSelectView *view = [[FSPropertiesSelectView alloc] init];
    [view setData:item upLoadData:uploadData];
    return view;
}

@end

@implementation FSPurchaseCommonCell

-(void)setControlWithData:(FSPurchaseForUpload*)data index:(int)aIndex
{
    if (!data) {
        return;
    }
    _cellHeight = 40;
    switch (aIndex) {
        case 0://送货方式
        {
            _title.text = @"送货地址 : ";
            if (!data.address) {
                _contentLb.text = @"请选择送货地址";
                _contentLb.textColor = [UIColor lightGrayColor];
                CGRect rect = _contentLb.frame;
                rect.size.height = 40;
                _contentLb.frame = rect;
            }
            else{
                _contentLb.text = [NSString stringWithFormat:@"%@\n%@", data.address.shippingperson,data.address.displayaddress];
                int height = [_contentLb.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(_contentLb.frame.size.width, 1000) lineBreakMode:NSLineBreakByCharWrapping].height;
                CGRect rect = _contentLb.frame;
                rect.origin.y = 10;
                rect.size.height = height;
                _contentLb.frame = rect;
                _cellHeight = height + 20;
                _contentLb.textColor = [UIColor colorWithHexString:@"181818"];
            }
            _contentLb.numberOfLines = 0;
            _contentLb.lineBreakMode = NSLineBreakByCharWrapping;
            _contentField.hidden = YES;
            _contentLb.hidden = NO;
        }
            break;
        case 1://支付方式
        {
            _title.text = @"支付方式 : ";
            if (!data.payment) {
                _contentLb.text = @"请选择支付方式";
                _contentLb.textColor = [UIColor lightGrayColor];
                CGRect rect = _contentLb.frame;
                rect.size.height = 40;
                _contentLb.frame = rect;
            }
            else{
                _contentLb.text = data.payment.name;
                _contentLb.textColor = [UIColor colorWithHexString:@"181818"];
            }
            CGRect rect = _contentLb.frame;
            rect.size.height = 40;
            _contentLb.frame = rect;
            
            _contentField.hidden = YES;
            _contentLb.hidden = NO;
        }
            break;
        case 2://发票
        {
            _title.text = @"发票抬头 : ";
            if (![NSString isNilOrEmpty:data.memo]) {
                _contentField.text = data.memo;
            }
            _contentField.placeholder = @"点击填写发票抬头";
            _contentField.hidden = NO;
            _contentLb.hidden = YES;
            /*
            _title.text = @"发票 : ";
            if ([NSString isNilOrEmpty:data.invoicetitle]) {
                _contentLb.text = @"点击填写发票信息";
                _contentLb.textColor = [UIColor lightGrayColor];
            }
            else{
                _contentLb.text = [NSString stringWithFormat:@"抬头:%@  明细:%@",data.invoicetitle, data.invoicedetail];
                _contentLb.textColor = [UIColor colorWithHexString:@"181818"];
                int height = [_contentLb.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(_contentLb.frame.size.width, 1000) lineBreakMode:NSLineBreakByCharWrapping].height;
                CGRect rect = _contentLb.frame;
                rect.origin.y = 10;
                rect.size.height = height;
                _contentLb.frame = rect;
                _cellHeight = height + 20;
            }
            _contentLb.numberOfLines = 0;
            _contentLb.lineBreakMode = NSLineBreakByCharWrapping;
            _contentField.hidden = YES;
            _contentLb.hidden = NO;
             */
        }
            break;
        case 3://预订单备注
        {
            _title.text = @"预订单备注 : ";
            if (![NSString isNilOrEmpty:data.memo]) {
                _contentField.text = data.memo;
            }
            _contentField.placeholder = @"点击填写订单备注信息";
            _contentField.hidden = NO;
            _contentLb.hidden = YES;
        }
            break;
        case 4://手机号码
        {
            _title.text = @"手机号码 : ";
            if (![NSString isNilOrEmpty:data.telephone]) {
                _contentField.text = data.telephone;
            }
            _contentField.placeholder = @"点击填写手机号码";
            _contentField.hidden = NO;
            _contentLb.hidden = YES;
        }
            break;
        default:
            break;
    }
    
    //lines
    CGRect rect = _lines.frame;
    rect.origin.y = _cellHeight - 2;
    _lines.frame = rect;
    
    rect = _title.frame;
    rect.origin.y = _contentLb.frame.origin.y;
    rect.size.height = _contentLb.frame.size.height;
    _title.frame = rect;
}

@end

@implementation FSPurchaseAmountCell

-(void)setData:(FSPurchase*)data
{
    _data = data;
    _cellHeight = 140;
    
    _totalAmount.text = [NSString stringWithFormat:@"￥%.2f", data.totalamount];
    _totalFee.text = [NSString stringWithFormat:@"￥%.2f", data.totalfee];
    _totalPoints.text = [NSString stringWithFormat:@"%d", data.totalpoints];
    _totalQuantity.text = [NSString stringWithFormat:@"%d件", data.totalquantity];
    _extendPrice.text = [NSString stringWithFormat:@"￥%.2f", data.extendprice];
}

@end

@implementation FSTitleContentCell

-(void)setDataWithTitle:(NSString *)aTtitle content:(NSString*)aContent
{
    int yCap = 12;
    _cellHeight = yCap;
    
    //title
    NSString *str = [NSString stringWithFormat:@"<font face='%@' size=14 color='#666666'>%@</font>", Font_Name_Normal, aTtitle];
    [_title setText:str];
    CGRect _rect = _title.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = _title.optimumSize.height;
    _title.frame = _rect;
    _cellHeight += _rect.size.height + yCap - 6;
    
    str = [NSString stringWithFormat:@"<font face='%@' size=14 color='#666666'>%@</font>", Font_Name_Normal, aContent];
    [_content setText:str];
    _rect = _content.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = _content.optimumSize.height;
    _content.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
}

@end

@implementation FSOrderSuccessCell

-(void)setData:(FSOrderInfo *)data
{
    _orderNumber.text = data.orderno;
    _orderNumber.hidden = NO;
    _orderAmount.text = [NSString stringWithFormat:@"￥%.2f", data.totalamount];
    _orderAmount.hidden = NO;
}

@end
