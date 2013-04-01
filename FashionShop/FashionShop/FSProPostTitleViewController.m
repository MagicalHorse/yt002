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
#import "FSAudioButton.h"

#define TITLE_MAX_LENGTH 15

@interface FSProPostTitleViewController ()
{
    UIView *backView;
    TDDatePickerController* _datePicker;
    TDDatePickerController* _dateEndPicker;
    id activityObject;
    
    RecordState _recordState;
    BOOL              _isRecording;
    NSDate* _downTime;//按下时间
    NSInteger _minRecordGap;//最小录制时间间隔
    
    AVAudioPlayer * _player;
    UIImageView *playImageView;
    UIImageView *animateView;
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
    if (!theApp.audioRecoder) {
        [theApp initAudioRecoder];
    }
    [self initRecordButton];
    
    _minRecordGap = 4;
}

-(void)initRecordButton
{
    UIImage *image = [UIImage imageNamed:@"audio_btn_normal.png"];
    [_btnRecord setBackgroundImage:image forState:UIControlStateNormal];
    image = [UIImage imageNamed:@"audio_btn_sel.png"];
    [_btnRecord setBackgroundImage:image forState:UIControlStateHighlighted];
    
    int height = _btnRecord.frame.size.height/2;
    CGRect _rect = CGRectMake((_btnRecord.frame.size.width-height)/2 - 40, height/2, height, height);
    //添加播放图标
    playImageView = [[UIImageView alloc] initWithFrame:_rect];
    playImageView.hidden = YES;
    playImageView.image = [UIImage imageNamed:@"play_icon.png"];
    playImageView.contentMode = UIViewContentModeCenter;
    [_btnRecord addSubview:playImageView];
    
    //添加播放动画
    animateView = [[UIImageView alloc] initWithFrame:_rect];
    animateView.animationImages = [NSArray arrayWithObjects:
                                   [UIImage imageNamed:@"audio_play0.png"],
                                   [UIImage imageNamed:@"audio_play1.png"],
                                   [UIImage imageNamed:@"audio_play2.png"],
                                   [UIImage imageNamed:@"audio_play3.png"],
                                   nil];
    animateView.animationDuration = 1.2;
    animateView.hidden = YES;
    animateView.contentMode = UIViewContentModeCenter;
    [_btnRecord addSubview:animateView];
}

-(void)showReRecordButton
{
    [UIView animateWithDuration:0.3 animations:^{
        //改变尺寸
        CGRect _rect = _btnRecord.frame;
        _rect.size.width -= 80;
        _btnRecord.frame = _rect;
        
        _btnReRecord.alpha = 1.0;
        _rect = _btnReRecord.frame;
        _rect.size.width = 75;
        _rect.origin.x -= 75;
        _btnReRecord.frame = _rect;
        
        //加入播放按钮
        [_btnRecord setTitle:@"" forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        playImageView.hidden = NO;
    }];
}

-(void)hideReRecordButton
{
    //设置状态
    _recordState = PTStartRecord;
    playImageView.hidden = YES;
    animateView.hidden = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        //改变尺寸
        CGRect _rect = _btnRecord.frame;
        _rect.size.width += 80;
        _btnRecord.frame = _rect;
        
        _btnReRecord.alpha = 0;
        _rect = _btnReRecord.frame;
        _rect.size.width = 0;
        _rect.origin.x += 75;
        _btnReRecord.frame = _rect;
    } completion:^(BOOL finished) {
        //加入播放按钮
        [_btnRecord setTitle:@"按住开始录音" forState:UIControlStateNormal];
        //清除文件内容
        NSString *recordAudioFullPath = [kRecorderDirectory stringByAppendingPathComponent:_recordFileName];
        NSLock* tempLock = [[NSLock alloc]init];
        [tempLock lock];
        if ([[NSFileManager defaultManager] fileExistsAtPath:recordAudioFullPath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:recordAudioFullPath error:nil];
        }
        [tempLock unlock];
        _recordFileName = nil;
        _player = nil;
    }];
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
    _txtTitle.placeholder = [NSString stringWithFormat:NSLocalizedString(@"only %d chars allowed", nil), TITLE_MAX_LENGTH];
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

-(void)startPlay
{
    if (!_player) {
        NSString *recordAudioFullPath = [kRecorderDirectory stringByAppendingPathComponent:_recordFileName];
        NSURL *url = [NSURL fileURLWithPath:recordAudioFullPath];
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        _player.delegate = self;
        [_player prepareToPlay];
    }
    _recordState = PTPlaying;
    [animateView startAnimating];
    animateView.hidden = NO;
    playImageView.hidden = YES;
    [_player play];
}

-(void)stopPlay
{
    _recordState = PTWaitPlay;
    [animateView stopAnimating];
    animateView.hidden = YES;
    playImageView.hidden = NO;
    _player.currentTime = 0;
    [_player stop];
}

-(void)pausePlay
{
    animateView.hidden = YES;
    playImageView.hidden = NO;
    _recordState = PTWaitPlay;
    [animateView stopAnimating];
    [_player pause];
}

-(BOOL) checkInput
{
    if (!(_txtTitle.text.length > 0 &&
        _txtTitle.text.length < TITLE_MAX_LENGTH))
    {
        [self reportError:[NSString stringWithFormat:NSLocalizedString(@"PRO_POST_TITLE_LENGTH_ERROR %d", nil), TITLE_MAX_LENGTH]];
        return NO;
    }
    if ([NSString isNilOrEmpty:_txtDesc.text]) {
        [self reportError:NSLocalizedString(@"PRO_POST_DESC_INFO", nil)];
        return NO;
    }
    //如果选择了活动描述，则要求一定要输入有效期。
    if (![NSString isNilOrEmpty:_txtProDesc.text]) {
        if ([NSString isNilOrEmpty:_txtProStartTime.text] || [NSString isNilOrEmpty:_txtProStartTime.text]) {
            [self reportError:NSLocalizedString(@"PRO_POST_DURATION_ERROR", nil)];
            return NO;
        }
    }
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

-(void)cleanData
{
    [self hideReRecordButton];
    NSLock* tempLock = [[NSLock alloc]init];
    [tempLock lock];
    if ([[NSFileManager defaultManager] fileExistsAtPath:_recordFileName])
    {
        [[NSFileManager defaultManager] removeItemAtPath:_recordFileName error:nil];
    }
    [tempLock unlock];
    
    _txtTitle.text = @"";
    _txtDesc.text = @"";
    _txtPrice.text = @"";
    _txtProDesc.text = @"";
    _txtProStartTime.text = @"";
    _txtProEndTime.text = @"";
    _btnReRecord = nil;
    _btnRecord = nil;
}

#pragma mark - TDDatePickerControllerDelegate

- (void)datePickerSetDate:(TDDatePickerController *)viewController
{
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:NSLocalizedString(@"Year Month Day H&M", nil)];
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
//    if (textField == _txtTitle) {
//        if (textField.text.length > TITLE_MAX_LENGTH-1 && ![string isEqualToString:@""]) {
//            return NO;
//        }
//    }
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

#pragma mark record function

- (void)startToRecord
{
    [activityObject resignFirstResponder];
    
    if (!theApp.audioRecoder) {
        [theApp initAudioRecoder];
    }
    if (_isRecording == NO)
    {
        _isRecording = YES;
        _recordFileName = [NSString stringWithFormat:@"%f.m4a", [[NSDate date] timeIntervalSince1970]];
        theApp.audioRecoder.recorderingFileName = _recordFileName;
        [theApp.audioRecoder startRecord];
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
            [theApp.audioRecoder stopRecord];
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
            [theApp.audioRecoder stopAndDeleteRecord];
        });
    });
    dispatch_release(stopQueue);
}

#pragma mark button action

- (IBAction)recordTouchDown:(id)sender
{
    if (_recordState == PTWaitPlay ||
        _recordState == PTPlaying) {
        return;
    }
    _downTime = [NSDate date];
    [_btnRecord setTitle:NSLocalizedString(@"Up To End Record", nil) forState:UIControlStateNormal];
    [self startToRecord];
    _recordState = PTRecording;
}

- (IBAction)recordTouchUpInside:(id)sender
{
    [self endTouch];
}

- (IBAction)recordTouchUpOutside:(id)sender
{
    [self endTouch];
}

- (IBAction)reRecordTouchUpInside:(id)sender {
    [self hideReRecordButton];
}

-(void)endTouch
{
    if (_recordState == PTWaitPlay) {
        [self startPlay];
    }
    else if(_recordState == PTPlaying) {
        [self pausePlay];
    }
    else if(_recordState == PTRecording){
        NSInteger gap = [[NSDate date] timeIntervalSinceDate:_downTime];
        if (gap < _minRecordGap) {
            //显示提示时间太短对话框
            [self reportError:NSLocalizedString(@"Speak Too Short, Please Say Again", nil)];
            //重新设置为起始状态
            [_btnRecord setTitle:NSLocalizedString(@"Down To Start Record", nil) forState:UIControlStateNormal];
            _recordState = PTStartRecord;
            [self endRecordAndDelete];
        }
        else{
            [_btnRecord setTitle:NSLocalizedString(@"Click To Play", nil) forState:UIControlStateNormal];
            _recordState = PTWaitPlay;
            [self endRecord];
            
            //显示重新录入按钮
            [self showReRecordButton];
        }
    }
}

- (void)viewDidUnload {
    [self stopAllAudio];
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
    [self setBtnReRecord:nil];
    [super viewDidUnload];
}

-(void)stopAllAudio
{
    if (_player.isPlaying) {
        [_player stop];
        _recordState = PTWaitPlay;
    }
}

#pragma mark - AVAudioPlayDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopPlay];
}

@end
