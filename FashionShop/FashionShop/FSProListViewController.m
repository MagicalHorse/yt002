//
//  FSProListViewController.m
//  FashionShop
//
//  Created by gong yi on 11/17/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSProListViewController.h"
#import "FSAppDelegate.h"
#import "FSProListRequest.h"
#import "FSModelManager.h"
#import "FSProItemEntity.h"
#import "FSProItems.h"
#import "FSStore.h"
#import "FSCity.h"
#import "FSProNearestHeaderTableCell.h"
#import "FSProNewHeaderView.h"
#import "FSProNearDetailCell.h"
#import "FSProListTableCell.h"
#import "FSProDetailViewController.h"
#import "NSString+Extention.h"
#import "NSDate+Locale.h"
#import "UIColor+RGB.h"
#import "FSConfiguration.h"
#import "FSStoreDetailViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "UIImageView+WebCache.h"
#import "FSContentViewController.h"
#import "FSPointViewController.h"
#import "FSMeViewController.h"

#define PRO_LIST_FILTER_NEWEST @"newest"
#define PRO_LIST_FILTER_NEAREST @"nearest"
#define PRO_LIST_FILTER_WILLPUBLISH @"willpublish"
#define PRO_LIST_BANNER @"banner"
#define PRO_LIST_NEAREST_HEADER_CELL @"ProNearestHeaderTableCell"
#define PRO_LIST_NEAREST_CELL @"ProTableCell"

@interface FSProListViewController ()
{
    NSMutableDictionary *_dataSourceProvider;
    NSMutableArray *_dataSourceBannerData;
    NSMutableArray *_storeSource;
    NSMutableArray *_dateSource;
    NSMutableDictionary *_storeIndexSource;
    NSMutableDictionary *_dateIndexedSource;
    NSMutableArray *_cities;
    
    FSProSortBy _currentSearchIndex;
    NSMutableArray *_dataSourceList;
    NSMutableArray *_noMoreList;
    NSMutableArray *_pageIndexList;
    NSMutableArray *_refreshTimeList;
    NSMutableArray *_firstTimeList;
    BOOL _inLoading;
}

@end

@implementation FSProListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Promotions", nil);

    _currentSearchIndex = SortByDistance;
    _contentView.backgroundView = nil;
    _contentView.backgroundColor = APP_TABLE_BG_COLOR;
    _contentView.separatorColor = [UIColor clearColor];
    [_contentView registerNib:[UINib nibWithNibName:@"FSProNearestHeaderTableCell" bundle:nil] forCellReuseIdentifier:PRO_LIST_NEAREST_HEADER_CELL];
    
    [self initArray];
    __block FSProListViewController *blockSelf = self;    
    [_dataSourceProvider setValue:^(FSProListRequest *request,dispatch_block_t uicallback){
        blockSelf->_inLoading = YES;
        [request send:[FSProItems class] withRequest:request completeCallBack:^(FSEntityBase *respData) {
            blockSelf->_inLoading = NO;
            if (blockSelf->_currentSearchIndex != SortByDistance)
            {
                uicallback();
                return;
            }
            if (!respData.isSuccess)
            {
                [blockSelf reportError:respData.errorDescrip];
            }
            else
            {
                int currentPage = [[blockSelf->_pageIndexList objectAtIndex:blockSelf->_currentSearchIndex] intValue];
                FSProItems *response = (FSProItems *) respData.responseData;
                if (response.totalPageCount <= currentPage)
                    [blockSelf setNoMore:YES selectedSegmentIndex:blockSelf->_currentSearchIndex];
                [blockSelf fillFetchResultInMemory:response];
                [blockSelf reloadTableView];
            }
            if (uicallback)
                uicallback();
        }];
        
    } forKey:PRO_LIST_FILTER_NEAREST];
    
    [_dataSourceProvider setValue:^(FSProListRequest *request,dispatch_block_t uicallback){
        blockSelf->_inLoading = YES;
        [request send:[FSProItems class] withRequest:request completeCallBack:^(FSEntityBase *respData) {
            blockSelf->_inLoading = NO;
            if (blockSelf->_currentSearchIndex != SortByDate)
            {
                uicallback();
                return;
            }
            if (!respData.isSuccess)
            {
                [blockSelf reportError:respData.errorDescrip];
                
            }
            else
            {
                int currentPage = [[blockSelf->_pageIndexList objectAtIndex:blockSelf->_currentSearchIndex] intValue];
                FSProItems *response = (FSProItems *) respData.responseData;
                if (response.totalPageCount <= currentPage)
                    [blockSelf setNoMore:YES selectedSegmentIndex:blockSelf->_currentSearchIndex];
                [blockSelf fillFetchResultInMemory:response];
                [blockSelf reloadTableView];
            }
            if (uicallback)
                uicallback();
            
        }];
        
    } forKey:PRO_LIST_FILTER_NEWEST];
    
    [_dataSourceProvider setValue:^(FSProListRequest *request,dispatch_block_t uicallback){
        blockSelf->_inLoading = YES;
        [request send:[FSProItems class] withRequest:request completeCallBack:^(FSEntityBase *respData) {
            blockSelf->_inLoading = NO;
            if (blockSelf->_currentSearchIndex != SortByPre)
            {
                uicallback();
                return;
            }
            if (!respData.isSuccess)
            {
                [blockSelf reportError:respData.errorDescrip];
                
            }
            else
            {
                int currentPage = [[blockSelf->_pageIndexList objectAtIndex:blockSelf->_currentSearchIndex] intValue];
                FSProItems *response = (FSProItems *) respData.responseData;
                if (response.totalPageCount <= currentPage)
                    [blockSelf setNoMore:YES selectedSegmentIndex:blockSelf->_currentSearchIndex];
                [blockSelf fillFetchResultInMemory:response];
                [blockSelf reloadTableView];
            }
            if (uicallback)
                uicallback();
            
        }];
        
    } forKey:PRO_LIST_FILTER_WILLPUBLISH];
    
    [_dataSourceProvider setValue:^(FSProListRequest *request,dispatch_block_t uicallback){
        [request send:[FSProItems class] withRequest:request completeCallBack:^(FSEntityBase *respData) {
            if (!respData.isSuccess)
            {
                [blockSelf reportError:respData.errorDescrip];
            }
            else
            {
                FSProItems *response = (FSProItems *)respData.responseData;
                [blockSelf->_dataSourceBannerData removeAllObjects];
                for (FSProItemEntity *item in response.items) {
                    [blockSelf->_dataSourceBannerData addObject:item];
                }
            }
            if (uicallback)
                uicallback();
        }];
    } forKey:PRO_LIST_BANNER];
    
    [self setFilterType];
    [self initContentView];
    [self performSelector:@selector(loadBannerData) withObject:nil afterDelay:0.8];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_dataSourceBannerData.count > 0) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

-(void)dealloc
{
   // [[FSLocationManager sharedLocationManager] removeObserver:self forKeyPath:@"locationAwared"];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

-(void)loadBannerData
{
    DataSourceProviderRequest2Block block = [_dataSourceProvider objectForKey:PRO_LIST_BANNER];
    FSProListRequest *request = [[FSProListRequest alloc] init];
    request.routeResourcePath = RK_REQUEST_PRO_BANNER_LIST;
    request.requestType = 1;
    request.pageSize = COMMON_PAGE_SIZE;
    request.nextPage = 1;
    request.filterType = FSProSortByDate;
    block(request,^(){
        if (_dataSourceBannerData.count > 0) {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            FSCycleScrollView *csView = [[FSCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, NAV_HIGH)];
            csView.delegate = self;
            csView.datasource = self;
            csView.pageControl.frame = CGRectMake(0, 27, APP_WIDTH, 19);
            [self.view addSubview:csView];
            [self updateFrame];
        }
        else{
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
    });
}

-(void)initArray
{
    _dataSourceList = [@[] mutableCopy];
    _pageIndexList = [@[] mutableCopy];
    _noMoreList = [@[] mutableCopy];
    _refreshTimeList = [@[] mutableCopy];
    _firstTimeList = [@[] mutableCopy];
    
    for (int i = 0; i < 3; i++) {
        [_dataSourceList insertObject:[@[] mutableCopy] atIndex:i];
        [_pageIndexList insertObject:@1 atIndex:i];
        [_noMoreList insertObject:@NO atIndex:i];
        [_refreshTimeList insertObject:[NSDate date] atIndex:i];
        [_firstTimeList insertObject:[NSDate date] atIndex:i];
    }
    
    _dataSourceProvider = [@{} mutableCopy];
    _dataSourceBannerData = [@[] mutableCopy];
    _storeSource =[@[] mutableCopy];
    _dateSource = [@[] mutableCopy];
    _storeIndexSource = [@{} mutableCopy];
    _dateIndexedSource = [@{} mutableCopy];
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

-(void)setFirstTime:(NSDate*)_date selectedSegmentIndex:(NSInteger)_selIndexSegment
{
    [_firstTimeList replaceObjectAtIndex:_selIndexSegment withObject:_date];
}

-(void)updateFrame
{
    CGRect rect;
    if (_dataSourceBannerData.count > 0) {
        rect =  self.contentView.frame;
        rect.origin.y += NAV_HIGH;
        rect.size.height -= NAV_HIGH;
        self.contentView.frame = rect;
        rect =  self.segFilters.frame;
        rect.origin.y += NAV_HIGH;
        self.segFilters.frame = rect;
    }
    else{
        rect =  self.contentView.frame;
        rect.origin.y -= NAV_HIGH;
        rect.size.height += NAV_HIGH;
        self.contentView.frame = rect;
        rect =  self.segFilters.frame;
        rect.origin.y -= NAV_HIGH;
        self.segFilters.frame = rect;
    }
}

-(void) setFilterType
{
    [_segFilters removeAllSegments];
    [_segFilters insertSegmentWithTitle:NSLocalizedString(@"Nearest", nil) atIndex:0 animated:FALSE];
    [_segFilters insertSegmentWithTitle:NSLocalizedString(@"Newest", nil) atIndex:1 animated:FALSE];
    [_segFilters insertSegmentWithTitle:NSLocalizedString(@"WillPublish", nil) atIndex:2 animated:FALSE];
    [_segFilters addTarget:self action:@selector(filterSearch:) forControlEvents:UIControlEventValueChanged];
    _segFilters.selectedSegmentIndex = SortByDistance;
}

-(void) initContentView{
    [self prepareRefreshLayout:_contentView withRefreshAction:^(dispatch_block_t action) {
        if (_inLoading)
        {
            action();
            return;
        }
        DataSourceProviderRequest2Block block = [_dataSourceProvider objectForKey:[self getKeyFromSelectedIndex]];
        FSProListRequest *request = [[FSProListRequest alloc] init];
        request.requestType = 0;
        request.routeResourcePath = RK_REQUEST_PRO_LIST;
        FSProSortType type = FSProSortDefault;
        if (_currentSearchIndex == SortByDistance) {
            type = FSProSortByDist;
        }
        else if(_currentSearchIndex == SortByDate) {
            type = FSProSortByDate;
        }
        else if(_currentSearchIndex == SortByPre) {
            type = FSProSortByPre;
        }
        request.filterType = type;
        request.longit =  [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.longitude];
        request.lantit = [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.latitude];
        request.previousLatestDate = [_refreshTimeList objectAtIndex:_currentSearchIndex];
        request.pageSize = COMMON_PAGE_SIZE;
        block(request,^(){
            action();
        });
        
        [self setRefreshTime:[NSDate date] selectedSegmentIndex:_currentSearchIndex];
    }];
    if ([FSLocationManager sharedLocationManager].locationAwared)
    {
        [self loadFirstTime];
    } else
    {
        [self registerKVO];
    }
}

-(void)loadFirstTime
{
    _currentSearchIndex = SortByDistance;
    DataSourceProviderRequest2Block block = [_dataSourceProvider objectForKey:[self getKeyFromSelectedIndex]];
    [self setFirstTime:[NSDate date] selectedSegmentIndex:_currentSearchIndex];
    [self setPageIndex:1 selectedSegmentIndex:_currentSearchIndex];
    FSProListRequest *request = [[FSProListRequest alloc] init];
    request.filterType= FSProSortByDist;
    request.routeResourcePath = RK_REQUEST_PRO_LIST;
    request.longit = [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.longitude];
    request.lantit = [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.latitude];
    request.nextPage = 1;
    request.pageSize = COMMON_PAGE_SIZE;
    request.requestType = 1;
    request.previousLatestDate = [_firstTimeList objectAtIndex:_currentSearchIndex];
    [self beginLoading:_contentView];
    block(request,^(){
        [self endLoading:_contentView];
    });
}

-(void)registerKVO
{
    if ([FSLocationManager sharedLocationManager].locationAwared)
    {
        [self loadFirstTime];
        return;
    }
    [[FSLocationManager sharedLocationManager] addObserver:self forKeyPath:@"locationAwared" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [[FSLocationManager sharedLocationManager] removeObserver:self forKeyPath:@"locationAwared"];
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(reloadSortbyDistance:) withObject:keyPath waitUntilDone:NO];
	} else {
		[self reloadSortbyDistance:keyPath];
	}
}
-(void)reloadSortbyDistance:(NSString *)keyPath
{
    [self loadFirstTime];
}

-(NSString *)getKeyFromSelectedIndex
{
    switch (_currentSearchIndex)
    {
        case SortByDistance:
            return PRO_LIST_FILTER_NEAREST;
        case SortByDate:
            return PRO_LIST_FILTER_NEWEST;
        case SortByPre:
            return PRO_LIST_FILTER_WILLPUBLISH;
        default:
            break;
    }
    return nil;
}

-(void) reloadTableView
{
    [_contentView reloadData];
}

-(void)filterSearch:(UISegmentedControl *) segmentedControl
{
    int index = segmentedControl.selectedSegmentIndex;
    if(_currentSearchIndex == index || _inLoading)
    {
        return;
    }
    _currentSearchIndex = index;
    NSMutableArray *source = [_dataSourceList objectAtIndex:_currentSearchIndex];
    if (source == nil || source.count<=0)
    {
        [self setFirstTime:[NSDate date] selectedSegmentIndex:_currentSearchIndex];
        [self setRefreshTime:[NSDate date] selectedSegmentIndex:_currentSearchIndex];
        
        DataSourceProviderRequest2Block block = [_dataSourceProvider objectForKey:[self getKeyFromSelectedIndex]];
        FSProListRequest *request = [[FSProListRequest alloc] init];
        request.nextPage = 1;
        request.routeResourcePath = RK_REQUEST_PRO_LIST;
        FSProSortType type = FSProSortDefault;
        if (_currentSearchIndex == SortByDistance) {
            type = FSProSortByDist;
        }
        else if(_currentSearchIndex == SortByDate) {
            type = FSProSortByDate;
        }
        else if(_currentSearchIndex == SortByPre) {
            type = FSProSortByPre;
        }
        request.filterType = type;
        request.previousLatestDate = [NSDate date];
        request.longit = [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.longitude];
        request.lantit = [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.latitude];
        request.pageSize = COMMON_PAGE_SIZE;
        request.requestType = 1;
        
        [self beginLoading:_contentView];
        block(request,^(){
            [self endLoading:_contentView];
            [_contentView setContentOffset:CGPointZero];
            [self reloadTableView];
        });
    } else{
        [self showBlankIcon];
        [self reloadTableView];
        [_contentView setContentOffset:CGPointZero];
    }
}

-(void)calculateHeight:(FSProItems *)pros
{
    for (FSProItemEntity *item in pros.items) {
        item.height = [item.title sizeWithFont:FONT(11) constrainedToSize:CGSizeMake(175, 1000) lineBreakMode:NSLineBreakByCharWrapping].height + 20;
        NSLog(@"item.height:%d", item.height);
    }
}

-(void)fillFetchResultInMemory:(FSProItems *)pros isInsert:(BOOL)inserted
{
    NSMutableArray *tmpPros = [_dataSourceList objectAtIndex:_currentSearchIndex];
    [self calculateHeight:pros];
    @synchronized(tmpPros)
    {
        [pros.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            int index = [tmpPros indexOfObjectPassingTest:^BOOL(id obj1, NSUInteger idx1, BOOL *stop1) {
                if ([[(FSProItemEntity *)obj1 valueForKey:@"id"] isEqualToValue:[(FSProItemEntity *)obj valueForKey:@"id"]])
                {
                    return TRUE;
                    *stop1 = TRUE;
                }
                return FALSE;
            }];
            if (index == NSNotFound)
            {
                if (inserted)
                {
                    [tmpPros insertObject:obj atIndex:0];
                }
                else
                {
                    [tmpPros addObject:obj];
                }
                switch (_currentSearchIndex) {
                    case 0:
                        [self mergeByStore:obj isInserted:inserted];
                        break;
                    case 1:
                        [self mergeByDate:obj isInserted:inserted];
                        break;
                    case 2:
                        [self mergeByPre:obj isInserted:inserted];
                        break;
                    default:
                        break;
                }
            }
        }];
    }
    [self showBlankIcon];
}

-(void)showBlankIcon
{
    NSMutableArray *tmpPros = [_dataSourceList objectAtIndex:_currentSearchIndex];
    if (tmpPros.count < 1) {
        [self showNoResultImage:_contentView withImage:@"blank_activity.png" withText:NSLocalizedString(@"TipInfo_Promotion_List", nil) originOffset:50];
    }
    else{
        [self hideNoResultImage:_contentView];
    }
}

-(void) mergeByDate:(FSProItemEntity *)obj isInserted:(BOOL)isInsert
{
    int dateIndex = [_dateSource indexOfObjectPassingTest:^BOOL(id obj2, NSUInteger idx, BOOL *stop) {
        if ([(NSDate *)obj2 isSameDay:[obj startDate]])
        {
            *stop = TRUE;
            return TRUE;
        }
        return  FALSE;
    }];
    NSDateFormatter *mdf = [[NSDateFormatter alloc]init];
    [mdf setDateFormat:@"yyyy-MM-dd"];
    NSDate *formatDate = [mdf dateFromString:[mdf stringFromDate:[obj startDate]]];
    NSMutableArray *indexDates = [_dateIndexedSource objectForKey:[mdf stringFromDate:formatDate]];
    if (!indexDates)
    {
        indexDates =[@[] mutableCopy];
        [_dateIndexedSource setValue:indexDates forKey:[mdf stringFromDate:formatDate ]];
    }
    if (isInsert)
    {
        if (dateIndex ==NSNotFound)
            [_dateSource insertObject:formatDate atIndex:0];
        [indexDates insertObject:obj atIndex:0];
    }
    else
    {
        if (dateIndex ==NSNotFound)
            [_dateSource addObject:formatDate];
        
        [indexDates addObject:obj];
    }
}

-(void) mergeByStore:(FSProItemEntity *)obj isInserted:(BOOL)isInsert
{
    int storeIndex = [_storeSource indexOfObjectPassingTest:^BOOL(id obj2, NSUInteger idx, BOOL *stop) {
        if ([[(FSStore *)obj2 valueForKey:@"id"] isEqualToValue:[[obj store] valueForKey:@"id"]])
        {
            *stop = TRUE;
            return TRUE;
        }
        return  FALSE;
    }];
    NSString *storeKey = [NSString stringWithFormat:@"%d",[[obj.store valueForKey:@"id"] intValue]];
    NSMutableArray *indexStore = [_storeIndexSource objectForKey:storeKey];
    if (!indexStore)
    {
        indexStore =[@[] mutableCopy];
        [_storeIndexSource setValue:indexStore forKey:storeKey];
    }
    if (isInsert)
    {
        if (storeIndex ==NSNotFound)
            [_storeSource insertObject:obj.store atIndex:0];
        [indexStore insertObject:obj atIndex:0];
    }
    else
    {
        if (storeIndex ==NSNotFound)
            [_storeSource addObject:obj.store];
        
        [indexStore addObject:obj];
    }
}

-(void) mergeByPre:(FSProItemEntity *)obj isInserted:(BOOL)isInsert
{
    if (_currentSearchIndex != SortByPre) {
        return;
    }
    NSMutableArray *tmpPros = [_dataSourceList objectAtIndex:_currentSearchIndex];
    int storeIndex = [tmpPros indexOfObjectPassingTest:^BOOL(id obj2, NSUInteger idx, BOOL *stop) {
        if ([[(FSProItemEntity *)obj2 valueForKey:@"id"] isEqualToValue:[obj valueForKey:@"id"]])
        {
            *stop = TRUE;
            return TRUE;
        }
        return  FALSE;
    }];
    if (storeIndex ==NSNotFound && obj) {
        if (isInsert) {
            [tmpPros insertObject:obj atIndex:0];
        }
        else{
            [tmpPros addObject:obj];
        }
    }
}

-(void)fillFetchResultInMemory:(FSProItems *)pros
{
    [self fillFetchResultInMemory:pros isInsert:false];
}

-(void)loadMore{
    if (_inLoading)
        return;
    DataSourceProviderRequest2Block block = [_dataSourceProvider objectForKey:[self getKeyFromSelectedIndex]];
    FSProListRequest *request = [[FSProListRequest alloc] init];
    request.requestType = 1;
    request.routeResourcePath = RK_REQUEST_PRO_LIST;
    request.pageSize = COMMON_PAGE_SIZE;
    FSProSortType type = FSProSortDefault;
    if (_currentSearchIndex == SortByDistance) {
        type = FSProSortByDist;
    }
    else if(_currentSearchIndex == SortByDate) {
        type = FSProSortByDate;
    }
    else if(_currentSearchIndex == SortByPre) {
        type = FSProSortByPre;
    }
    request.filterType = type;
    request.longit = [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.longitude];
    request.lantit = [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.latitude];
    request.previousLatestDate = [_firstTimeList objectAtIndex:_currentSearchIndex];
    request.nextPage = [[_pageIndexList objectAtIndex:_currentSearchIndex] intValue] + 1;
    [self beginLoadMoreLayout:_contentView];
    block(request,^(){
        [self endLoadMore:_contentView];
    });
    
}

-(void)clickToStore:(UITapGestureRecognizer*)gesture
{
    id view = gesture.view;
    [self toStore:view];
}

-(void)clickToStoreByButton:(UIButton*)sender
{
    id view = sender.superview;
    [self toStore:view];
}

-(void)toStore:(UIView*)view
{
    if ([view isKindOfClass:[FSProNearestHeaderTableCell class]]) {
        FSProNearestHeaderTableCell *cell = (FSProNearestHeaderTableCell*)view;
        if (_storeSource.count >= cell.tag) {
            FSStore * store = [_storeSource objectAtIndex:cell.tag];
            FSStoreDetailViewController *storeController = [[FSStoreDetailViewController alloc] initWithNibName:@"FSStoreDetailViewController" bundle:nil];
            storeController.storeID = store.id;
            storeController.title = store.name;
            [self.navigationController setNavigationBarHidden:NO];
            [self.navigationController pushViewController:storeController animated:YES];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    switch (_currentSearchIndex) {
        case SortByDistance:
            return _storeSource.count;
            break;
        case SortByDate:
            return _dateSource.count;
        case SortByPre:
            return 1;
        default:
            break;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (_currentSearchIndex) {
        case SortByDistance:
        {
            int storeId = [[[_storeSource objectAtIndex:section] valueForKey:@"id"] intValue];
            NSArray *rows =  [_storeIndexSource objectForKey:[NSString stringWithFormat:@"%d",storeId]];
            if (rows.count > 2) {
                return 2;
            }
            return rows.count;
            break;
        }
        case SortByDate:
        {
            NSDate *sectionDate = [_dateSource objectAtIndex:section];
            NSDateFormatter *mdf = [[NSDateFormatter alloc]init];
            [mdf setDateFormat:@"yyyy-MM-dd"];
            NSMutableArray *rows = [_dateIndexedSource objectForKey:[mdf stringFromDate:sectionDate]];
            return rows.count;
            break;
        }
        case SortByPre:
        {
            if (_dataSourceList.count > _currentSearchIndex) {
                NSMutableArray *tmpPros = [_dataSourceList objectAtIndex:_currentSearchIndex];
                return tmpPros.count;
            }
        }
        default:
            break;
    }
    return 0;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (_currentSearchIndex) {
        case SortByDistance:
        {
            FSProNearestHeaderTableCell *header = [[[NSBundle mainBundle] loadNibNamed:@"FSProNearestHeaderTableCell" owner:self options:nil] lastObject];
            header.tag = section;
            FSStore * store = [_storeSource objectAtIndex:section];
            header.lblTitle.text =[NSString stringWithFormat:NSLocalizedString(@"%@", nil),store.name];
            [header.lblTitle sizeToFit];
            if (store.distance <= 0 || store.distance > 10000) {
                header.lblDistance.hidden = YES;
            }
            else{
                header.lblDistance.hidden = NO;
                header.lblDistance.frame = CGRectMake(header.lblTitle.frame.origin.x + header.lblTitle.frame.size.width, header.lblTitle.frame.origin.y + 2, 200, header.frame.size.height);
                if (store.distance >= 100) {
                    header.lblDistance.text = [NSString stringWithFormat:@"(约%.0f公里)",store.distance];
                }
                else{
                    header.lblDistance.text = [NSString stringWithFormat:@"(约%.2f公里)",store.distance];
                }
                [header.lblDistance sizeToFit];
            }
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToStore:)];
            [header addGestureRecognizer:tapGesture];
            [header.moreBtn addTarget:self action:@selector(clickToStoreByButton:) forControlEvents:UIControlEventTouchUpInside];
            return header;
            break;
        }
        case SortByDate:
        {
            FSProNewHeaderView_1 *header = [[[NSBundle mainBundle] loadNibNamed:@"FSProNewHeaderView" owner:self options:nil] objectAtIndex:0];
            NSDate * date = [_dateSource objectAtIndex:section];
            header.data = date;
            return header;
            break;
        }
        default:
            break;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (_currentSearchIndex) {
        case SortByDistance:
        {
            return 40;
        }
            break;
        case SortByDate:
        {
            return 40;
        }
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (_currentSearchIndex) {
        case SortByDistance:
        {
            FSProNearDetailCell *listCell = [_contentView dequeueReusableCellWithIdentifier:@"FSProNearDetailCell"];
            if (listCell == nil) {
                NSArray *_array = [[NSBundle mainBundle] loadNibNamed:@"FSProNearDetailCell" owner:self options:nil];
                if (_array.count > 0) {
                    listCell = (FSProNearDetailCell*)_array[0];
                }
                else{
                    listCell = [[FSProNearDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FSProNearDetailCell"];
                }
            }
            listCell.contentView.backgroundColor = [UIColor colorWithHexString:@"909090"];
            listCell.lblTitle.textColor = [UIColor whiteColor];
            listCell.lblTitle.font = ME_FONT(14);
            listCell.lblSubTitle.textColor = [UIColor colorWithHexString:@"#dddddd"];
            listCell.lblSubTitle.font = ME_FONT(13);
            listCell.line.backgroundColor = [UIColor lightGrayColor];
            listCell.line2.backgroundColor = [UIColor lightGrayColor];
            int storeId = [[[_storeSource objectAtIndex:indexPath.section] valueForKey:@"id"] intValue];
            NSArray *rows =  [_storeIndexSource objectForKey:[NSString stringWithFormat:@"%d",storeId]];
            FSProItemEntity* proData = [rows objectAtIndex:indexPath.row];
            
            NSDateFormatter *smdf = [[NSDateFormatter alloc]init];
            [smdf setDateFormat:@"yyyy.MM.dd"];
            NSDateFormatter *emdf = [[NSDateFormatter alloc]init];
            [emdf setDateFormat:@"yyyy.MM.dd"];
            
            NSString * str = [NSString stringWithFormat:@"<font size=12 color='#ccd2a3'>%@\n</font><font size=12 color='#dddddd'>至\n</font><font size=12 color='#ccd2a3'>%@\n</font>", [smdf stringFromDate:proData.startDate], [emdf stringFromDate:proData.endDate]];
            [listCell setTitle:proData.title subTitle:proData.descrip dateString:str];
            
            return listCell;
            
            break;
        }
        case SortByDate:
        case SortByPre:
        {   
            FSProDateDetailCell *listCell = [_contentView dequeueReusableCellWithIdentifier:@"FSProDateDetailCell"];
            if (listCell == nil) {
                NSArray *_array = [[NSBundle mainBundle] loadNibNamed:@"FSProNearDetailCell" owner:self options:nil];
                if (_array.count > 1) {
                    listCell = (FSProDateDetailCell*)_array[1];
                }
                else{
                    listCell = [[FSProDateDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FSProDateDetailCell"];
                }
            }
            listCell.contentView.backgroundColor = [UIColor colorWithHexString:@"909090"];
            listCell.titleView.textColor = [UIColor whiteColor];
            listCell.descView.textColor = [UIColor colorWithHexString:@"#dddddd"];
            listCell.address.textColor = [UIColor colorWithHexString:@"#dddddd"];
            listCell.line.backgroundColor = [UIColor lightGrayColor];
            listCell.line2.backgroundColor = [UIColor lightGrayColor];
            
            NSMutableArray *rows = nil;
            if (_currentSearchIndex == SortByDate) {
                NSDate *sectionDate = [_dateSource objectAtIndex:indexPath.section];
                NSDateFormatter *mdf = [[NSDateFormatter alloc]init];
                [mdf setDateFormat:@"yyyy-MM-dd"];
                rows = [_dateIndexedSource objectForKey:[mdf stringFromDate:sectionDate]];
            }
            else{
                rows = [_dataSourceList objectAtIndex:_currentSearchIndex];
            }
            FSProItemEntity * proData = [rows objectAtIndex:indexPath.row];
            
            NSDateFormatter *smdf = [[NSDateFormatter alloc]init];
            [smdf setDateFormat:@"yyyy.MM.dd"];
            NSDateFormatter *emdf = [[NSDateFormatter alloc]init];
            [emdf setDateFormat:@"yyyy.MM.dd"];
            
            NSString * str = [NSString stringWithFormat:@"<font size=12 color='#ccd2a3'>%@\n</font><font size=12 color='#dddddd'>至\n</font><font size=12 color='#ccd2a3'>%@\n</font>", [smdf stringFromDate:proData.startDate], [emdf stringFromDate:proData.endDate]];
            
            [listCell setTitle:proData.title desc:proData.descrip address:proData.store.name dateString:str];
            
            return listCell;
        }
        default:
            break;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_currentSearchIndex == SortByDistance) {
        FSProNearDetailCell *cell = (FSProNearDetailCell*)[tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.cellHeight;
    }
    else{
        FSProDateDetailCell *cell = (FSProDateDetailCell*)[tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.cellHeight;
    }
    
    return 0;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_inLoading) {
        return;
    }
    FSProDetailViewController *detailViewController = [[FSProDetailViewController alloc] initWithNibName:@"FSProDetailViewController" bundle:nil];
    NSMutableArray *rows = NULL;
    if (_currentSearchIndex==SortByDistance)
    {
        int storeId = [[[_storeSource objectAtIndex:indexPath.section] valueForKey:@"id"] intValue];
        rows =  [_storeIndexSource objectForKey:[NSString stringWithFormat:@"%d",storeId]];
    }
    else if(_currentSearchIndex==SortByDate)
    {
        NSDate *sectionDate = [_dateSource objectAtIndex:indexPath.section];
        NSDateFormatter *mdf = [[NSDateFormatter alloc]init];
        [mdf setDateFormat:@"yyyy-MM-dd"];
        rows = [_dateIndexedSource objectForKey:[mdf stringFromDate:sectionDate]];
    }
    else{
        rows = [_dataSourceList objectAtIndex:_currentSearchIndex];
    }
    detailViewController.navContext = rows;
    detailViewController.dataProviderInContext = self;
    detailViewController.indexInContext = indexPath.row;
    detailViewController.sourceType = FSSourcePromotion;
    UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    [self presentViewController:navControl animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:FALSE];
    
    //统计
    NSMutableDictionary *_dic = [NSMutableDictionary dictionaryWithCapacity:2];
    NSMutableArray *tmpPros = [_dataSourceList objectAtIndex:_currentSearchIndex];
    FSProItemEntity *_item = [tmpPros objectAtIndex:indexPath.row];
    if (_currentSearchIndex == (int)PRO_LIST_FILTER_NEAREST) {
        [_dic setValue:@"最近距离" forKey:@"查看方式"];
    }
    else {
        [_dic setValue:@"最新发布" forKey:@"查看方式"];
    }
    [_dic setValue:_item.title forKey:@"活动名称"];
    [_dic setValue:[NSString stringWithFormat:@"%d", _item.id] forKey:@"活动ID"];
    [[FSAnalysis instance] logEvent:@"查看活动详情" withParameters:_dic];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    bool cannotLoadMore = [_noMoreList objectAtIndex:_currentSearchIndex];
    if(!_inLoading
       && (scrollView.contentOffset.y+scrollView.frame.size.height) + 150 > scrollView.contentSize.height
       && scrollView.contentOffset.y>0
       && !cannotLoadMore)
    {
        [self loadMore];
    }
}

#pragma mark - FSProDetailItemSourceProvider

-(void)proDetailViewDataFromContext:(FSProDetailViewController *)view forIndex:(NSInteger)index  completeCallback:(UICallBackWith1Param)block errorCallback:(dispatch_block_t)errorBlock
{
    FSProItemEntity *item =  [view.navContext objectAtIndex:index];
    if (item)
        block(item);
    else
        errorBlock();

}
-(FSSourceType)proDetailViewSourceTypeFromContext:(FSProDetailViewController *)view forIndex:(NSInteger)index
{
    return FSSourcePromotion;
}

-(BOOL)proDetailViewNeedRefreshFromContext:(FSProDetailViewController *)view forIndex:(NSInteger)index
{
    return TRUE;
}

#pragma mark - FSCycleScrollViewDatasource & FSCycleScrollViewDelegate

- (NSInteger)numberOfPages
{
    return _dataSourceBannerData.count;
}

- (UIView *)pageAtIndex:(NSInteger)index
{
    FSProItemEntity * item = _dataSourceBannerData[index];
    NSURL *url = [(FSResource *)item.resource[0] absoluteUr:APP_WIDTH height:NAV_HIGH];
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, NAV_HIGH)];
    view.contentMode = UIViewContentModeScaleAspectFill;
    [view setImageUrl:url resizeWidth:CGSizeMake(APP_WIDTH, NAV_HIGH) placeholderImage:[UIImage imageNamed:@"default_icon320x44.png"]];
    return view;
}

- (void)didClickPage:(FSCycleScrollView *)csView atIndex:(NSInteger)index
{
    FSProItemEntity *proItem = [_dataSourceBannerData objectAtIndex:index];
    switch (proItem.targetType) {
        case SkipTypeDefault:
        case SkipTypeProductList:
        {
            FSProductListViewController *dr = [[FSProductListViewController alloc] initWithNibName:@"FSProductListViewController" bundle:nil];
            FSTopic *topic = [[FSTopic alloc] init];
            topic.name = proItem.title;
            topic.topicId = proItem.targetId;
            dr.topic = topic;
            dr.pageType = FSPageTypeTopic;
            [self.navigationController pushViewController:dr animated:TRUE];
        }
            break;
        case SkipTypePromotionDetail:
        {
            FSProDetailViewController *detailView = [[FSProDetailViewController alloc] initWithNibName:@"FSProDetailViewController" bundle:nil];
            FSProdItemEntity *item = [[FSProdItemEntity alloc] init];
            item.id = [proItem.targetId intValue];
            detailView.navContext = [[NSMutableArray alloc] initWithObjects:item, nil];
            detailView.sourceType = FSSourcePromotion;
            detailView.indexInContext = 0;
            detailView.dataProviderInContext = self;
            UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:detailView];
            [self presentViewController:navControl animated:true completion:nil];
        }
            break;
        case SkipTypeProductDetail:
        {
            FSProDetailViewController *detailView = [[FSProDetailViewController alloc] initWithNibName:@"FSProDetailViewController" bundle:nil];
            FSProItemEntity *item = [[FSProItemEntity alloc] init];
            item.id = [proItem.targetId intValue];
            detailView.navContext = [[NSMutableArray alloc] initWithObjects:item, nil];
            detailView.sourceType = FSSourceProduct;
            detailView.indexInContext = 0;
            detailView.dataProviderInContext = self;
            UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:detailView];
            [self presentViewController:navControl animated:true completion:nil];
        }
            break;
        case SkipTypeURL:
        {
            FSContentViewController *controller = [[FSContentViewController alloc] init];
            controller.fileName = proItem.targetId;
            controller.title = proItem.title;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case SkipTypeNone:
        {
            //do nothing
        }
            break;
        case SkipTypePointEx://积点兑换
        {
            bool isLogined = [[FSModelManager sharedModelManager] isLogined];
            if (!isLogined)
            {
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                FSMeViewController *loginController = [storyBoard instantiateViewControllerWithIdentifier:@"userProfile"];
                __block FSMeViewController *blockMeController = loginController;
                loginController.completeCallBack=^(BOOL isSuccess){
                    [blockMeController dismissViewControllerAnimated:true completion:^{
                        if (!isSuccess)
                        {
                            [blockMeController reportError:NSLocalizedString(@"COMM_OPERATE_FAILED", nil)];
                        }
                        else
                        {
                            FSPointViewController *pointView = [[FSPointViewController alloc] initWithNibName:@"FSPointViewController" bundle:nil];
                            pointView.currentUser = [FSUser localProfile];
                            [self.navigationController pushViewController:pointView animated:TRUE];
                        }
                    }];
                };
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
                [self presentViewController:navController animated:YES completion:nil];
                
            }
            else
            {
                FSPointViewController *pointView = [[FSPointViewController alloc] initWithNibName:@"FSPointViewController" bundle:nil];
                pointView.currentUser = [FSUser localProfile];
                [self.navigationController pushViewController:pointView animated:TRUE];
            }
        }
            break;
        default:
            break;
    }
}

@end
