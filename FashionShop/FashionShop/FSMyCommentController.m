//
//  FSMyCommentController.m
//  FashionShop
//
//  Created by HeQingshan on 13-5-14.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSMyCommentController.h"
#import "FSProCommentCell.h"
#import "FSCommonCommentRequest.h"
#import "FSPagedMyComment.h"
#import "FSMyCommentCell.h"
#import "FSDRViewController.h"

@interface FSMyCommentController ()
{
    NSMutableArray *_comments;
    BOOL _isInLoading;
    int _currentPage;
    BOOL _noMoreResult;
    FSSourceType *type;
    FSAudioButton   *lastButton;
    
    NSOperationQueue *_asyncQueue;
}

@end

@implementation FSMyCommentController

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
    _tbAction.backgroundView = nil;
    _tbAction.backgroundColor = APP_TABLE_BG_COLOR;
    self.title = @"我的评论";
    
    UIBarButtonItem *baritemCancel = [self createPlainBarButtonItem:@"goback_icon.png" target:self action:@selector(onButtonBack:)];
    [self.navigationItem setLeftBarButtonItem:baritemCancel];
    
    [_tbAction registerNib:[UINib nibWithNibName:@"FSMyCommentCell" bundle:nil] forCellReuseIdentifier:@"FSMyCommentCell"];
    
    _currentPage = 1;
    [self requestData:NO];
}

- (IBAction)onButtonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)requestData:(BOOL)isLoadMore
{
    FSCommonCommentRequest * request=[[FSCommonCommentRequest alloc] init];
    request.routeResourcePath = RK_REQUEST_MYCOMMENT_LIST;
    request.nextPage = [NSNumber numberWithInt:_currentPage + (isLoadMore?1:0)];
    request.pageSize = @COMMON_PAGE_SIZE;
    request.userToken = [FSModelManager sharedModelManager].loginToken;
    isLoadMore?[self beginLoadMoreLayout:_tbAction]:[self beginLoading:_tbAction];
    _isInLoading = YES;
    [request send:[FSPagedMyComment class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
        isLoadMore?[self endLoadMore:_tbAction]:[self endLoading:_tbAction];
        _isInLoading = NO;
        if (resp.isSuccess)
        {
            FSPagedMyComment *result = resp.responseData;
            _currentPage += isLoadMore?1:0;
            if (result.totalPageCount <= _currentPage)
                _noMoreResult = TRUE;
            [self fillProdInMemory:result.items isInsert:NO];
            
            if (_tbAction.hidden) {
                _tbAction.hidden = NO;
            }
            [_tbAction reloadData];
            if (!isLoadMore) {
                //更新badge存储内容
                [self updateBadgeData];
            }
        }
        else
        {
            [self reportError:resp.errorDescrip];
        }
    }];
}

-(void)updateBadgeData
{
    if (!_asyncQueue) {
        _asyncQueue = [[NSOperationQueue alloc] init];
        [_asyncQueue setMaxConcurrentOperationCount:1];
    }
    [_asyncQueue addOperationWithBlock:^{
        NSMutableArray *toRemove = [NSMutableArray array];
        NSMutableArray *_array = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"targetvalue"]];
        if (!_array) {
            return ;
        }
        for (NSString *item1 in _array) {
            BOOL flag = NO;
            for (FSComment *item2 in _comments) {
                if ([item1 intValue] == item2.sourceid) {
                    flag = YES;
                    break;
                }
            }
            if (!flag) {
                [toRemove addObject:item1];
            }
        }
        if (toRemove.count > 0) {
//            [_array removeObjectsInArray:toRemove];
            [theApp removeCommentIDs:toRemove];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceivePushNotification" object:nil];
        }
    }];
}

-(void) fillProdInMemory:(NSArray *)prods isInsert:(BOOL)isinserted
{
    if (!prods)
        return;
    if (!_comments) {
        _comments = [NSMutableArray array];
    }
    [prods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        int index = [_comments indexOfObjectPassingTest:^BOOL(id obj1, NSUInteger idx1, BOOL *stop1) {
            if ([[(FSComment *)obj1 valueForKey:@"commentid"] intValue] ==[[(FSComment *)obj valueForKey:@"commentid"] intValue])
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
                [_comments addObject:obj];
            } else
            {
                [_comments insertObject:obj atIndex:0];
            }
        }
    }];
    [_tbAction reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_noMoreResult &&
        !_isInLoading &&
        (scrollView.contentOffset.y+scrollView.frame.size.height) + 200 > scrollView.contentSize.height
        && scrollView.contentSize.height>scrollView.frame.size.height
        &&scrollView.contentOffset.y>0)
    {
        [self requestData:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTbAction:nil];
    [super viewDidUnload];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSComment *item = _comments[indexPath.row];
    FSProDetailViewController *detailViewController = [[FSProDetailViewController alloc] initWithNibName:@"FSProDetailViewController" bundle:nil];
    if (item.sourcetype == FSSourceProduct) {
        FSProdItemEntity *fsItem = [[FSProdItemEntity alloc] init];
        fsItem.id = item.sourceid;
        type = FSSourceProduct;
        detailViewController.navContext = [NSArray arrayWithObjects:fsItem, nil];
    }
    if (item.sourcetype == FSSourcePromotion) {
        FSProItemEntity *fsItem = [[FSProItemEntity alloc] init];
        fsItem.id = item.sourceid;
        type = FSSourcePromotion;
        detailViewController.navContext = [NSArray arrayWithObjects:fsItem, nil];
    }
    detailViewController.dataProviderInContext = self;
    detailViewController.indexInContext = 0;
    detailViewController.sourceType = item.sourcetype;
    UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    [self presentViewController:navControl animated:YES completion:nil];
    [theApp removeCommentID:[NSString stringWithFormat:@"%d", item.sourceid]];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView deselectRowAtIndexPath:indexPath animated:FALSE];
}

#pragma mark - UITableViewSource delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _comments.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSMyCommentCell *cellMy =  [tableView dequeueReusableCellWithIdentifier:@"FSMyCommentCell"];
    cellMy.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cellMy.selectionStyle = UITableViewCellSelectionStyleNone;
    FSComment *item = [_comments objectAtIndex:indexPath.row];
    [cellMy setData:item];
    cellMy.clipsToBounds = YES;
    cellMy.imgThumb.delegate = self;
    if (!cellMy.audioButton.audioDelegate) {
        cellMy.audioButton.audioDelegate = self;
    }
    [cellMy updateFrame];
    
    BOOL flag = YES;
    NSArray *_array = [[NSUserDefaults standardUserDefaults] objectForKey:@"targetvalue"];
    if (_array) {
        //增加显示红点标识
        for (NSString *value in _array) {
            if ([value intValue] == item.sourceid) {
                flag = NO;
                break;
            }
        }
    }
    cellMy.dotView.hidden = flag;
    
    return cellMy;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSMyCommentCell *cell = (FSMyCommentCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.cellHeight;
}

#pragma mark - FSThumbView delegate

-(void)didTapThumView:(id)sender
{
    if ([sender isKindOfClass:[FSThumView class]])
    {
        [self goDR:[(FSThumView *)sender ownerUser].uid];
    }
}

- (IBAction)goDR:(NSNumber *)userid {
    
    FSDRViewController *dr = [[FSDRViewController alloc] initWithNibName:@"FSDRViewController" bundle:nil];
    dr.userId = [userid intValue];
    [self.navigationController pushViewController:dr animated:TRUE];
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
    return type;
    
    FSComment *item = _comments[index];
    return item.sourcetype;
}

-(BOOL)proDetailViewNeedRefreshFromContext:(FSProDetailViewController *)view forIndex:(NSInteger)index
{
    return TRUE;
}

#pragma mark - FSAudioDelegate

-(void)clickAudioButton:(FSAudioButton*)aButton
{
    if (lastButton) {
        if (lastButton != aButton) {
            [lastButton stop];
        }
    }
    lastButton = aButton;
}

@end
