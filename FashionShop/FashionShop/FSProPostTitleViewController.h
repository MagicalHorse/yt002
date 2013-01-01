//
//  FSProPostTitleViewController.h
//  FashionShop
//
//  Created by gong yi on 12/1/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCommonProRequest.h"
#import "TDSemiModalViewController.h"

@protocol FSProPostTitleViewControllerDelegate;

@interface FSProPostTitleViewController : TDSemiModalViewController<UITextFieldDelegate,UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextField *txtTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblDescName;

@property (strong, nonatomic) IBOutlet UITextView *txtDesc;
- (IBAction)doSave:(id)sender;

- (IBAction)doCancel:(id)sender;

@property (strong,nonatomic) id delegate;

@end

@interface NSObject (FSProPostTitleViewControllerDelegate)
-(void)titleViewControllerSetTitle:(FSProPostTitleViewController*)viewController;
-(void)titleViewControllerCancel:(FSProPostTitleViewController*)viewController;
@end