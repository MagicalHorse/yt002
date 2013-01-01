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
@interface FSRefreshableViewController ()
{
    EGORefreshTableHeaderView *refreshHeaderView;
    UIRefreshControl *refreshControlView;
    
    UICallBackWith1Param _action;
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
-(void) prepareRefreshLayout:(UIScrollView *)container withRefreshAction:(UICallBackWith1Param)action 
{
    if ([UIRefreshControl class] &&[container isKindOfClass:[UITableView class]])
    {
        refreshControlView = [[UIRefreshControl alloc] init];
        refreshControlView.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"COMM_REFRESH_PULLTEXT", nil)];
        [refreshControlView addTarget:self action:@selector(RefreshViewControlEventValueChanged:) forControlEvents:UIControlEventValueChanged];
        [container addSubview:refreshControlView];
    }
    else
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
