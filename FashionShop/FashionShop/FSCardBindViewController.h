//
//  FSCardBindViewController.h
//  FashionShop
//
//  Created by HeQingshan on 13-3-11.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSUser.h"

@interface FSCardBindViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *bindView;
@property (strong, nonatomic) IBOutlet UITextField *cardNumField;
@property (strong, nonatomic) IBOutlet UITextField *cardPwField;
@property (strong, nonatomic) IBOutlet UIButton *btnBindCard;
- (IBAction)bindCard:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *resultView;
@property (strong, nonatomic) IBOutlet UILabel *cardLevel;
@property (strong, nonatomic) IBOutlet UILabel *cardNum;
@property (strong, nonatomic) IBOutlet UILabel *cardPoint;
- (IBAction)unBindCard:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;

@property (strong, nonatomic) FSUser *currentUser;

@end
