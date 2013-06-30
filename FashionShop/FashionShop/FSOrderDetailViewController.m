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
    self.title = @"订单详情";
    UIBarButtonItem *baritemCancel = [self createPlainBarButtonItem:@"goback_icon.png" target:self action:@selector(onButtonBack:)];
    [self.navigationItem setLeftBarButtonItem:baritemCancel];
    
    _tbAction.backgroundView = nil;
    _tbAction.backgroundColor = APP_TABLE_BG_COLOR;
    
    //加载数据
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!orderInfo) {
        return 0;
    }
    if (section == 2) {
        return 2;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!orderInfo) {
        return 0;
    }
    if (orderInfo.rmas) {
        return 4;
    }
    return 3;
}

#define Title_Content_Cell_Indentifier @"FSTitleContentCell"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    FSTitleContentCell *cell = (FSTitleContentCell*)[tableView dequeueReusableCellWithIdentifier:Title_Content_Cell_Indentifier];
    if (cell == nil) {
        NSArray *_array = [[NSBundle mainBundle] loadNibNamed:@"FSPurchaseProdCell" owner:self options:nil];
        if (_array.count > 3) {
            cell = (FSTitleContentCell*)_array[3];
        }
        else{
            cell = [[FSTitleContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Title_Content_Cell_Indentifier];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell setDataWithTitle:_myTitle content:_purchase.rmapolicy];
    */
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"收货信息";
            break;
        case 1:
            return @"订单信息";
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
    return 100;
    /*
    FSTitleContentCell *cell = (FSTitleContentCell*)[tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.cellHeight;
     */
}

@end
