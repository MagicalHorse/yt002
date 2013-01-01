//
//  FSSuggestCell.m
//  FashionShop
//
//  Created by gong yi on 11/14/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSFavorProCell.h"
#import "SpringboardLayoutAttributes.h"
#import "FSResource.h"


#define MARGIN 2
@interface FSFavorProCell()
{
    
    UIImage *deleteButtonImg;
    BOOL isInRemove;
}
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDuration;
@property (strong, nonatomic) IBOutlet UILabel *lblStore;


- (IBAction)doRemoveItem:(id)sender;

@end

@implementation FSFavorProCell
@synthesize data = _data;
@synthesize lblDuration=_lblDuration,lblTitle=_lblTitle,lblStore=_lblStore;
@synthesize deleteButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareRemoveClick];
    }
    return self;
}
 - (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self prepareRemoveClick];
    }
    return self;
}

-(void)willRemoveFromView
{
    _imgResource.image = nil;
   // [deleteButton setImage:nil forState:UIControlStateNormal];
    NSLog(@"image removed");
}

-(void) prepareRemoveClick
{
    
    deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 23, 24)];
    [deleteButton setImage:[UIImage imageNamed:@"cancel2_icon.png"] forState:UIControlStateNormal];
     
    [self.contentView addSubview:deleteButton];
}


-(void) setData:(FSFavor *)dataSource{
    if (dataSource){
        _data = dataSource;
        _lblTitle.text = [NSString stringWithFormat:@"%@",_data.sourceName];
        _lblStore.text = _data.store.name;
    }
}



- (void)applyLayoutAttributes:(SpringboardLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    if (layoutAttributes.isDeleteButtonHidden)
    {
        deleteButton.layer.opacity = 0.0;
        [self stopQuivering];
    }
    else
    {
        deleteButton.layer.opacity = 1.0;
        [self bringSubviewToFront:deleteButton];
        [self startQuivering];
        
    }
}

- (void)imageContainerStartDownload:(id)container withObject:(id)indexPath andCropSize:(CGSize)crop
{
    if (!self.imgResource.image)
    {
        if (_data.resources && _data.resources.count>0)
        {
            NSURL *url = [(FSResource *)_data.resources[0] absoluteUrl];
            if (url)
            {
                [self.imgResource setImageUrl:url resizeWidth:crop];
            }
        }
       
    }
}


- (void)startQuivering
{
    CABasicAnimation *quiverAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    float startAngle = (-2) * M_PI/180.0;
    float stopAngle = -startAngle;
    quiverAnim.fromValue = [NSNumber numberWithFloat:startAngle];
    quiverAnim.toValue = [NSNumber numberWithFloat:3 * stopAngle];
    quiverAnim.autoreverses = YES;
    quiverAnim.duration = 0.5;
    quiverAnim.repeatCount = HUGE_VALF;
    float timeOffset = (float)(arc4random() % 100)/100 - 0.50;
    quiverAnim.timeOffset = timeOffset;
    CALayer *layer = self.layer;
    [layer addAnimation:quiverAnim forKey:@"quivering"];
}

- (void)stopQuivering
{
    CALayer *layer = self.layer;
    [layer removeAnimationForKey:@"quivering"];
}
@end
