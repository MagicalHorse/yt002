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
    FSMyPickerView *invoicePickerView;
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
    
    if (!_data.invoicedetails) {
        _data.invoicedetails = [NSMutableArray arrayWithCapacity:4];
    }
    if (_data.invoicedetails.count <= 0) {
        [_data.invoicedetails addObject:@"服装"];
    }
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请选择发票明细" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        
        [self selectDetail:nil];
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
    [theApp cleanAllPickerView];
    [super viewDidUnload];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [theApp hiddenPickerView];
}

- (IBAction)selectDetail:(id)sender {
    if (!invoicePickerView) {
        invoicePickerView = [[FSMyPickerView alloc] init];
        invoicePickerView.delegate = self;
        invoicePickerView.datasource = self;
    }
    //初始化选中项
    for (int i = 0; i < _data.invoicedetails.count; i++) {
        NSString *item = _data.invoicedetails[i];
        if ([item isEqualToString:_uploadData.invoicedetail]) {
            [invoicePickerView.picker selectRow:i inComponent:0 animated:NO];
            break;
        }
    }
    [activityField resignFirstResponder];
    [invoicePickerView showPickerView:nil];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activityField = textField;
    [invoicePickerView hidenPickerView:YES action:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - FSMyPickerViewDatasource

- (NSInteger)numberOfComponentsInMyPickerView:(FSMyPickerView *)pickerView
{
    if (pickerView == invoicePickerView) {
        return 1;
    }
    return 0;
}

- (NSInteger)myPickerView:(FSMyPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == invoicePickerView) {
        return _data.invoicedetails.count;
    }
    return 0;
}

#pragma mark - FSMyPickerViewDelegate

- (void)didClickOkButton:(FSMyPickerView *)aMyPickerView
{
    if (aMyPickerView == invoicePickerView) {
        int index = [aMyPickerView.picker selectedRowInComponent:0];
        NSString *aItem = _data.invoicedetails[index];
        _invoiceDetail.text = aItem;
    }
}

- (NSString *)myPickerView:(FSMyPickerView *)aMyPickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _data.invoicedetails[row];
}

@end
