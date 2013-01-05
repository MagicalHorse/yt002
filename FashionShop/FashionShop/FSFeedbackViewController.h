//
//  FSFeedbackViewController.h
//  FashionShop
//
//  Created by HeQingshan on 13-1-3.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSUser.h"

//带有placeholder的UITextView
@interface UIPlaceHolderTextView : UITextView {
    NSString *placeholder;
    UIColor *placeholderColor;
    
@private
    UILabel *placeHolderLabel;
}

@property (nonatomic, strong) UILabel *placeHolderLabel;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end

@interface FSFeedbackViewController : UIViewController<UITextViewDelegate,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tbAction;

@property (strong, nonatomic) FSUser *currentUser;

@end
