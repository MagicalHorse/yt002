//
//  FSNickieViewController.h
//  FashionShop
//
//  Created by gong yi on 11/30/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSUser.h"

@interface FSNickieViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *txtNicke;
- (IBAction)doSave:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *txtPhone;

@property (strong, nonatomic) FSUser *currentUser;
@end
