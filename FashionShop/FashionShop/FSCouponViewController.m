//
//  FSLikeViewController.m
//  FashionShop
//
//  Created by gong yi on 11/28/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSCouponViewController.h"
#import "FSCouponDetailCell.h"
#import "FSCouponProDetailCell.h"
#import "FSCommonUserRequest.h"
#import "FSPagedCoupon.h"
#import "FSModelManager.h"
#import "FSCommonProRequest.h"
#import "FSLocationManager.h"
#import "FSDRViewController.h"

@interface FSCouponViewController ()
{
    FSGiftSortBy _currentSelIndex;
    
    NSMutableArray *_dataSourceList;
    NSMutableArray *_noMoreList;
    NSMutableArray *_pageIndexList;
    NSMutableArray *_refreshTimeList;
    BOOL _inLoading;
}

@end

#define USER_COUPON_TABLE_CELL @"usercoupontablecell"
#define USER_COUPON_PRO_TABLE_CELL @"usercouponprotablecell"

@implementation FSCouponViewController
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
    self.title = NSLocalizedString(@"My Promotion List",nil);
    UIBarButtonItem *baritemCancel = [self createPlainBarButtonItem:@"goback_icon.png" target:self action:@selector(onButtonBack:)];
    [self.navigationItem setLeftBarButtonItem:baritemCancel];
    
    [_contentView registerNib:[UINib nibWithNibName:@"FSCouponDetailCell" bundle:Nil] forCellReuseIdentifier:USER_COUPON_TABLE_CELL];
    [_contentView registerNib:[UINib nibWithNibName:@"FSCouponProDetailCell" bundle:Nil] forCellReuseIdentifier:USER_COUPON_PRO_TABLE_CELL];
    
    [self setFilterType];
    [self initArray];
    
    _currentSelIndex = SortByUnUsed;
    _contentView.backgroundView = nil;
    _contentView.backgroundColor = APP_TABLE_BG_COLOR;
    
    [self prepareRefreshLayout:_contentView withRefreshAction:^(dispatch_block_t action) {
        if (_inLoading)
        {
            action();
            return;
        }
        int currentPage = [[_pageIndexList objectAtIndex:_segFilters.selectedSegmentIndex] intValue];
        FSCommonUserRequest *request = [self createRequest:currentPage];
        request.previousLatestDate = [_refreshTimeList objectAtIndex:_segFilters.selectedSegmentIndex];
        _inLoading = YES;
        [request send:[FSPagedCoupon class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
            _inLoading = NO;
            action();
            if (resp.isSuccess)
            {
                FSPagedCoupon *innerResp = resp.responseData;
                if (innerResp.totalPageCount <= currentPage)
                    [self setNoMore:YES selectedSegmentIndex:_segFilters.selectedSegmentIndex];
                [self mergeLike:innerResp isInsert:YES];
                
                [self setRefreshTime:[NSDate date] selectedSegmentIndex:_segFilters.selectedSegmentIndex];
            }
            else
            {
                [self reportError:resp.errorDescrip];
            }
        }];
    }];
}

- (void)onButtonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestData];
}

-(void) setFilterType
{
    [_segFilters removeAllSegments];
    [_segFilters insertSegmentWithTitle:NSLocalizedString(@"ExchangeList_UnUsed", nil) atIndex:0 animated:FALSE];
    [_segFilters insertSegmentWithTitle:NSLocalizedString(@"ExchangeList_Used", nil) atIndex:1 animated:FALSE];
    [_segFilters insertSegmentWithTitle:NSLocalizedString(@"ExchangeList_Disable", nil) atIndex:2 animated:FALSE];
    [_segFilters addTarget:self action:@selector(filterSearch:) forControlEvents:UIControlEventValueChanged];
    _segFilters.selectedSegmentIndex = 0;
}

-(void)initArray
{
    _dataSourceList = [@[] mutableCopy];
    _pageIndexList = [@[] mutableCopy];
    _noMoreList = [@[] mutableCopy];
    _refreshTimeList = [@[] mutableCopy];
    
    for (int i = 0; i < 3; i++) {
        [_dataSourceList insertObject:[@[] mutableCopy] atIndex:i];
        [_pageIndexList insertObject:@1 atIndex:i];
        [_noMoreList insertObject:@NO atIndex:i];
        [_refreshTimeList insertObject:[NSDate date] atIndex:i];
    }
}

-(void)filterSearch:(UISegmentedControl *) segmentedControl
{
    int index = segmentedControl.selectedSegmentIndex;
    if(_currentSelIndex == index)
    {
        return;
    }
    _currentSelIndex = index;
    NSMutableArray *source = [_dataSourceList objectAtIndex:index];
    if (source == nil || source.count<=0)
    {
        [self requestData];
    }
    [_contentView reloadData];
    [_contentView setContentOffset:CGPointZero];
}

-(void)setPageIndex:(int)_index selectedSegmentIndex:(NSInteger)_selIndexSegment
{
    NSNumber * nsNum = [NSNumber numberWithInt:_index];
    [_pageIndexList replaceObjectAtIndex:_selIndexSegment withObject:nsNum];
}

-(void)setNoMore:(BOOL)_more selectedSegmentIndex:(NSInteger)_selIndexSegment
{
    NSNumber * nsNum = [NSNumber numberWithBool:_more];
    [_noMoreList replaceObjectAtIndex:_selIndexSegment withObject:nsNum];
}

-(void)setRefreshTime:(NSDate*)_date selectedSegmentIndex:(NSInteger)_selIndexSegment
{
    [_refreshTimeList replaceObjectAtIndex:_selIndexSegment withObject:_date];
}

-(void) requestData
{
    int currentPage = [[_pageIndexList objectAtIndex:_segFilters.selectedSegmentIndex] intValue];
    FSCommonUserRequest *request = [self createRequest:currentPage];
    [self beginLoading:_contentView];
    [request send:[FSPagedCoupon class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
        [self endLoading:_contentView];
        if (resp.isSuccess)
        {
            FSPagedCoupon *innerResp = resp.responseData;
            if (innerResp.totalPageCount <= currentPage)
                [self setNoMore:YES selectedSegmentIndex:_segFilters.selectedSegmentIndex];
            [self mergeLike:innerResp isInsert:NO];
            
            [self setRefreshTime:[NSDate date] selectedSegmentIndex:_segFilters.selectedSegmentIndex];
        }
        else
        {
            [self reportError:resp.errorDescrip];
        }
    }];
}

-(void) mergeLike:(FSPagedCoupon *)response isInsert:(BOOL)isinsert
{
    NSMutableArray *_likes = _dataSourceList[_segFilters.selectedSegmentIndex];
    if (response && response.items)
    {
        [response.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            int index = [_likes indexOfObjectPassingTest:^BOOL(id obj1, NSUInteger idx1, BOOL *stop1) {
                if ([[(FSCoupon *)obj1 valueForKey:@"id"] isEqualToValue:[(FSCoupon *)obj valueForKey:@"id" ]])
                {
                    return TRUE;
                    *stop1 = TRUE;
                }
                return FALSE;
            }];
            if (index == NSNotFound)
            {
                if (isinsert)
                    [_likes insertObject:obj atIndex:0];
                else
                    [_likes addObject:obj];
            }
        }];
        [_contentView reloadData];
    }
    if (_likes.count<1)
    {
        //加载空视图
        [self showNoResultImage:_contentView withImage:@"blank_me_fans.png" withText:NSLocalizedString(@"TipInfo_Coupon_List", nil)  originOffset:30];
    }
    else
    {
        [self hideNoResultImage:_contentView];
    }
}

-(FSCommonUserRequest *)createRequest:(int)index
{
    FSCommonUserRequest *request = [[FSCommonUserRequest alloc] init];
    request.userToken =[FSModelManager sharedModelManager].loginToken;
    request.pageSize = [NSNumber numberWithInt:COMMON_PAGE_SIZE];
    request.pageIndex =[NSNumber numberWithInt:index];
    request.sort = @0;
    request.routeResourcePath = RK_REQUEST_COUPON_LIST;
    return request;
}

- (void)viewDidUnload {
    [self setSegFilters:nil];
    [super viewDidUnload];
}

#pragma mark - UITableViewDelegate && UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSMutableArray *_likes = _dataSourceList[_segFilters.selectedSegmentIndex];
    return _likes?_likes.count:0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *_likes = _dataSourceList[_segFilters.selectedSegmentIndex];
    FSCoupon *coupon = [_likes objectAtIndex:indexPath.section];
    UITableViewCell *detailCell = nil;
    if (coupon.producttype == FSSourceProduct)
    {
        detailCell = [_contentView dequeueReusableCellWithIdentifier:USER_COUPON_TABLE_CELL];
        [(FSCouponDetailCell *)detailCell setData:coupon];
    } else
    {
        detailCell = [_contentView dequeueReusableCellWithIdentifier:USER_COUPON_PRO_TABLE_CELL];
        [(FSCouponProDetailCell *)detailCell setData:coupon];
    }
    return detailCell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSCouponProDetailCell *cell = (FSCouponProDetailCell*)[tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSProDetailViewController *detailView = [[FSProDetailViewController alloc] initWithNibName:@"FSProDetailViewController" bundle:nil];
    NSMutableArray *_likes = _dataSourceList[_segFilters.selectedSegmentIndex];
    detailView.navContext = _likes;
    detailView.indexInContext = indexPath.row* [self numberOfSectionsInTableView:tableView] + indexPath.section;
    detailView.sourceType = [(FSCoupon *)[_likes objectAtIndex:detailView.indexInContext] producttype];
    detailView.dataProviderInContext = self;
    UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:detailView];
    [self presentViewController:navControl animated:true completion:nil];
      [tableView deselectRowAtIndexPath:indexPath animated:FALSE];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    BOOL _noMore = [[_noMoreList objectAtIndex:_segFilters.selectedSegmentIndex] boolValue];
    if(!_inLoading
       && (scrollView.contentOffset.y+scrollView.frame.size.height) + 150 > scrollView.contentSize.height
       &&scrollView.contentOffset.y>0
       && !_noMore)
    {
        _inLoading = TRUE;
        int currentPage = [[_pageIndexList objectAtIndex:_segFilters.selectedSegmentIndex] intValue];
        FSCommonUserRequest *request = [self createRequest:currentPage+1];
        [request send:[FSPagedCoupon class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
            _inLoading = FALSE;
            if (resp.isSuccess)
            {
                FSPagedCoupon *innerResp = resp.responseData;
                if (innerResp.totalPageCount<=currentPage+1)
                    [self setNoMore:YES selectedSegmentIndex:_segFilters.selectedSegmentIndex];
                [self setPageIndex:currentPage+1 selectedSegmentIndex:_segFilters.selectedSegmentIndex];
                [self mergeLike:innerResp isInsert:NO];
            }
            else
            {
                [self reportError:resp.errorDescrip];
            }
        }];
    }
}

#pragma mark - FSProDetailItemSourceProvider

-(void)proDetailViewDataFromContext:(FSProDetailViewController *)view forIndex:(NSInteger)index completeCallback:(UICallBackWith1Param)block errorCallback:(dispatch_block_t)errorBlock
{
    __block FSCoupon * favorCurrent = [view.navContext objectAtIndex:index];
    FSCommonProRequest *request = [[FSCommonProRequest alloc] init];
    request.uToken = [FSModelManager sharedModelManager].loginToken;
    request.routeResourcePath = RK_REQUEST_PRO_DETAIL;
    request.id = [NSNumber numberWithInt:favorCurrent.productid];
    request.longit =[NSNumber numberWithFloat:[FSLocationManager sharedLocationManager].currentCoord.longitude];
    request.lantit = [NSNumber numberWithFloat:[FSLocationManager sharedLocationManager].currentCoord.latitude];
    Class respClass;
    if (favorCurrent.producttype == FSSourceProduct)
    {
        request.pType = FSSourceProduct;
        request.routeResourcePath = RK_REQUEST_PROD_DETAIL;
        respClass = [FSProdItemEntity class];
    }
    else
    {
        request.pType = FSSourcePromotion;
        request.routeResourcePath = RK_REQUEST_PRO_DETAIL;
        respClass = [FSProItemEntity class];
        
    }
    [request send:respClass withRequest:request completeCallBack:^(FSEntityBase *resp) {
        if (!resp.isSuccess)
        {
            [view reportError:NSLocalizedString(@"COMM_OPERATE_FAILED", nil)];
            errorBlock();
        }
        else
        {
            block(resp.responseData);
        }
    }];
}

-(FSSourceType)proDetailViewSourceTypeFromContext:(FSProDetailViewController *)view forIndex:(NSInteger)index
{
    FSCoupon * favorCurrent = [view.navContext objectAtIndex:index];
    return favorCurrent.producttype;
}

@end
