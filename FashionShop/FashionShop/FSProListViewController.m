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
    
    UIRefreshControl *_refreshControl;
    EGORefreshTableHeaderView *refreshView;
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
    _currentSearchIndex=SortByNone;
    
    [_dataSourceProvider setValue:^(FSProListRequest *request,dispatch_block_t uicallback){
        
        [request send:[FSProItems class] withRequest:request completeCallBack:^(FSEntityBase *respData) {
            if (blockSelf->_currentSearchIndex != SortByDistance)
                return;
            if (!respData.isSuccess)
            {
                [blockSelf reportError:respData.errorDescrip];
                
            }
            else
            {
                FSProItems *response = (FSProItems *) respData.responseData;
                if (blockSelf->_state == BeginLoadingMore)
                {
                    if (blockSelf->_nearestPageIndex+1>=response.totalPageCount)
                    {
                        blockSelf->_noMoreNearest = true;
                        
                    }
                    blockSelf->_nearestPageIndex++;
                    if(!blockSelf->_nearLatestDate)
                        [blockSelf renewLastUpdateTime];
                    [blockSelf fillFetchResultInMemory:response];
                    
                    
                } else if(blockSelf->_state == BeginLoadingLatest){
                    
                    [blockSelf renewLastUpdateTime];
                    [blockSelf fillFetchResultInMemory:response isInsert:true];
                }
                [blockSelf reloadTableView];
            }
            if (uicallback)
                uicallback();
            
        }];
        
    } forKey:PRO_LIST_FILTER_NEAREST];
    
    [_dataSourceProvider setValue:^(FSProListRequest *request,dispatch_block_t uicallback){
        [request send:[FSProItems class] withRequest:request completeCallBack:^(FSEntityBase *respData) {
            if (blockSelf->_currentSearchIndex != SortByDate)
                return;
            if (!respData.isSuccess)
            {
                [blockSelf reportError:respData.errorDescrip];
                
            }
            else
            {
                FSProItems *response = (FSProItems *)respData.responseData;
                if (blockSelf->_state == BeginLoadingMore)
                {
                    if (blockSelf->_newestPageIndex+1>=response.totalPageCount)
                    {
                        blockSelf->_noMoreNewest = true;
                        
                    }
                    blockSelf->_newestPageIndex++;
                    if(!blockSelf->_newLatestDate)
                        [blockSelf renewLastUpdateTime];
                    [blockSelf fillFetchResultInMemory:response];
                    
                    
                } else if(blockSelf->_state == BeginLoadingLatest){
                    
                    [blockSelf renewLastUpdateTime];
                    [blockSelf fillFetchResultInMemory:response isInsert:true];
                }
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
    [self.navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeFont:ME_FONT(16),UITextAttributeTextColor:[UIColor colorWithRed:239 green:239 blue:239]}];
    

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
        DataSourceProviderRequest2Block block = [_dataSourceProvider objectForKey:[self getKeyFromSelectedIndex]];
        FSProListRequest *request = [[FSProListRequest alloc] init];
        request.requestType = 0;
        request.filterType = _currentSearchIndex ==0?FSProSortByDist:FSProSortByDate;
        request.longit =  [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.longitude];
        request.lantit = [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.latitude];
        request.previousLatestDate = _currentSearchIndex == 0?_nearLatestDate:_newLatestDate;
        _state = BeginLoadingLatest;
        block(request,^(){
            action();
            _state = EndLoadingLatest;
            
        });

    }];
    _state = NormalList;
    //load data first time;
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
    [self beginLoading:_contentView];
    _state = BeginLoadingMore;
    block(request,^(){
        _state = EndLoadingMore;
        [self endLoading:_contentView];
        
    });
    
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
    if(_currentSearchIndex==index)
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
        block(request,^(){
            _state = EndLoadingMore;
            [self endLoading:_contentView];
        });
    } else{
        [self reloadTableView];
    }
}

-(void)fillFetchResultInMemory:(FSProItems *)pros isInsert:(bool)inserted
{
    NSMutableArray *tmpPros =[_dataSourcePro objectForKey:[self getKeyFromSelectedIndex]];
    if (pros.items==nil || pros.items.count<=0)
        return;
    
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
        if ([[(FSStore *)obj2 valueForKey:@"id"] isEqualToValue:[[obj store]valueForKey:@"id"]])
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
-(void)fillFetchResultInMemory:(FSProItems *)pros
{
    
    [self fillFetchResultInMemory:pros isInsert:false];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadLatest{
    DataSourceProviderRequest2Block block = [_dataSourceProvider objectForKey:[self getKeyFromSelectedIndex]];
    FSProListRequest *request = [[FSProListRequest alloc] init];
    request.requestType = 0;
    request.filterType = _currentSearchIndex ==0?FSProSortByDist:FSProSortByDate;
    request.longit =  [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.longitude];
    request.lantit = [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.latitude];
    request.previousLatestDate = _currentSearchIndex == 0?_nearLatestDate:_newLatestDate;
    _state = BeginLoadingLatest;
    block(request,^(){
        [_refreshControl endRefreshing];
        _state = EndLoadingLatest;
        
    });
    
}

-(void)loadMore{
    
    UIActivityIndicatorView *loadMore = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    _contentView.tableFooterView = loadMore;
    [loadMore startAnimating];
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
    block(request,^(){
        _contentView.tableFooterView = nil;
        _state = EndLoadingMore;
    });
    
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
            FSStore * store = [_storeSource objectAtIndex:section];
            header.lblTitle.text =[NSString stringWithFormat:NSLocalizedString(@"%@(%@)", nil),store.name,[NSString stringMetersFromDouble:store.distance]];
            return header;
            break;
        }
        case SortByDate:
        {
            FSProNewHeaderView *header = [[[NSBundle mainBundle] loadNibNamed:@"FSProNewHeaderView" owner:self options:nil] lastObject];
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
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (_currentSearchIndex) {
        case SortByDistance:
        {
            FSProNearDetailCell *listCell = [_contentView dequeueReusableCellWithIdentifier:PRO_LIST_NEAREST_CELL];
            int storeId = [[_storeSource objectAtIndex:indexPath.section] id];
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
    detailViewController.navContext = [_dataSourcePro objectForKey:[self getKeyFromSelectedIndex]];
    detailViewController.dataProviderInContext = self;
    int rows = 0;
    for(int i=0;i<indexPath.section;i++)
    {
        rows+= [self tableView:tableView numberOfRowsInSection:i];
    }
    detailViewController.indexInContext = rows+indexPath.row;
    detailViewController.sourceType = FSSourcePromotion;
    UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    [self presentViewController:navControl animated:YES completion:nil];
    
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

#pragma FSProDetailItemSourceProvider
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

- (void)viewDidUnload {
    [self setLblTitle:nil];
    [super viewDidUnload];
}
@end
