//
//  FSTopicViewController.m
//  FashionShop
//
//  Created by HeQingshan on 13-1-25.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSTopicViewController.h"
#import "FSTopicListCell.h"

#define TOPIC_LIST_CELL @"FSTopicListCell"

@interface FSTopicViewController ()
{
    NSMutableArray *_topicList;
    int _currentPage;
    BOOL _noMore;
    BOOL _inLoading;
    UIRefreshControl *_refreshControl;
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
    
    [self.tbAction registerNib:[UINib nibWithNibName:@"FSTopicListCell" bundle:nil] forCellReuseIdentifier:TOPIC_LIST_CELL];
    self.tbAction.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tbAction.backgroundColor = [UIColor lightGrayColor];
    
    [self prepareData];
    [self preparePresent];
}

-(void) prepareData
{
    if (!_topicList)
    {
//        [self beginLoading:tbAction];
        _currentPage = 1;
//        FSCommonUserRequest *request = [self createRequest:_currentPage];
//        [request send:[FSPagedLike class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
//            [self endLoading:_contentView];
//            if (resp.isSuccess)
//            {
//                FSPagedLike *innerResp = resp.responseData;
//                if (innerResp.totalPageCount<=_currentPage)
//                    _noMore = true;
//                [self mergeLike:innerResp isInsert:false];
//            }
//            else
//            {
//                [self reportError:resp.errorDescrip];
//            }
//        }];
    }
}

-(void) preparePresent
{
    [self prepareRefreshLayout:tbAction withRefreshAction:^(dispatch_block_t action) {
//        FSCommonUserRequest *request = [self createRequest:1];
//        [request send:[FSPagedLike class] withRequest:request completeCallBack:^(FSEntityBase * resp) {
//            action();
//            if (resp.isSuccess)
//            {
//                FSPagedLike *innerResp = resp.responseData;
//                if (innerResp.totalPageCount<=_currentPage)
//                    _noMore = true;
//                [self mergeLike:innerResp isInsert:true];
//            }
//            else
//            {
//                [self reportError:resp.errorDescrip];
//            }
//        }];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 201;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSTopicListCell *cell = [self.tbAction dequeueReusableCellWithIdentifier:TOPIC_LIST_CELL];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.content.image = [UIImage imageNamed:[NSString stringWithFormat:@"topic%d.png", indexPath.row+1]];
    cell.content.layer.cornerRadius = 8;
    cell.content.layer.borderWidth = 0;
    return cell;
}

- (void)viewDidUnload {
    [self setTbAction:nil];
    [super viewDidUnload];
}
@end
