//
//  FSProPostMainViewController.m
//  FashionShop
//
//  Created by gong yi on 11/30/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSProPostMainViewController.h"
#import "FSCommonProRequest.h"
#import "UIImageView+WebCache.h"
#import "FSStore.h"
#import "FSBrand.h"
#import "FSCoreBrand.h"
#import "FSCoreTag.h"
#import "FSProPostTitleViewController.h"
#import "FSPostTableSelViewController.h"
#import "UIViewController+Loading.h"
#import "FSProItemEntity.h"
#import "FSCoreStore.h"


@interface FSProPostMainViewController ()
{
    FSCommonProRequest  *_proRequest;
    NSMutableArray *_sections;
    NSMutableArray *_keySections;
    NSMutableDictionary *_rows;
    NSMutableDictionary *_rowDone;
    BOOL _originalTabbarStatus;
    
    TDDatePickerController* _datePicker;
    FSProPostTitleViewController *_titleSel;
    UIImagePickerController *camera;
    int _dateRowIndex;
    
    PostFields _availFields;
    int _totalFields;
    NSString * _route;
}

@end

@implementation FSProPostMainViewController
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
    if (self.navigationItem)
    {
        UIBarButtonItem *baritemCancel= [self createPlainBarButtonItem:@"goback_icon" target:self action:@selector(onButtonCancel)];
        UIBarButtonItem *baritemSet= [self createPlainBarButtonItem:@"ok_icon" target:self action:@selector(doSave)];
        [self.navigationItem setLeftBarButtonItem:baritemCancel];
        [self.navigationItem setRightBarButtonItem:baritemSet];
        [baritemSet setEnabled:false];
        
    }
    [self initActionsSource];
    [self bindControl];
}


-(void) initActionsSource
{
    _keySections = [@[NSLocalizedString(@"PRO_POST_IMG_LABEL", Nil),
                    NSLocalizedString(@"PRO_POST_TITLE_LABEL", Nil),
                    NSLocalizedString(@"PRO_POST_DURATION_LABEL", Nil),
                    NSLocalizedString(@"PRO_POST_BRAND_LABEL", Nil),
                    NSLocalizedString(@"PRO_POST_TAG_LABEL", Nil),
                    NSLocalizedString(@"PRO_POST_STORE_LABEL", Nil)
                    ] mutableCopy];
    _sections = [@[] mutableCopy];
    _totalFields = 0;
    if (_availFields & ImageField)
    {
        [_sections addObject:NSLocalizedString(@"PRO_POST_IMG_LABEL", Nil)];
        _totalFields++;
    }
    if (_availFields & TitleField)
    {
        [_sections addObject:NSLocalizedString(@"PRO_POST_TITLE_LABEL", Nil)];
        _totalFields++;
    }
    if (_availFields & DurationField)
    {
        [_sections addObject:NSLocalizedString(@"PRO_POST_DURATION_LABEL", Nil)];
        _totalFields+=2;
    }
    if (_availFields & BrandField)
    {
        [_sections addObject:NSLocalizedString(@"PRO_POST_BRAND_LABEL", Nil)];
        _totalFields++;
    }
    if (_availFields & TagField)
    {
        [_sections addObject:NSLocalizedString(@"PRO_POST_TAG_LABEL", Nil)];
        _totalFields++;
    }
    if (_availFields & StoreField)
    {
        [_sections addObject:NSLocalizedString(@"PRO_POST_STORE_LABEL", Nil)];
        _totalFields++;
    }
    
    _rows = [@{NSLocalizedString(@"PRO_POST_IMG_LABEL", Nil):NSLocalizedString(@"PRO_POST_IMG_NOTEXT", Nil),
             NSLocalizedString(@"PRO_POST_TITLE_LABEL", Nil):NSLocalizedString(@"PRO_POST_TITLE_NOTEXT", Nil),
            NSLocalizedString(@"PRO_POST_DURATION_LABEL", Nil):
                    [@[NSLocalizedString(@"PRO_POST_DURATION_STARTTEXT", Nil),NSLocalizedString(@"PRO_POST_DURATION_ENDTEXT", Nil)] mutableCopy],
            NSLocalizedString(@"PRO_POST_BRAND_LABEL", Nil):NSLocalizedString(@"PRO_POST_BRAND_NOTEXT", Nil),
            NSLocalizedString(@"PRO_POST_TAG_LABEL", Nil):NSLocalizedString(@"PRO_POST_TAG_NOTEXT", Nil),
            NSLocalizedString(@"PRO_POST_STORE_LABEL", Nil):NSLocalizedString(@"PRO_POST_STORE_NOTEXT", Nil),
            } mutableCopy];
    _rowDone = [@{} mutableCopy];
}

-(void) setAvailableFields:(PostFields)fields
{
    _availFields = fields;
}


-(void) setRoute:(NSString *)route
{
    _route = route;
}

-(void)onButtonCancel
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

-(void) bindControl
{
    self.navigationItem.title = NSLocalizedString(@"Publish product", nil);
    [self.view setBackgroundColor:[UIColor colorWithRed:229 green:229 blue:229]];
    [_tbAction setBackgroundView:nil];
    [_tbAction setBackgroundColor:[UIColor clearColor]];
    [self setProgress:PostBegin withObject:nil];
    _tbAction.dataSource = self;
    _tbAction.delegate = self;
    [_tbAction reloadData];
    
}

-(void) clearData
{
    _proRequest.img = nil;
    [self initActionsSource];
    [self bindControl];
}

-(void) internalDoSave:(dispatch_block_t) cleanup
{
    __block FSProPostMainViewController *blockSelf = self;
    [_proRequest upload:^{

        [blockSelf updateProgress:NSLocalizedString(@"COMM_OPERATE_COMPL",nil)];
        if (cleanup)
            cleanup();
        [blockSelf clearData];

    } error:^{

        [blockSelf updateProgress:NSLocalizedString(@"upload failed!", nil)];
        if (cleanup)
            cleanup();
    }];
}

-(void) doSave
{
    [self startProgress:NSLocalizedString(@"prodct uploading...", nil) withExeBlock:^(dispatch_block_t callback){
        [self internalDoSave:callback];
    } completeCallbck:^{
        [self endProgress];
    }];

}


-(void) setProgress:(PostProgressStep)step withObject:(id)value
{
    switch (step) {
        case PostBegin:
        {
            _proRequest = [[FSCommonProRequest alloc] init];
            _proRequest.uToken = currentUser.uToken;
            _proRequest.routeResourcePath = _route;

            break;
        }
        case PostStep1Finished:
        {
            _proRequest.img = (UIImage *)value[0];
            break;
        }
        case PostStep2Finished:
        {
            _proRequest.title = [(NSArray *)value objectAtIndex:0];
            _proRequest.descrip = [(NSArray *)value objectAtIndex:1];
            break;
        }
        case PostStep3Finished:
        {
            if (value)
            {
                if (_dateRowIndex == 0)
                    _proRequest.startdate = value[0];
                else
                    _proRequest.enddate = value[0];
            }
            break;
        }
        case PostStep4Finished:
        {
            _proRequest.brandId = [(FSCoreBrand *)value valueForKey:@"id"];
            _proRequest.brandName = [(FSCoreBrand *)value valueForKey:@"name"];
            break;
        }
        case PostStepStoreFinished:
        {
            _proRequest.storeId = [(FSStore *)value valueForKey:@"id"];
            _proRequest.storeName = [(FSStore *)value name];
            break;
        }
        case PostStepTagFinished:
        {
            _proRequest.tagId =[(FSCoreTag *)value valueForKey:@"id"];
            _proRequest.tagName = [(FSCoreTag *)value valueForKey:@"name"];
            break;
        }
        default:
            break;
    }
    _pvIndicator.progress = [self uploadPercent];
    [_pvIndicator setNeedsDisplay];
    if (_pvIndicator.progress>=1)
    {
        UIBarButtonItem *rightButton = self.navigationItem.rightBarButtonItem;
        [rightButton setEnabled:true];
    } else
    {
        UIBarButtonItem *rightButton = self.navigationItem.rightBarButtonItem;
        [rightButton setEnabled:false];
    }
}

-(float) uploadPercent
{
    int finishedFields = 0;
    int totalFields = _totalFields;
    _proRequest.img && (_availFields&ImageField)?finishedFields++:finishedFields;
    _proRequest.descrip && (_availFields&TitleField)?finishedFields++:finishedFields;
    _proRequest.startdate &&(_availFields & DurationField)?finishedFields++:finishedFields;
    _proRequest.enddate&&(_availFields &DurationField)?finishedFields++:finishedFields;
    _proRequest.brandId&&(_availFields &TagField)?finishedFields++:finishedFields;
    _proRequest.storeId&&(_availFields &StoreField)?finishedFields++:finishedFields;
    _proRequest.tagId&&(_availFields &TagField)?finishedFields++:finishedFields;
    return _totalFields==0?0:(float)finishedFields/(float)totalFields;

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doTakePhoto:(id)sender {
    if (!camera)
    {
        camera = [[UIImagePickerController alloc] init];
        camera.delegate = self;
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        camera.sourceType = UIImagePickerControllerSourceTypeCamera;
        camera.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        camera.allowsEditing = false;
        [self decorateOverlayToCamera:camera];
        [self presentViewController:camera animated:YES completion:nil];

    }
    else
    {
        NSLog(@"Camera not exist");
        return;
    }
    

}


- (IBAction)doTakeDescrip:(id)sender {
    if (!_titleSel)
        _titleSel = [[FSProPostTitleViewController alloc] initWithNibName:@"FSProPostTitleViewController" bundle:nil];
    _titleSel.delegate = self;
    [self presentSemiModalViewController:_titleSel];
    
    
}

- (IBAction)doSelStore:(id)sender {
    FSPostTableSelViewController *tableSelect = [[FSPostTableSelViewController alloc] initWithNibName:@"FSPostTableSelViewController" bundle:Nil];
    [ tableSelect setDataSource:^id{
        return [FSCoreStore allStoresLocal];
    } step:PostStepStoreFinished selectedCallbackTarget:self];
    tableSelect.navigationItem.title =NSLocalizedString(@"PRO_POST_STORE_NOTEXT", nil);
    [self.navigationController pushViewController:tableSelect animated:TRUE];

}

- (IBAction)doSelBrand:(id)sender {
    FSPostTableSelViewController *tableSelect = [[FSPostTableSelViewController alloc] initWithNibName:@"FSPostTableSelViewController" bundle:Nil];
    [ tableSelect setDataSource:^id{
        return [FSBrand allBrandsLocal];
    } step:PostStep4Finished selectedCallbackTarget:self];
    tableSelect.navigationItem.title =NSLocalizedString(@"PRO_POST_BRAND_NOTEXT", nil);
    [self.navigationController pushViewController:tableSelect animated:TRUE];}

-(void)doSelTag:(id)sender
{
    FSPostTableSelViewController *tableSelect = [[FSPostTableSelViewController alloc] initWithNibName:@"FSPostTableSelViewController" bundle:Nil];
   [ tableSelect setDataSource:^id{
       return [FSCoreTag findAllSortedBy:@"name" ascending:TRUE];
   } step:PostStepTagFinished selectedCallbackTarget:self];
    tableSelect.navigationItem.title =NSLocalizedString(@"PRO_POST_TAG_NOTEXT", nil);
    [self.navigationController pushViewController:tableSelect animated:TRUE];
}

-(void)doSelDuration:(id)sender{
    if (!_datePicker)
        _datePicker = [[TDDatePickerController alloc] initWithNibName:@"TDDatePickerController" bundle:nil];
    _datePicker.delegate = self;
    [self presentSemiModalViewController:_datePicker];
}

#pragma FSProPostStepCompleteDelegate
-(void)proPostStep:(PostProgressStep)step didCompleteWithObject:(NSArray *)object
{
    [self setProgress:step withObject:object];
    switch (step) {
        case PostStep1Finished:
        {
            //[_rows setValue:[object objectAtIndex:0] forKey:NSLocalizedString(@"PRO_POST_IMG_LABEL", Nil)];
            [_tbAction reloadData];
            break;
        }
        case PostStep2Finished:
        {
            [_rows setValue:_proRequest.title forKey:NSLocalizedString(@"PRO_POST_TITLE_LABEL", Nil)];
            [_tbAction reloadData];
            break;
        }
        case PostStep3Finished:
        {
            NSDateFormatter *formater = [[NSDateFormatter alloc] init];
            [formater setDateFormat:@"yyyy/MM/dd"];
            if (_dateRowIndex==0 && _proRequest.startdate)
            {
                [(NSMutableArray *)[_rows objectForKey:NSLocalizedString(@"PRO_POST_DURATION_LABEL", Nil)] replaceObjectAtIndex:0 withObject:[formater stringFromDate:_proRequest.startdate]] ;
                 [_tbAction reloadData];
            } else if(_dateRowIndex == 1 && _proRequest.enddate)
            {
                 [(NSMutableArray *)[_rows objectForKey:NSLocalizedString(@"PRO_POST_DURATION_LABEL", Nil)] replaceObjectAtIndex:1 withObject:[formater stringFromDate:_proRequest.enddate]] ;
                 [_tbAction reloadData];
            }
                       
            break;
        }
        case PostStep4Finished:
        {
            [_rows setValue:_proRequest.brandName forKey:NSLocalizedString(@"PRO_POST_BRAND_LABEL", Nil)];
            [_tbAction reloadData];
            break;
        }
        case PostStepTagFinished:
        {
            [_rows setValue:_proRequest.tagName forKey:NSLocalizedString(@"PRO_POST_TAG_LABEL", Nil)];
            [_tbAction reloadData];
            break;
        }
        case PostStepStoreFinished:
        {
            [_rows setValue:_proRequest.storeName forKey:NSLocalizedString(@"PRO_POST_STORE_LABEL", Nil)];
            [_tbAction reloadData];
            break;
        }
       
        default:
            break;
    }
  
}

#pragma UITableViewSource delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return _sections.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![NSLocalizedString(@"PRO_POST_DURATION_LABEL", Nil) isEqualToString:[_sections objectAtIndex:section]])
        return 1;
    else
        return [[_rows objectForKey:[_sections objectAtIndex:section]] count];
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_sections objectAtIndex:section];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *detailCell =  [tableView dequeueReusableCellWithIdentifier:@"defaultcell"];
    if (!detailCell)
    {
        detailCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultcell"];
    }
    detailCell.imageView.image = nil;
    detailCell.textLabel.text = nil;
    id detailText = [_rows objectForKey:[_sections objectAtIndex:indexPath.section]];
    int keyIndex = [_keySections indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        BOOL match = [[_sections objectAtIndex:indexPath.section] isEqualToString:obj];
        *stop = match;
        return match;
    }];
    switch (keyIndex) {
        case 0:
        {
            if (_proRequest.img)
            {
                detailCell.imageView.image = _proRequest.img;
                detailCell.textLabel.text = @"";
            }
            else
            {
                detailCell.imageView.image = nil;
                detailCell.textLabel.text = detailText;
            }
            break;
        }
        case 1:
        case 3:
        case 4:
        case 5:
        {
            detailCell.textLabel.text = detailText;
            break;

        }
        case 2:
        {
            detailCell.textLabel.text = [detailText objectAtIndex:indexPath.row];
        }
        default:
            break;
    }
    return detailCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int keyIndex = [_keySections indexOfObject:[_sections objectAtIndex:indexPath.section]];

    switch (keyIndex*10+indexPath.row) {
        case 0:
        {
            [self doTakePhoto:nil];
            break;
        }
        case 10:
        {
            [self doTakeDescrip:nil];
            break;
        }
        case 20:
        case 21:
        {
            _dateRowIndex = indexPath.row;
            [self doSelDuration:nil];
            break;
        }
        case 30:
        {
            [self doSelBrand:nil];
            break;
        }
        case 40:
        {
            [self doSelTag:nil];
            break;
        }
        case 50:
        {
            [self doSelStore:nil];
            break;
        }
        default:
            break;
    }
}

#pragma UIImagePicker delegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];  
	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	
	if([mediaType isEqualToString:@"public.image"])
	{
		UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

        [NSThread detachNewThreadSelector:@selector(cropImage:) toTarget:self withObject:image];
            }
	else
	{
		NSLog(@"Error media type");
		return;
	}
}
- (void)cropImage:(UIImage *)image {
    // Create a graphics image context
    CGSize newSize = CGSizeMake(320, 480);
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    [self proPostStep:PostStep1Finished didCompleteWithObject:@[newImage]];

}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];  
    return;
}
-(UIImagePickerController*) inUserCamera
{
    return  camera;
}
#pragma TDDatePickerControllerDelegate
- (void)datePickerSetDate:(TDDatePickerController *)viewController
{
    [self proPostStep:PostStep3Finished didCompleteWithObject:@[_datePicker.datePicker.date]];
    [self dismissSemiModalViewController:_datePicker];

    
}

- (void)datePickerCancel:(TDDatePickerController *)viewController
{
    [self proPostStep:PostStep3Finished didCompleteWithObject:nil];
    [self dismissSemiModalViewController:_datePicker];
}

#pragma titleViewControllerDelegate
-(void)titleViewControllerCancel:(FSProPostTitleViewController *)viewController
{
    [self dismissSemiModalViewController:_titleSel];
}
-(void)titleViewControllerSetTitle:(FSProPostTitleViewController *)viewController
{
    [self proPostStep:PostStep2Finished didCompleteWithObject:@[viewController.txtTitle.text,viewController.txtDesc.text]];
    [self dismissSemiModalViewController:_titleSel];
}

@end
