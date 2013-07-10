//
//  FSMessageViewController.m
//  FashionShop
//
//  Created by HeQingshan on 13-7-10.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSMessageViewController.h"
#import "NSString+Extention.h"
#import "FSPagedMyPLetter.h"
#import "FSPLetterRequest.h"
#import "FSCoreMyLetter.h"
#import "FSDRViewController.h"

@interface FSMessageViewController ()
{
    BOOL _isInLoading;
    BOOL _isSending;
    BOOL noMore;
    BOOL _isLoadData;
    NSMutableArray *dataArray;
}

@end

@implementation FSMessageViewController

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
    self.title = _touchUser.nickie;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = APP_TABLE_BG_COLOR;
    
    UIBarButtonItem *baritemCancel = [self createPlainBarButtonItem:@"goback_icon.png" target:self action:@selector(onButtonBack:)];
    [self.navigationItem setLeftBarButtonItem:baritemCancel];
    
    NSArray *array = [FSCoreMyLetter fetchLatestLetters:10 one:[[FSModelManager sharedModelManager].localLoginUid intValue] two:[_touchUser.uid intValue]];
    if (array.count > 0) {
        [self fillDataArray:array isInsert:NO];
        _lastConversationId = [array[array.count - 1] id];
        [self.tableView reloadData];
    }
    else{
        _lastConversationId = 0;
    }
    [self requestData:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePushNotification_pletter:) name:@"ReceivePushNotification_pletter" object:nil];
}

-(void)receivePushNotification_pletter:(NSNotification*)notification
{
    //获取最新的数据
    [self requestData:NO];
}

-(void)addLastData:(dispatch_block_t)action
{
    if (noMore) {
        if (action) {
            action();
        }
        return;
    }
    [self endLoadData:self.tableView];
    _isLoadData = NO;
    FSCoreMyLetter *item = dataArray[0];
    NSArray *array = [FSCoreMyLetter fetchData:item.id one:[[FSModelManager sharedModelManager].localLoginUid intValue] two:[_touchUser.uid intValue] length:5 ascending:NO];
    if (array.count > 0) {
        [self fillDataArray:array isInsert:YES];
        NSMutableArray *paths = [NSMutableArray array];
        for (int i = 0; i < array.count; i++) {
            NSIndexPath *_item = [NSIndexPath indexPathForRow:i inSection:0];
            [paths addObject:_item];
        }
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView endUpdates];
    }
    else{
        noMore = YES;
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.tableHeaderView = nil;
    }];
    if (action) {
        action();
    }
}

-(void) fillDataArray:(NSArray *)prods isInsert:(BOOL)isinserted
{
    if (!prods || prods.count <= 0)
        return;
    if (!dataArray) {
        dataArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    if (isinserted) {
        prods = [[prods reverseObjectEnumerator] allObjects];
    }
    [prods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        int index = [dataArray indexOfObjectPassingTest:^BOOL(id obj1, NSUInteger idx1, BOOL *stop1) {
            if ([[(FSCoreMyLetter *)obj1 valueForKey:@"id"] intValue] ==[[(FSCoreMyLetter *)obj valueForKey:@"id"] intValue])
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
                [dataArray addObject:obj];
            }
            else
            {
                [dataArray insertObject:obj atIndex:0];
            }
        }
    }];
}

-(void)requestData:(int)flag
{
    if (_isInLoading) {
        return;
    }
    FSPLetterRequest * request=[[FSPLetterRequest alloc] init];
    request.routeResourcePath = RK_REQUEST_MY_PLETTER_CONVERSATION;
    request.nextPage = [NSNumber numberWithInt:1];
    request.pageSize = @COMMON_PAGE_SIZE;
    request.userToken = [FSModelManager sharedModelManager].loginToken;
    request.userid = _touchUser.uid;
    request.lastconversationid = [NSNumber numberWithInt:_lastConversationId];
    if(flag)[self beginLoading:self.view];
    _isInLoading = YES;
    request.rootKeyPath = @"data.items";
    [request send:[FSCoreMyLetter class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
        if(flag)[self endLoading:self.view];
        _isInLoading = NO;
        if (resp.isSuccess)
        {
            NSArray *array = [FSCoreMyLetter fetchData:_lastConversationId one:[[FSModelManager sharedModelManager].localLoginUid intValue] two:[_touchUser.uid intValue] length:[resp.responseData count] ascending:YES];
            if (array.count > 0) {
                if (!dataArray) {
                    dataArray = [NSMutableArray arrayWithCapacity:5];
                }
                [self fillDataArray:array isInsert:NO];
                _lastConversationId = [dataArray[dataArray.count - 1] id];
            }
            [self.tableView reloadData];
            [self scrollToBottomAnimated:YES];
        }
        else
        {
            [self reportError:resp.errorDescrip];
        }
    }];
}

- (IBAction)onButtonBack:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

-(void) fillProdInMemory:(NSArray *)prods isInsert:(BOOL)isinserted
{
    if (!prods)
        return;
    if (!dataArray) {
        dataArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    [prods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        int index = [dataArray indexOfObjectPassingTest:^BOOL(id obj1, NSUInteger idx1, BOOL *stop1) {
            if ([[(FSCoreMyLetter *)obj1 valueForKey:@"id"] intValue] ==[[(FSCoreMyLetter *)obj valueForKey:@"id"] intValue])
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
                [dataArray addObject:obj];
            }
            else
            {
                [dataArray insertObject:obj atIndex:0];
            }
        }
    }];
}

#pragma mark - UITableViewSource delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hidenKeyboard];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BubbleMessageStyle style = [self messageStyleForRowAtIndexPath:indexPath];
    NSString *CellID = [NSString stringWithFormat:@"MessageCell%d", style];
    BubbleMessageCell *cell = (BubbleMessageCell*)[tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        NSArray *_array = [[NSBundle mainBundle] loadNibNamed:@"BubbleMessageCell" owner:self options:nil];
        if (_array.count > 0) {
            cell = (BubbleMessageCell*)_array[0];
        }
        else{
            cell = [[BubbleMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
        }
        [cell.bubbleView setStyle:style];
        cell.backgroundColor = tableView.backgroundColor;
    }
    FSCoreMyLetter *item = [dataArray objectAtIndex:indexPath.row];
    [cell updateControls:item showTime:[self needShowTime:indexPath.row]];
    cell.thumView.delegate = self;
    
    return cell;
}

-(BOOL)needShowTime:(int)index
{
    FSCoreMyLetter *item1 = [dataArray objectAtIndex:index];
    if (index - 1 > 0) {
        FSCoreMyLetter *item2 = [dataArray objectAtIndex:index-1];
        NSTimeInterval timeInterval = abs([item2.createdate timeIntervalSinceDate:item1.createdate]);
        if (timeInterval < 10) {
            return NO;
        }
        return YES;
    }
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BubbleMessageCell *cell = (BubbleMessageCell*)[tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.cellHeight;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

#pragma mark - Messages view controller
- (BubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSCoreMyLetter *item = [dataArray objectAtIndex:indexPath.row];
    int _id = item.fromuser.uid;
    if (_id != [[FSModelManager sharedModelManager].localLoginUid intValue] && _id != 0) {
        return BubbleMessageStyleIncoming;
    }
    else{
        return BubbleMessageStyleOutgoing;
    }
}

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSCoreMyLetter *item = [dataArray objectAtIndex:indexPath.row];
    return item.msg;
}

- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
    if (_isSending) {
        return;
    }
    if ([NSString isNilOrEmpty:text]) {
        return;
    }
    FSPLetterRequest * request=[[FSPLetterRequest alloc] init];
    request.routeResourcePath = RK_REQUEST_MY_PLETTER_SAY;
    request.touchUser = _touchUser.uid;
    request.textmsg = text;
    request.userToken = [FSModelManager sharedModelManager].loginToken;
    _isSending = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [request send:[FSCoreMyLetter class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
        if (resp.isSuccess)
        {
            if (!dataArray) {
                dataArray = [NSMutableArray arrayWithCapacity:5];
            }
            NSArray *array = [FSCoreMyLetter fetchLatestLetters:1 one:[[FSModelManager sharedModelManager].localLoginUid intValue] two:[_touchUser.uid intValue]];
            if (array.count > 0) {
                FSCoreMyLetter *result1 = array[0];
                if (result1) {
                    [self fillDataArray:[NSArray arrayWithObject:result1] isInsert:NO];
                    _lastConversationId = result1.id;
                    [self finishSend];
                }
            }
        }
        else
        {
            [self reportError:resp.errorDescrip];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        _isSending = NO;
    }];
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_isLoadData && !noMore && scrollView.contentOffset.y < -40) {
        [self beginLoadData:self.tableView];
        self.tableView.tableHeaderView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
        _isLoadData = YES;
        [self performSelector:@selector(addLastData:) withObject:nil afterDelay:0.5];
    }
    
}

@end
