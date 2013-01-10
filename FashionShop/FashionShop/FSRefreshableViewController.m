//
//  FSRefreshableViewController.m
//  FashionShop
//
//  Created by gong yi on 12/27/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSRefreshableViewController.h"
#import "EGORefreshTableHeaderView.h"

#define REFRESHINGVIEW_HEIGHT 60
#define LOADMOREVIEW_HEIGHT 40
@interface FSRefreshableViewController ()
{
    EGORefreshTableHeaderView *refreshHeaderView;
    UIRefreshControl *refreshControlView;
    UIImageView *loadMoreView;
    
    UICallBackWith1Param _action;
    BOOL _inLoading;
}

@end

@implementation FSRefreshableViewController
@synthesize isInRefresh = _isInRefreshing;

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

}
-(void) beginLoadMoreLayout:(UIScrollView *)container
{
    if (_inLoading)
        return;
    _inLoading = TRUE;
    loadMoreView= [[UIImageView alloc] initWithFrame:CGRectMake(container.frame.size.width/2-LOADMOREVIEW_HEIGHT/2,container.superview.frame.size.height-LOADMOREVIEW_HEIGHT, LOADMOREVIEW_HEIGHT, LOADMOREVIEW_HEIGHT)];
    [container.superview addSubview:loadMoreView];
    [loadMoreView.layer removeAllAnimations];
    loadMoreView.image = [UIImage imageNamed:@"refresh-spinner-dark"];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI/180, 0, 0, 1.0)];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0, 0, 1.0)];
    animation.duration = .4;
    animation.cumulative =YES;
    animation.repeatCount = 2000;
    [loadMoreView.layer addAnimation:animation forKey:@"animation"];
    [loadMoreView startAnimating];
    [container.superview setNeedsLayout];
    [container.superview setNeedsDisplay];
}
-(void)internalEndMore
{
    [loadMoreView.layer removeAllAnimations];
    loadMoreView.image = nil;
    loadMoreView = nil;
    [loadMoreView removeFromSuperview];
    _inLoading = FALSE;
}
-(void) endLoadMore:(UIScrollView *)container
{
    [loadMoreView.layer removeAllAnimations];
    loadMoreView.image = nil;
    loadMoreView = nil;
    [loadMoreView removeFromSuperview];
    _inLoading = FALSE;
    
}
-(void) prepareRefreshLayout:(UIScrollView *)container withRefreshAction:(UICallBackWith1Param)action 
{
    /*
    if ([UIRefreshControl class] &&[container isKindOfClass:[UITableView class]])
    {
        refreshControlView = [[UIRefreshControl alloc] init];
        refreshControlView.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"COMM_REFRESH_PULLTEXT", nil)];
        [refreshControlView addTarget:self action:@selector(RefreshViewControlEventValueChanged:) forControlEvents:UIControlEventValueChanged];
        [container addSubview:refreshControlView];
    }
    else
     */
    {
        refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f,  -REFRESHINGVIEW_HEIGHT, container.frame.size.width,REFRESHINGVIEW_HEIGHT)];
        refreshHeaderView.backgroundColor = [UIColor whiteColor];
        [container addSubview:refreshHeaderView];
        refreshHeaderView.delegate = self;
    }
    container.delegate = self;
    _action = action;
}

-(void)RefreshViewControlEventValueChanged:(UIView *)sender{
    refreshControlView.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"COMM_REFRESH_INGTEXT", nil)];
    [self startRefresh:sender.superview withCallback:^{
        [refreshControlView endRefreshing];
    }];
    
}

-(void)startRefresh:(id)view withCallback:(dispatch_block_t)callback
{
    _action(callback);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    [refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
	[refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    if (!_isInRefreshing)
    {
        
        _isInRefreshing = TRUE;
        [self startRefresh:view.superview  withCallback:^{
            _isInRefreshing = FALSE;
            [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:view.superview];
        }];
    } else
    {
        [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:view.superview];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _isInRefreshing;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
