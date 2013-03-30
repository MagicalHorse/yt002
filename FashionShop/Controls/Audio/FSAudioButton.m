//
//  FSAudioButton.m
//  FashionShop
//
//  Created by HeQingshan on 13-3-29.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSAudioButton.h"
#import "CL_VoiceEngine.h"

@interface FSAudioButton(){
    UILabel *timeLb;
    UIImageView *soundImageView;
    UIActivityIndicatorView *activity;
    UIImageView *playImageView;
    UIImageView *animateView;
    
    NSMutableData * receiveData;
    AVAudioPlayer * player;
    NSString *fileName;
}

@end

@implementation FSAudioButton
@synthesize fullPath;
@synthesize state;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initControl];
    }
    return self;
}

-(void)initControl
{
    //设置按钮属性
    [self setBackgroundColor:[UIColor clearColor]];
    UIImage *image = [UIImage imageNamed:@"audio_btn_normal.png"];
    //image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 30, image.size.height, image.size.width-30)];
    [self setBackgroundImage:image forState:UIControlStateNormal];
    [self setBackgroundImage:image forState:UIControlStateHighlighted];
    
    //添加时间标签
//    timeLb = [[UILabel alloc] initWithFrame:CGRectMake(9, 0, 0, 0)];
//    timeLb.font = [UIFont boldSystemFontOfSize:10];
//    timeLb.backgroundColor = [UIColor clearColor];
//    timeLb.textColor = RGBCOLOR(0, 0, 0);
//    [self addSubview:timeLb];
    
    int height = self.frame.size.height/2;
    CGRect _rect = CGRectMake((self.frame.size.width-height)/2, height/2, height, height);
    
    //添加加载
    activity = [[UIActivityIndicatorView alloc] initWithFrame:_rect];
    activity.hidden = YES;
    activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [self addSubview:activity];
    
    //添加播放图标
    playImageView = [[UIImageView alloc] initWithFrame:_rect];
    playImageView.image = [UIImage imageNamed:@"play_icon.png"];
    playImageView.contentMode = UIViewContentModeCenter;
    [self addSubview:playImageView];
    
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
    [self addSubview:animateView];
    
    [self addTarget:self action:@selector(clickToPlay:) forControlEvents:UIControlEventTouchUpInside];
    
    state = Normal;
    [self updateState];
}

-(void)updateState
{
    switch (state) {
        case Normal:
        {
            activity.hidden = YES;
            playImageView.hidden = NO;
            animateView.hidden = YES;
        }
            break;
        case Playing:
        {
            activity.hidden = YES;
            playImageView.hidden = YES;
            animateView.hidden = NO;
        }
            break;
        case Stop:
        {
            activity.hidden = YES;
            playImageView.hidden = NO;
            animateView.hidden = YES;
        }
            break;
        case Pause:
        {
            activity.hidden = YES;
            playImageView.hidden = NO;
            animateView.hidden = YES;
        }
            break;
        case Loading:
        {
            activity.hidden = NO;
            playImageView.hidden = YES;
            animateView.hidden = YES;
        }
            break;
        default:
            break;
    }
}

-(void)clickToPlay:(UIButton*)sender
{
    if (_audioDelegate && [_audioDelegate respondsToSelector:@selector(clickAudioButton:)]) {
        [_audioDelegate clickAudioButton:self];
    }
    [self play];
}

//异步播放歌曲，边缓冲边播放,异步连接
-(void)play
{
    if (state == Playing) {
        state = Pause;
        [self updateState];
        [player pause];
        [animateView stopAnimating];
    }
    else if(state == Loading) {
        [activity stopAnimating];
        state = Normal;
        [self updateState];
    }
    else if(state == Pause) {
        state = Playing;
        [self updateState];
        [player play];
        [animateView startAnimating];
    }
    else if(state == Stop) {
        state = Playing;
        [self updateState];
        [player play];
        [animateView startAnimating];
    }
    else{
        //首先检测该文件是否已经存在缓存列表中，如果存在，则直接使用播放
        fileName = [fullPath lastPathComponent];
        NSString *recordAudioFullPath = [kRecorderDirectory stringByAppendingPathComponent:fileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:recordAudioFullPath])
        {
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:recordAudioFullPath] error:nil];
            player.delegate = self;
            [player prepareToPlay];
            [player play];
            state = Playing;
            [self updateState];
            [animateView startAnimating];
        }
        else{
            NSURL * url = [[NSURL alloc] initWithString:fullPath];
            NSURLRequest * urlRequest = [[NSURLRequest alloc] initWithURL:url];
            //异步请求数据
            [NSURLConnection connectionWithRequest:urlRequest delegate:self];
            //给状态栏加菊花
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
    }
}

-(void)stop
{
    [player stop];
    player.currentTime = 0;
    state = Stop;
    [self updateState];
}

-(void)pause
{
    [player pause];
    state = Pause;
    [self updateState];
}

-(BOOL)isPlaying
{
    return [player isPlaying];
}

#pragma mak - NSURLConnectionDataDelegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    receiveData = [[NSMutableData alloc] init];
    state = Loading;
    [self updateState];
    [activity startAnimating];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [receiveData  appendData:data];
    /*
    if ([receiveData length] > 20000) {
        if (player == nil) {
            player = [[AVAudioPlayer alloc] initWithData:receiveData error:nil];
            [player prepareToPlay];
        }else if (player.isPlaying == NO){
            [player play];
            state = Playing;
        }
    }
     */
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    //缓冲完成后关闭菊花
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    /*
     将下载好的数据写入沙盒的cache目录下
     */
    NSString *filePath=[kRecorderDirectory  stringByAppendingPathComponent:fileName];
    [receiveData writeToFile:filePath atomically:YES];
    [self performSelector:@selector(showPlay:) withObject:filePath afterDelay:1.5];
}
-(void)showPlay:(NSString*)filePath
{
    //以该路径初始化一个url,然后以url初始化player
    NSError * error;
    NSURL * url = [NSURL fileURLWithPath:filePath];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    player.delegate = self;
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }
    [player prepareToPlay];
    [player play];
    state = Playing;
    [self updateState];
    [animateView startAnimating];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    //网络连接失败，关闭菊花
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }
    state = Normal;
    [self updateState];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    state = Stop;
    [self updateState];
}

@end
