//
//  FSOrderSuccessViewController.m
//  FashionShop
//
//  Created by HeQingshan on 13-6-30.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSOrderSuccessViewController.h"
#import "FSPurchaseProdCell.h"
#import "FSPointExSuccessFooter.h"
#import "FSMoreViewController.h"
#import "FSMeViewController.h"
#import "FSOrderListViewController.h"
#import "FSOrderDetailViewController.h"

@interface FSOrderSuccessViewController ()

@end

@implementation FSOrderSuccessViewController

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
    self.navigationItem.hidesBackButton = YES;
    
    [self loadFooter];
    _tbAction.backgroundView = nil;
    _tbAction.backgroundColor = APP_TABLE_BG_COLOR;
}

-(void)loadFooter
{
    NSArray *_array = [[NSBundle mainBundle] loadNibNamed:@"FSPointExSuccessFooter" owner:self options:nil];
    if (_array.count > 0) {
        FSCommonSuccessFooter *footer = (FSCommonSuccessFooter*)_array[0];
        [footer.continueBtn setTitle:@"查看预订单" forState:UIControlStateNormal];
        [footer.continueBtn addTarget:self action:@selector(clickToOrderDetail:) forControlEvents:UIControlEventTouchUpInside];
        [footer.backHomeBtn setTitle:@"继 续 购 物" forState:UIControlStateNormal];
        [footer.backHomeBtn addTarget:self action:@selector(clickToContinue:) forControlEvents:UIControlEventTouchUpInside];
        NSString *msg = [theApp messageForKey:EM_O_C_SUCC];
        if (msg) {
            [footer initView:msg];
        }
        _tbAction.tableFooterView = footer;
    }
}

- (void)viewDidUnload {
    [self setTbAction:nil];
    [super viewDidUnload];
}

-(void)clickToContinue:(UIButton*)sender
{
    [self dismissModalViewControllerAnimated:YES];
    UITabBarController *root = (UITabBarController*)theApp.window.rootViewController;
    root.selectedIndex = 2;
    UINavigationController *nav = (UINavigationController*)root.viewControllers[3];
    [nav popToRootViewControllerAnimated:YES];
    
    [[FSAnalysis instance] logEvent:BUY_CONTINE withParameters:nil];
}

-(void)clickToOrderDetail:(UIButton*)sender
{
    [self dismissModalViewControllerAnimated:NO];
    UITabBarController *root = (UITabBarController*)theApp.window.rootViewController;
    root.selectedIndex = 3;
    UINavigationController *nav = (UINavigationController*)root.viewControllers[3];
    NSMutableArray *_mutArray = [NSMutableArray arrayWithObject:nav.topViewController];
    FSMoreViewController *controller = [[FSMoreViewController alloc] initWithNibName:@"FSMoreViewController" bundle:nil];
    controller.delegate = (FSMeViewController*)nav.topViewController;
    controller.currentUser = [FSUser localProfile];
    [_mutArray addObject:controller];
    
    FSOrderListViewController *orderView = [[FSOrderListViewController alloc] initWithNibName:@"FSOrderListViewController" bundle:nil];
    [_mutArray addObject:orderView];
    
    /*
     //跳转到订单列表，就不需要此处的代码
    FSOrderDetailViewController *detailView = [[FSOrderDetailViewController alloc] initWithNibName:@"FSOrderDetailViewController" bundle:nil];
    detailView.orderno = _data.orderno;
    [_mutArray addObject:detailView];
    */
    
    [nav setViewControllers:_mutArray animated:YES];
    
    [[FSAnalysis instance] logEvent:BUY_LOOK_ORDER withParameters:nil];
    
    //统计
    NSMutableDictionary *_dic = [NSMutableDictionary dictionaryWithCapacity:4];
    [_dic setValue:@"订单提交成功页" forKey:@"来源页面"];
    [_dic setValue:[NSString stringWithFormat:@"%@", _data.orderno] forKey:@"订单号"];
    [[FSAnalysis instance] logEvent:CHECK_ORDER_DETAIL withParameters:_dic];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#define Order_Success_Cell_Indentifier @"FSOrderSuccessCell"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSOrderSuccessCell *cell = (FSOrderSuccessCell*)[tableView dequeueReusableCellWithIdentifier:Order_Success_Cell_Indentifier];
    if (cell == nil) {
        NSArray *_array = [[NSBundle mainBundle] loadNibNamed:@"FSPurchaseProdCell" owner:self options:nil];
        if (_array.count > 4) {
            cell = (FSOrderSuccessCell*)_array[4];
        }
        else{
            cell = [[FSOrderSuccessCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Order_Success_Cell_Indentifier];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell setData:_data];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

@end
