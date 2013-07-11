//
//  FSOrderDetailViewController.m
//  FashionShop
//
//  Created by HeQingshan on 13-6-30.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSOrderDetailViewController.h"
#import "FSPurchaseRequest.h"
#import "FSOrder.h"
#import "FSOrderListCell.h"
#import "FSOrderRMARequestViewController.h"

@interface FSOrderDetailViewController ()
{
    FSOrderInfo *orderInfo;
}

@end

@implementation FSOrderDetailViewController
@synthesize orderno;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"预订单详情";
    UIBarButtonItem *baritemCancel = [self createPlainBarButtonItem:@"goback_icon.png" target:self action:@selector(onButtonBack:)];
    [self.navigationItem setLeftBarButtonItem:baritemCancel];
    
    _tbAction.backgroundView = nil;
    _tbAction.backgroundColor = APP_TABLE_BG_COLOR;
    
    [self requestData];
}

-(void)requestData
{
    FSPurchaseRequest *request = [[FSPurchaseRequest alloc] init];
    request.routeResourcePath = RK_REQUEST_ORDER_DETAIL;
    request.orderno = orderno;
    request.uToken = [FSModelManager sharedModelManager].loginToken;
    [self beginLoading:self.view];
    _tbAction.hidden = YES;
    [request send:[FSOrderInfo class] withRequest:request completeCallBack:^(FSEntityBase *respData) {
        [self endLoading:self.view];
        _tbAction.hidden = NO;
        if (respData.isSuccess)
        {
            orderInfo = respData.responseData;
            _tbAction.tableFooterView = [self createTableFooterView];
            [_tbAction reloadData];
        }
        else
        {
            [self reportError:respData.errorDescrip];
        }
    }];
}

- (void)viewDidUnload {
    [self setTbAction:nil];
    [super viewDidUnload];
}

- (IBAction)onButtonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(UIView*)createTableFooterView
{
    if (!orderInfo.canvoid && !orderInfo.canrma) {
        return nil;
    }
    int height = 20;
    int xOffset = 49;
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    
    if (orderInfo.canrma) {
        UIButton *btnClean = [UIButton buttonWithType:UIButtonTypeCustom];
        btnClean.frame = CGRectMake(xOffset, height, 222, 40);
        [btnClean setTitle:@"申请退货" forState:UIControlStateNormal];
        [btnClean setBackgroundImage:[UIImage imageNamed:@"btn_bg.png"] forState:UIControlStateNormal];
        [btnClean setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnClean addTarget:self action:@selector(requestRMA:) forControlEvents:UIControlEventTouchUpInside];
        btnClean.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [view addSubview:btnClean];
        height += 50;
    }
    if (orderInfo.canvoid) {
        UIButton *btnClean = [UIButton buttonWithType:UIButtonTypeCustom];
        btnClean.frame = CGRectMake(xOffset, height, 222, 40);
        [btnClean setTitle:@"取消预订单" forState:UIControlStateNormal];
        [btnClean setBackgroundImage:[UIImage imageNamed:@"btn_bg.png"] forState:UIControlStateNormal];
        [btnClean setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnClean addTarget:self action:@selector(cancelOrder:) forControlEvents:UIControlEventTouchUpInside];
        btnClean.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [view addSubview:btnClean];
        height += 50;
    }
    height += 10;
    
    view.frame = CGRectMake(0, 0, 320, height);
    return view;
}

-(void)requestRMA:(UIButton*)sender
{
    FSOrderRMARequestViewController *controller = [[FSOrderRMARequestViewController alloc] initWithNibName:@"FSOrderRMARequestViewController" bundle:nil];
    controller.orderno = orderno;
    [self.navigationController pushViewController:controller animated:YES];
}

#define Request_Cancel_Tag 200

-(void)cancelOrder:(UIButton*)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您确定要取消该预订单吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = Request_Cancel_Tag;
    [alert show];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!orderInfo) {
        return 0;
    }
    if (section == 2) {
        return 2;
    }
    else if(section == 3) {
        return orderInfo.rmas.count;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!orderInfo) {
        return 0;
    }
    if (orderInfo.rmas && orderInfo.rmas.count > 0) {
        return 4;
    }
    return 3;
}

#define OrderInfo_Address_Cell_Indentifier @"FSOrderInfoAddressCell"
#define OrderInfo_Message_Cell_Indentifier @"FSOrderInfoMessageCell"
#define OrderInfo_Amount_Cell_Indentifier @"FSOrderInfoAmount"
#define OrderInfo_Product_Cell_Indentifier @"FSOrderInfoProductCell"
#define Order_RMA_List_Cell_Indentifier @"FSOrderRMAListCell"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        FSOrderInfoAddressCell *cell = (FSOrderInfoAddressCell*)[tableView dequeueReusableCellWithIdentifier:OrderInfo_Address_Cell_Indentifier];
        if (cell == nil) {
            NSArray *_array = [[NSBundle mainBundle] loadNibNamed:@"FSOrderListCell" owner:self options:nil];
            if (_array.count > 1) {
                cell = (FSOrderInfoAddressCell*)_array[1];
            }
            else{
                cell = [[FSOrderInfoAddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:OrderInfo_Address_Cell_Indentifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell setData:orderInfo];
        
        return cell;
    }
    else if (indexPath.section == 1) {
        FSOrderInfoMessageCell *cell = (FSOrderInfoMessageCell*)[tableView dequeueReusableCellWithIdentifier:OrderInfo_Message_Cell_Indentifier];
        if (cell == nil) {
            NSArray *_array = [[NSBundle mainBundle] loadNibNamed:@"FSOrderListCell" owner:self options:nil];
            if (_array.count > 2) {
                cell = (FSOrderInfoMessageCell*)_array[2];
            }
            else{
                cell = [[FSOrderInfoMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:OrderInfo_Message_Cell_Indentifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell setData:orderInfo];
        
        return cell;
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) { 
            FSOrderInfoProductCell *cell = (FSOrderInfoProductCell*)[tableView dequeueReusableCellWithIdentifier:OrderInfo_Product_Cell_Indentifier];
            if (cell == nil) {
                NSArray *_array = [[NSBundle mainBundle] loadNibNamed:@"FSOrderListCell" owner:self options:nil];
                if (_array.count > 4) {
                    cell = (FSOrderInfoProductCell*)_array[4];
                }
                else{
                    cell = [[FSOrderInfoProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:OrderInfo_Product_Cell_Indentifier];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell setData:orderInfo];
            
            return cell;
        }
        else if (indexPath.row == 1) {
            FSOrderInfoAmount *cell = (FSOrderInfoAmount*)[tableView dequeueReusableCellWithIdentifier:OrderInfo_Amount_Cell_Indentifier];
            if (cell == nil) {
                NSArray *_array = [[NSBundle mainBundle] loadNibNamed:@"FSOrderListCell" owner:self options:nil];
                if (_array.count > 3) {
                    cell = (FSOrderInfoAmount*)_array[3];
                }
                else{
                    cell = [[FSOrderInfoAmount alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:OrderInfo_Amount_Cell_Indentifier];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell setData:orderInfo];
            
            return cell;
        }
    }
    else if (indexPath.section == 3) {
        FSOrderRMAListCell *cell = (FSOrderRMAListCell*)[tableView dequeueReusableCellWithIdentifier:Order_RMA_List_Cell_Indentifier];
        if (cell == nil) {
            NSArray *_array = [[NSBundle mainBundle] loadNibNamed:@"FSOrderListCell" owner:self options:nil];
            if (_array.count > 5) {
                cell = (FSOrderRMAListCell*)_array[5];
            }
            else{
                cell = [[FSOrderRMAListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Order_RMA_List_Cell_Indentifier];
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell setData:orderInfo.rmas[indexPath.row]];
        
        return cell;
    }
    
    
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"收货信息";
            break;
        case 1:
            return @"预订单信息";
            break;
        case 2:
            return @"商品清单";
            break;
        case 3:
            return @"退货信息";
            break;
        default:
            break;
    }
    return @"";
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        FSOrderInfoAddressCell *cell = (FSOrderInfoAddressCell*)[tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.cellHeight;
    }
    else if (indexPath.section == 1) {
        FSOrderInfoMessageCell *cell = (FSOrderInfoMessageCell*)[tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.cellHeight;
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            FSOrderInfoProductCell *cell = (FSOrderInfoProductCell*)[tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
            return cell.cellHeight;
        }
        else if (indexPath.row == 1) {
            FSOrderInfoAmount *cell = (FSOrderInfoAmount*)[tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
            return cell.cellHeight;
        }
    }
    else if(indexPath.section == 3) {
        FSOrderRMAListCell *cell = (FSOrderRMAListCell*)[tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.cellHeight;
    }
    return 40;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == Request_Cancel_Tag && buttonIndex == 1) {
        FSPurchaseRequest *request = [[FSPurchaseRequest alloc] init];
        request.routeResourcePath = RK_REQUEST_ORDER_CANCEL;
        request.orderno = orderno;
        request.uToken = [[FSModelManager sharedModelManager] loginToken];
        [self beginLoading:self.view];
        [request send:[FSOrderInfo class] withRequest:request completeCallBack:^(FSEntityBase *respData) {
            [self endLoading:self.view];
            if (respData.isSuccess)
            {
                orderInfo = respData.responseData;
                _tbAction.tableFooterView = [self createTableFooterView];
                [self reportError:respData.message];
                [_tbAction reloadData];
            }
            else
            {
                [self reportError:respData.errorDescrip];
            }
        }];
    }
}

#pragma mark - FSOrderRMARequestViewControllerDelegate

-(void)refreshViewController:(FSOrderRMARequestViewController*)controller needRefresh:(BOOL)flag
{
    [self requestData];
}



@end
