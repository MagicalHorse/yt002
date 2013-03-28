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
#import "NSString+Extention.h"
#import "CL_VoiceEngine.h"

@interface FSProPostTitleViewController ()
{
    UIView *backView;
    TDDatePickerController* _datePicker;
    TDDatePickerController* _dateEndPicker;
    id activityObject;
    
    RecordState _recordState;
    CL_AudioRecorder* _audioRecoder;
    BOOL              _isRecording;
    NSDate* _downTime;//按下时间
    NSInteger _minRecordGap;//最小录制时间间隔
    
    AVAudioPlayer * _player;
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
    
    _minRecordGap = 1;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_txtTitle becomeFirstResponder];
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
        self.navigationItem.title = NSLocalizedString(@"PRO_POST_TITLE_LABEL", nil);
    }
    _lblName.font = ME_FONT(14);
    _lblName.textColor = [UIColor colorWithRed:76 green:86 blue:108];
    _lblName.textAlignment = NSTextAlignmentRight;
    _lblDescName.font = ME_FONT(14);
    _lblDescName.textColor = [UIColor colorWithRed:76 green:86 blue:108];
    _lblDescName.textAlignment = NSTextAlignmentRight;
    [_txtTitle setBackgroundColor:[UIColor colorWithRed:247 green:247 blue:247]];
    _txtTitle.layer.borderWidth = 0.5;
    _txtTitle.layer.borderColor = [UIColor colorWithRed:222 green:222 blue:222].CGColor;
    _txtTitle.placeholder = [NSString stringWithFormat:NSLocalizedString(@"only %d chars allowed", nil), 10];
    [_txtDesc setBackgroundColor:[UIColor colorWithRed:247 green:247 blue:247]];
    _txtDesc.layer.borderWidth = 2;
    _txtDesc.layer.borderColor = [UIColor colorWithRed:222 green:222 blue:222].CGColor;
    if (_publishSource==FSSourceProduct)
    {
        _txtDesc.placeholder = NSLocalizedString(@"Input Product Desc", nil);
        _lblPrice.font = ME_FONT(14);
        _lblPrice.textColor = [UIColor colorWithRed:76 green:86 blue:108];;
        _lblPrice.textAlignment = NSTextAlignmentRight;
        [_txtPrice setBackgroundColor:[UIColor colorWithRed:247 green:247 blue:247]];
        _txtPrice.layer.borderWidth = 1;
        _txtPrice.layer.borderColor = [UIColor colorWithRed:222 green:222 blue:222].CGColor;
        _txtPrice.delegate = self;
        
        _lbProDesc.font = ME_FONT(14);
        _lbProDesc.textColor = [UIColor colorWithRed:76 green:86 blue:108];;
        _lbProDesc.textAlignment = NSTextAlignmentRight;
        [_txtProDesc setBackgroundColor:[UIColor colorWithRed:247 green:247 blue:247]];
        _txtProDesc.layer.borderWidth = 1;
        _txtProDesc.layer.borderColor = [UIColor colorWithRed:222 green:222 blue:222].CGColor;
        _txtProDesc.delegate = self;
        
        _lbProTime.font = ME_FONT(14);
        _lbProTime.textColor = [UIColor colorWithRed:76 green:86 blue:108];;
        _lbProTime.textAlignment = NSTextAlignmentRight;
        [_txtProStartTime setBackgroundColor:[UIColor colorWithRed:247 green:247 blue:247]];
        _txtProStartTime.layer.borderWidth = 1;
        _txtProStartTime.layer.borderColor = [UIColor colorWithRed:222 green:222 blue:222].CGColor;
        _txtProStartTime.tag = 1;
        
        [_txtProEndTime setBackgroundColor:[UIColor colorWithRed:247 green:247 blue:247]];
        _txtProEndTime.layer.borderWidth = 1;
        _txtProEndTime.tag = 2;
        _txtProEndTime.layer.borderColor = [UIColor colorWithRed:222 green:222 blue:222].CGColor;
    }
    else
    {
        _txtDesc.placeholder = NSLocalizedString(@"Input Promotion Desc", nil);
        _lblPrice.layer.opacity = 0;
        _txtPrice.layer.opacity = 0;
        
        _lbProDesc.layer.opacity = 0;
        _txtProDesc.layer.opacity = 0;
        
        _lbProTime.layer.opacity = 0;
        _txtProStartTime.layer.opacity = 0;
        _txtProEndTime.layer.opacity = 0;
        
        if ([_txtProEndTime.superview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scroll = (UIScrollView*)_txtProEndTime.superview;
            scroll.scrollEnabled = NO;
        }
    }
    _txtTitle.delegate = self;
    _txtDesc.delegate = self;
}

-(void)initAudioPlayer
{
    NSString *recordAudioFullPath = [kRecorderDirectory stringByAppendingPathComponent:_recordFileName];
    NSURL *url = [NSURL fileURLWithPath:recordAudioFullPath];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [_player prepareToPlay];
}

-(BOOL) checkInput
{
    if (!(_txtTitle.text.length > 0 &&
        _txtTitle.text.length < 10))
    {
        int titleLength = 10;
        [self reportError:[NSString stringWithFormat:NSLocalizedString(@"PRO_POST_TITLE_LENGTH_ERROR %d", nil), titleLength]];
        return NO;
    }
    //如果选择了活动描述，则要求一定要输入有效期。
    if (![NSString isNilOrEmpty:_txtProDesc.text]) {
        if ([NSString isNilOrEmpty:_txtProStartTime.text] || [NSString isNilOrEmpty:_txtProStartTime.text]) {
            [self reportError:NSLocalizedString(@"PRO_POST_DURATION_ERROR", nil)];
            return NO;
        }
        //有效期合法性判断
        //...
    }
    //如果是商品，必须要输入价格
//    if (_publishSource == FSSourceProduct &&
//        ([NSString isNilOrEmpty:_txtPrice.text] || _txtPrice.text.intValue <= 0)) {
//        [self reportError:NSLocalizedString(@"", nil)];
//        return NO;
//    }
    if ([_txtProDesc.text isEqualToString:@""]) {
        return YES;
    }
    NSMutableString *error = [@"" mutableCopy];
    if(![self validateDate:&error])
    {
        [self reportError:error];
        return NO;
    }
    return YES;
}



- (BOOL)validateDate:(NSMutableString **)errorin
{
    if (_publishSource == FSSourcePromotion) {
        return YES;
    }
    if ([_txtProDesc.text isEqualToString:@""]) {
        return YES;
    }
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

#pragma mark - TDDatePickerControllerDelegate

- (void)datePickerSetDate:(TDDatePickerController *)viewController
{
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy年MM月dd日 HH时mm分"];
    if (viewController == _datePicker)
    {
        _txtProStartTime.text = [formater stringFromDate:_datePicker.datePicker.date];
    }
    else if(viewController == _dateEndPicker)
    {
        _txtProEndTime.text = [formater stringFromDate:_dateEndPicker.datePicker.date];
    }
    [self dismissSemiModalViewController:viewController];
}

- (void)datePickerCancel:(TDDatePickerController *)viewController
{
    [self dismissSemiModalViewController:viewController];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    activityObject = textView;
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    activityObject = textField;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _txtTitle) {
        if (textField.text.length > 9 && ![string isEqualToString:@""]) {
            return NO;
        }
    }
    if (textField == _txtPrice) {
        if ([string isEqualToString:@""]) {
            return YES;
        }
        if (textField.text.length > 7) {
            return NO;
        }
    }
    
    return YES;
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

- (IBAction)selDuration:(id)sender {
    UIButton* btn = (UIButton*)sender;
    if (btn.tag == 1) {
        if (!_datePicker) {
            _datePicker = [[TDDatePickerController alloc] init];
            _datePicker.delegate = self;
        }
        [self presentSemiModalViewController:_datePicker];
    }
    else {
        if (!_dateEndPicker) {
            _dateEndPicker = [[TDDatePickerController alloc] init];
            _dateEndPicker.delegate = self;
        }
        [self presentSemiModalViewController:_dateEndPicker];
    }
    [activityObject resignFirstResponder];
}

- (IBAction)record:(id)sender {
    switch (_recordState) {
        case StartRecord:
        {
            
        }
            break;
        case Recording:
        {
            
        }
            break;
        default:
            break;
    }
}

#pragma mark record function

- (void)startToRecord
{
    [activityObject resignFirstResponder];
    
    if (!_audioRecoder) {
        _isRecording = NO;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone || UIUserInterfaceIdiomPad)
        {
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            NSError *error;
            if ([audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
            {
                if ([audioSession setActive:YES error:&error])
                {
                }
                else
                {
                    NSLog(@"Failed to set audio session category: %@", error);
                }
            }
            else
            {
                NSLog(@"Failed to set audio session category: %@", error);
            }
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
            AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof(audioRouteOverride),&audioRouteOverride);
        }
        _audioRecoder = [[CL_AudioRecorder alloc] initWithFinishRecordingBlock:^(CL_AudioRecorder *recorder, BOOL success) {
            } encodeErrorRecordingBlock:^(CL_AudioRecorder *recorder, NSError *error) {
                NSLog(@"%@",[error localizedDescription]);
            } receivedRecordingBlock:^(CL_AudioRecorder *recorder, float peakPower, float averagePower, float currentTime) {
                NSLog(@"%f,%f,%f",peakPower,averagePower,currentTime);
        }];
    }
    if (_isRecording == NO)
    {
        _isRecording = YES;
        _recordFileName = [NSString stringWithFormat:@"%f.aac", [[NSDate date] timeIntervalSince1970]];
        _audioRecoder.recorderingFileName = _recordFileName;
        [_audioRecoder startRecord];
    }
}

- (void)endRecord
{
    _isRecording = NO;
    dispatch_queue_t stopQueue;
    stopQueue = dispatch_queue_create("stopQueue", NULL);
    dispatch_async(stopQueue, ^(void){
        //run in main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [_audioRecoder stopRecord];
        });
    });
    dispatch_release(stopQueue);
}

-(void)endRecordAndDelete
{
    _isRecording = NO;
    dispatch_queue_t stopQueue;
    stopQueue = dispatch_queue_create("stopQueue", NULL);
    dispatch_async(stopQueue, ^(void){
        //run in main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [_audioRecoder stopAndDeleteRecord];
        });
    });
    dispatch_release(stopQueue);
}

#pragma mark button action

- (IBAction)recordTouchDown:(id)sender
{
    if (_recordState == WaitPlay) {
        return;
    }
    _downTime = [NSDate date];
    [_btnRecord setTitle:@"松开结束" forState:UIControlStateNormal];
    [self startToRecord];
    _recordState = Recording;
}

- (IBAction)recordTouchUpInside:(id)sender
{
    [self endTouch];
}

- (IBAction)recordTouchUpOutside:(id)sender
{
    [self endTouch];
}

-(void)endTouch
{
    if (_recordState == WaitPlay) {
        [self initAudioPlayer];
        [_player play];
    }
    else if(_recordState == Recording){
        NSInteger gap = [[NSDate date] timeIntervalSinceDate:_downTime];
        if (gap < _minRecordGap) {
            //显示提示时间太短对话框
            [self reportError:@"说话时间太短"];
            //重新设置为起始状态
            [_btnRecord setTitle:@"按住说话" forState:UIControlStateNormal];
            _recordState = StartRecord;
            [self endRecordAndDelete];
        }
        else{
            [_btnRecord setTitle:@"点击播放" forState:UIControlStateNormal];
            _recordState = WaitPlay;
            [self endRecord];
        }
        NSLog(@"fileName:%@", _recordFileName);
    }
}

- (void)viewDidUnload {
    [self setLblName:nil];
    [self setLblDescName:nil];
    [self setLblPrice:nil];
    [self setTxtPrice:nil];
    [self setLbProDesc:nil];
    [self setTxtProDesc:nil];
    [self setLbProTime:nil];
    [self setTxtProEndTime:nil];
    [self setTxtProStartTime:nil];
    [self setLblDescVoice:nil];
    [self setBtnRecord:nil];
    [super viewDidUnload];
}
@end
