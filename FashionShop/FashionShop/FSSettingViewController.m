//
//  FSSettingViewController.m
//  FashionShop
//
//  Created by gong yi on 11/30/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSSettingViewController.h"
#import "FSNickieViewController.h"
#import "FSFeedbackViewController.h"
#import "FSModelManager.h"
#import "UIViewController+Loading.h"
#import "FSCardBindViewController.h"

@interface FSSettingViewController ()
{
    NSArray *_rows;
}

@end

@implementation FSSettingViewController

@synthesize currentUser;
@synthesize delegate;

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
    self.title = NSLocalizedString(@"User_Profile_Setting", nil);
    UIBarButtonItem *baritemCancel = [self createPlainBarButtonItem:@"goback_icon.png" target:self action:@selector(onButtonBack:)];
    [self.navigationItem setLeftBarButtonItem:baritemCancel];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self bindAction];
}

- (IBAction)onButtonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) bindAction
{
    if ([currentUser.isBindCard boolValue]) {
        _rows = @[NSLocalizedString(@"USER_SETTING_EDITNGINFO", nil), NSLocalizedString(@"USER_SETTING_FEEDBACK", nil),
                  NSLocalizedString(@"Card Info Query", nil)];
    }
    else{
        _rows = @[NSLocalizedString(@"USER_SETTING_EDITNGINFO", nil), NSLocalizedString(@"USER_SETTING_FEEDBACK", nil),
                  NSLocalizedString(@"Bind Card", nil)];
    }

    _tbAction.dataSource= self;
    _tbAction.delegate = self;
    _tbAction.backgroundView = [[UIView alloc]init];
    _tbAction.backgroundColor = APP_BACKGROUND_COLOR;
    [_tbAction reloadData];
}

#pragma UITableViewController delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_rows count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: //编辑个人资料
        {
            FSNickieViewController *nickieController = [[FSNickieViewController alloc] initWithNibName:@"FSNickieViewController" bundle:nil];
            nickieController.currentUser = currentUser;
            [self.navigationController pushViewController:nickieController animated:true];
            break;
        }
        case 1:    //意见反馈
        {
            FSFeedbackViewController *feedbackController = [[FSFeedbackViewController alloc] initWithNibName:@"FSFeedbackViewController" bundle:nil];
            feedbackController.currentUser = currentUser;
            [self.navigationController pushViewController:feedbackController animated:true];
            break;
        }
        case 2: //会员卡绑定和会员卡积分查询
        {
            FSCardBindViewController *con = [[FSCardBindViewController alloc] initWithNibName:@"FSCardBindViewController" bundle:nil];
            con.currentUser = currentUser;
            [self.navigationController pushViewController:con animated:YES];
        }
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuserId = @"detailcell";
    UITableViewCell *cell = [_tbAction dequeueReusableCellWithIdentifier:reuserId];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserId];
         
    }
    cell.textLabel.text = [_rows objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor colorWithRed:113.0/255.0 green:113.0/255.0 blue:113.0/255.0 alpha:1.0f];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 220;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 220)];
    view.backgroundColor = [UIColor clearColor];
    
    int xOffset = 10;
    int yOffset = 20;
//    UIButton *btnComment = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnComment.frame = CGRectMake(xOffset, yOffset, (320-xOffset*2), 40);
//    [btnComment setTitle:NSLocalizedString(@"USER_SETTING_COMMENT", nil) forState:UIControlStateNormal];
//    [btnComment setBackgroundImage:[UIImage imageNamed:@"btn_bg.png"] forState:UIControlStateNormal];
//    [btnComment setTitleColor:[UIColor colorWithRed:38.0/255.0 green:38.0/255.0 blue:38.0/255.0 alpha:1.0f] forState:UIControlStateNormal];
//    [btnComment addTarget:self action:@selector(clickToComment:) forControlEvents:UIControlEventTouchUpInside];
//    btnComment.titleLabel.font = [UIFont systemFontOfSize:16];
//    yOffset += btnComment.frame.size.height + 10;
    
    UIButton *btnClean = [UIButton buttonWithType:UIButtonTypeCustom];
    btnClean.frame = CGRectMake(xOffset, yOffset, (320-xOffset*2), 40);
    [btnClean setTitle:NSLocalizedString(@"USER_SETTING_CLEAR", nil) forState:UIControlStateNormal];
    [btnClean setBackgroundImage:[UIImage imageNamed:@"btn_bg.png"] forState:UIControlStateNormal];
    [btnClean setTitleColor:RGBCOLOR(38, 38, 38) forState:UIControlStateNormal];
    [btnClean addTarget:self action:@selector(clickToClean:) forControlEvents:UIControlEventTouchUpInside];
    btnClean.titleLabel.font = [UIFont systemFontOfSize:16];
    yOffset += btnClean.frame.size.height + 35;
    
    UIButton *btnExit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnExit.frame = CGRectMake(xOffset, yOffset, (320-xOffset*2), 40);
    [btnExit setTitle:NSLocalizedString(@"USER_SETTING_LOGOUT", nil) forState:UIControlStateNormal];
    [btnExit setBackgroundImage:[UIImage imageNamed:@"logout_icon.png"] forState:UIControlStateNormal];
    [btnExit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnExit addTarget:self action:@selector(clickToExit:) forControlEvents:UIControlEventTouchUpInside];
    btnExit.titleLabel.font = [UIFont systemFontOfSize:16];
    
    //[view addSubview:btnComment];
    [view addSubview:btnClean];
    [view addSubview:btnExit];
    
    return view;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (IBAction)clickToComment:(id)sender {
    NSLog(@"app id:%@", currentUser.appID);
    if (!currentUser.appID || [currentUser.appID isEqualToString:@""]) {
        currentUser.appID = @"452703031";
    }
    NSString *str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",currentUser.appID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

- (IBAction)clickToClean:(id)sender {
    [self beginLoading:self.view];
    [[FSModelManager sharedModelManager] clearCache];
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0f];
}

- (void)stopLoading
{
    [self endLoading:self.view];
}

- (IBAction)clickToExit:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warm prompt", nil) message:NSLocalizedString(@"Exit Current Account", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [FSUser removeUserProfile];
        if (delegate)
        {
            [delegate settingView:self didLogOut:true];
        }
        [self reportError:NSLocalizedString(@"COMM_OPERATE_COMPL", nil)];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
