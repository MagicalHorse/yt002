//
//  FSDRViewController.m
//  FashionShop
//
//  Created by gong yi on 12/21/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSDRViewController.h"
#import "FSProdDetailCell.h"
#import "FSProDetailViewController.h"
#import "FSMeViewController.h"
#import "FSLikeViewController.h"

#import "FSCommonUserRequest.h"
#import "FSModelManager.h"
#import "FSProListRequest.h"
#import "FSLocationManager.h"
#import "FSBothItems.h"


#define DR_DETAIL_CELL @"DRdetailcell"
#define  PROD_LIST_DETAIL_CELL_WIDTH 100
#define ITEM_CELL_WIDTH 100;
#define PROD_PAGE_SIZE 20;
#define LOADINGVIEW_HEIGHT 44

@interface FSDRViewController ()
{
    NSMutableArray *_items;
    FSUser *_daren;
    
    UIActivityIndicatorView *moreIndicator;
    
    int _prodPageIndex;   
    NSDate *_refreshLatestDate;
    NSDate * _firstLoadDate;
    bool _noMoreResult;
    BOOL _isInLoadingMore;
}

@end

@implementation FSDRViewController

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
    [self prepareData];
    
}

-(void)prepareData
{
    [self prepareEnterView:self.view];
    FSCommonUserRequest *request = [self createDRRequest];
    [self beginLoading:self.view];
    [request send:[FSUser class] withRequest:request completeCallBack:^(FSEntityBase * resp) {
        [self endLoading:self.view];
        [self didEnterView:self.view];
        if (resp.isSuccess)
        {
            _daren = resp.responseData;
            [self presentData];
        }
        else
        {
            [self reportError:resp.errorDescrip];
        }
    }];
}
-(void) prepareLayout
{
    self.navigationItem.title = NSLocalizedString(@"Ta homepage", nil);
    
    SpringboardLayout *layout = [[SpringboardLayout alloc] init];
    layout.itemWidth = ITEM_CELL_WIDTH;
    layout.columnCount = 3;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    layout.delegate = self;

    _itemsView = [[PSUICollectionView alloc] initWithFrame:_itemsContainer.bounds collectionViewLayout:layout];
    _itemsView.backgroundColor = [UIColor whiteColor];
    [_itemsContainer addSubview:_itemsView];
    _itemsView.dataSource = self;
    _itemsView.delegate = self;
    [_itemsView registerNib:[UINib nibWithNibName:@"FSProdDetailCell" bundle:nil] forCellWithReuseIdentifier:DR_DETAIL_CELL];
    [self prepareRefreshLayout:_itemsView withRefreshAction:^(dispatch_block_t action) {
        [self refreshContent:TRUE withCallback:^{
            action();
        }];
    }];
    
   
}
-(void) presentData
{
    [self presentData:TRUE];
}

-(void) presentData:(BOOL)isUpdateCollection
{
    UIBarButtonItem *baritemSet= nil;
    if (!_daren.isLiked)
        baritemSet= [self createPlainBarButtonItem:@"follow_icon.png" target:self action:@selector(doLike)];
    else
        baritemSet= [self createPlainBarButtonItem:@"cancel_follow_btn.png" target:self action:@selector(doLikeRemove)];
    [self.navigationItem setRightBarButtonItem:baritemSet];
    [self replaceBackItem];
    _thumLogo.ownerUser = _daren;
    _lblNickie.text = _daren.nickie;
    _lblNickie.font = ME_FONT(18);
    [_lblNickie sizeToFit];
    [_lblNickie setTextColor:[UIColor colorWithRed:0 green:0 blue:0]];
    [_btnLike setTitle:[NSString stringWithFormat:@"%d",_daren.likeTotal] forState:UIControlStateNormal];
    [_btnLike setTitleColor:[UIColor colorWithRed:102 green:102 blue:102] forState:UIControlStateNormal];
    _btnLike.titleLabel.font = ME_FONT(9);
    [_btnFans setTitle:[NSString stringWithFormat:@"%d",_daren.fansTotal] forState:UIControlStateNormal];
    [_btnFans setTitleColor:[UIColor colorWithRed:102 green:102 blue:102] forState:UIControlStateNormal];
    _btnFans.titleLabel.font = ME_FONT(9);
    _lblItemTitle.font = ME_FONT(12);
    _lblItemTitle.text = NSLocalizedString(@"Ta like", nil);
    _lblItemTitle.textColor = [UIColor colorWithRed:0 green:0 blue:0];
    if (!isUpdateCollection)
        return;
    [self prepareLayout];
    
    [self beginLoading:_itemsView];
    
    _prodPageIndex = 1;
    FSProListRequest *request = [self createListRequest:_prodPageIndex isRefresh:FALSE];
    [request send:[FSBothItems class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
        [self endLoading:_itemsView];
        if (!resp.isSuccess)
            [self reportError:resp.errorDescrip];
        else
        {
            FSBothItems *result = resp.responseData;
            if (self.isInRefresh)
                _refreshLatestDate = [[NSDate alloc] init];
            else
            {
                if (result.totalPageCount <= _prodPageIndex+1)
                    _noMoreResult = TRUE;
            }
            [self fillProdInMemory:result.prodItems isInsert:self.isInRefresh];
        }
    }];

}

-(void) fillProdInMemory:(NSArray *)prods isInsert:(BOOL)isinserted
{
    if(!_items)
        _items = [@[] mutableCopy];
    if (!prods)
        return;
    [prods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        int index = [_items indexOfObjectPassingTest:^BOOL(id obj1, NSUInteger idx1, BOOL *stop1)
                     {
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
                [_items addObject:obj];
            } else
            {
                [_items insertObject:obj atIndex:0];
            }
            
            
        }
    }];
    
    [_itemsView reloadData];
    if (!_items ||
        _items.count<=0)
        [self showNoResult:_itemsView withText:NSLocalizedString(@"no products shared", Nil)];
    else
        [self hideNoResult:_itemsView];
    
}


-(FSCommonUserRequest *)createDRRequest
{
    FSCommonUserRequest *request = [[FSCommonUserRequest alloc] init];
    request.userId =[NSNumber numberWithInt:_userId] ;
    request.userToken = [FSModelManager sharedModelManager].loginToken;
    request.routeResourcePath = RK_REQUEST_DAREN_DETAIL;
    return request;
}


-(FSProListRequest *)createListRequest:(int)page isRefresh:(BOOL)isRefresh
{
    FSProListRequest *request = [[FSProListRequest alloc] init];
    request.routeResourcePath = RK_REQUEST_PROD_DR_LIST;
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
    request.pageSize = PROD_PAGE_SIZE;
    request.drUserId = [NSNumber numberWithInt:_userId];
    return request;
}

-(void)doLike
{
    [self doLike:FALSE];
}
-(void)doLikeRemove
{
    [self doLike:TRUE];
}

-(void)doLike:(BOOL)isRemove
{
    
    bool isLogined = [[FSModelManager sharedModelManager] isLogined];
    if (!isLogined)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        FSMeViewController *loginController = [storyboard instantiateViewControllerWithIdentifier:@"userProfile"];
        __block FSMeViewController *blockMeController = loginController;
        loginController.completeCallBack=^(BOOL isSuccess){
            
            [blockMeController dismissViewControllerAnimated:true completion:^{
                if (!isSuccess)
                {
                    [self reportError:NSLocalizedString(@"COMM_OPERATE_FAILED", nil)];
                }
                else
                {
                    
                    [self internalDoLike:isRemove];
                    /*
                    [self startProgress:NSLocalizedString(@"Do liking...",nil)withExeBlock:^(dispatch_block_t callback){
                        [self internalDoLike:isRemove withCallback:callback];
                    } completeCallbck:^{
                        [self endProgress];
                    }];
                     */
                }
            }];
        };
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
        [self presentViewController:navController animated:false completion:nil];
        
    }
    else
    {
        [self internalDoLike:isRemove];
        /*
        [self startProgress:NSLocalizedString(@"Do liking...",nil)withExeBlock:^(dispatch_block_t callback){
            [self internalDoLike:isRemove withCallback:callback];
        } completeCallbck:^{
            [self endProgress];
        }];
        */
        
    }

}

-(void) internalDoLike:(BOOL)isRemove withCallback:(dispatch_block_t)cleanup
{
    FSCommonUserRequest *request = [[FSCommonUserRequest alloc] init];
    request.userToken = [FSModelManager sharedModelManager].loginToken;
    request.likeUserId =[NSString stringWithFormat:@"%d",[_daren.uid intValue]];
    request.routeResourcePath =isRemove?RK_REQUEST_LIKE_REMOVE: RK_REQUEST_LIKE_DO;
    __block FSDRViewController *blockSelf = self;
    
    [request send:[FSUser class] withRequest:request completeCallBack:^(FSEntityBase *respData){
        if (!respData.isSuccess)
        {
            [blockSelf updateProgress:respData.errorDescrip];
        }
        else
        {
            //FSUser *newUser =  respData.responseData;
            [blockSelf updateProgress:NSLocalizedString(@"COMM_OPERATE_COMPL", nil)];
            blockSelf->_daren.isLiked = !isRemove;
            [blockSelf presentData:FALSE];
        }
        if (cleanup)
            cleanup();
    }];
    
    
}

-(void) internalDoLike:(BOOL)isRemove
{
    FSCommonUserRequest *request = [[FSCommonUserRequest alloc] init];
    request.userToken = [FSModelManager sharedModelManager].loginToken;
    request.likeUserId =[NSString stringWithFormat:@"%d",[_daren.uid intValue]];
    request.routeResourcePath =isRemove?RK_REQUEST_LIKE_REMOVE: RK_REQUEST_LIKE_DO;
    __block FSDRViewController *blockSelf = self;
    [self updateLikeButtonStatus:isRemove canClick:FALSE];
    self.navigationItem.rightBarButtonItem.enabled = false;
    [request send:[FSUser class] withRequest:request completeCallBack:^(FSEntityBase *respData){
        if (!respData.isSuccess)
        {
            [blockSelf updateLikeButtonStatus:!isRemove canClick:FALSE];
        }
        else
        {
            blockSelf->_daren.isLiked = !isRemove;
        }
        self.navigationItem.rightBarButtonItem.enabled = true;
        
    }];
    
    
}
-(void) updateLikeButtonStatus:(BOOL)canLike canClick:(BOOL)isClickable
{
    UIBarButtonItem *barSet = nil;
    if (canLike)
        barSet= [self createPlainBarButtonItem:@"follow_icon.png" target:self action:@selector(doLike)];
    else
        barSet= [self createPlainBarButtonItem:@"cancel_follow_btn.png" target:self action:@selector(doLikeRemove)];
    [self.navigationItem setRightBarButtonItem:barSet];
    
}


-(void)refreshContent:(BOOL)isRefresh withCallback:(dispatch_block_t)callback
{
    int nextPage = 1;
    if (!isRefresh)
    {
        _prodPageIndex++;
        nextPage = _prodPageIndex +1;
    }
    FSProListRequest *request = [self createListRequest:nextPage isRefresh:TRUE];
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
    if (!moreIndicator)
        moreIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    moreIndicator.center = CGPointMake(_itemsView.frame.size.width/2, _itemsView.contentSize.height);
    [moreIndicator startAnimating];
    [_itemsView addSubview:moreIndicator];
    _isInLoadingMore = TRUE;
    
    [self refreshContent:FALSE withCallback:^{
        [moreIndicator removeFromSuperview];
        _isInLoadingMore = FALSE;
    }];
    
}


- (void)loadImagesForOnscreenRows
{
    if ([_items count] > 0)
    {
        NSArray *visiblePaths = [_itemsView indexPathsForVisibleItems];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            id<ImageContainerDownloadDelegate> cell = (id<ImageContainerDownloadDelegate>)[_itemsView cellForItemAtIndexPath:indexPath];
            int width = ITEM_CELL_WIDTH;
            int height = [(PSUICollectionViewCell *)cell frame].size.height - 40;
            [cell imageContainerStartDownload:cell withObject:indexPath andCropSize:CGSizeMake(width, height) ];
            
        }
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
	[super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    [self loadImagesForOnscreenRows];
    if (!_noMoreResult &&
        !_isInLoadingMore &&
        (scrollView.contentOffset.y+scrollView.frame.size.height) > scrollView.contentSize.height
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
    
    return _items.count;
    
}

- (NSInteger)numberOfSectionsInCollectionView: (PSUICollectionView *)collectionView {
    
    return 1;
}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PSUICollectionViewCell * cell = [cv dequeueReusableCellWithReuseIdentifier:DR_DETAIL_CELL forIndexPath:indexPath];
    [(FSProdDetailCell *)cell setData:[_items objectAtIndex:indexPath.row]];
    cell.layer.borderColor = [UIColor grayColor].CGColor;
    cell.layer.borderWidth = 1;
    if (_itemsView.dragging == NO &&
        _itemsView.decelerating == NO)
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
        detailViewController.navContext = _items;
        detailViewController.dataProviderInContext = self;
        detailViewController.indexInContext = indexPath.row;
        detailViewController.sourceType = FSSourceProduct;
        UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:detailViewController];
        [self presentViewController:navControl animated:YES completion:nil];
 
    
}

-(void)collectionView:(PSUICollectionView *)collectionView didEndDisplayingCell:(PSUICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{

        [(FSProdDetailCell *)cell willRemoveFromView];

}

- (CGFloat)collectionView:(PSUICollectionView *)collectionView
                   layout:(SpringboardLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSProdItemEntity * data = [_items objectAtIndex:indexPath.row];
    FSResource * resource = data.resource&&data.resource.count>0?[data.resource objectAtIndex:0]:nil;
    float totalHeight = 0.0f;
    if (resource)
    {
        int cellWidth = ITEM_CELL_WIDTH;
        float imgHeight = (cellWidth * resource.height)/(resource.width);
        totalHeight = totalHeight+imgHeight;
    } else
    {
        totalHeight = 20.0f;
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
    [self setItemsContainer:nil];
    [self setLblItemTitle:nil];
    [self setThumLogo:nil];
    [super viewDidUnload];
}
- (IBAction)goLikeView:(id)sender {
    FSLikeViewController *likeView = [[FSLikeViewController alloc] initWithNibName:@"FSLikeViewController" bundle:nil];
    likeView.likeType = 0;
    likeView.currentUser = _daren;
    likeView.navigationItem.title = NSLocalizedString(@"Ta likes persons", nil);
    [self.navigationController pushViewController:likeView animated:TRUE];
}

- (IBAction)goFanView:(id)sender {
    FSLikeViewController *likeView = [[FSLikeViewController alloc] initWithNibName:@"FSLikeViewController" bundle:nil];
    likeView.likeType = 1;
    likeView.currentUser = _daren;
    likeView.navigationItem.title = NSLocalizedString(@"Ta fans", nil);
    [self.navigationController pushViewController:likeView animated:TRUE];
}
@end
