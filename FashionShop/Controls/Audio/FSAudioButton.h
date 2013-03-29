//
//  FSAudioButton.h
//  FashionShop
//
//  Created by HeQingshan on 13-3-29.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    Normal,
    Playing,
    Stop,
    Loading,
    Pause,
}AudioState;

@interface FSAudioButton : UIButton<AVAudioPlayerDelegate>

@property (nonatomic,strong) NSString *fullPath;//声音文件
@property (nonatomic,assign) AudioState state;

-(void)play;
-(void)stop;
-(void)pause;

-(void)initControl;
-(BOOL)isPlaying;

@end
