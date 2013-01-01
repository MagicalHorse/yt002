//
//  FSLikeViewController.m
//  FashionShop
//
//  Created by gong yi on 11/28/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSCouponViewController.h"
#import "UIViewController+Loading.h"
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
    NSMutableArray *_likes;
    int _currentPage;
    BOOL _noMore;
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
    [_contentView registerNib:[UINib nibWithNibName:@"FSCouponDetailCell" bundle:Nil] forCellReuseIdentifier:USER_COUPON_TABLE_CELL];
    [_contentView registerNib:[UINib nibWithNibName:@"FSCouponProDetailCell" bundle:Nil] forCellReuseIdentifier:USER_COUPON_PRO_TABLE_CELL];
    [self prepareData];
    [self preparePresent];
    
}

-(void) prepareData
{
    if (!_likes)
    {
        [self beginLoading:_contentView];
        _currentPage = 1;
        FSCommonUserRequest *request = [self createRequest:_currentPage];
        [request send:[FSPagedCoupon class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
            [self endLoading:_contentView];
            if (resp.isSuccess)
            {
                FSPagedCoupon *innerResp = resp.responseData;
                if (innerResp.totalPageCount<=_currentPage)
                    _noMore = true;
                [self mergeLike:innerResp isInsert:false];
            }
            else
            {
                [self reportError:resp.errorDescrip];
            }
        }];
    }
}
-(void) preparePresent
{
    self.navigationItem.title = NSLocalizedString(@"Promotion codes", nil);
    [self prepareRefreshLayout:_contentView withRefreshAction:^(dispatch_block_t action) {
        FSCommonUserRequest *request = [self createRequest:1];
        [request send:[FSPagedCoupon class] withRequest:request completeCallBack:^(FSEntityBase * resp) {
            action();
            if (resp.isSuccess)
            {
                FSPagedCoupon *innerResp = resp.responseData;
                if (innerResp.totalPageCount<=_currentPage)
                    _noMore = true;
                [self mergeLike:innerResp isInsert:true];
            }
            else
            {
                [self reportError:resp.errorDescrip];
            }
        }];

    }];
    _contentView.dataSource = self;
    _contentView.delegate =self;
}

-(void) mergeLike:(FSPagedCoupon *)response isInsert:(BOOL)isinsert
{
    if (!_likes)
    {
        _likes = [@[] mutableCopy];
    }
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
    
}

-(FSCommonUserRequest *)createRequest:(int)index
{
    FSCommonUserRequest *request = [[FSCommonUserRequest alloc] init];
    request.userToken =[FSModelManager sharedModelManager].loginToken;
    request.pageSize = [NSNumber numberWithInt:20];
    request.pageIndex =[NSNumber numberWithInt:index];
    request.sort = @0;
    request.routeResourcePath = RK_REQUEST_COUPON_LIST;
    return request;
}
-(void) presentData
{
    
    [_contentView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _likes?_likes.count:0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSCoupon *coupon = [_likes objectAtIndex:indexPath.row];
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
    return 70;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row %2==0)
    {
        cell.backgroundColor = PRO_LIST_NEAR_CELL1_BGCOLOR;
        
    } else
    {
        cell.backgroundColor = PRO_LIST_NEAR_CELL2_BGCOLOR;
    }
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSProDetailViewController *detailView = [[FSProDetailViewController alloc] initWithNibName:@"FSProDetailViewController" bundle:nil];
    detailView.navContext = _likes;
    detailView.indexInContext = indexPath.row* [self numberOfSectionsInTableView:tableView] + indexPath.section;
    detailView.sourceType = [(FSCoupon *)[_likes objectAtIndex:detailView.indexInContext] producttype];
    detailView.dataProviderInContext = self;
    UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:detailView];
    [self presentViewController:navControl animated:true completion:nil];

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate

{
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if(!_inLoading &&
       (scrollView.contentOffset.y+scrollView.frame.size.height) > scrollView.contentSize.height
       &&scrollView.contentOffset.y>0
       && !_noMore)
        
    {
        _inLoading = TRUE;
        FSCommonUserRequest *request = [self createRequest:_currentPage+1];
        [request send:[FSPagedCoupon class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
            _inLoading = FALSE;
            if (resp.isSuccess)
            {
                FSPagedCoupon *innerResp = resp.responseData;
                if (innerResp.totalPageCount<=_currentPage+1)
                    _noMore = true;
                _currentPage ++;
                [self mergeLike:innerResp isInsert:FALSE];
            }
            else
            {
                [self reportError:resp.errorDescrip];
            }
        }];
        
        
    }
    
    
}


#pragma FSProDetailItemSourceProvider
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
