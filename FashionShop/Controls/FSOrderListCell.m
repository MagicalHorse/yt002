//
//  FSOrderListCell.m
//  FashionShop
//
//  Created by HeQingshan on 13-6-22.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSOrderListCell.h"
#import "UIImageView+WebCache.h"
#import "NSString+Extention.h"

@implementation FSOrderListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setData:(FSOrderInfo *)data
{
    _data = data;
    
    FSResource *defaultRes = _data.resource;
    [_imgPro setImageWithURL:defaultRes.absoluteUrl120];
    _imgPro.contentMode = UIViewContentModeScaleAspectFit;
    
    _priceLb.text = [NSString stringWithFormat:@"￥%.2f", _data.totalamount];
    _priceLb.backgroundColor = [UIColor clearColor];
    
    _orderNumber.text = [NSString stringWithFormat:@"预订单编号:%@", _data.orderno];
    _orderNumber.textColor = [UIColor colorWithHexString:@"#181818"];
    _orderNumber.font = [UIFont systemFontOfSize:15];
    _orderNumber.adjustsFontSizeToFitWidth = YES;
    _orderNumber.minimumFontSize = 12;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    _crateDate.text = [NSString stringWithFormat:@"创建时间:%@", [df stringFromDate:_data.createdate]];
    _crateDate.textColor = [UIColor colorWithHexString:@"#181818"];
    _crateDate.font = [UIFont systemFontOfSize:15];
    _crateDate.adjustsFontSizeToFitWidth = YES;
    _crateDate.minimumFontSize = 12;
}

@end

@implementation FSOrderInfoAddressCell

-(void) setData:(FSOrderInfo *)data
{
    _data = data;
    int yCap = 10;
    _cellHeight = yCap;
    
    [self initComponent:@"收货人" value:_data.shippingcontactperson component:_name];
    [self initComponent:@"收货地址" value:_data.shippingaddress component:_address];
    [self initComponent:@"联系电话" value:_data.shippingcontactphone component:_telephone];
}

-(void)initComponent:(NSString*)title value:(NSString*)aValue component:(RTLabel*)label
{
    if (!aValue) {
        label.hidden = YES;
        return;
    }
    label.hidden = NO;
    int yCap = 10;
    NSString *str = [NSString stringWithFormat:@"<font face='%@' size=14 color='#181818'>%@ : </font><font face='%@' size=14 color='#181818'>%@</font>", Font_Name_Bold, title, Font_Name_Normal, aValue];
    [label setText:str];
    CGRect _rect = label.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = label.optimumSize.height;
    label.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
}

@end

@implementation FSOrderInfoMessageCell

-(void)setData:(FSOrderInfo *)data
{
    _data = data;
    int yCap = 10;
    _cellHeight = yCap;
    
    [self initComponent:@"预订单编号" value:_data.orderno component:_orderno];
    [self initComponent:@"预订单状态" value:_data.status component:_orderstatus];
    if (![NSString isNilOrEmpty:_data.shippingvianame]) {
        [self initComponent:@"支付方式" value:_data.shippingvianame component:_sendway];
    }
    else{
        _sendway.hidden = YES;
    }
    [self initComponent:@"支付方式" value:_data.paymentname component:_payway];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
    [self initComponent:@"创建时间" value:[df stringFromDate:_data.createdate] component:_createtime];
    [self initComponent:@"开发票" value:_data.needinvoice?@"是":@"否" component:_needinvoice];
    if (_data.needinvoice) {
        [self initComponent:@"发票抬头" value:_data.invoicesubject component:_invoicetitle];
        [self initComponent:@"发票内容" value:_data.invoicedetail component:_invoicedetail];
    }
    else{
        _invoicedetail.hidden = YES;
        _invoicetitle.hidden = YES;
    }
    if (![NSString isNilOrEmpty:_data.memo]) {
        [self initComponent:@"预订单备注" value:_data.memo component:_ordermemo];
    }
    else{
        _ordermemo.hidden = YES;
    }
}

-(void)initComponent:(NSString*)title value:(NSString*)aValue component:(RTLabel*)label
{
    if (!aValue) {
        label.hidden = YES;
        return;
    }
    label.hidden = NO;
    int yCap = 10;
    NSString *str = [NSString stringWithFormat:@"<font face='%@' size=14 color='#181818'>%@ : </font><font face='%@' size=14 color='#181818'>%@</font>", Font_Name_Bold, title, Font_Name_Normal, aValue];
    [label setText:str];
    CGRect _rect = label.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = label.optimumSize.height;
    label.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
}

@end

@implementation FSOrderInfoAmount

-(void)setData:(FSOrderInfo*)data
{
    _data = data;
    _cellHeight = 140;
    
    _totalAmount.text = [NSString stringWithFormat:@"￥%.2f", data.totalamount];
    _totalFee.text = [NSString stringWithFormat:@"￥%.2f", data.shippingfee];
    _totalPoints.text = [NSString stringWithFormat:@"%d", data.totalpoints];
    _totalQuantity.text = [NSString stringWithFormat:@"%d件", data.totalquantity];
    _extendPrice.text = [NSString stringWithFormat:@"￥%.2f", data.extendprice];
    
    self.clipsToBounds = YES;
}

@end

@implementation FSOrderInfoProductCell

-(void)setData:(FSOrderInfo *)data
{
    if (!data) {
        return;
    }
    _data = data;
    int yGap = 9;
    
    FSOrderProduct *product = data.product;
    //productImage
    [_productImage setImageWithURL:[product.resource absoluteUrl120] placeholderImage:[UIImage imageNamed:@"default_icon120.png"]];
    _productImage.layer.borderWidth = 1;
    _productImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
    float pWidth = _productImage.frame.size.width;
    float pHeight = product.resource.height * pWidth / product.resource.width;
    if (pHeight > 120) {
        pHeight = 120;
    }
    CGRect rect = _productImage.frame;
    rect.size.height = pHeight;
    _productImage.frame = rect;
    
    _cellHeight = ((pHeight+20) - 3*22)/2;
    
    rect = _productName.frame;
    UIFont *font = [UIFont systemFontOfSize:13];
    //productName
    int height = [product.productname sizeWithFont:font constrainedToSize:CGSizeMake(rect.size.width, 1000) lineBreakMode:NSLineBreakByCharWrapping].height;
    _productName.text = product.productname;
    _productName.font = [UIFont boldSystemFontOfSize:13];
    _productName.numberOfLines = 0;
    _productName.lineBreakMode = NSLineBreakByCharWrapping;
    _productName.textColor = [UIColor colorWithHexString:@"181818"];
    
    rect.origin.y = _cellHeight;
    rect.size.height = height;
    _productName.frame = rect;
    _cellHeight += rect.size.height + yGap;
    
    //productDesc
    if (product.properties) {
        rect = _productProperties.frame;
        _productProperties.font = font;
        _productProperties.text = product.properties;
        _productProperties.numberOfLines = 0;
        _productProperties.lineBreakMode = NSLineBreakByTruncatingTail;
        _productProperties.textColor = [UIColor colorWithHexString:@"666666"];
        height = [product.properties sizeWithFont:font constrainedToSize:CGSizeMake(rect.size.width, 1000) lineBreakMode:NSLineBreakByCharWrapping].height;
        rect.origin.y = _cellHeight;
        rect.size.height = height;
        _productProperties.frame = rect;
        _cellHeight += height + yGap;
    }
    
    //prodPrice
    rect = _prodPriceAndCount.frame;
    _prodPriceAndCount.font = font;
    _prodPriceAndCount.text = [NSString stringWithFormat:@"￥%.2f x %d件", product.price, product.quantity];
    _prodPriceAndCount.textColor = [UIColor colorWithHexString:@"e5004f"];
    height = [_prodPriceAndCount.text sizeWithFont:font constrainedToSize:CGSizeMake(rect.size.width, 1000) lineBreakMode:NSLineBreakByCharWrapping].height;
    rect.origin.y = _cellHeight;
    rect.size.height = height;
    _prodPriceAndCount.frame = rect;
    _cellHeight += height + yGap;
    
    if (_cellHeight < pHeight + 20) {
        _cellHeight = pHeight + 20;
    }
}

@end

@implementation FSOrderRMAListCell
@synthesize createTime,rmano,rmaReason,bankName,bankCard;
@synthesize bankAccount,rmaType,chargegiftFee,chargePostFee,rebatePostFee;
@synthesize rmaAmount,accessoryType,status,actualAmount,rejectReason;

-(void)setData:(FSOrderRMAItem *)data
{
    _data = data;
    int yCap = 10;
    _cellHeight = yCap;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
    [self initComponent:@"退单时间" value:[df stringFromDate:data.createdate] component:createTime];
    [self initComponent:@"退单编号" value:data.rmano component:rmano];
    [self initComponent:@"退单原因" value:data.reason component:rmaReason];
    [self initComponent:@"开户行" value:data.bankname component:bankName];
    [self initComponent:@"银行卡号" value:data.bankcard component:bankCard];
    [self initComponent:@"收款人" value:data.bankaccount component:bankAccount];
    [self initComponent:@"退单方式" value:data.rmatype component:rmaType];
    [self initComponent:@"收邮费" value:data.chargepostfee component:chargePostFee];
    [self initComponent:@"退邮费" value:data.rebatepostfee component:rebatePostFee];
    [self initComponent:@"赠品扣款" value:data.chargegiftfee component:chargegiftFee];
    [self initComponent:@"实际退还金额" value:data.actualamount component:actualAmount];
    [self initComponent:@"厂家退回原因" value:data.rejectreason component:rejectReason];
    [self initComponent:@"退单状态" value:data.status component:status];
}

-(void)initComponent:(NSString*)title value:(id)aValue component:(RTLabel*)label
{
    if (!aValue) {
        label.hidden = YES;
        return;
    }
    label.hidden = NO;
    int yCap = 10;
    NSString *str = [NSString stringWithFormat:@"<font face='%@' size=14 color='#181818'>%@ : </font><font face='%@' size=14 color='#181818'>%@</font>", Font_Name_Bold, title, Font_Name_Normal, aValue];
    [label setText:str];
    CGRect _rect = label.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = label.optimumSize.height;
    label.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
}

@end