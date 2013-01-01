//
//  FSProPostMainViewController.h
//  FashionShop
//
//  Created by gong yi on 11/30/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "FSUser.h"
#import "TDSemiModal.h"
#import "TDDatePickerController.h"

typedef enum{
    PostBegin,
    PostStep1Finished,
    PostStep2Finished,
    PostStep3Finished,
    PostStep4Finished,
    PostStepTagFinished,
    PostStepStoreFinished
} PostProgressStep;

typedef enum{
    ImageField = 1,
    TitleField = 1<<1,
    DurationField = 1<<2,
    StoreField = 1<<3,
    BrandField = 1<<4,
    TagField = 1<<5
    
} PostFields;


@protocol FSProPostStepCompleteDelegate <NSObject>

-(void) proPostStep:(PostProgressStep)step didCompleteWithObject:(NSArray *)object;

@end

@interface FSProPostMainViewController : UIViewController<UIImagePickerControllerDelegate,UITableViewDataSource,UITableViewDelegate,FSProPostStepCompleteDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imgPhoto;
@property (strong, nonatomic) IBOutlet UIProgressView *pvIndicator;

@property (strong, nonatomic) IBOutlet UITableView *tbAction;



- (IBAction)doTakePhoto:(id)sender;
- (IBAction)doTakeDescrip:(id)sender;
- (IBAction)doSelStore:(id)sender;

- (IBAction)doSelBrand:(id)sender;


@property (strong, nonatomic) FSUser *currentUser;

-(void) setAvailableFields:(PostFields)fields;

-(void) setRoute:(NSString *)route;
@end

