//
//  FSProdListViewController.m
//  FashionShop
//
//  Created by gong yi on 12/10/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSProdListViewController.h"
#import "UIViewController+Loading.h"
#import "FSProdDetailCell.h"
#import "FSProdTagCell.h"
#import "FSProDetailViewController.h"
#import "FSProductListViewController.h"
#import "FSFeedbackViewController.h"
#import "FSCommonRequest.h"
#import "FSBrand.h"

#import "FSTag.h"
#import "FSCoreTag.h"
#import "FSProListRequest.h"
#import "FSResource.h"
#import "FSLocationManager.h"
#import "FSBothItems.h"
#import "FSModelManager.h"
#import "FSConfigListRequest.h"
#import "FSKeyword.h"

#define  PROD_LIST_TAG_CELL @"FSProdListTagCell"
#define PROD_LIST_DETAIL_CELL @"FSProdListDetailCell"
#define  PROD_LIST_DETAIL_CELL_WIDTH 100
#define LOADINGVIEW_HEIGHT 44
#define ITEM_CELL_WIDTH 100
#define DEFAULT_TAG_WIDTH 50

@implementation FSSearchBar

- (void)layoutSubviews {
    self.autoresizesSubviews = YES;
	NSUInteger numViews = [self.subviews count];
	for(int i = 0; i < numViews; i++) {
        id cc = [self.subviews objectAtIndex:i];
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
            btn.backgroundColor = RGBCOLOR(234, 234, 234);
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
            if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 60000) {
                btn.titleLabel.shadowOffset = CGSizeMake(0, 0);
            }
            cancel = btn;
        }
        if ([cc isKindOfClass:[UISegmentedControl class]]) {
            UISegmentedControl * seg = (UISegmentedControl*)cc;
            seg.tintColor = RGBCOLOR(200, 200, 200);
            [seg addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
            [self ChangeSegmentFont:seg];
        }
	}
    
    [self setCancelButtonEnable:YES];
	[super layoutSubviews];
}

-(void)setCancelButtonEnable:(BOOL)_enable
{
    if (cancel) {
        [cancel setEnabled:_enable];
    }
    else{
        NSUInteger numViews = [self.subviews count];
        for(int i = 0; i < numViews; i++) {
            id cc = [self.subviews objectAtIndex:i];
            if([cc isKindOfClass:[UIButton class]])
            {
                UIButton *btn = (UIButton *)cc;
                [btn setEnabled:_enable];
                cancel = btn;
            }
        }
    }
}

-(void)valueChanged:(UISegmentedControl *)sender
{
    [self ChangeSegmentFont:sender];
    if (_segmentDelegate && [_segmentDelegate respondsToSelector:@selector(segmentValueChanged:)]) {
        [_segmentDelegate segmentValueChanged:sender];
    }
}

-(void)ChangeSegmentFont:(UIView *)aView
{
    if ([aView isKindOfClass:[UILabel class]]) {
        UILabel *lb = (UILabel*)aView;
        [lb setTextAlignment:UITextAlignmentCenter];
        [lb setFrame:CGRectMake(0, 0, 155, 30)];
        [lb setFont:[UIFont systemFontOfSize:14]];
        lb.textColor = [UIColor blackColor];
        lb.shadowOffset = CGSizeMake(0, 0);
    }
    NSArray *na = [aView subviews];
    NSEnumerator *ne = [na objectEnumerator];
    UIView *subView;
    while (subView = [ne nextObject]) {
        [self ChangeSegmentFont:subView];
    }
}

@end

@interface FSProdListViewController ()
{
    NSMutableArray *_tags;
    NSMutableArray *_prods;
    NSMutableArray *_prodKeywords;
    NSMutableArray *_brandKeywords;
    
    UIActivityIndicatorView * moreIndicator;
    BOOL _isInLoading;
    BOOL _firstTimeLoadDone;
    int _selectedTagIndex;
    int _prodPageIndex;
    CGFloat _actualTagWidth;
    NSInteger _selectedIndex;
    
    NSDate *_refreshLatestDate;
    NSDate * _firstLoadDate;
    FSCoreTag * _currentTag;
    
    bool _noMoreResult;
    BOOL _isSearching;
    
    UIView *searchFilterView;
}

@property(nonatomic, strong, readwrite) FSSearchBar *searchBar;
@property(nonatomic, strong) UITableView *tableSearch;

@end

@implementation FSProdListViewController

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
    [self prepareLayout];
    [self prepareData];
    
    UIBarButtonItem *baritemSearch = [self createPlainBarButtonItem:@"search.png" target:self action:@selector(onSearch:)];
    [self.navigationItem setRightBarButtonItem:baritemSearch];
}

-(void)onSearch:(UIButton*)sender
{
    if (!_tableSearch) {
        self.searchBar = [[FSSearchBar alloc] initWithFrame:CGRectMake(0, -0, 0, 0)];
        self.searchBar.placeholder = NSLocalizedString(@"Search Bar PlaceHolder String", nil);
        self.searchBar.delegate = self;
        self.searchBar.showsScopeBar = YES;
        self.searchBar.selectedScopeButtonIndex = 0;
        self.searchBar.scopeButtonTitles = [NSArray arrayWithObjects:NSLocalizedString(@"Hot Keys Desc", nil),NSLocalizedString(@"Hot Brands Desc", nil), nil];
        self.searchBar.tintColor = RGBCOLOR(246, 246, 246);
        self.searchBar.segmentDelegate = self;
        self.searchBar.showsCancelButton = YES;
        [self.searchBar sizeToFit];
        _selectedIndex = 0;
        [self segmentValueChanged:nil];
        
        CGRect _rect = self.view.bounds;
        _rect.size.height += NAV_HIGH;
        _tableSearch = [[UITableView alloc] initWithFrame:_rect];
        _tableSearch.dataSource = self;
        _tableSearch.delegate = self;
        _tableSearch.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_tableSearch];
    }
    _tableSearch.contentOffset = CGPointMake(0, 0);
    [self.searchBar becomeFirstResponder];
    if(!_isSearching){
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.view addSubview:_tableSearch];
        _isSearching = YES;
    }
    else {
        [_tableSearch removeFromSuperview];
    }
    
    if (!_prodKeywords && !_brandKeywords) {
        _prodKeywords = nil;
        _brandKeywords = nil;
        FSCommonRequest *request = [[FSCommonRequest alloc] init];
        [request setRouteResourcePath:RK_REQUEST_KEYWORD_LIST];
        __block FSProdListViewController *blockSelf = self;
        [request send:[FSKeyword class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
            if (resp.isSuccess)
            {
                FSKeyword *result = resp.responseData;
                _prodKeywords = [NSMutableArray arrayWithArray:result.keyWords];
                _brandKeywords = [NSMutableArray arrayWithArray:result.brandWords];
                [_tableSearch reloadData];
                [self.searchBar becomeFirstResponder];
            }
            else
            {
                [blockSelf reportError:resp.errorDescrip];
            }
        }];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    if (!_firstTimeLoadDone)
    {
        if (_tags.count>0)
        {
            [_cvTags selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:TRUE scrollPosition:PSTCollectionViewScrollPositionCenteredHorizontally];
            [self collectionView:_cvTags didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [self resetTagFrameIfNeed];
            _firstTimeLoadDone  = true;
        } else
        {
            [self prepareData];
        }
    }
}

-(void) prepareData
{
    _tags = [@[] mutableCopy];
    _prods = [@[] mutableCopy];
    
     _actualTagWidth = 0;
    [self zeroMemoryBlock];
    [_tags addObjectsFromArray:[FSTag localTags]];
    if (!_tags ||
        _tags.count<1)
    {
        [self beginLoading:_cvTags];
        __block FSProdListViewController *blockSelf = self;
        FSConfigListRequest *request = [[FSConfigListRequest alloc] init];
        request.routeResourcePath = RK_REQUEST_CONFIG_TAG_ALL;
        [request send:[FSCoreTag class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
            [blockSelf endLoading:_cvTags];
            if (blockSelf->_tags.count>0)
                return;
            [blockSelf->_tags addObjectsFromArray:[FSTag localTags]];
            [blockSelf endPrepareData];
        }];
    }
    else
    {
        [self endPrepareData];
    }
   
}
-(void)endPrepareData
{
    if (!_tags ||
        _tags.count<1)
        return;
    [_cvTags reloadData];

}
-(void) zeroMemoryBlock
{
    _prodPageIndex = 0;
    _noMoreResult= FALSE;
}

-(void)resetTagFrameIfNeed
{
    if (_actualTagWidth+5<self.view.frame.size.width)
    {
        CGFloat offset = self.view.frame.size.width - _actualTagWidth-5;
        CGRect origiFrame = _cvTags.frame;
        origiFrame.origin.x = offset/2;
        [_cvTags setFrame:origiFrame];
    }
}
-(void) prepareLayout
{
    self.navigationItem.title = NSLocalizedString(@"Products", nil);
    PSUICollectionViewFlowLayout *layout = [[PSUICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(DEFAULT_TAG_WIDTH, 34);
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
     _cvTags = [[PSUICollectionView alloc] initWithFrame:_tagContainer.bounds collectionViewLayout:layout];
    [_tagContainer addSubview:_cvTags];
    _tagContainer.backgroundColor = [UIColor whiteColor];//RGBCOLOR(242, 242, 242);
    [_cvTags registerNib:[UINib nibWithNibName:@"FSProdTagCell" bundle:nil] forCellWithReuseIdentifier:PROD_LIST_TAG_CELL];
    _cvTags.backgroundColor = [UIColor clearColor];
    _tagContainer.contentMode = UIViewContentModeCenter;
    _cvTags.showsHorizontalScrollIndicator = NO;
    _cvTags.delegate = self;
    _cvTags.dataSource = self;
    [self reCreateContentView];
}
-(void)reCreateContentView
{
    if (_cvContent)
    {
        [_cvContent removeFromSuperview];
        _cvContent = nil;
    }
    SpringboardLayout *clayout = [[SpringboardLayout alloc] init];
    clayout.itemWidth = ITEM_CELL_WIDTH;
    clayout.columnCount = 3;
    clayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    clayout.delegate = self;
    CGRect conFrame = _contentContainer.bounds;
    conFrame.origin.y = 0;
    conFrame.size.height -= NAV_HIGH + TAB_HIGH;
    _cvContent = [[PSUICollectionView alloc] initWithFrame:conFrame collectionViewLayout:clayout];
    [_contentContainer addSubview:_cvContent];
    [_cvContent setCollectionViewLayout:clayout];
    _cvContent.backgroundColor = RGBCOLOR(242, 242, 242);//[UIColor whiteColor];
    [_cvContent registerNib:[UINib nibWithNibName:@"FSProdDetailCell" bundle:nil] forCellWithReuseIdentifier:PROD_LIST_DETAIL_CELL];
    [self prepareRefreshLayout:_cvContent withRefreshAction:^(dispatch_block_t action) {
        [self refreshContent:TRUE withCallback:^(){
            action();
        }];
        
    }];
    
    _cvContent.delegate = self;
    _cvContent.dataSource = self;
}

-(void) fillProdInMemory:(NSArray *)prods isInsert:(BOOL)isinserted needReload:(BOOL)shouldReload
{
    if (!prods)
        return;
    [prods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        int index = [_prods indexOfObjectPassingTest:^BOOL(id obj1, NSUInteger idx1, BOOL *stop1) {
            if ([[(FSProdItemEntity *)obj1 valueForKey:@"id"] intValue] ==[[(FSProdItemEntity *)obj valueForKey:@"id"] intValue])
            {
                return TRUE;
                *stop1 = TRUE;
            }
            return FALSE;
        }];
        if (index==NSNotFound)
        {
            if (!isinserted)
            {
                [_prods addObject:obj];
                if (!shouldReload)
                    [_cvContent insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_prods.count-1 inSection:0]]];
            } else
            {
                [_prods insertObject:obj atIndex:0];
                if (!shouldReload)
                [_cvContent insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
            }
        }
    }];
    if (shouldReload)
      [_cvContent reloadData];
    
    if (_prods.count<1)
    {
        //加载空视图
        [self showNoResultImage:_cvContent withImage:@"blank_dongdong.png" withText:NSLocalizedString(@"TipInfo_DongDong_ProductList", nil)   originOffset:30];
    }
    else
    {
        [self hideNoResultImage:_cvContent];
    }
}

-(void) fillProdInMemory:(NSArray *)prods isInsert:(BOOL)isinserted
{    
    [self fillProdInMemory:prods isInsert:isinserted needReload:FALSE];
}

-(void)beginSwitchTag:(FSCoreTag *)tag
{
    [self zeroMemoryBlock];
    [self beginLoading:_cvContent];
    _prodPageIndex = 0;
    _currentTag = tag;
    _refreshLatestDate = _firstLoadDate = [NSDate date];
    FSProListRequest *request =
    [self buildListRequest:RK_REQUEST_PROD_LIST nextPage:1 isRefresh:FALSE];
    __block FSProdListViewController *blockSelf = self;
    [request send:[FSBothItems class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
        [self endLoading:_cvContent];
        if (resp.isSuccess)
        {
            FSBothItems *result = resp.responseData;
            if (result.totalPageCount <= blockSelf->_prodPageIndex+1)
                blockSelf->_noMoreResult = TRUE;
            [blockSelf->_prods removeAllObjects];
            
            [blockSelf fillProdInMemory:result.prodItems isInsert:FALSE needReload:TRUE];
            [blockSelf->_cvContent setContentOffset:CGPointZero];
        }
        else
        {
            [self reportError:resp.errorDescrip];
        }
    }];
    
}
-(FSProListRequest *)buildListRequest:(NSString *)route nextPage:(int)page isRefresh:(BOOL)isRefresh
{
    FSProListRequest *request = [[FSProListRequest alloc] init];
    request.routeResourcePath = route;
    request.longit = [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.longitude];
    request.lantit = [NSNumber numberWithDouble:[FSLocationManager sharedLocationManager].currentCoord.latitude];
    if(isRefresh)
    {
        request.requestType = 0;
        request.previousLatestDate = _refreshLatestDate;
    }
    else
    {
        request.requestType = 1;
        request.previousLatestDate = _firstLoadDate;
    }

    request.tagid =[_currentTag valueForKey:@"id"];
    request.nextPage = page;
    request.pageSize = COMMON_PAGE_SIZE;
    return request;
}
-(void)refreshContent:(BOOL)isRefresh withCallback:(dispatch_block_t)callback
{
    int nextPage = 1;
    if (!isRefresh)
    {
        _prodPageIndex++;
        nextPage = _prodPageIndex +1;
    }
    FSProListRequest *request = [self buildListRequest:RK_REQUEST_PROD_LIST nextPage:nextPage isRefresh:isRefresh];
    __block FSProdListViewController *blockSelf = self;
    [request send:[FSBothItems class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
        callback();
        if (resp.isSuccess)
        {
            FSBothItems *result = resp.responseData;
            if (isRefresh)
                blockSelf->_refreshLatestDate = [[NSDate alloc] init];
            else
            {
                if (result.totalPageCount <= blockSelf->_prodPageIndex+1)
                   blockSelf-> _noMoreResult = TRUE;
            }
            [blockSelf fillProdInMemory:result.prodItems isInsert:isRefresh];
        }
        else
        {
            [blockSelf reportError:resp.errorDescrip];
        }
    }];
}

-(void)loadMore
{
    [self beginLoadMoreLayout:_cvContent];
    __block FSProdListViewController *blockSelf = self;
    [self refreshContent:FALSE withCallback:^{
        [blockSelf endLoadMore:_cvContent];
    }];
    
}

- (void)loadImagesForOnscreenRows
{
    if ([_prods count] > 0)
    {
        NSArray *visiblePaths = [_cvContent indexPathsForVisibleItems];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            id<ImageContainerDownloadDelegate> cell = (id<ImageContainerDownloadDelegate>)[_cvContent cellForItemAtIndexPath:indexPath];
            int width = ITEM_CELL_WIDTH;
            int height = [(PSUICollectionViewCell *)cell frame].size.height - 40;
            [cell imageContainerStartDownload:cell withObject:indexPath andCropSize:CGSizeMake(width, height) ];
            
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    if (scrollView == _tableSearch) {
        [self.searchBar resignFirstResponder];
        [UIView animateWithDuration:0.8 animations:nil completion:^(BOOL finished) {
            [self.searchBar setCancelButtonEnable:YES];
        }];
    }
    else{
        [self loadImagesForOnscreenRows];
        
        if (!_noMoreResult && !self.inLoading &&
            (scrollView.contentOffset.y+scrollView.frame.size.height) + 200 > scrollView.contentSize.height
            && scrollView.contentSize.height>scrollView.frame.size.height
            &&scrollView.contentOffset.y>0)
        {
            [self loadMore];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

#pragma mark - PSUICollectionView Datasource

- (NSInteger)collectionView:(PSUICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if (view == _cvTags)
    {
        return _tags.count;
    } else if (view == _cvContent)
    {
        return _prods.count;
    }
    return 0;
    
}

- (NSInteger)numberOfSectionsInCollectionView: (PSUICollectionView *)collectionView {
    return 1;
}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PSUICollectionViewCell * cell = nil;
    if (cv == _cvTags)
    {
        cell = [cv dequeueReusableCellWithReuseIdentifier:PROD_LIST_TAG_CELL forIndexPath:indexPath];
        [(FSProdTagCell *)cell setData:[_tags objectAtIndex:indexPath.row]];
    }
    else if (cv == _cvContent)
    {
        cell = [cv dequeueReusableCellWithReuseIdentifier:PROD_LIST_DETAIL_CELL forIndexPath:indexPath];
        FSProdItemEntity *_data = [_prods objectAtIndex:indexPath.row];
        [(FSProdDetailCell *)cell setData:_data];
        if (_data.hasPromotion) {
            [(FSProdDetailCell *)cell showProIcon];
        }
        else {
            [(FSProdDetailCell *)cell hidenProIcon];
        }
        int width = PROD_LIST_DETAIL_CELL_WIDTH;
        int height = cell.frame.size.height;
        [(id<ImageContainerDownloadDelegate>)cell imageContainerStartDownload:cell withObject:indexPath andCropSize:CGSizeMake(width, height) ];
    }
    return cell;
}

#pragma mark - PSUICollectionViewDelegate

- (void)collectionView:(PSUICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == _cvTags)
    {
        [[collectionView cellForItemAtIndexPath:indexPath] setSelected:TRUE];
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:TRUE];
        FSCoreTag *tag = [_tags objectAtIndex:indexPath.row];
        [self beginSwitchTag:tag];
        
        //统计
        NSMutableDictionary *_dic = [NSMutableDictionary dictionaryWithCapacity:2];
        [_dic setValue:tag.name forKey:@"分类名称"];
        [_dic setValue:@"东东商品列表" forKey:@"页面来源"];
        [[FSAnalysis instance] logEvent:@"查看分类" withParameters:_dic];
    }
    else if (collectionView == _cvContent)
    {
        FSProDetailViewController *detailViewController = [[FSProDetailViewController alloc] initWithNibName:@"FSProDetailViewController" bundle:nil];
        detailViewController.navContext = _prods;
        detailViewController.dataProviderInContext = self;
        detailViewController.indexInContext = indexPath.row;
        detailViewController.sourceType = FSSourceProduct;
        UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:detailViewController];
        [self presentViewController:navControl animated:YES completion:nil];
        
        //统计
        NSMutableDictionary *_dic = [NSMutableDictionary dictionaryWithCapacity:2];
        FSProdItemEntity *_item = [_prods objectAtIndex:indexPath.row];
        [_dic setValue:_item.title forKey:@"商品名称"];
        [_dic setValue:[NSString stringWithFormat:@"%d", _item.id] forKey:@"商品ID"];
        [_dic setValue:@"东东商品列表" forKey:@"页面来源"];
        [[FSAnalysis instance] logEvent:@"查看详情" withParameters:_dic];
    }
}

-(void)collectionView:(PSUICollectionView *)collectionView didEndDisplayingCell:(PSUICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (collectionView == _cvContent)
    {
        [(FSProdDetailCell *)cell willRemoveFromView];
    }
     
}
-(CGSize)collectionView:(PSTCollectionView *)collectionView layout:(PSTCollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _cvTags &&
        _tags)
    {
        CGSize actualSize = [[(FSTag *)[_tags objectAtIndex:indexPath.row] name] sizeWithFont:ME_FONT(12)];
        CGFloat width = MAX(actualSize.width, DEFAULT_TAG_WIDTH);
        _actualTagWidth+=width+5;
        return CGSizeMake(width, MAX(actualSize.height, 34));
    }
    return  CGSizeMake(ITEM_CELL_WIDTH, ITEM_CELL_WIDTH);
}

- (CGFloat)collectionView:(PSUICollectionView *)collectionView
                   layout:(SpringboardLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSProdItemEntity * data = [_prods objectAtIndex:indexPath.row];
    FSResource * resource = data.resource&&data.resource.count>0?[data.resource objectAtIndex:0]:nil;
    float totalHeight = 0.1f;
    if (resource &&
        resource.width>0 &&
        resource.height>0)
    {
        int cellWidth = ITEM_CELL_WIDTH;
        float imgHeight = (cellWidth * resource.height)/(resource.width);
        totalHeight = totalHeight+imgHeight;
    } else
    {
        totalHeight = CollectionView_Default_Height;
    }
    return totalHeight;
}



#pragma FSProDetailItemSourceProvider
-(void)proDetailViewDataFromContext:(FSProDetailViewController *)view forIndex:(NSInteger)index  completeCallback:(UICallBackWith1Param)block errorCallback:(dispatch_block_t)errorBlock
{
    FSProdItemEntity *item =  [view.navContext objectAtIndex:index];
    if (item)
        block(item);
    else
        errorBlock();
    
}
-(FSSourceType)proDetailViewSourceTypeFromContext:(FSProDetailViewController *)view forIndex:(NSInteger)index
{
    return FSSourceProduct;
}
-(BOOL)proDetailViewNeedRefreshFromContext:(FSProDetailViewController *)view forIndex:(NSInteger)index
{
    return TRUE;
}

- (BOOL) isDeletionModeActiveForCollectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout
{
    return FALSE;
}

- (void)viewDidUnload {
    [self setTagContainer:nil];
    [self setContentContainer:nil];
    [self setLblTitle:nil];
    [super viewDidUnload];
}

#pragma mark - TableView Delegate and DataSource

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == _tableSearch) {
        return self.searchBar;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _tableSearch) {
        return 88;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_selectedIndex == 0) {
        return _prodKeywords.count;
    }
    else{
        return _brandKeywords.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (_selectedIndex == 0) {
        cell.textLabel.text = _prodKeywords[indexPath.row];
    }
    else{
        FSBrand *brand = _brandKeywords[indexPath.row];
        cell.textLabel.text = brand.name;
    }
    cell.textLabel.font = FONT(15);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self toSearch:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == _tableSearch) {
        return;
    }
    else{
        [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

#pragma mark - Search Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self toSearch:-1];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    if (_isSearching) {
        self.searchBar.text = @"";
        [_tableSearch removeFromSuperview];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        _isSearching = NO;
    }
}

//type<0:搜索文本框中输入的内容
//type>=0:搜索热门关键词、热门品牌
-(void)toSearch:(int)type
{
    //跳转搜索界面进行搜索
    FSProductListViewController *dr = [[FSProductListViewController alloc] initWithNibName:@"FSProductListViewController" bundle:nil];
    if (type < 0) {
        dr.keyWords = _searchBar.text;
        dr.pageType = FSPageTypeSearch;
    }
    else{
        if (_selectedIndex == 0) {//热门关键字
            dr.keyWords = _prodKeywords[type];
            dr.pageType = FSPageTypeSearch;
        }
        else{//品牌搜索
            FSBrand *brand = _brandKeywords[type];
            dr.pageType = FSPageTypeBrand;
            dr.brand = brand;
            dr.keyWords = brand.name;
        }
    }
    dr.titleName = dr.keyWords;
    dr.isModel = YES;
    UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:dr];
    [self presentModalViewController:navControl animated:YES];
}

#pragma mark - MySegmentValueChangedDelegate

-(void)segmentValueChanged:(UISegmentedControl*)seg
{
    BOOL hasFoucus = self.searchBar.isFirstResponder;
    if (seg) {
        _selectedIndex = seg.selectedSegmentIndex;
    }
    [_tableSearch reloadData];
    if (hasFoucus) {
        [self.searchBar becomeFirstResponder];
    }
}



@end
