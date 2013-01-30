//
//  FSFeedback1ViewController.m
//  FashionShop
//
//  Created by  赵学智 on 13-1-15.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSFeedbackViewController.h"
#import "UIViewController+Loading.h"
#import "FSFeedbackRequest.h"
#import "NSString+Extention.h"

#define Table_Cell_Width 290

@interface FSFeedbackViewController ()
{
    UIView *backView;
}
@end

@implementation FSFeedbackViewController
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
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"USER_SETTING_FEEDBACK", nil);
    
    UIBarButtonItem *baritemCancel = [self createPlainBarButtonItem:@"goback_icon.png" target:self action:@selector(onButtonBack:)];
    UIBarButtonItem *baritemShare = [self createPlainBarButtonItem:@"ok_icon.png" target:self action:@selector(doSave:)];
    [self.navigationItem setLeftBarButtonItem:baritemCancel];
    [self.navigationItem setRightBarButtonItem:baritemShare];
    
    [self decorateTapDismissKeyBoard];
    [self bindControl];
}

-(void) bindControl
{
    [_txtContent setBackgroundColor:[UIColor colorWithRed:247 green:247 blue:247]];
    _txtContent.layer.borderWidth = 2;
    _txtContent.layer.borderColor = [UIColor colorWithRed:222 green:222 blue:222].CGColor;
    _txtContent.placeholder = NSLocalizedString(@"Feedback content place holder", nil);
    
    [_txtPhone setBackgroundColor:[UIColor colorWithRed:247 green:247 blue:247]];
    _txtPhone.layer.borderWidth = 1;
    _txtPhone.layer.borderColor = [UIColor colorWithRed:222 green:222 blue:222].CGColor;
    _txtPhone.placeholder = NSLocalizedString(@"Contact place holder", nil);
    _txtContent.delegate = self;
    _txtPhone.delegate = self;
}

-(void) decorateTapDismissKeyBoard
{
    backView = [[UIView alloc] initWithFrame:self.view.frame];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKB)];
    [backView addGestureRecognizer:recognizer];
    [self.view addSubview:backView];
    [self.view sendSubviewToBack:backView];
}

-(void) dismissKB
{
    if ([_txtContent isFirstResponder])
        [_txtContent resignFirstResponder];
    else if ([_txtPhone isFirstResponder])
    {
        [_txtPhone resignFirstResponder];
    }     
}

-(BOOL) checkInput
{
    if (_txtContent.text.length<=0)
    {
        [self reportError:NSLocalizedString(@"USER_FEEDBACK_CONTENT_VALIDATE_ZERO", nil)];;
        return FALSE;
    }
    else if (_txtPhone.text.length>0)
    {
        if ([NSString isMobileNum:_txtPhone.text]) {
            return YES;
        }
        else {
            [self reportError:NSLocalizedString(@"USER_NICKIE_VALIDATE_PHONE", nil)];
            return NO;
        }
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButtonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doSave:(id)sender {
    if ([self checkInput])
    {
        FSFeedbackRequest *request = [[FSFeedbackRequest alloc] init];
        request.userToken = currentUser.uToken;
        request.content = _txtContent.text;
        request.phone = _txtPhone.text;
        [self beginLoading:self.view];
        [request send:[FSModelBase class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
            if (!resp.isSuccess)
            {
                [self reportError:resp.description];
            }
            else
            {
                [self reportError:resp.message];
                [_txtContent resignFirstResponder];
                _txtContent.text = @"";
                _txtContent.placeholder = NSLocalizedString(@"Feedback content place holder", nil);
                [_txtContent setNeedsDisplay];
                [_txtPhone resignFirstResponder];
                _txtPhone.text = @"";
            }
            [self endLoading:self.view];
        }];
    }
}

#pragma uitextfielddelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.text.length > 140 && ![text isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _txtPhone) {
        if (textField.text.length > 10 && ![string isEqualToString:@""]) {
            return NO;
        }
        else {
            return YES;
        }
    }
    return YES;
}

- (void)viewDidUnload {
    [self setTxtContent:nil];
    [self setTxtPhone:nil];
    [super viewDidUnload];
}
@end

