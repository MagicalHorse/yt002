//
//  FSFeedbackViewController.m
//  FashionShop
//
//  Created by HeQingshan on 13-1-3.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSFeedbackViewController.h"
#import "UIViewController+Loading.h"
#import "FSFeedbackRequest.h"

#define Table_Cell_Width 290

@interface FSFeedbackViewController () {
    UIPlaceHolderTextView *_contentView;
    UITextField *_contactField;
    BOOL isKeyBourdShown;
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
    self.title = NSLocalizedString(@"USER_SETTING_FEEDBACK", nil);
    
    UIBarButtonItem *baritemCancel = [self createPlainBarButtonItem:@"goback_icon.png" target:self action:@selector(onButtonBack:)];
    UIBarButtonItem *baritemShare = [self createPlainBarButtonItem:@"ok_icon.png" target:self action:@selector(doSave:)];
    [self.navigationItem setLeftBarButtonItem:baritemCancel];
    [self.navigationItem setRightBarButtonItem:baritemShare];
    
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowing:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHiding:) name:UIKeyboardWillHideNotification object:nil];
    // 键盘高度变化通知，ios5.0新增的
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowing:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif
     */
    
    _tbAction.backgroundView = [[UIView alloc]init];
    _tbAction.backgroundColor = [UIColor whiteColor];
    [_tbAction reloadData];
}

- (IBAction)onButtonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)validateContent:(NSMutableString **)errorin
{
    if (!errorin)
        *errorin = [@"" mutableCopy];
    NSMutableString *error = *errorin;
    if (_contentView.text.length<=0)
    {
        [error appendString:NSLocalizedString(@"USER_FEEDBACK_CONTENT_VALIDATE_ZERO", nil)];;
        return false;
    }
    else if (_contactField.text.length>0)
    {
        NSString *phone = _contactField.text;
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

- (IBAction)doSave:(id)sender {
    NSMutableString *error = [@"" mutableCopy];
    if([self validateContent:&error])
    {
        FSFeedbackRequest *request = [[FSFeedbackRequest alloc] init];
        request.userToken = currentUser.uToken;
        request.content = _contentView.text;
        request.phone = _contactField.text;
        [self beginLoading:self.view];
        [request send:[FSModelBase class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
            if (!resp.isSuccess)
            {
                [self reportError:resp.description];
            }
            else
            {
                [self reportError:resp.message];
                [_contentView resignFirstResponder];
                _contentView.text = @"";
                _contentView.placeholder = NSLocalizedString(@"Feedback content place holder", nil);
                [_contentView setNeedsDisplay];
                [_contactField resignFirstResponder];
                _contactField.text = @"";
            }
            [self endLoading:self.view];
        }];
    }
    else
    {
        [self reportError:error];
    }
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

#pragma UITableViewController delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 110;
    }
    else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 60;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 30;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, 60)];
        view.backgroundColor = [UIColor clearColor];
        UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(13, 5, APP_WIDTH-26, 50)];
        desc.text = NSLocalizedString(@"Feedback tip message", nil);
        desc.font = [UIFont systemFontOfSize:14];
        desc.numberOfLines = 0;
        desc.textColor = RGBCOLOR(83, 90, 109);
        desc.lineBreakMode = UILineBreakModeCharacterWrap;
        desc.backgroundColor = [UIColor clearColor];
        [view addSubview:desc];
        return view;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        int xOffset = 5;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, 60)];
        view.backgroundColor = [UIColor clearColor];
        UILabel *_contactLb = [[UILabel alloc] initWithFrame:CGRectMake(13, xOffset + 8, 0, 35)];
        _contactLb.text = NSLocalizedString(@"Contact method", nil);
        _contactLb.font = [UIFont systemFontOfSize:14];
        _contactLb.textColor = RGBCOLOR(83, 90, 109);
        [_contactLb sizeToFit];
        [view addSubview:_contactLb];
        
        if (!_contactField) {
            int xStart = _contactLb.frame.origin.x + _contactLb.frame.size.width + xOffset;
            _contactField= [[UITextField alloc] initWithFrame:CGRectMake(xStart, xOffset+2, Table_Cell_Width - xStart + 15, 31)];
            _contactField.placeholder = NSLocalizedString(@"Contact place holder", nil);
            _contactField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            _contactField.delegate = self;
            _contactField.borderStyle = UITextBorderStyleNone;
            _contactField.returnKeyType = UIReturnKeySend;
            _contactField.layer.borderWidth = 1;
            _contactField.layer.borderColor = RGBCOLOR(166, 166, 166).CGColor;
            _contactField.keyboardType = UIKeyboardTypeNumberPad;
            _contactField.font = [UIFont systemFontOfSize:14];
            _contactField.backgroundColor = RGBCOLOR(245,245,245);
            _contactField.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
        [view addSubview:_contactField];
        return view;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    int xOffset = 5;
    switch (indexPath.section) {
        case 0:
        {
            if (!_contentView) {
                _contentView= [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(xOffset, xOffset, Table_Cell_Width - xOffset*2, 100)];
                _contentView.backgroundColor = [UIColor clearColor];
                _contentView.placeholder = NSLocalizedString(@"Feedback content place holder", nil);
                _contentView.placeholderColor = [UIColor colorWithRed:142/255.0f green:142/255.0f blue:142/255.0f alpha:1.0f];
                _contentView.delegate = self;
                _contentView.returnKeyType = UIReturnKeyDefault;
                _contentView.keyboardType = UIKeyboardTypeNamePhonePad;
                _contentView.scrollEnabled = YES;
                _contentView.font = [UIFont systemFontOfSize:14];
            }
            [cell.contentView addSubview:_contentView];
            cell.backgroundColor = RGBCOLOR(245, 245, 245);
        }
            break;
        default:
            break;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.5 animations:^{
        if (textField == _contactField) {
            if (SCREEN_HIGH <= 480) {
                self.tbAction.scrollEnabled = NO;
                [self.tbAction setContentOffset:CGPointMake(0, 45)];
            }
        }
    } completion:^(BOOL finished) {
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.5 animations:^{
        if (textField == _contactField) {
            if (SCREEN_HIGH <= 480) {
                self.tbAction.scrollEnabled = YES;
                [self.tbAction setContentOffset:CGPointMake(0, 0)];
            }
        }
    } completion:^(BOOL finished) {
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _contactField) {
        [textField resignFirstResponder];
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _contactField) {
        if (textField.text.length > 10 && ![string isEqualToString:@""]) {
            return NO;
        }
        else {
            return YES;
        }
    }
    return YES;
}

#pragma mark -
#pragma mark Responding to keyboard events
/*
- (void)keyboardWillShowing:(NSNotification *)notification {
    if (isKeyBourdShown) {
        return;
    }
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    CGRect rect = self.tbAction.frame;
    rect.size.height -= keyboardSize.height - 44;
    self.tbAction.frame = rect;
    [UIView commitAnimations];
    if (!isKeyBourdShown) {
        isKeyBourdShown = YES;
    }
}

- (void)keyboardWillHiding:(NSNotification *)notification {
    isKeyBourdShown = NO;
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    CGRect rect = self.tbAction.frame;
    rect.size.height += keyboardSize.height - 44;
    self.tbAction.frame = rect;
    [UIView commitAnimations];
}
*/
@end

@implementation UIPlaceHolderTextView

@synthesize placeHolderLabel;
@synthesize placeholder;
@synthesize placeholderColor;

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setPlaceholder:@""];
    [self setPlaceholderColor:[UIColor lightGrayColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    if( (self = [super initWithFrame:frame]) )
    {
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0)
    {
        return;
    }
    
    if([[self text] length] == 0)
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    else
    {
        [[self viewWithTag:999] setAlpha:0];
    }
}

- (void)drawRect:(CGRect)rect
{
    if( [[self placeholder] length] > 0 )
    {
        if ( placeHolderLabel == nil )
        {
            placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8,8,self.bounds.size.width - 16,0)];
            placeHolderLabel.lineBreakMode = UILineBreakModeWordWrap;
            placeHolderLabel.numberOfLines = 0;
            placeHolderLabel.font = self.font;
            placeHolderLabel.backgroundColor = [UIColor clearColor];
            placeHolderLabel.textColor = self.placeholderColor;
            placeHolderLabel.alpha = 0;
            placeHolderLabel.tag = 999;
            [self addSubview:placeHolderLabel];
        }
        
        placeHolderLabel.text = self.placeholder;
        [placeHolderLabel sizeToFit];
        [self sendSubviewToBack:placeHolderLabel];
    }
    
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    [super drawRect:rect];
}

@end
