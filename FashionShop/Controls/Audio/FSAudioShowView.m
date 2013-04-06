
//
//  FSAudioShowView.m
//  FashionShop
//
//  Created by HeQingshan on 13-4-6.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSAudioShowView.h"

#define AudioLabel_Height 47

@interface FSAudioShowView(){
    UIImageView *audioView;
    UILabel *audioLabel;
}

@end

@implementation FSAudioShowView

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
    self.layer.borderWidth = 0;
    self.layer.cornerRadius = 10;
    self.backgroundColor = [UIColor blackColor];
    self.alpha = 0.8;
    
    audioView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audio_speaker.png"]];
    audioView.frame = CGRectMake((self.frame.size.width - 52)/2, (self.frame.size.height-70)/2, 52, 70);
    [self addSubview:audioView];
    
    UIView *_view = [[UIView alloc] initWithFrame:CGRectMake(audioView.frame.origin.x + 12, audioView.frame.origin.y, 28.5, AudioLabel_Height)];
    _view.layer.cornerRadius = 12;
    _view.layer.borderWidth = 0;
    _view.clipsToBounds = YES;
    [self addSubview:_view];
    
    audioLabel = [[UILabel alloc] initWithFrame:_view.bounds];
    audioLabel.backgroundColor = [UIColor greenColor];
    [_view addSubview:audioLabel];
    
    [self updateAudioLabelFrame:0];
}

-(void)updateAudioLabelFrame:(double)aRate
{
    double height = aRate;
    double yOffset = AudioLabel_Height - height;
    CGRect _rect = audioLabel.frame;
    _rect.origin.y = yOffset;
    _rect.size.height = height;
    audioLabel.frame = _rect;
}

@end

