//
//  FSProdListViewController.m
//  FashionShop
//
//  Created by gong yi on 12/10/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSProductListViewController.h"
#import "UIViewController+Loading.h"
#import "FSProdDetailCell.h"
#import "FSProDetailViewController.h"

#import "FSProListRequest.h"
#import "FSResource.h"
#import "FSLocationManager.h"
#import "FSBothItems.h"
#import "FSModelManager.h"

#define PROD_LIST_DETAIL_CELL @"FSProdListDetailCell"
#define  PROD_LIST_DETAIL_CELL_WIDTH 100
#define LOADINGVIEW_HEIGHT 44
#define ITEM_CELL_WIDTH 100
#define PROD_PAGE_SIZE 20

@interface FSProductListViewController ()
{
    NSMutableArray *_prods;
    
    UIActivityIndicatorView * moreIndicator;
    BOOL _isInLoading;
    BOOL _firstTimeLoadDone;
    int _prodPageIndex;

    NSDate *_refreshLatestDate;
    NSDate * _firstLoadDate;
    
    bool _noMoreResult;
    BOOL _isLoading;
}

@end

@implementation FSProductListViewController

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
    
}

-(void) prepareData
{
    _prods = [@[] mutableCopy];
    [self zeroMemoryBlock];
    [self beginLoading:_productContent];
    _prodPageIndex = 0;
    FSProListRequest *request =
    [self buildListRequest:RK_REQUEST_PROD_LIST nextPage:1 isRefresh:FALSE];
    [request send:[FSBothItems class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
        [self endLoading:_productContent];
        if (resp.isSuccess)
        {
            FSBothItems *result = resp.responseData;
            if (result.totalPageCount <= _prodPageIndex+1)
                _noMoreResult = TRUE;
            [_prods removeAllObjects];
            [self fillProdInMemory:result.prodItems isInsert:FALSE];
        }
        else
        {
            [self reportError:resp.errorDescrip];
        }
    }];


    
}
-(void) zeroMemoryBlock
{
    _prodPageIndex = 0;
    _noMoreResult= FALSE;
   
}

-(void) prepareLayout
{
    if (_pageType == FSPageTypeBrand) {
        self.navigationItem.title = _brand.name;
    }
    else if(_pageType == FSPageTypeTopic) {
        self.navigationItem.title = _topic.name;
    }
    else if(_pageType == FSPageTypeCommon) {
        self.navigationItem.title = _titleName;
    }
    [self replaceBackItem];
    SpringboardLayout *clayout = [[SpringboardLayout alloc] init];
    clayout.itemWidth = ITEM_CELL_WIDTH;
    clayout.columnCount = 3;
    clayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    clayout.delegate = self;
//    CGRect _rect = _contentView.frame;
//    _rect.size.height = (APP_HIGH>480?504:415) - (_pageType==FSPageTypeTopic?TAB_HIGH:0);
//    _contentView.frame = _rect;_productContent.bounds
    //_productContent = [[PSUICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 460) collectionViewLayout:clayout];
//    [_contentView addSubview:_productContent];
//    [_productContent setCollectionViewLayout:clayout];
    [_productContent setCollectionViewLayout:clayout];
    _productContent.backgroundColor = [UIColor whiteColor];
    [_productContent registerNib:[UINib nibWithNibName:@"FSProdDetailCell" bundle:nil] forCellWithReuseIdentifier:PROD_LIST_DETAIL_CELL];
    [self prepareRefreshLayout:_productContent withRefreshAction:^(dispatch_block_t action) {
        [self refreshContent:TRUE withCallback:^(){
            action();
        }];
        
    }];
    
    _productContent.delegate = self;
    _productContent.dataSource = self;
    
}


-(void) fillProdInMemory:(NSArray *)prods isInsert:(BOOL)isinserted
{
    
    if (!prods)
        return;
    [prods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        int index = [_prods indexOfObjectPassingTest:^BOOL(id obj1, NSUInteger idx1, BOOL *stop1) {
            if ([[(FSProdItemEntity *)obj1 valueForKey:@"id"] isEqualToValue:[(FSProdItemEntity *)obj valueForKey:@"id"]])
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
                [_productContent insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_prods.count-1 inSection:0]]];
            } else
            {
                [_prods insertObject:obj atIndex:0];
                [_productContent insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
            }
        }
    }];
    if (_prods.count<1)
    {
        //加载空视图
        [self showNoResultImage:_productContent withImage:@"blank_preferential.png" withText:NSLocalizedString(@"TipInfo_Product_List", nil)  originOffset:30];
    }
    else
    {
        [self hideNoResultImage:_productContent];
    }
}


-(FSProListRequest *)buildListRequest:(NSString *)route nextPage:(int)page isRefresh:(BOOL)isRefresh
{
    FSProListRequest *request = [[FSProListRequest alloc] init];
    request.routeResourcePath = route;
    if (_pageType == FSPageTypeBrand) {
        request.brandId = [_brand valueForKey:@"id"];
    }
    else if(_pageType == FSPageTypeTopic) {
        request.topicId = [NSNumber numberWithInt:_topic.topicId];
    }
    else if(_pageType == FSPageTypeCommon) {
        request.promotionId = [NSNumber numberWithInt:_commonID];
    }
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
    [request send:[FSBothItems class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
        callback();
        if (resp.isSuccess)
        {
            FSBothItems *result = resp.responseData;
            if (isRefresh)
                _refreshLatestDate = [[NSDate alloc] init];
            else
            {
                if (result.totalPageCount <= _prodPageIndex+1)
                    _noMoreResult = TRUE;
            }
            [self fillProdInMemory:result.prodItems isInsert:isRefresh];
        }
        else
        {
            [self reportError:resp.errorDescrip];
        }
    }];
    
}

-(void)loadMore
{
    [self beginLoadMoreLayout:_productContent];
    __block FSProductListViewController *blockSelf = self;
    _isLoading = YES;
    [self refreshContent:FALSE withCallback:^{
         [blockSelf endLoadMore:_productContent];
        _isLoading = NO;
    }];
}


- (void)loadImagesForOnscreenRows
{
    if ([_prods count] > 0)
    {
        NSArray *visiblePaths = [_productContent indexPathsForVisibleItems];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            id<ImageContainerDownloadDelegate> cell = (id<ImageContainerDownloadDelegate>)[_productContent cellForItemAtIndexPath:indexPath];
            int width = ITEM_CELL_WIDTH;
            int height = [(PSUICollectionViewCell *)cell frame].size.height;
            [cell imageContainerStartDownload:cell withObject:indexPath andCropSize:CGSizeMake(width, height)];
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    [self loadImagesForOnscreenRows];
    if (!_noMoreResult && !_isLoading &&
        (scrollView.contentOffset.y+scrollView.frame.size.height) + 200 > scrollView.contentSize.height
        && scrollView.contentSize.height>scrollView.frame.size.height
        &&scrollView.contentOffset.y>0)
    {
        [self loadMore];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

#pragma mark - PSUICollectionView Datasource

- (NSInteger)collectionView:(PSUICollectionView *)view numberOfItemsInSection:(NSInteger)section {

        return _prods.count;

    
}

- (NSInteger)numberOfSectionsInCollectionView: (PSUICollectionView *)collectionView {
    
    return 1;
}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PSUICollectionViewCell * cell = nil;
    cell = [cv dequeueReusableCellWithReuseIdentifier:PROD_LIST_DETAIL_CELL forIndexPath:indexPath];
    FSProdItemEntity *_data = [_prods objectAtIndex:indexPath.row];
    [(FSProdDetailCell *)cell setData: _data];
//    cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    cell.layer.borderWidth = 0.5;
    if (_data.hasPromotion) {
        [(FSProdDetailCell *)cell showProIcon];
    }
    else {
        [(FSProdDetailCell *)cell hidenProIcon];
    }
//    if (_productContent.dragging == NO &&
//        _productContent.decelerating == NO)
    {
        int width = PROD_LIST_DETAIL_CELL_WIDTH;
        int height = cell.frame.size.height;
        [(id<ImageContainerDownloadDelegate>)cell imageContainerStartDownload:cell withObject:indexPath andCropSize:CGSizeMake(width, height) ];
    }
   
    return cell;
}




#pragma mark - PSUICollectionViewDelegate


- (void)collectionView:(PSUICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
           FSProDetailViewController *detailViewController = [[FSProDetailViewController alloc] initWithNibName:@"FSProDetailViewController" bundle:nil];
        detailViewController.navContext = _prods;
        detailViewController.dataProviderInContext = self;
        detailViewController.indexInContext = indexPath.row;
        detailViewController.sourceType = FSSourceProduct;
        UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:detailViewController];
        [self presentViewController:navControl animated:YES completion:nil];
    
    
}

-(void)collectionView:(PSUICollectionView *)collectionView didEndDisplayingCell:(PSUICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _productContent)
    {
        [(FSProdDetailCell *)cell willRemoveFromView];
    }
}

- (CGFloat)collectionView:(PSUICollectionView *)collectionView
                   layout:(SpringboardLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSProdItemEntity * data = [_prods objectAtIndex:indexPath.row];
    FSResource * resource = data.resource&&data.resource.count>0?[data.resource objectAtIndex:0]:nil;
    float totalHeight = 0.0f;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setProductContent:nil];
    [super viewDidUnload];
}
@end
