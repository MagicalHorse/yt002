//
//  FSMoreViewController.m
//  FashionShop
//
//  Created by HeQingshan on 13-4-27.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSMoreViewController.h"
#import "FSNickieViewController.h"
#import "FSFeedbackViewController.h"
#import "FSCardBindViewController.h"
#import "WXApi.h"
#import "FSAboutViewController.h"

@interface FSMoreViewController () {
    NSMutableArray *_titles;
}

@end

@implementation FSMoreViewController

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
    self.title = NSLocalizedString(@"More", nil);
    UIBarButtonItem *baritemCancel = [self createPlainBarButtonItem:@"goback_icon.png" target:self action:@selector(onButtonBack:)];
    [self.navigationItem setLeftBarButtonItem:baritemCancel];
    _tbAction.tableFooterView = [self createTableFooterView];
    _tbAction.backgroundColor = APP_TABLE_BG_COLOR;
    _tbAction.backgroundView = nil;
    
    [self initTitlesArray];
}

- (IBAction)onButtonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initTitlesArray
{
    if (_titles) {
        return;
    }
    
    _titles = [@[
                @[
                    NSLocalizedString(@"Pre Order Title", nil)],
                @[
                    NSLocalizedString(@"Edit Personal Info",nil),
                    ([_currentUser.isBindCard boolValue]?NSLocalizedString(@"Card Info Query", nil):NSLocalizedString(@"Bind Member Card",nil)),
                    NSLocalizedString(@"Address Manager",nil)],
                @[
                    NSLocalizedString(@"FeedBack",nil),
                    NSLocalizedString(@"About Love Intime",nil),
                    NSLocalizedString(@"Check Version",nil),
                    NSLocalizedString(@"Like Intime",nil),
                    NSLocalizedString(@"Clear Cache",nil)]
               ] mutableCopy];
}

- (IBAction)clickToExit:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warm prompt", nil) message:NSLocalizedString(@"Exit Current Account", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    [alert show];
}

-(void)attentionXhyt:(UIButton*)sender
{
    [WXApi openWXApp];
}

- (void)stopLoading
{
    [self endLoading:self.view];
}

-(UIView*)createTableFooterView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 130)];
    view.backgroundColor = [UIColor clearColor];
    
    int xOffset = 49;
    int yOffset = 15;
    
    UIButton *btnAttention = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAttention.frame = CGRectMake(xOffset, yOffset, 222, 40);
    [btnAttention setTitle:NSLocalizedString(@"Attention XHYT", nil) forState:UIControlStateNormal];
    [btnAttention setBackgroundImage:[UIImage imageNamed:@"btn_bg.png"] forState:UIControlStateNormal];
    [btnAttention setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnAttention addTarget:self action:@selector(attentionXhyt:) forControlEvents:UIControlEventTouchUpInside];
    btnAttention.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    yOffset += btnAttention.frame.size.height + yOffset;
    
    UIButton *btnExit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnExit.frame = CGRectMake(xOffset, yOffset, 222, 40);
    [btnExit setTitle:NSLocalizedString(@"USER_SETTING_LOGOUT", nil) forState:UIControlStateNormal];
    [btnExit setBackgroundImage:[UIImage imageNamed:@"btn_bg.png"] forState:UIControlStateNormal];
    [btnExit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnExit addTarget:self action:@selector(clickToExit:) forControlEvents:UIControlEventTouchUpInside];
    btnExit.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    
    [view addSubview:btnAttention];
    [view addSubview:btnExit];
    
    return view;
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_titles || section >= _titles.count) {
        return 0;
    }
    return [[_titles objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"MoreCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.imageView.image = [UIImage imageNamed:@"promotion_header_icon"];
    NSArray *array = [_titles objectAtIndex:indexPath.section];
    cell.textLabel.text = [array objectAtIndex:indexPath.row];
    cell.textLabel.font = ME_FONT(15);
    if (indexPath.section == 2 &&
        indexPath.row + indexPath.section * 10 == FSMoreCheckVersion) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"当前版本V%@", REST_API_CLIENT_VERSION];
        cell.detailTextLabel.font = ME_FONT(14);
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _titles.count;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row + indexPath.section * 10) {
        case FSMoreOrder:
        {
            
        }
            break;
        case FSMoreEdit:    //编辑个人资料
        {
            FSNickieViewController *nickieController = [[FSNickieViewController alloc] initWithNibName:@"FSNickieViewController" bundle:nil];
            nickieController.currentUser = _currentUser;
            [self.navigationController pushViewController:nickieController animated:true];
        }
            break;
        case FSMoreBindCard: //会员卡绑定和会员卡积分查询
        {
            FSCardBindViewController *con = [[FSCardBindViewController alloc] initWithNibName:@"FSCardBindViewController" bundle:nil];
            con.currentUser = _currentUser;
            [self.navigationController pushViewController:con animated:YES];
        }
            break;
        case FSMoreAddress:
        {
            
        }
            break;
        case FSMoreFeedback:    //意见反馈
        {
            FSFeedbackViewController *feedbackController = [[FSFeedbackViewController alloc] initWithNibName:@"FSFeedbackViewController" bundle:nil];
            feedbackController.currentUser = _currentUser;
            [self.navigationController pushViewController:feedbackController animated:true];
        }
            break;
        case FSMoreAbout:
        {
            FSAboutViewController *controller = [[FSAboutViewController alloc] initWithNibName:@"FSAboutViewController" bundle:nil];
            [self.navigationController pushViewController:controller animated:true];
        }
            break;
        case FSMoreCheckVersion:
        {
            
        }
            break;
        case FSMoreLike:    //去appstore评论
        {
            if (!_currentUser.appID || [_currentUser.appID isEqualToString:@""]) {
                _currentUser.appID = @"615975780";
            }
            NSString *str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",_currentUser.appID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
            break;
        case FSMoreClear:   //清理缓存
        {
            [self beginLoading:self.view];
            [[FSModelManager sharedModelManager] clearCache];
            [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0f];
        }
            break;
            
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [FSUser removeUserProfile];
        if (_delegate)
        {
            [_delegate settingView:self didLogOut:true];
        }
        [self reportError:NSLocalizedString(@"COMM_OPERATE_COMPL", nil)];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
