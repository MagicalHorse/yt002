//
//  FSOrderListCell.h
//  FashionShop
//
//  Created by HeQingshan on 13-6-22.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSOrder.h"
#import "RTLabel.h"

@interface FSOrderListCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgPro;
@property (strong, nonatomic) IBOutlet UILabel *priceLb;
@property (strong, nonatomic) IBOutlet UILabel *orderNumber;
@property (strong, nonatomic) IBOutlet UILabel *crateDate;

@property (strong,nonatomic) FSOrderInfo *data;

@end

@interface FSOrderInfoAddressCell : UITableViewCell

@property (strong, nonatomic) IBOutlet RTLabel *name;
@property (strong, nonatomic) IBOutlet RTLabel *address;
@property (strong, nonatomic) IBOutlet RTLabel *telephone;

@property (strong,nonatomic) FSOrderInfo *data;
@property (nonatomic) int cellHeight;

@end

@interface FSOrderInfoMessageCell : UITableViewCell

@property (strong, nonatomic) IBOutlet RTLabel *orderno;
@property (strong, nonatomic) IBOutlet RTLabel *orderstatus;
@property (strong, nonatomic) IBOutlet RTLabel *sendway;
@property (strong, nonatomic) IBOutlet RTLabel *payway;
@property (strong, nonatomic) IBOutlet RTLabel *createtime;
@property (strong, nonatomic) IBOutlet RTLabel *needinvoice;
@property (strong, nonatomic) IBOutlet RTLabel *invoicetitle;
@property (strong, nonatomic) IBOutlet RTLabel *invoicedetail;
@property (strong, nonatomic) IBOutlet RTLabel *ordermemo;

@property (strong,nonatomic) FSOrderInfo *data;
@property (nonatomic) int cellHeight;

@end

@interface FSOrderInfoAmount : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *bgImage;
@property (strong, nonatomic) IBOutlet UILabel *quantityLb;
@property (strong, nonatomic) IBOutlet UILabel *pointLb;
@property (strong, nonatomic) IBOutlet UILabel *priceLb;
@property (strong, nonatomic) IBOutlet UILabel *feeLb;
@property (strong, nonatomic) IBOutlet UILabel *amountLb;

@property (strong, nonatomic) IBOutlet UILabel *totalQuantity;
@property (strong, nonatomic) IBOutlet UILabel *totalPoints;
@property (strong, nonatomic) IBOutlet UILabel *extendPrice;
@property (strong, nonatomic) IBOutlet UILabel *totalFee;
@property (strong, nonatomic) IBOutlet UILabel *totalAmount;

@property (strong,nonatomic) FSOrderInfo *data;
@property (nonatomic) int cellHeight;

@end

@interface FSOrderInfoProductCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (strong, nonatomic) IBOutlet UILabel *productProperties;
@property (strong, nonatomic) IBOutlet UILabel *prodPriceAndCount;

@property (strong,nonatomic) FSOrderInfo *data;
@property (nonatomic) int cellHeight;

@end

@interface FSOrderRMAListCell : UITableViewCell

@property (strong, nonatomic) IBOutlet RTLabel *createTime;
@property (strong, nonatomic) IBOutlet RTLabel *rmano;
@property (strong, nonatomic) IBOutlet RTLabel *rmaReason;
@property (strong, nonatomic) IBOutlet RTLabel *bankName;
@property (strong, nonatomic) IBOutlet RTLabel *bankCard;
@property (strong, nonatomic) IBOutlet RTLabel *bankAccount;
@property (strong, nonatomic) IBOutlet RTLabel *rmaType;
@property (strong, nonatomic) IBOutlet RTLabel *chargePostFee;
@property (strong, nonatomic) IBOutlet RTLabel *chargegiftFee;
@property (strong, nonatomic) IBOutlet RTLabel *rebatePostFee;
@property (strong, nonatomic) IBOutlet RTLabel *rmaAmount;
@property (strong, nonatomic) IBOutlet RTLabel *actualAmount;
@property (strong, nonatomic) IBOutlet RTLabel *rejectReason;
@property (strong, nonatomic) IBOutlet RTLabel *status;


@property (nonatomic,strong) FSOrderRMAItem* data;
@property (nonatomic) int cellHeight;

@end
