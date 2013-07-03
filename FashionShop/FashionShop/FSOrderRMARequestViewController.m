//
//  FSOrderRMARequestViewController.m
//  FashionShop
//
//  Created by HeQingshan on 13-7-1.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSOrderRMARequestViewController.h"
#import "FSPurchaseRequest.h"
#import "NSString+Extention.h"
#import "FSOrder.h"
#import "FSOrderRMASuccessViewController.h"

@interface FSOrderRMARequestViewController ()
{
    id activityField;
    UIColor *fieldTextColor;
    UIColor *redColor;
}

@end

@implementation FSOrderRMARequestViewController

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
    self.title = @"申请在线退货";
    
    UIBarButtonItem *baritemCancel = [self createPlainBarButtonItem:@"goback_icon.png" target:self action:@selector(onButtonBack:)];
    [self.navigationItem setLeftBarButtonItem:baritemCancel];
    
    _reason.layer.borderWidth = 2;
    _reason.layer.cornerRadius = 10;
    _reason.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _reason.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    _reason.layer.shadowOffset = CGSizeMake(3, 3);
    _reason.placeholder = @"请输入您的退货原因";
    _contentView.backgroundColor = APP_TABLE_BG_COLOR;
    self.view.backgroundColor = APP_TABLE_BG_COLOR;
    
    redColor = [UIColor redColor];
    fieldTextColor = _bankName.textColor;
}

- (void)viewDidUnload {
    [self setContentView:nil];
    [self setBankName:nil];
    [self setBankNumber:nil];
    [self setBankUserName:nil];
    [self setTelephone:nil];
    [self setSubmitBtn:nil];
    [self setContentView:nil];
    [super viewDidUnload];
}

- (IBAction)onButtonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(FSPurchaseRequest*)createRequest:(NSString *)routePath
{   
    FSPurchaseRequest *request = [[FSPurchaseRequest alloc] init];
    request.uToken = [FSModelManager sharedModelManager].loginToken;
    request.routeResourcePath = routePath;
    
    return request;
}

-(BOOL)check
{
    BOOL flag = YES;
    {
        //判断是否合理
        //银行名称
        if (_bankName.text.length <= 0) {
            _bankName.text = @"请输入银行名称";
            _bankName.textColor = redColor;
            
            flag = NO;
        }
        else {
            if ([_bankName.textColor isEqual:redColor]) {
                flag = NO;
            }
        }
        
        //银行卡号
        if (_bankNumber.text.length <= 0) {
            _bankNumber.text = _bankNumber.placeholder;
            _bankNumber.textColor = redColor;
            flag = NO;
        }
        else {
            if ([_bankNumber.textColor isEqual:redColor]) {
                flag = NO;
            }
        }
        
        //银行卡对应的用户名
        if (_bankUserName.text.length <= 0) {
            _bankUserName.text = _bankUserName.placeholder;
            _bankUserName.textColor = redColor;
        }
        else {
            if ([_bankUserName.textColor isEqual:redColor]) {
                flag = NO;
            }
        }
        
        //手机号码
        if (_telephone.text.length <= 0) {
            _telephone.text = _telephone.placeholder;
            _telephone.textColor = redColor;
            flag = NO;
        }
        else {
            BOOL tempFlag = YES;
            if ([_telephone.textColor isEqual:redColor]) {
                flag = NO;
                tempFlag = NO;
            }
            if (tempFlag && ![NSString isMobileNum:_telephone.text]) {
                _telephone.text = @"请输入正确的联系方式";
                _telephone.textColor = redColor;
                
                flag = NO;
            }
        }
        
        if (_telephone.text.length > 0) {
            BOOL tempFlag = YES;
            if ([_telephone.textColor isEqual:redColor]) {
                flag = NO;
                tempFlag = NO;
            }
            if (tempFlag && ![NSString isPhoneNum:_telephone.text]) {
                _telephone.text = @"请输入正确的联系方式";
                _telephone.textColor = redColor;
                
                flag = NO;
            }
        }
    }
    return flag;
}

- (IBAction)requestRMA:(id)sender {
    if ([self check]) {
        //退货预览
        NSMutableString *msg = [NSMutableString stringWithString:@""];
        [msg appendFormat:@"收款银行 : %@\n", _bankName.text];
        [msg appendFormat:@"银行卡号 : %@\n", _bankNumber.text];
        [msg appendFormat:@"银行卡开户用户名 : %@\n", _bankUserName.text];
        [msg appendFormat:@"联系方式 : %@\n", _telephone.text];
        [msg appendFormat:@"退货原因 : %@\n", _reason.text];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        
        //左对齐
        for(UIView *subview in alert.subviews)
        {
            if([[subview class] isSubclassOfClass:[UILabel class]])
            {
                UILabel *label = (UILabel*)subview;
                if([label.text isEqualToString:msg])
                    label.textAlignment = UITextAlignmentLeft;
            }
        }
        [alert show];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.text.length > 0 && [textField.textColor isEqual:redColor]) {
        textField.text = @"";
        textField.textColor = fieldTextColor;
    }
    activityField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _bankName) {
        [_bankNumber becomeFirstResponder];
    }
    else if(textField == _bankNumber) {
        [_bankUserName becomeFirstResponder];
    }
    else if(textField == _bankUserName) {
        [_telephone becomeFirstResponder];
    }
    else if(textField == _telephone){
        [_telephone resignFirstResponder];
    }
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView.text.length > 0 && [textView.textColor isEqual:redColor]) {
        textView.text = @"";
        textView.textColor = fieldTextColor;
    }
    activityField = textView;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1) {
        FSPurchaseRequest *request = [[FSPurchaseRequest alloc] init];
        request.routeResourcePath = RK_REQUEST_ORDER_RMA;
        request.reason = _reason.text;
        request.bankname = _bankName.text;
        request.bankcard = _bankNumber.text;
        request.bankaccount = _bankUserName.text;
        request.contactphone = _telephone.text;
        request.orderno = _orderno;
        request.uToken = [[FSModelManager sharedModelManager] loginToken];
        [self beginLoading:self.view];
        [request send:[FSOrderRMAItem class] withRequest:request completeCallBack:^(FSEntityBase *respData) {
            [self endLoading:self.view];
            if (respData.isSuccess)
            {
                FSOrderRMAItem *rmaData = respData.responseData;
                FSOrderRMASuccessViewController *controller = [[FSOrderRMASuccessViewController alloc] initWithNibName:@"FSOrderRMASuccessViewController" bundle:nil];
                controller.data = rmaData;
                controller.title = @"退货申请成功";
                [self.navigationController pushViewController:controller animated:YES];
                if (_delegate && [_delegate respondsToSelector:@selector(refreshViewController:needRefresh:)]) {
                    [_delegate refreshViewController:self needRefresh:YES];
                }
            }
            else
            {
                [self reportError:respData.errorDescrip];
            }
        }];
    }
}

@end
