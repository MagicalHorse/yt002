//
//  FSPointGiftDetailViewController.m
//  FashionShop
//
//  Created by HeQingshan on 13-4-28.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSPointGiftDetailViewController.h"
#import "FSPointExDescCell.h"

@interface FSPointGiftDetailViewController ()

@end

@implementation FSPointGiftDetailViewController

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
    self.title = @"积点礼券详情";//NSLocalizedString(@"Point Activity List", nil);
    UIBarButtonItem *baritemCancel = [self createPlainBarButtonItem:@"goback_icon.png" target:self action:@selector(onButtonBack:)];
    [self.navigationItem setLeftBarButtonItem:baritemCancel];
    
    _tbAction.tableFooterView = [self createTableFooterView];
}

- (IBAction)onButtonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTbAction:nil];
    [super viewDidUnload];
}

-(UIView*)createTableFooterView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    view.backgroundColor = [UIColor clearColor];
    
    int xOffset = 10;
    int yOffset = 30;
    
    UIButton *btnClean = [UIButton buttonWithType:UIButtonTypeCustom];
    btnClean.frame = CGRectMake(xOffset, yOffset, (320-xOffset*2), 40);
    [btnClean setTitle:NSLocalizedString(@"Cancel Point Exchange", nil) forState:UIControlStateNormal];
    [btnClean setBackgroundImage:[UIImage imageNamed:@"btn_bg.png"] forState:UIControlStateNormal];
    [btnClean setTitleColor:RGBCOLOR(38, 38, 38) forState:UIControlStateNormal];
    [btnClean addTarget:self action:@selector(pointExchangeCancel:) forControlEvents:UIControlEventTouchUpInside];
    btnClean.titleLabel.font = [UIFont systemFontOfSize:16];
    [view addSubview:btnClean];
    return view;
}

-(void)pointExchangeCancel:(UIButton*)sender
{
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;//[[_dataSourceList objectAtIndex:section] count];
}

#define Point_Ex_Detail_Desc_Cell_Indentifier @"PointGiftDescCell"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSPointExCommonCell *cell = (FSPointExCommonCell*)[tableView dequeueReusableCellWithIdentifier:Point_Ex_Detail_Desc_Cell_Indentifier];
    if (cell == nil) {
        NSArray *_array = [[NSBundle mainBundle] loadNibNamed:@"FSPointExDescCell" owner:self options:nil];
        if (_array.count > 0) {
            cell = (FSPointExCommonCell*)_array[2];
        }
        else{
            cell = [[FSPointExCommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Point_Ex_Detail_Desc_Cell_Indentifier];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.row) {
        case 0:
        {
            [cell setData:nil];
        }
            break;
        case 1:
        {
            [cell setData:nil];
        }
            break;
        case 2:
        {
            [cell setData:nil];
        }
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSPointExDescCell *cell = (FSPointExDescCell*)[tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.cellHeight;
}

@end
