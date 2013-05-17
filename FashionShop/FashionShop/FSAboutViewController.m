//
//  FSAboutViewController.m
//  FashionShop
//
//  Created by HeQingshan on 13-5-12.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSAboutViewController.h"
#import "UIDevice+Extention.h"

@interface FSAboutViewController ()

@end

@implementation FSAboutViewController

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
    self.title = NSLocalizedString(@"About Love Intime", nil);
    
    UIBarButtonItem *baritemCancel = [self createPlainBarButtonItem:@"goback_icon.png" target:self action:@selector(onButtonBack:)];
    [self.navigationItem setLeftBarButtonItem:baritemCancel];
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    _versionLb.text = [NSString stringWithFormat:@"喜欢银泰 V%@", [infoDict objectForKey:@"CFBundleVersion"]];
    self.view.backgroundColor = APP_TABLE_BG_COLOR;
    
    _verView.layer.borderWidth = 0;
    _verView.layer.cornerRadius = 10;
    _verView.backgroundColor = [UIColor whiteColor];
    [self.view bringSubviewToFront:_verView];
    
    if ([UIDevice isRunningOniPhone5]) {
        CGRect _rect = _verView.frame;
        _rect.origin.y += 44;
        _verView.frame = _rect;
        
        _rect = _desc.frame;
        _rect.origin.y += 44;
        _desc.frame = _rect;
    }
}

- (IBAction)onButtonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setVersionLb:nil];
    [self setVerView:nil];
    [self setDesc:nil];
    [super viewDidUnload];
}
@end
