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
#import "FSGroupBrand.h"
#import "FSCoreBrand.h"
#import "FSCoreTag.h"
#import "FSProPostTitleViewController.h"
#import "FSPostTableSelViewController.h"
#import "UIViewController+Loading.h"
#import "FSProItemEntity.h"
#import "FSCoreStore.h"
#import "FSImageUploadCell.h"
#import "NSString+Extention.h"

#define EXIT_ALERT_TAG 1011
#define SAVE_INFO_TAG 1012


@interface FSProPostMainViewController ()
{
    FSCommonProRequest  *_proRequest;
    NSMutableArray *_sections;
    NSMutableArray *_keySections;
    NSMutableDictionary *_rows;
    NSMutableDictionary *_rowDone;
    BOOL _originalTabbarStatus;
    
    TDDatePickerController* _datePicker;
    TDDatePickerController* _dateEndPicker;
    FSProPostTitleViewController *_titleSel;
    UIImagePickerController *camera;
    int _dateRowIndex;
    
    PostFields _availFields;
    PostFields _mustFields;
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
                    NSLocalizedString(@"PRO_POST_STORE_LABEL", Nil)
                    ] mutableCopy];
    _sections = [@[] mutableCopy];
    _totalFields = 0;
    if (_availFields & ImageField)
    {
        [_sections addObject:NSLocalizedString(@"PRO_POST_IMG_LABEL", Nil)];
        if (_mustFields & ImageField)
            _totalFields++;
    }
    if (_availFields & TitleField)
    {
        [_sections addObject:NSLocalizedString(@"PRO_POST_TITLE_LABEL", Nil)];
         if (_mustFields & TitleField)
        _totalFields++;
    }
    if (_availFields & DurationField)
    {
        [_sections addObject:NSLocalizedString(@"PRO_POST_DURATION_LABEL", Nil)];
         if (_mustFields & DurationField)
             _totalFields+=2;
    }
    if (_availFields & BrandField)
    {
        [_sections addObject:NSLocalizedString(@"PRO_POST_BRAND_LABEL", Nil)];
         if (_mustFields & BrandField)
        _totalFields++;
    }
    if (_availFields & StoreField)
    {
        [_sections addObject:NSLocalizedString(@"PRO_POST_STORE_LABEL", Nil)];
         if (_mustFields & StoreField)
        _totalFields++;
    }
    
    _rows = [@{NSLocalizedString(@"PRO_POST_IMG_LABEL", Nil):NSLocalizedString(@"PRO_POST_IMG_NOTEXT", Nil),
             NSLocalizedString(@"PRO_POST_TITLE_LABEL", Nil):NSLocalizedString(@"PRO_POST_TITLE_NOTEXT", Nil),
            NSLocalizedString(@"PRO_POST_DURATION_LABEL", Nil):
                    [@[NSLocalizedString(@"PRO_POST_DURATION_STARTTEXT", Nil),NSLocalizedString(@"PRO_POST_DURATION_ENDTEXT", Nil)] mutableCopy],
            NSLocalizedString(@"PRO_POST_BRAND_LABEL", Nil):NSLocalizedString(@"PRO_POST_BRAND_NOTEXT", Nil),
            NSLocalizedString(@"PRO_POST_STORE_LABEL", Nil):NSLocalizedString(@"PRO_POST_STORE_NOTEXT", Nil),
            } mutableCopy];
    _rowDone = [@{} mutableCopy];
}

-(void) setAvailableFields:(PostFields)fields
{
    _availFields = fields;
}

-(void) setMustFields:(PostFields)fields
{
    _mustFields = fields;
}

-(void) setRoute:(NSString *)route
{
    _route = route;
}

-(void)onButtonCancel
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warm prompt",nil) message:NSLocalizedString(@"Exit Upload", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    alert.tag = EXIT_ALERT_TAG;
    [alert show];
}

-(void) bindControl
{

    [self.view setBackgroundColor:[UIColor colorWithRed:229 green:229 blue:229]];
    [_tbAction setBackgroundView:nil];
    [_tbAction setBackgroundColor:[UIColor clearColor]];
    [_tbAction registerNib:[UINib nibWithNibName:@"FSImageUploadCell" bundle:nil] forCellReuseIdentifier:@"imageuploadcell"];
    [self setProgress:PostBegin withObject:nil];
    _tbAction.dataSource = self;
    _tbAction.delegate = self;
    [_tbAction reloadData];
}

-(void) clearData
{
    _proRequest.imgs = nil;
    [self initActionsSource];
    [self bindControl];
}

-(void) internalDoSave:(dispatch_block_t) cleanup
{
    __block FSProPostMainViewController *blockSelf = self;
    [_proRequest upload:^{
        //如果是上传活动成功，则返回活动id，在客户端显示
        if (self.publishSource == FSSourcePromotion) {
            UIAlertView *_alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warm prompt", nil) message:[NSString stringWithFormat:NSLocalizedString(@"Take_Care_Invoice:%@", nil), _proRequest.pID] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [_alert show];
        }
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
    NSMutableString *error = [@"" mutableCopy];
    if (_publishSource == FSSourcePromotion) {
        if(![self validateDate:&error])
        {
            [self reportError:error];
        }
    }
    //做预发布
    NSMutableString *_msg = [NSMutableString string];
    [_msg appendFormat:@"标题:%@\n", _proRequest.title];
    [_msg appendFormat:@"描述信息:%@\n", _proRequest.descrip];
    if (_publishSource == FSSourceProduct) {
        [_msg appendFormat:@"价格:￥%@\n", _proRequest.price];
        [_msg appendFormat:@"品牌名称:%@\n", _proRequest.brandName];
    }
    else {
        [_msg appendFormat:@"活动开始时间:%@\n", _proRequest.startdate];
        [_msg appendFormat:@"活动结束时间:%@\n", _proRequest.enddate];
    }
    [_msg appendFormat:@"门店名称:%@", _proRequest.storeName];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Content Preview",nil) message:_msg delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    alert.tag = SAVE_INFO_TAG;
    [alert show];
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
            if (!_proRequest.imgs)
                _proRequest.imgs = [@[] mutableCopy];
            if (value && [value count]>0)
                [_proRequest.imgs addObject:(UIImage *)value[0]];
            else
                [_proRequest.imgs removeAllObjects];
            //disable photo button if more than 3 imags
            if (_proRequest.imgs.count>=3)
                _btnPhoto.enabled = FALSE;
            else
                _btnPhoto.enabled = TRUE;
            break;
        }
        case PostStep2Finished:
        {
            _proRequest.title = [(NSArray *)value objectAtIndex:0];
            _proRequest.descrip = [(NSArray *)value objectAtIndex:1];
            NSString *price = [(NSArray *)value objectAtIndex:2];
            
            _proRequest.price =[NSNumber numberWithInt:[price intValue]];
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
    if ([self uploadPercent]>=1)
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
    _proRequest.imgs &&_proRequest.imgs.count>0 && (_mustFields&ImageField)?finishedFields++:finishedFields;
    _proRequest.title && (_mustFields&TitleField)?finishedFields++:finishedFields;
    _proRequest.startdate &&(_mustFields & DurationField)?finishedFields++:finishedFields;
    _proRequest.enddate&&(_mustFields &DurationField)?finishedFields++:finishedFields;
    _proRequest.brandId&&(_mustFields &TagField)?finishedFields++:finishedFields;
    _proRequest.storeId&&(_mustFields &StoreField)?finishedFields++:finishedFields;
    _proRequest.tagId&&(_mustFields &TagField)?finishedFields++:finishedFields;
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
        [UIView animateWithDuration:0.2 animations:nil completion:^(BOOL finished) {
            [self presentViewController:camera animated:YES completion:nil];
        }];
    }
    else
    {
        [self reportError:NSLocalizedString(@"Can Not Camera", nil)];
        return;
    }
}
-(void)didImageRemoveAll
{
    [self proPostStep:PostStep1Finished didCompleteWithObject:nil];
}

- (IBAction)doTakeDescrip:(id)sender {
    if (!_titleSel)
        _titleSel = [[FSProPostTitleViewController alloc] initWithNibName:@"FSProPostTitleViewController" bundle:nil];
    _titleSel.delegate = self;
    _titleSel.publishSource = _publishSource;
    [self presentViewController:_titleSel animated:TRUE completion:nil];
    
    
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
        //return [FSBrand allBrandsLocal];
        return [FSGroupBrandList allBrandsLocal];
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
    if (_dateRowIndex == 0) {
        if (!_datePicker) {
            _datePicker = [[TDDatePickerController alloc] init];
            _datePicker.delegate = self;
        }
        //_datePicker.datePicker.minimumDate = [NSDate date];
        [self presentSemiModalViewController:_datePicker];
    }
    else {
        if (!_dateEndPicker) {
            _dateEndPicker = [[TDDatePickerController alloc] init];
            _dateEndPicker.delegate = self;
        }
        //_dateEndPicker.datePicker.minimumDate = [NSDate date];
        [self presentSemiModalViewController:_dateEndPicker];
    }
}

#pragma FSProPostStepCompleteDelegate
-(void)proPostStep:(PostProgressStep)step didCompleteWithObject:(NSArray *)object
{
    [self setProgress:step withObject:object];
    switch (step) {
        case PostStep1Finished:
        {
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
            [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
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
    int keyIndex = [_keySections indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        BOOL match = [[_sections objectAtIndex:section] isEqualToString:obj];
        *stop = match;
        return match;
    }];
    switch (keyIndex) {
       // case 0:
       //     return _proRequest.imgs?_proRequest.imgs.count:1;
        case 2:
            return [[_rows objectForKey:[_sections objectAtIndex:section]] count];
        default:
            return 1;
    }
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
            if (_proRequest.imgs &&
                _proRequest.imgs.count>0)
            {
                detailCell = [tableView dequeueReusableCellWithIdentifier:@"imageuploadcell"];
                [(FSImageUploadCell *)detailCell setImages:_proRequest.imgs];
                [(FSImageUploadCell *)detailCell setImageRemoveDelegate:self];
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
            [self doSelStore:nil];
            break;
        }
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int keyIndex = [_keySections indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        BOOL match = [[_sections objectAtIndex:indexPath.section] isEqualToString:obj];
        *stop = match;
        return match;
    }];
    if (keyIndex==0 &&
        _proRequest.imgs.count>0)
    {
        return floor((_proRequest.imgs.count+2)/3)*150;
    }
    else
    {
        return tableView.rowHeight;
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
    CGSize newSize = image.size;
    newSize = CGSizeMake(640*RetinaFactor, 640*RetinaFactor*image.size.height/image.size.width);
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
#pragma mark - TDDatePickerControllerDelegate
- (void)datePickerSetDate:(TDDatePickerController *)viewController
{
    [self proPostStep:PostStep3Finished didCompleteWithObject:@[viewController.datePicker.date]];
    [self dismissSemiModalViewController:viewController];
}

- (void)datePickerCancel:(TDDatePickerController *)viewController
{
    [self proPostStep:PostStep3Finished didCompleteWithObject:nil];
    [self dismissSemiModalViewController:viewController];
}

#pragma titleViewControllerDelegate
-(void)titleViewControllerCancel:(FSProPostTitleViewController *)viewController
{
    [viewController dismissViewControllerAnimated:TRUE completion:nil];
}
-(void)titleViewControllerSetTitle:(FSProPostTitleViewController *)viewController
{
    NSMutableString *_desc = [NSMutableString stringWithFormat:@"%@", viewController.txtDesc.text];
    if (_publishSource == FSSourceProduct) {
        if (![NSString isNilOrEmpty:viewController.txtProDesc.text]) {
            [_desc appendFormat:@"。\n参与活动:%@", viewController.txtProDesc.text];
        }
        if (![NSString isNilOrEmpty:viewController.txtProStartTime.text]) {
            [_desc appendFormat:@"。\n活动有效期:%@ ~ ", viewController.txtProStartTime.text];
            if (![NSString isNilOrEmpty:viewController.txtProEndTime.text]) {
                [_desc appendFormat:@"%@", viewController.txtProEndTime.text];
            }
            else {
                [_desc appendFormat:@"%@", @"Error"];
            }
        }
    }
    NSLog(@"desc:%@", _desc);
    [self proPostStep:PostStep2Finished didCompleteWithObject:@[viewController.txtTitle.text, _desc, viewController.txtPrice.text]];
    [viewController dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)viewDidUnload {
    [self setBtnPhoto:nil];
    [super viewDidUnload];
}

#pragma UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == EXIT_ALERT_TAG && buttonIndex == 1) {
        [self dismissViewControllerAnimated:TRUE completion:nil];
    }
    if (alertView.tag == SAVE_INFO_TAG && buttonIndex == 1) {
        [self startProgress:NSLocalizedString(@"prodct uploading...", nil) withExeBlock:^(dispatch_block_t callback){
            [self internalDoSave:callback];
        } completeCallbck:^{
            [self endProgress];
            [[NSNotificationCenter defaultCenter] postNotificationName:LN_ITEM_UPDATED object:nil];
        }];
    }
}

- (BOOL)validateDate:(NSMutableString **)errorin
{
    if (!errorin)
        *errorin = [@"" mutableCopy];
    NSMutableString *error = *errorin;
    if([_dateEndPicker.datePicker.date compare:_datePicker.datePicker.date] != NSOrderedDescending)
    {
        [error appendString:NSLocalizedString(@"PRO_POST_DURATION_DATE_VALIDATE", nil)];;
        return false;
    }
    return true;
}

@end
