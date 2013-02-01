//
//  FSTopicViewController.m
//  FashionShop
//
//  Created by HeQingshan on 13-1-25.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSTopicViewController.h"
#import "FSTopicListCell.h"

#import "UIViewController+Loading.h"
#import "FSTopicRequest.h"
#import "FSModelManager.h"
#import "FSResource.h"
#import "FSPagedTopic.h"
#import "FSTopic.h"

#define TOPIC_LIST_CELL @"FSTopicListCell"

@interface FSTopicViewController ()
{
    NSMutableArray *_topicList;
    int _currentPage;
    bool _noMoreResult;
    
    UIActivityIndicatorView * moreIndicator;
    BOOL _isInLoading;
    BOOL _firstTimeLoadDone;
    
    NSDate *_refreshLatestDate;
    NSDate * _firstLoadDate;
}

@end

@implementation FSTopicViewController
@synthesize tbAction;

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
    
//    [self prepareData];
//    [self prepareLayout];
}

-(void) prepareData
{
    if (!_topicList)
    {
        _topicList = [@[] mutableCopy];
        [self zeroMemoryBlock];
        [self beginLoading:tbAction];
        _currentPage = 0;
        FSTopicRequest *request =
        [self buildListRequest:RK_REQUEST_TOPIC_LIST nextPage:1 isRefresh:FALSE];
        [request send:[FSPagedTopic class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
            [self endLoading:tbAction];
            if (resp.isSuccess)
            {
                FSPagedTopic *result = resp.responseData;
                if (result.totalPageCount <= _currentPage+1)
                    _noMoreResult = TRUE;
                [_topicList removeAllObjects];
                [self fillProdInMemory:result.items isInsert:FALSE];
            }
            else
            {
                [self reportError:resp.errorDescrip];
            }
        }];
    }
}

-(void) zeroMemoryBlock
{
    _currentPage = 0;
    _noMoreResult= FALSE;
}

-(FSTopicRequest *)buildListRequest:(NSString *)route nextPage:(int)page isRefresh:(BOOL)isRefresh
{
    FSTopicRequest *request = [[FSTopicRequest alloc] init];
    if(isRefresh)
    {
    //    request.requestType = 0;
        request.previousLatestDate = _refreshLatestDate;
    }
    else
    {
     //   request.requestType = 1;
        request.previousLatestDate = _firstLoadDate;
    }
    
    request.nextPage = page;
    request.pageSize = COMMON_PAGE_SIZE;
    return request;
}

-(void) fillProdInMemory:(NSArray *)prods isInsert:(BOOL)isinserted
{
    if (!prods)
        return;
    [prods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        int index = [prods indexOfObjectPassingTest:^BOOL(id obj1, NSUInteger idx1, BOOL *stop1) {
            if ([[(FSTopic *)obj1 valueForKey:@"id"] isEqualToValue:[(FSTopic *)obj valueForKey:@"id"]])
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
                [_topicList addObject:obj];
            } else
            {
                [_topicList insertObject:obj atIndex:0];
            }
            
        }
    }];
    [tbAction reloadData];
}

-(void) prepareLayout
{
    [self.tbAction registerNib:[UINib nibWithNibName:@"FSTopicListCell" bundle:nil] forCellReuseIdentifier:TOPIC_LIST_CELL];
    self.tbAction.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tbAction.backgroundColor = APP_BACKGROUND_COLOR;
    
    self.navigationItem.title = NSLocalizedString(@"Topics", nil);
    [self prepareRefreshLayout:tbAction withRefreshAction:^(dispatch_block_t action) {
        [self refreshContent:TRUE withCallback:^(){
            action();
        }];
        
    }];
    
    tbAction.delegate = self;
    tbAction.dataSource = self;
}

-(void)refreshContent:(BOOL)isRefresh withCallback:(dispatch_block_t)callback
{
    int nextPage = 1;
    if (!isRefresh)
    {
        _currentPage++;
        nextPage = _currentPage +1;
    }
    FSTopicRequest *request = [self buildListRequest:RK_REQUEST_TOPIC_LIST nextPage:nextPage isRefresh:isRefresh];
    [request send:[FSPagedTopic class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
        callback();
        if (resp.isSuccess)
        {
            FSPagedTopic *result = resp.responseData;
            if (isRefresh)
                _refreshLatestDate = [[NSDate alloc] init];
            else
            {
                if (result.totalPageCount <= _currentPage+1)
                    _noMoreResult = TRUE;
            }
            [self fillProdInMemory:result.items isInsert:isRefresh];
        }
        else
        {
            [self reportError:resp.errorDescrip];
        }
    }];
}

#pragma UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 205;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_topicList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= _topicList.count) {
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    
    FSTopicListCell *cell = [self.tbAction dequeueReusableCellWithIdentifier:TOPIC_LIST_CELL];
    [cell setData:_topicList[indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //cell.content.image = [UIImage imageNamed:[NSString stringWithFormat:@"topic%d.png", indexPath.row+1]];
    cell.content.layer.cornerRadius = 8;
    cell.content.layer.borderWidth = 0;
    return cell;
}

- (void)viewDidUnload {
    [self setTbAction:nil];
    [super viewDidUnload];
}
@end
