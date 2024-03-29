//
//  FSProPostTitleViewController.m
//  FashionShop
//
//  Created by gong yi on 12/1/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSProPostTitleViewController.h"
#import "UIViewController+Loading.h"
#import "FSProPostMainViewController.h"

@interface FSProPostTitleViewController ()
{
    UIView *backView;
}

@end

@implementation FSProPostTitleViewController

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
    [self decorateTapDismissKeyBoard];
    [self bindControl];
}

-(void) decorateTapDismissKeyBoard
{
    backView = [[UIView alloc] initWithFrame:self.view.frame];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKB)];
    [backView addGestureRecognizer:recognizer];
    [self.view addSubview:backView];
    [self.view sendSubviewToBack:backView];
}

- (void) bindControl
{
    if (self.navigationItem)
    {
        self.navigationItem.title = NSLocalizedString(@"Fill title", nil);
    }
    _lblName.font = ME_FONT(14);
    _lblName.textColor = [UIColor colorWithRed:76 green:86 blue:108];
    _lblName.textAlignment = NSTextAlignmentRight;
    _lblDescName.font = ME_FONT(14);
    _lblDescName.textColor = [UIColor colorWithRed:76 green:86 blue:108];
    _lblDescName.textAlignment = NSTextAlignmentRight;
    [_txtTitle setBackgroundColor:[UIColor colorWithRed:247 green:247 blue:247]];
    _txtTitle.layer.borderWidth = 1;
    _txtTitle.layer.borderColor = [UIColor colorWithRed:222 green:222 blue:222].CGColor;
    _txtTitle.placeholder =NSLocalizedString(@"only 40 chars allowed", nil);
    [_txtDesc setBackgroundColor:[UIColor colorWithRed:247 green:247 blue:247]];
    _txtDesc.layer.borderWidth = 2;
    _txtDesc.layer.borderColor = [UIColor colorWithRed:222 green:222 blue:222].CGColor;
    if (_publishSource==FSSourceProduct)
    {
        _lblPrice.font = ME_FONT(14);
        _lblPrice.textColor = [UIColor colorWithRed:76 green:86 blue:108];;
        _lblPrice.textAlignment = NSTextAlignmentRight;
        [_txtPrice setBackgroundColor:[UIColor colorWithRed:247 green:247 blue:247]];
        _txtPrice.layer.borderWidth = 1;
        _txtPrice.layer.borderColor = [UIColor colorWithRed:222 green:222 blue:222].CGColor;
        _txtPrice.delegate = self;
    } else
    {
        _lblPrice.layer.opacity = 0;
        _txtPrice.layer.opacity = 0;
    }
    _txtTitle.delegate = self;
    _txtDesc.delegate = self;
    
}


-(BOOL) checkInput
{
    if (!(_txtTitle.text.length>0 &&
        _txtTitle.text.length<40))
    {
        [self reportError:NSLocalizedString(@"PRO_POST_TITLE_LENGTH_ERROR", nil)];
        return FALSE;
    }
    return YES;

    
}

-(void) dismissKB
{
    if ([_txtTitle isFirstResponder])
        [_txtTitle resignFirstResponder];
    else if ([_txtDesc isFirstResponder])
    {
        [_txtDesc resignFirstResponder];
    } else if ([_txtPrice isFirstResponder])
    {
        [_txtPrice resignFirstResponder];
    }

}

#pragma uitextfielddelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField != _txtPrice) {
        return YES;
    }
    if ([string isEqualToString:@""]) {
        return YES;
    }
    if (textField.text.length > 7) {
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doSave:(id)sender {
    if ([self checkInput])
    {
        if ([delegate respondsToSelector:@selector(titleViewControllerSetTitle:)])
        {
            [delegate titleViewControllerSetTitle:self];
        } 
    }

}

- (IBAction)doCancel:(id)sender {
    if([delegate respondsToSelector:@selector(titleViewControllerCancel:)])
    {
        [delegate titleViewControllerCancel:self];
    }
}
- (void)viewDidUnload {
    [self setLblName:nil];
    [self setLblDescName:nil];
    [self setLblPrice:nil];
    [self setTxtPrice:nil];
    [super viewDidUnload];
}
@end
