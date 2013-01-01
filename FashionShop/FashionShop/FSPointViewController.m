//
//  FSLikeViewController.m
//  FashionShop
//
//  Created by gong yi on 11/28/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSPointViewController.h"
#import "UIViewController+Loading.h"
#import "FSPointDetailCell.h"
#import "FSCommonUserRequest.h"
#import "FSPagedPoint.h"
#import "FSModelManager.h"

@interface FSPointViewController ()
{
    NSMutableArray *_likes;
    int _currentPage;
    BOOL _noMore;
    BOOL _inLoading;
    UIRefreshControl *_refreshControl;
}

@end

#define USER_POINT_TABLE_CELL @"userpointtablecell"
@implementation FSPointViewController
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
    [_contentView registerNib:[UINib nibWithNibName:@"FSPointDetailCell" bundle:Nil] forCellReuseIdentifier:USER_POINT_TABLE_CELL];
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
        [request send:[FSPagedPoint class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
            [self endLoading:_contentView];
            if (resp.isSuccess)
            {
                FSPagedPoint *innerResp = resp.responseData;
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
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"points%d", nil),currentUser.pointsTotal];
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"COMM_REFRESH_PULLTEXT", nil)];
    [_refreshControl addTarget:self action:@selector(RefreshViewControlEventValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_contentView addSubview:_refreshControl];
    _contentView.dataSource = self;
    _contentView.delegate =self;
}

-(void)RefreshViewControlEventValueChanged:(id)sender{
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"COMM_REFRESH_INGTEXT", nil)];
    FSCommonUserRequest *request = [self createRequest:1];
    [request send:[FSPagedPoint class] withRequest:request completeCallBack:^(FSEntityBase * resp) {
        [_refreshControl endRefreshing];
        if (resp.isSuccess)
        {
            FSPagedPoint *innerResp = resp.responseData;
            if (innerResp.totalPageCount<=_currentPage)
                _noMore = true;
            [self mergeLike:innerResp isInsert:true];
        }
        else
        {
            [self reportError:resp.errorDescrip];
        }
    }];
    
}
-(void) mergeLike:(FSPagedPoint *)response isInsert:(BOOL)isinsert
{
    if (!_likes)
    {
        _likes = [@[] mutableCopy];
    }
    if (response && response.items)
    {
        [response.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            int index = [_likes indexOfObjectPassingTest:^BOOL(id obj1, NSUInteger idx1, BOOL *stop1) {
                if ([(FSUser *)obj1 valueForKey:@"id"] == [(FSUser *)obj valueForKey:@"id"])
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
    request.routeResourcePath = RK_REQUEST_POINT_LIST;
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
    
    FSPointDetailCell *detailCell = [_contentView dequeueReusableCellWithIdentifier:USER_POINT_TABLE_CELL];
    detailCell.data = [_likes objectAtIndex:indexPath.row];
    return detailCell;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSPoint *point = [_likes objectAtIndex:indexPath.row];
    CGFloat baseHeight = 35;
    CGSize newSize = [point.getReason sizeWithFont:ME_FONT(14) constrainedToSize:CGSizeMake(200, 200) lineBreakMode:NSLineBreakByWordWrapping];
    return MAX(newSize.height+20, baseHeight);
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
    //GOTO DAREN PROFILE
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate

{
    if(!_inLoading &&
       (scrollView.contentOffset.y+scrollView.frame.size.height) > scrollView.contentSize.height
       &&scrollView.contentOffset.y>0
       && !_noMore)
        
    {
        _inLoading = TRUE;
        FSCommonUserRequest *request = [self createRequest:_currentPage+1];
        [request send:[FSPagedPoint class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
            _inLoading = FALSE;
            if (resp.isSuccess)
            {
                FSPagedPoint *innerResp = resp.responseData;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
