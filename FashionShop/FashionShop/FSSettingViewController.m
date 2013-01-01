//
//  FSSettingViewController.m
//  FashionShop
//
//  Created by gong yi on 11/30/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSSettingViewController.h"
#import "FSNickieViewController.h"
#import "FSModelManager.h"
#import "UIViewController+Loading.h"

@interface FSSettingViewController ()
{
    NSArray *_sections;
    NSDictionary *_rows;
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
    [self bindAction];
}

-(void) bindAction
{
    _sections = @[@"userinfo",@"account"];
    _rows = @{@"userinfo":@[NSLocalizedString(@"USER_SETTING_EDITNGINFO", nil)],
                @"account":@[NSLocalizedString(@"USER_SETTING_CLEAR", nil),
                        NSLocalizedString(@"USER_SETTING_LOGOUT", nil)]
            };

    _tbAction.dataSource= self;
    _tbAction.delegate = self;
    [_tbAction reloadData];
}

#pragma UITableViewController delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sections.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"section:%d,rows:%d",section,[(NSArray *)[_rows objectForKey:[_sections objectAtIndex:section]] count]);
    return [(NSArray *)[_rows objectForKey:[_sections objectAtIndex:section]] count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section*10+indexPath.row) {
        case 0:
        {
            FSNickieViewController *nickieController = [[FSNickieViewController alloc] initWithNibName:@"FSNickieViewController" bundle:nil];
            nickieController.currentUser = currentUser;
            [self.navigationController pushViewController:nickieController animated:true];
            break;
        }
        case 10:
        {
            [[FSModelManager sharedModelManager] clearCache];
             [self reportError:NSLocalizedString(@"COMM_OPERATE_COMPL", nil)];
            break;
        }
        case 11:
        {
            [FSUser removeUserProfile];
            if (delegate)
            {
                [delegate settingView:self didLogOut:true];
            }
            [self reportError:NSLocalizedString(@"COMM_OPERATE_COMPL", nil)];
            [self.navigationController popViewControllerAnimated:true];
            
            break;
           
        }
            
        default:
            break;
    }
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuserId = @"detailcell";
    UITableViewCell *cell = [_tbAction dequeueReusableCellWithIdentifier:reuserId];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserId];
         
    }
    cell.textLabel.text = [(NSArray *)[_rows objectForKey:[_sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
   cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
