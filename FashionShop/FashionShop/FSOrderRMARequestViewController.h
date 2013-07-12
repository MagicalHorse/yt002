//
//  FSOrderRMARequestViewController.h
//  FashionShop
//
//  Created by HeQingshan on 13-7-1.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPlaceHoldTextView.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "FSOrder.h"

@interface FSOrderRMARequestViewController : UIViewController

@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *contentView;
@property (strong, nonatomic) IBOutlet FSPlaceHoldTextView *reason;
@property (strong, nonatomic) IBOutlet UITextField *bankName;
@property (strong, nonatomic) IBOutlet UITextField *bankNumber;
@property (strong, nonatomic) IBOutlet UITextField *bankUserName;
@property (strong, nonatomic) IBOutlet UITextField *telephone;
@property (strong, nonatomic) IBOutlet UIButton *submitBtn;

@property (strong, nonatomic) FSOrderRMAItem *rmaData;

@property (nonatomic,strong) NSString *orderno;
- (IBAction)requestRMA:(id)sender;

@property (nonatomic,strong) id delegate;

@end

@interface NSObject(FSOrderRMARequestViewControllerDelegate)

-(void)refreshViewController:(UIViewController*)controller needRefresh:(BOOL)flag;
@end
