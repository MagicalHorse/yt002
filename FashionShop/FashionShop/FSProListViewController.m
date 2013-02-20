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
#import "UIViewController+Loading.h"
#import "NSString+Extention.h"
#import "NSDate+Locale.h"
#import "UIColor+RGB.h"
#import "FSConfiguration.h"
#import "FSStoreDetailViewController.h"

#import "EGORefreshTableHeaderView.h"

#define PRO_LIST_FILTER_NEWEST @"newest"
#define PRO_LIST_FILTER_NEAREST @"nearest"
#define PRO_LIST_NEAREST_HEADER_CELL @"ProNearestHeaderTableCell"
#define PRO_LIST_NEAREST_CELL @"ProTableCell"
#define PRO_LIST_PAGE_SIZE @10

typedef enum {
    NormalList = 0,
    BeginLoadingMore = 1,
    EndLoadingMore = 2,
    BeginLoadingLatest = 3,
    EndLoadingLatest = 4
}ListSearchState;

typedef enum {
    SortByNone = -1,
    SortByDistance = 0,
    SortByDate = 1,
    SortByPre = 2
}FSProSortBy;

@interface FSProListViewController ()
{
    FSProSortBy _currentSearchIndex;
    NSMutableDictionary *_dataSourceProvider;
    NSMutableDictionary *_dataSourcePro;
    NSMutableArray *_storeSource;
    NSMutableArray *_dateSource;
    NSMutableDictionary *_storeIndexSource;
    NSMutableDictionary *_dateIndexedSource;
    NSMutableArray *_cities;
    
    ListSearchState _state;
    
    int _nearestPageIndex;
    int _newestPageIndex;
    NSDate *_nearLatestDate;
    NSDate *_newLatestDate;
    NSDate * _nearFirstLoadDate;
    NSDate * _newFirstLoadDate;
    
    bool _noMoreNearest;
    bool _noMoreNewest;
    bool _inLoading;
    
  
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
    

    // Do any additional setup after loading the view
    _nearestPageIndex = 0;
    _newestPageIndex = 0;

    
    _dataSourceProvider = [@{} mutableCopy];
    _dataSourcePro = [@{} mutableCopy];
    _storeSource =[@[] mutableCopy];
    _dateSource = [@[] mutableCopy];
    _storeIndexSource = [@{} mutableCopy];
    _dateIndexedSource = [@{} mutableCopy];
    [_dataSourcePro setObject:[@[] mutableCopy] forKey:PRO_LIST_FILTER_NEWEST];
    [_dataSourcePro setObject:[@[] mutableCopy] forKey:PRO_LIST_FILTER_NEAREST];
    __block FSProListViewController *blockSelf = self;
    _currentSearchIndex=SortByDistance;
    
    [_dataSourceProvider setValue:^(FSProListRequest *request,dispatch_block_t uicallback){
        
        [request send:[FSProItems class] withRequest:request completeCallBack:^(FSEntityBase *respData) {
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
                FSProItems *response = (FSProItems *) respData.responseData;
                if (blockSelf->_state == BeginLoadingMore)
                {
                    blockSelf->_nearestPageIndex++;
                    [blockSelf fillFetchResultInMemory:response];
                    
                    
                } else if(blockSelf->_state == BeginLoadingLatest){
                    blockSelf->_nearestPageIndex = 1;
                    [blockSelf renewLastUpdateTime];
                    //[blockSelf fillFetchResultInMemory:response isInsert:true];
                    [blockSelf fillFetchResultInMemory:response isInsert:false];
                }
                blockSelf->_noMoreNearest = blockSelf->_nearestPageIndex+1>response.totalPageCount;
                [blockSelf reloadTableView];
            }
            if (uicallback)
                uicallback();
            
        }];
        
    } forKey:PRO_LIST_FILTER_NEAREST];
    
    [_dataSourceProvider setValue:^(FSProListRequest *request,dispatch_block_t uicallback){
        [request send:[FSProItems class] withRequest:request completeCallBack:^(FSEntityBase *respData) {
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
                FSProItems *response = (FSProItems *)respData.responseData;
                if (blockSelf->_state == BeginLoadingMore)
                {
                    
                    blockSelf->_newestPageIndex++;
                    [blockSelf fillFetchResultInMemory:response];
                    
                } else if(blockSelf->_state == BeginLoadingLatest){
                    blockSelf->_newestPageIndex =1;
                    [blockSelf renewLastUpdateTime];
                    
                    //[blockSelf fillFetchResultInMemory:response isInsert:true];
                    [blockSelf fillFetchResultInMemory:response isInsert:false];
                }
                blockSelf->_noMoreNewest = blockSelf->_newestPageIndex+1>response.totalPageCount;
               
                [blockSelf reloadTableView];
            }
            if (uicallback)
                uicallback();
            
        }];
        
    } forKey:PRO_LIST_FILTER_NEWEST];
    [_contentView registerNib:[UINib nibWithNibName:@"FSProNearDetailCell" bundle:nil] forCellReuseIdentifier:PRO_LIST_NEAREST_CELL];
    [_contentView registerNib:[UINib nibWithNibName:@"FSProNearestHeaderTableCell" bundle:nil] forCellReuseIdentifier:PRO_LIST_NEAREST_HEADER_CELL];

    [self prepareLayout];
    [self setFilterType];
    [self initContentView];
    
    
}
-(void) prepareLayout
{
    self.navigationItem.title = NSLocalizedString(@"Promotions", nil);
    

}
-(void) setFilterType
{
    [_segFilters removeAllSegments];
    [_segFilters insertSegmentWithTitle:NSLocalizedString(@"Nearest", nil) atIndex:0 animated:FALSE];
    [_segFilters insertSegmentWithTitle:NSLocalizedString(@"Newest", nil) atIndex:1 animated:FALSE];
    [_segFilters addTarget:self action:@selector(filterSearch:) forControlEvents:UIControlEventValueChanged];
    _segFilters.selectedSegmentIndex = 0;
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
        request.requestType = 1;
        request.filterType = _currentSearchIndex ==0?FSProSortByDist:FSProSortByDate;
        request.longit =  [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.longitude];
        request.lantit = [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.latitude];
        request.previousLatestDate = [[NSDate alloc] init];
        request.pageSize = [PRO_LIST_PAGE_SIZE intValue];
        request.nextPage = 1;
        _state = BeginLoadingLatest;
        _inLoading = TRUE;
        block(request,^(){
            action();
            _state = EndLoadingLatest;
            _inLoading = FALSE;
        });

    }];
    _state = NormalList;
    //load data first time;
    [self beginLoading:_contentView];
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
    FSProListRequest *request = [[FSProListRequest alloc] init];
    request.filterType= FSProSortByDist;
    request.longit = [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.longitude];
    request.lantit = [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.latitude];
    _nearFirstLoadDate = [[NSDate alloc] init];
    request.previousLatestDate = _nearFirstLoadDate;
    request.nextPage = 1;
    request.pageSize = [PRO_LIST_PAGE_SIZE intValue];
    request.requestType = 1;
    
    _state = BeginLoadingMore;
    _inLoading = TRUE;
    block(request,^(){
        _state = EndLoadingMore;
        [self endLoading:_contentView];
        _inLoading = FALSE;
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
-(void) renewLastUpdateTime
{
    if (_currentSearchIndex == 0)
        _nearLatestDate = [[NSDate alloc] init];
    else
        _newLatestDate =[[NSDate alloc] init];
}

-(NSString *)getKeyFromSelectedIndex
{
    
    switch (_currentSearchIndex)
    {
        case SortByDistance:
            return PRO_LIST_FILTER_NEAREST;
        case SortByDate:
            return PRO_LIST_FILTER_NEWEST;
            
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
    if(_currentSearchIndex==index ||
       _inLoading)
    {
        return;
    }
    _currentSearchIndex = index;
    //check whether have data in memory, if yes, just let it be;
    NSMutableArray *source = [_dataSourcePro objectForKey:[self getKeyFromSelectedIndex]];
    if (source == nil || source.count<=0)
    {
        DataSourceProviderRequest2Block block = [_dataSourceProvider objectForKey:[self getKeyFromSelectedIndex]];
        FSProListRequest *request = [[FSProListRequest alloc] init];
        request.nextPage = 1;
        request.filterType= _currentSearchIndex ==0?FSProSortByDist:FSProSortByDate;
        if (_currentSearchIndex == 1)
            _newFirstLoadDate = [[NSDate alloc] init];
        request.previousLatestDate = _currentSearchIndex==0?_nearFirstLoadDate: _newFirstLoadDate;
        request.longit = [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.longitude];
        request.lantit = [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.latitude];
        request.pageSize = [PRO_LIST_PAGE_SIZE intValue];
        [self beginLoading:_contentView];
        _state = BeginLoadingMore;
        _inLoading = TRUE;
        block(request,^(){
            _state = EndLoadingMore;
            _inLoading = FALSE;
            [self endLoading:_contentView];
            [_contentView setContentOffset:CGPointZero];
        });
    } else{
        [self reloadTableView];
        [_contentView setContentOffset:CGPointZero];
    }
}

-(void)fillFetchResultInMemory:(FSProItems *)pros isInsert:(bool)inserted
{
    NSMutableArray *tmpPros =[_dataSourcePro objectForKey:[self getKeyFromSelectedIndex]];
    if (pros.items==nil || pros.items.count<=0)
        return;
    if (inserted)
    {
        [tmpPros removeAllObjects];
        if (_currentSearchIndex==0)
        {
            [_storeIndexSource removeAllObjects];
            [_storeSource removeAllObjects];
        } else
        {
            [_dateIndexedSource removeAllObjects];
            [_dateSource removeAllObjects];
        }
    }
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
            if (index==NSNotFound)
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
                        break;
                    default:
                        break;
                }
            }
        }];
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
    
    if (_dateSource.count<1)
    {
        //加载空视图
        [self showNoResultImage:_contentView withImage:@"blank_activity.png" withText:NSLocalizedString(@"TipInfo_Promotion_List", nil)   originOffset:30];
    }
    else
    {
        [self hideNoResultImage:_contentView ];
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
    
    if (_storeSource.count<1)
    {
        //加载空视图
        [self showNoResultImage:_contentView withImage:@"blank_activity.png" withText:NSLocalizedString(@"TipInfo_Promotion_List", nil)   originOffset:30];
    }
    else
    {
        [self hideNoResultImage:_contentView ];
    }
}
-(void)fillFetchResultInMemory:(FSProItems *)pros
{
    
    [self fillFetchResultInMemory:pros isInsert:false];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)loadMore{
    if (_inLoading)
        return;
    //UIActivityIndicatorView *loadMore = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    //_contentView.tableFooterView = loadMore;
    //[loadMore startAnimating];
    [self beginLoadMoreLayout:_contentView];
    DataSourceProviderRequest2Block block = [_dataSourceProvider objectForKey:[self getKeyFromSelectedIndex]];
    FSProListRequest *request = [[FSProListRequest alloc] init];
    request.requestType = 1;
    request.pageSize = [PRO_LIST_PAGE_SIZE intValue];
    request.filterType= _currentSearchIndex ==0?FSProSortByDist:FSProSortByDate;
    request.longit = [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.longitude];
    request.lantit = [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.latitude];
    request.previousLatestDate =_currentSearchIndex==0?_nearFirstLoadDate:_newFirstLoadDate;
    request.nextPage = (_currentSearchIndex==0?_nearestPageIndex:_newestPageIndex)+1;
    _state = BeginLoadingMore;
    _inLoading = TRUE;
    block(request,^(){
        //_contentView.tableFooterView = nil;
        [self endLoadMore:_contentView];
        _state = EndLoadingMore;
        _inLoading = FALSE;
    });
    
}

-(void)clickToStore:(UITapGestureRecognizer*)gesture
{
    id view = gesture.view;
    if ([view isKindOfClass:[FSProNearestHeaderTableCell class]]) {
        FSProNearestHeaderTableCell *cell = (FSProNearestHeaderTableCell*)view;
        if (_storeSource.count >= cell.tag) {
            FSStore * store = [_storeSource objectAtIndex:cell.tag];
            FSStoreDetailViewController *storeController = [[FSStoreDetailViewController alloc] initWithNibName:@"FSStoreDetailViewController" bundle:nil];
            storeController.store = store;
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
            header.lblDistance.frame = CGRectMake(header.lblTitle.frame.origin.x + header.lblTitle.frame.size.width, header.lblTitle.frame.origin.y + 2, 200, header.frame.size.height);
            header.lblDistance.text = [NSString stringWithFormat:@"(%@)",[NSString stringMetersFromDouble:store.distance]];
            [header.lblDistance sizeToFit];
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToStore:)];
            [header addGestureRecognizer:tapGesture];
            return header;
            break;
        }
        case SortByDate:
        {
            FSProNewHeaderView_1 *header = [[[NSBundle mainBundle] loadNibNamed:@"FSProNewHeaderView" owner:self options:nil] objectAtIndex:1];
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
    return 40;
    
    switch (_currentSearchIndex) {
        case SortByDistance:
        {
            return 40;
            break;
        }
        case SortByDate:
        {
            return 55;
            break;
            
        }
        default:
            break;
    }
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (_currentSearchIndex) {
        case SortByDistance:
        {
            FSProNearDetailCell *listCell = [_contentView dequeueReusableCellWithIdentifier:PRO_LIST_NEAREST_CELL];
            int storeId = [[[_storeSource objectAtIndex:indexPath.section] valueForKey:@"id"] intValue];
            NSArray *rows =  [_storeIndexSource objectForKey:[NSString stringWithFormat:@"%d",storeId]];
          
            FSProItemEntity* proData = [rows objectAtIndex:indexPath.row];
            NSDateFormatter *smdf = [[NSDateFormatter alloc]init];
            [smdf setDateFormat:@"yyyy.MM.dd"];
            NSDateFormatter *emdf = [[NSDateFormatter alloc]init];
            [emdf setDateFormat:@"MM.dd"];
            listCell.lblTitle.text = proData.title;
            listCell.lblSubTitle.text = [NSString stringWithFormat:NSLocalizedString(@"%@~%@", nil),[smdf stringFromDate:proData.startDate],[emdf stringFromDate:proData.endDate]];
                       return listCell;
            break;
        }
        case SortByDate:
        {
            FSProNearDetailCell *listCell = [_contentView dequeueReusableCellWithIdentifier:PRO_LIST_NEAREST_CELL ];
            NSDate *sectionDate = [_dateSource objectAtIndex:indexPath.section];
            NSDateFormatter *mdf = [[NSDateFormatter alloc]init];
            [mdf setDateFormat:@"yyyy-MM-dd"];
            NSMutableArray *rows = [_dateIndexedSource objectForKey:[mdf stringFromDate:sectionDate]];
            FSProItemEntity * proData = [rows objectAtIndex:indexPath.row];
            listCell.lblTitle.text = proData.title;
            listCell.lblSubTitle.text = proData.store.name;
            return listCell;

        }
        default:
            break;
    }
    return nil;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row %2==0)
    {
        cell.backgroundColor = PRO_LIST_NEAR_CELL1_BGCOLOR;
        [(FSProNearDetailCell *)cell lblTitle].textColor = PRO_LIST_NEAR_CELL_LCOLOR;
        [(FSProNearDetailCell *)cell lblTitle].font = [UIFont systemFontOfSize:PRO_LIST_NEAR_CELL_LFONTSZ];
        [(FSProNearDetailCell *)cell lblSubTitle].textColor = PRO_LIST_NEAR_CELL_RCOLOR;
        [(FSProNearDetailCell *)cell lblSubTitle].font = [UIFont systemFontOfSize:PRO_LIST_NEAR_CELL_RFONTSZ];
        
    } else
    {
        cell.backgroundColor = PRO_LIST_NEAR_CELL2_BGCOLOR;
        [(FSProNearDetailCell *)cell lblTitle].textColor = PRO_LIST_NEAR_CELL_LCOLOR;
        [(FSProNearDetailCell *)cell lblTitle].font = [UIFont systemFontOfSize:PRO_LIST_NEAR_CELL_LFONTSZ];
        [(FSProNearDetailCell *)cell lblSubTitle].textColor = PRO_LIST_NEAR_CELL_RCOLOR;
        [(FSProNearDetailCell *)cell lblSubTitle].font = [UIFont systemFontOfSize:PRO_LIST_NEAR_CELL_RFONTSZ];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSProDetailViewController *detailViewController = [[FSProDetailViewController alloc] initWithNibName:@"FSProDetailViewController" bundle:nil];
    NSMutableArray *rows = NULL;
    if (_currentSearchIndex==SortByDistance)
    {
        int storeId = [[[_storeSource objectAtIndex:indexPath.section] valueForKey:@"id"] intValue];
        rows =  [_storeIndexSource objectForKey:[NSString stringWithFormat:@"%d",storeId]];
    } else
    {
        NSDate *sectionDate = [_dateSource objectAtIndex:indexPath.section];
        NSDateFormatter *mdf = [[NSDateFormatter alloc]init];
        [mdf setDateFormat:@"yyyy-MM-dd"];
       rows = [_dateIndexedSource objectForKey:[mdf stringFromDate:sectionDate]];

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
    NSMutableArray *tmpPros =[_dataSourcePro objectForKey:[self getKeyFromSelectedIndex]];
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

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate

{
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    bool cannotLoadMore = _currentSearchIndex==0?_noMoreNearest:_noMoreNewest;
    if(_state!=BeginLoadingMore
       && (scrollView.contentOffset.y+scrollView.frame.size.height) > scrollView.contentSize.height
       &&scrollView.contentOffset.y>0
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

-(void)dealloc
{
    [[FSLocationManager sharedLocationManager] removeObserver:self forKeyPath:@"locationAwared"];
}

- (void)viewDidUnload {
    [self setLblTitle:nil];
    [super viewDidUnload];
}
@end
