//
//  FSInvoiceViewController.m
//  FashionShop
//
//  Created by HeQingshan on 13-7-1.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSInvoiceViewController.h"
#import "NSString+Extention.h"

@interface FSInvoiceViewController () {
    id activityField;
}

@end

@implementation FSInvoiceViewController

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
    self.title = @"填写发票信息";
    UIBarButtonItem *baritemCancel = [self createPlainBarButtonItem:@"goback_icon.png" target:self action:@selector(onButtonBack:)];
    [self.navigationItem setLeftBarButtonItem:baritemCancel];
    [self addRightButton:@"保存"];
    
    _contentView.backgroundColor = APP_TABLE_BG_COLOR;
    [_invoiceTitle becomeFirstResponder];
    
    _invoiceTitle.text = _uploadData.invoicetitle;
    _invoiceDetail.text = _uploadData.invoicedetail;
}

-(void)addRightButton:(NSString*)title
{
    UIImage *btnNormal = [[UIImage imageNamed:@"btn_normal.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    UIButton *sheepButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sheepButton setTitle:title forState:UIControlStateNormal];
    [sheepButton addTarget:self action:@selector(saveInvoice:) forControlEvents:UIControlEventTouchUpInside];
    sheepButton.titleLabel.font = ME_FONT(13);
    sheepButton.showsTouchWhenHighlighted = YES;
    [sheepButton setBackgroundImage:btnNormal forState:UIControlStateNormal];
    [sheepButton sizeToFit];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:sheepButton];
    [self.navigationItem setRightBarButtonItem:item];
}

- (IBAction)onButtonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveInvoice:(UIButton*)sender
{
    if ([NSString isNilOrEmpty:_invoiceTitle.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请输入发票抬头" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        [_invoiceTitle becomeFirstResponder];
        return;
    }
    if ([NSString isNilOrEmpty:_invoiceDetail.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请输入发票明细" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        [_invoiceDetail becomeFirstResponder];
        return;
    }
    [self reportError:@"保存成功"];
    [self performSelector:@selector(onButtonBack:) withObject:nil afterDelay:1.0f];
    if (_delegate && [_delegate respondsToSelector:@selector(completeInvoiceInput:)]) {
        [_delegate completeInvoiceInput:self];
    }
}

- (void)viewDidUnload {
    [self setInvoiceTitle:nil];
    [self setInvoiceDetail:nil];
    [self setContentView:nil];
    [super viewDidUnload];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activityField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _invoiceDetail) {
        [self saveInvoice:nil];
        [textField resignFirstResponder];
    }
    return YES;
}

@end
