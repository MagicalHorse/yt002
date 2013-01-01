//
//  FSNickieViewController.m
//  FashionShop
//
//  Created by gong yi on 11/30/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSNickieViewController.h"
#import "UIViewController+Loading.h"
#import "FSUserProfileRequest.h"


@interface FSNickieViewController ()
{
}

@end

@implementation FSNickieViewController
@synthesize currentUser;

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
    
    [self bindControl];
}

- (void)bindControl
{
    UIBarButtonItem *baritemSetting = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"USER_NICKIE_SET_BUTTON", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(doSave:)];
    [self.navigationItem setRightBarButtonItem:baritemSetting];
    [self.navigationItem setTitle:NSLocalizedString(@"USER_NICKIE_SET_TITLE", nil)];
    _txtNicke.delegate = self;
    _txtPhone.delegate = self;
    _txtNicke.text = currentUser.nickie;
    _txtPhone.text = currentUser.phone;
}
- (BOOL)validateUser:(NSMutableString **)errorin
{
    if (!errorin)
        *errorin = [@"" mutableCopy];
    NSMutableString *error = *errorin;
    if (_txtNicke.text.length<=0)
    {
        [error appendString:NSLocalizedString(@"USER_NICKIE_VALIDATE_ZERO", nil)];;
        return false;
    } else if(_txtNicke.text.length>10)
    {
        [error appendString:NSLocalizedString(@"USER_NICKIE_VALIDATE_TOO_LONG", nil)];;
        return false;
    }
    else if (_txtPhone.text.length>0)
    {
        NSString *phone = _txtPhone.text;
        NSError *error1 = NULL;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:&error1];
        NSArray *matches = [detector matchesInString:phone options:0 range:NSMakeRange(0, [phone length])];
        if (!(matches != nil && matches.count ==1)) {
            [error appendString:NSLocalizedString(@"USER_NICKIE_VALIDATE_PHONE", nil)];
            return false;
        }
    }
    return true;
}

#pragma TEXTField delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return TRUE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doSave:(id)sender {
    NSMutableString *error = [@"" mutableCopy];
    if([self validateUser:&error])
    {
        FSUserProfileRequest *request = [[FSUserProfileRequest alloc] init];
        request.userToken = currentUser.uToken;
        request.nickie = [_txtNicke.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        request.phone = [_txtPhone.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        [self beginLoading:self.view];
        [request send:[FSUser class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
            if (!resp.isSuccess)
            {
                [self reportError:resp.description];
            }
            else
            {
                currentUser.nickie = request.nickie;
                [self reportError:NSLocalizedString(@"COMM_OPERATE_COMPL", nil)];
            }
            [self endLoading:self.view];
        }];
    }
    else
    {
        [self reportError:error];
    }
}
@end
