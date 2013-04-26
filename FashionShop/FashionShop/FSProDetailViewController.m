//
//  FSProDetailViewController.m
//  FashionShop
//
//  Created by gong yi on 11/20/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSProDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "FSModelManager.h"
#import "FSMeViewController.h"
#import "MBProgressHUD.h"
#import "FSProDetailView.h"
#import "FSProdDetailView.h"
#import "FSProCommentCell.h"
#import "FSProCommentInputView.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "FSDRViewController.h"
#import "FSProCommentHeader.h"
#import "FSProductListViewController.h"
#import "FSStoreDetailViewController.h"
#import "FSSearchViewController.h"
#import "FSProPostTitleViewController.h"
#import "CL_VoiceEngine.h"
#import "FSAudioShowView.h"
#import "FSImageBrowserView.h"

#import "FSCouponRequest.h"
#import "FSFavorRequest.h"
#import "FSUser.h"
#import "FSCoupon.H"
#import "FSCommonProRequest.h"
#import "FSCommonCommentRequest.h"
#import "FSLocationManager.h"

#import "FSShareView.h"
#import "AWActionSheet.h"
#import "UIBarButtonItem+Title.h"
#import "UIViewController+Loading.h"
#import <PassKit/PassKit.h>
#import "NSData+Base64.h"

#import "EGOPhotoGlobal.h"
#import "MyPhoto.h"
#import "MyPhotoSource.h"

#define PRO_DETAIL_COMMENT_INPUT_TAG 200
#define TOOLBAR_HEIGHT 44
#define PRO_DETAIL_COMMENT_INPUT_HEIGHT 63
#define PRO_DETAIL_COMMENT_HEADER_HEIGHT 30

@interface FSProDetailViewController ()
{
    MBProgressHUD   *statusReport;
    id              proItem;
    int             currentPageIndex;
    
    int             replyIndex;//回复索引
    BOOL            isReplyToAll;//是否是回复给所有人
    
    RecordState     _recordState;
    BOOL            _isRecording;
    NSDate*         _downTime;//按下时间
    NSInteger       _minRecordGap;//最小录制时间间隔
    BOOL            _isAudio;//是否是语音内容
    BOOL            _isPlaying;//是否正在播放声音
    FSAudioButton   *lastButton;
    NSTimer         *_timer;
    FSAudioShowView *_audioShowView;//音量检测视图
}

@end

@implementation FSProDetailViewController
@synthesize dataProviderInContext,navContext,indexInContext;

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
    [self beginPrepareData];
    if (!theApp.audioRecoder) {
        [theApp initAudioRecoder];
    }
    
    _minRecordGap = 1.5;
    theApp.audioRecoder.clAudioDelegate = self;
}

-(void) beginPrepareData
{
    [self doBinding:nil];
}

-(void) onButtonCancel
{
    [self.navigationController dismissViewControllerAnimated:true completion:nil];
}

-(void) doBinding:(FSProItemEntity *)source
{
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];

    UIBarButtonItem *baritemCancel = [self createPlainBarButtonItem:@"goback_icon.png" target:self action:@selector(onButtonCancel)];
    UIBarButtonItem *baritemShare = [self createPlainBarButtonItem:@"share_icon.png" target:self action:@selector(doShare:)];
    [self.navigationItem setLeftBarButtonItem:baritemCancel];
    [self.navigationItem setRightBarButtonItem:baritemShare];
    currentPageIndex = -1;
    replyIndex = -1;
    [self.paginatorView reloadData];
    self.currentPageIndex = indexInContext;
    
    if (!_audioShowView) {
        int height = 120;
        _audioShowView = [[FSAudioShowView alloc] initWithFrame:CGRectMake((APP_WIDTH - height)/2, (APP_HIGH - height)/2 - 70, height, height)];
        [self.view addSubview:_audioShowView];
        _audioShowView.hidden = YES;
    }
}

-(id)itemSource
{
    return [(id)self.paginatorView.currentPage data];
}

#pragma mark - SYPaginatorViewDataSource

- (NSInteger)numberOfPagesForPaginatorView:(SYPaginatorView *)paginatorView {
	return navContext.count;
}

- (SYPageView *)paginatorView:(SYPaginatorView *)paginatorView viewForPageAtIndex:(NSInteger)pageIndex {
    NSString *identifier = NSStringFromClass([FSProDetailView class]);
    FSSourceType source = [dataProviderInContext proDetailViewSourceTypeFromContext:self forIndex:pageIndex];
	if (source == FSSourceProduct)
        identifier = NSStringFromClass([FSProdDetailView class]);
	FSDetailBaseView * view = (FSDetailBaseView*)[paginatorView dequeueReusablePageWithIdentifier:identifier];
	if (!view) {
        if (source == FSSourcePromotion)
            view = [[[NSBundle mainBundle] loadNibNamed:@"FSProDetailView" owner:self options:nil] lastObject];
        else
            view = [[[NSBundle mainBundle] loadNibNamed:@"FSProdDetailView" owner:self options:nil] lastObject];
    }
    [view setPType:source];
    CGRect _rect = view.myToolBar.frame;
    _rect.size.height = TAB_HIGH;
    view.myToolBar.frame = _rect;
    [view setToolBarBackgroundImage];

    if ([view respondsToSelector:@selector(imgThumb)])
    {
        [(FSThumView *)[(id)view imgThumb] setDelegate:self];
    }
    if ([view respondsToSelector:@selector(imgView)])
    {
        UIImageView *prodImage = (UIImageView *)[(id)view imgView];
        [prodImage setUserInteractionEnabled:TRUE];
        UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapProImage:)];
        [prodImage addGestureRecognizer:imgTap];
    }
    if ([view respondsToSelector:@selector(btnTag)])
    {
        UIButton *tagButton = (UIButton *)[(id)view btnTag];
        [tagButton addTarget:self action:@selector(goTag:) forControlEvents:UIControlEventTouchUpInside];
    }
    [[(id)view tbComment] registerNib:[UINib nibWithNibName:@"FSProCommentCell" bundle:nil] forCellReuseIdentifier:@"commentCell"];
    
    if (![(id)view audioButton].audioDelegate) {
        [(id)view audioButton].audioDelegate = self;
    }
    [(id)view svContent].delegate = self;
    [(id)view tbComment].delegate = self;
    [(id)view tbComment].dataSource = self;
    [(id)view tbComment].scrollEnabled = FALSE;
    [(id)view svContent].scrollEnabled = TRUE;
    view.showViewMask = TRUE;
	return view;
}

-(void) resetScrollViewSize:(FSDetailBaseView *)view
{
    [view resetScrollViewSize];
}

- (void)paginatorView:(SYPaginatorView *)paginatorView didScrollToPageAtIndex:(NSInteger)pageIndex
{
    if (currentPageIndex== pageIndex)
        return;
    currentPageIndex= pageIndex;
    __block FSDetailBaseView * blockViewForRefresh = (FSDetailBaseView*)paginatorView.currentPage;
    __block FSProDetailViewController *blockSelf = self;
    _sourceType = blockViewForRefresh.pType;
   
    if ([dataProviderInContext respondsToSelector:@selector(proDetailViewNeedRefreshFromContext:forIndex:)] &&
        [dataProviderInContext proDetailViewNeedRefreshFromContext:self forIndex:pageIndex]==TRUE)
    {
        NSNumber * itemId = nil;
        if (_fromBanner) {
            itemId = [[navContext objectAtIndex:pageIndex] valueForKey:@"promotionid"];
        }
        else{
            itemId = [[navContext objectAtIndex:pageIndex] valueForKey:@"id"];
        }
        FSCommonProRequest *drequest = [[FSCommonProRequest alloc] init];
        drequest.uToken = [FSModelManager sharedModelManager].loginToken;
        drequest.id = itemId;
        drequest.longit =[NSNumber numberWithFloat:[FSLocationManager sharedLocationManager].currentCoord.longitude];
        drequest.lantit = [NSNumber numberWithFloat:[FSLocationManager sharedLocationManager].currentCoord.latitude];
        drequest.pType= blockViewForRefresh.pType;
        Class respClass;
        if (drequest.pType == FSSourceProduct)
        {
            drequest.routeResourcePath = RK_REQUEST_PROD_DETAIL;
            respClass = [FSProdItemEntity class];
        }
        else
        {
            drequest.routeResourcePath = RK_REQUEST_PRO_DETAIL;
            respClass = [FSProItemEntity class];
        }
        [drequest send:respClass withRequest:drequest completeCallBack:^(FSEntityBase *resp) {
            if (resp.isSuccess)
            {
                [blockViewForRefresh setData:resp.responseData];
                [(FSProDetailView*)blockViewForRefresh audioButton].audioDelegate = self;
                [blockViewForRefresh updateToolBar:resp.responseData];
                NSString *navTitle = [blockViewForRefresh.data valueForKey:@"title"];
                if (blockSelf->_sourceType==FSSourcePromotion)
                    navTitle = NSLocalizedString(@"promotion detail", nil);
                [blockSelf.navigationItem setTitle:navTitle] ;
                blockViewForRefresh.showViewMask= FALSE;
                [blockSelf delayLoadComments:[blockViewForRefresh.data valueForKey:@"id"]];
                
                //左右箭头
                //_arrowRight.hidden = [self hasNextPage]?NO:YES;
//                [self.view bringSubviewToFront:_arrowRight];
//                CGRect _rect = _arrowRight.frame;
//                _rect.size.height = 15;
//                _arrowRight.frame = _rect;
//                //_arrowLeft.hidden = [self hasPrePage]?NO:YES;
//                [self.view bringSubviewToFront:_arrowLeft];
//                _rect = _arrowLeft.frame;
//                _rect.size.height = 15;
//                _arrowLeft.frame = _rect;
            } else
            {
                [self onButtonCancel];
            }
        }];

    } else
    {
        [dataProviderInContext proDetailViewDataFromContext:self forIndex:pageIndex completeCallback:^(id input){
            [blockViewForRefresh setData:input];
            [(FSProdDetailView*)blockViewForRefresh audioButton].audioDelegate = self;
            [blockViewForRefresh updateToolBar:input];
            blockViewForRefresh.showViewMask= FALSE;
            NSString *navTitle = [blockViewForRefresh.data valueForKey:@"title"];
            if (blockSelf->_sourceType==FSSourcePromotion)
                navTitle = NSLocalizedString(@"promotion detail", nil);
            [blockSelf.navigationItem setTitle:navTitle] ;
            [blockSelf delayLoadComments:[blockViewForRefresh.data valueForKey:@"id"]];
            
        } errorCallback:^{
            [self onButtonCancel];
        }];
    }
    [self hideCommentInputView:nil];
}

-(void)delayLoadComments:(NSNumber *)proId
{
    __block FSDetailBaseView * blockViewForRefresh = (FSDetailBaseView*)self.paginatorView.currentPage;
    if (!blockViewForRefresh)
        return;
    __block FSProDetailViewController *blockSelf = self;
    FSCommonCommentRequest * request=[[FSCommonCommentRequest alloc] init];
    request.routeResourcePath = RK_REQUEST_COMMENT_LIST;
    request.sourceid = proId;
    request.sourceType =[NSNumber numberWithInt:blockViewForRefresh.pType];//promotion
    request.nextPage = @1;
    request.pageSize = @100;
    request.refreshTime = [[NSDate alloc] init];
    request.rootKeyPath = @"data.comments";
    [request send:[FSComment class] withRequest:request completeCallBack:^(FSEntityBase *resp) {
        if (resp.isSuccess)
        {
            [[blockViewForRefresh data] setComments:resp.responseData];
            replyIndex = -1;
            if (blockViewForRefresh && blockSelf)
                [[(id)blockViewForRefresh tbComment] reloadData];
        }
        else
        {
            NSLog(@"comment list failed");
        }
    }];
}

-(void)scrollToTableTop:(FSDetailBaseView*)blockViewForRefresh
{
    CGRect _rect = [(id)blockViewForRefresh tbComment].frame;
    _rect.size.height = 100;
    [[(id)blockViewForRefresh svContent] scrollRectToVisible:_rect animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

-(Class)convertSourceTypeToClass:(FSSourceType)pType
{
    switch (pType) {
        case FSSourceProduct:
            return [FSProdItemEntity class];
        case  FSSourcePromotion:
            return [FSProItemEntity class];
            
        default:
            break;
    }
    return nil;
}

-(void) internalGetCoupon:(dispatch_block_t) cleanup
{
    FSCouponRequest *request = [[FSCouponRequest alloc] init];
    request.userToken = [FSModelManager sharedModelManager].loginToken;
    request.productId = [[self.itemSource valueForKey:@"id"] intValue];
    request.productType = _sourceType ;
    request.includePass = [PKPass class]?TRUE:FALSE;
    request.rootKeyPath = @"data.coupon";
    
    __block FSProDetailViewController *blockSelf = self;
    [request send:[FSCoupon class] withRequest:request completeCallBack:^(FSEntityBase *respData){
        if(!respData.isSuccess)
        {
            [blockSelf updateProgress:respData.errorDescrip];
            if (cleanup)
                cleanup();
        }
        else
        {
            FSCoupon *coupon = respData.responseData;
            FSDetailBaseView *view = (FSDetailBaseView*)blockSelf.paginatorView.currentPage;
            if ([view.data isKindOfClass:[FSProdItemEntity class]])
            {
                ((FSProdItemEntity *)view.data).couponTotal ++;
            } else if ([view.data isKindOfClass:[FSProItemEntity class]])
            {
                 ((FSProItemEntity *)view.data).couponTotal ++;
            }
            FSUser *localUser = (FSUser *)[FSUser localProfile];
            localUser.couponsTotal ++;
            //add pass to passbook
            if (coupon.pass &&
                [PKPass class])
            {
                NSError *error = nil;
                NSString *passByte = coupon.pass;
                 PKPass *pass = [[PKPass alloc] initWithData:[NSData dataFromBase64String:passByte] error:&error];
                if (pass)
                {
                    PKAddPassesViewController *passController = [[PKAddPassesViewController alloc] initWithPass:pass];
                    [self presentViewController:passController animated:TRUE completion:nil];
                }
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warm prompt", nil) message:NSLocalizedString(@"Pass Add Tip Info", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
            [blockSelf updateProgressThenEnd:NSLocalizedString(@"coupon use instruction",nil) withDuration:2];
        }

    }];
    
    //统计
    FSDetailBaseView *view = (FSDetailBaseView*)blockSelf.paginatorView.currentPage;
    NSString *_name;
    if (_sourceType == FSSourceProduct) {
        _name = [NSString stringWithFormat:@"商品-优惠券  %@", [view.data valueForKey:@"title"]];
    }
    else {
        _name = [NSString stringWithFormat:@"活动-优惠券  %@", [view.data valueForKey:@"title"]];
    }
    [[FSAnalysis instance] logEvent:_name withParameters:nil];
}

-(void) internalDoFavor:(UIBarButtonItem *)button
{
    
    FSFavorRequest *request = [[FSFavorRequest alloc] init];
    request.userToken = [FSModelManager sharedModelManager].loginToken;
    request.productId = [self.itemSource valueForKey:@"id"];
    request.productType = _sourceType ;
    __block BOOL favored = [[self.itemSource valueForKey:@"isFavored"] boolValue];
    if (favored)
    {
        request.routeResourcePath = _sourceType==FSSourceProduct?RK_REQUEST_FAVOR_PROD_REMOVE:RK_REQUEST_FAVOR_PRO_REMOVE;
    }
    FSDetailBaseView *view = (FSDetailBaseView*)self.paginatorView.currentPage;
    if ([view.data isKindOfClass:[FSProdItemEntity class]])
    {
        ((FSProdItemEntity *)view.data).isFavored = !favored;
    } else if ([view.data isKindOfClass:[FSProItemEntity class]])
    {
        ((FSProItemEntity *)view.data).isFavored = !favored;
    }

    button.enabled = false;
    __block FSProDetailViewController *blockSelf = self;
    
    [request send:[self convertSourceTypeToClass:_sourceType] withRequest:request completeCallBack:^(FSEntityBase *respData){
        if (respData.isSuccess)
        {
            
            FSDetailBaseView *view = (FSDetailBaseView*)blockSelf.paginatorView.currentPage;
            if ([view.data isKindOfClass:[FSProdItemEntity class]])
            {
                ((FSProdItemEntity *)view.data).isFavored = !favored;
                if (favored)
                    ((FSProdItemEntity *)view.data).favorTotal --;
                else
                    ((FSProdItemEntity *)view.data).favorTotal ++;
            } else if ([view.data isKindOfClass:[FSProItemEntity class]])
            {
                ((FSProItemEntity *)view.data).isFavored = !favored;
                if (favored)
                    ((FSProItemEntity *)view.data).favorTotal --;
                else
                    ((FSProItemEntity *)view.data).favorTotal ++;
            }

            if (favored &&
                [blockSelf.dataProviderInContext respondsToSelector:@selector(proDetailViewShouldPostNotification:)])
            {
                BOOL shouldPostMesg = [blockSelf.dataProviderInContext proDetailViewShouldPostNotification:blockSelf];
                if (shouldPostMesg)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:LN_FAVOR_UPDATED object:[blockSelf.navContext objectAtIndex:blockSelf.paginatorView.currentPageIndex] ];
                }
            }
        } 
        button.enabled = TRUE;
    }];
    
    //统计
    NSString *_name;
    if (favored) {
        if (_sourceType == FSSourceProduct) {
            _name = [NSString stringWithFormat:@"商品-喜欢  %@", [view.data valueForKey:@"title"]];
        }
        else {
            _name = [NSString stringWithFormat:@"活动-喜欢  %@", [view.data valueForKey:@"title"]];
        }
    }
    else {
        if (_sourceType == FSSourceProduct) {
            _name = [NSString stringWithFormat:@"商品-取消喜欢  %@", [view.data valueForKey:@"title"]];
        }
        else {
            _name = [NSString stringWithFormat:@"活动-取消喜欢  %@", [view.data valueForKey:@"title"]];
        }
    }
    
    [[FSAnalysis instance] logEvent:_name withParameters:nil];
}
-(void) updateFavorButtonStatus:(UIBarButtonItem *)button canFavored:(BOOL)canfavored
{
    NSString *name = canfavored?@"bottom_nav_like_icon":@"bottom_nav_notlike_icon";
    UIImage *sheepImage = [UIImage imageNamed:name];
    if (!button.customView)
    {
        UIButton *sheepButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sheepButton setShowsTouchWhenHighlighted:YES];
        [sheepButton addTarget:self action:@selector(doFavor:) forControlEvents:UIControlEventTouchUpInside];
        button.customView = sheepButton;
    }
    UIButton *sheepButton = (UIButton*)button.customView;
    [sheepButton setImage:sheepImage forState:UIControlStateNormal];
    [sheepButton sizeToFit];
}

- (IBAction)doBack:(id)sender {
    [self dismissViewControllerAnimated:FALSE completion:nil];
}

- (IBAction)doComment:(id)sender {
    id currentView =  self.paginatorView.currentPage;
    isReplyToAll = YES;
    
    //[(UIScrollView *)[currentView tbComment].superview scrollRectToVisible:[currentView tbComment].frame animated:TRUE];
    [self displayCommentInputView:currentView];
}

- (IBAction)doGetCoupon:(id)sender {
    bool isLogined = [[FSModelManager sharedModelManager] isLogined];
    NSString *_loginToken = [FSModelManager sharedModelManager].loginToken;
    if (!isLogined || !_loginToken)
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
                    [self startProgress:NSLocalizedString(@"coupon use instruction", nil) withExeBlock:^(dispatch_block_t callback){
                        [self internalGetCoupon:callback];
                    } completeCallbck:^{
                        [self endProgress];
                    }];
                }
            }];
        };
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
        [self presentViewController:navController animated:true completion:nil] ;
    }
    else
    {
        [self startProgress:NSLocalizedString(@"coupon use instruction", nil) withExeBlock:^(dispatch_block_t callback){
            [self internalGetCoupon:callback];
        } completeCallbck:^{
            [self endProgress];
        }];   
    }
}

- (IBAction)doShare:(id)sender {
    NSMutableArray *shareItems = [@[] mutableCopy];
    id view = self.paginatorView.currentPage;
    NSString *title = [self.itemSource valueForKey:@"title"];
    title = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"share prefix", nil),title];
    [shareItems addObject:title?title:@""];
    if ([view imgView].image != nil)
    {
        [shareItems addObject:[view imgView].image];
        if ([view imageURL]) {
            [shareItems addObject:[view imageURL]];
        }
    }
    
    [[FSShareView instance] shareBegin:self withShareItems:shareItems  completeHander:^(NSString *activityType, BOOL completed){
        if (completed)
        {
            [self reportError:NSLocalizedString(@"COMM_OPERATE_COMPL", nil)];
        }
    }];
}

- (IBAction)showBrand:(id)sender {
    FSDetailBaseView * view = (FSDetailBaseView*)self.paginatorView.currentPage;
    FSBrand *tbrand = [view.data brand];
    FSProductListViewController *dr = [[FSProductListViewController alloc] initWithNibName:@"FSProductListViewController" bundle:nil];
    dr.brand = tbrand;
    dr.pageType = FSPageTypeBrand;
    [self.navigationController pushViewController:dr animated:TRUE];
}

- (IBAction)goStore:(id)sender {
    FSDetailBaseView * view = (FSDetailBaseView*)self.paginatorView.currentPage;
    FSStore *store = [view.data store];
    FSStoreDetailViewController *sv = [[FSStoreDetailViewController alloc] initWithNibName:@"FSStoreDetailViewController" bundle:nil];
    sv.store =store;
    [self.navigationController pushViewController:sv animated:TRUE];
}

- (IBAction)goDR:(NSNumber *)userid {

    FSDRViewController *dr = [[FSDRViewController alloc] initWithNibName:@"FSDRViewController" bundle:nil];
    dr.userId = [userid intValue];
    [self.navigationController pushViewController:dr animated:TRUE];
}

-(void) goTag:(id)sender
{
    
    if (![[self itemSource] respondsToSelector:@selector(tagId)])
    {
        return;
    }
    int input = [[[self itemSource] valueForKey:@"tagId"] intValue];
    FSSearchViewController *tag = [[FSSearchViewController alloc] initWithNibName:@"FSSearchViewController" bundle:nil];
    tag.searchTag = input;
    tag.navigationItem.title = [[self itemSource] valueForKey:@"title"];
    [self.navigationController pushViewController:tag animated:TRUE];
}

- (IBAction)doFavor:(id)sender {
    
    bool isLogined = [[FSModelManager sharedModelManager] isLogined];
     __block id view = self.paginatorView.currentPage;
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
                    if ([view respondsToSelector:@selector(btnFavor)])
                    {
                        UIBarButtonItem *favorButton = [view btnFavor];
                        [self internalDoFavor:favorButton];
                    }
                }
            }];
        };
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
        [self presentViewController:navController animated:false completion:nil];
        
    }
    else
    {
        if ([view respondsToSelector:@selector(btnFavor)])
        {
            UIBarButtonItem *favorButton = [view btnFavor];
            [self internalDoFavor:favorButton];
        }
    }
    
}
-(void)didTapProImage:(id) sender
{
    if ([self numberOfImagesInSlides:nil]<=0)
        return;
    
    NSMutableArray *photoArray=[NSMutableArray arrayWithCapacity:[[self itemSource] resource].count];
    for(FSResource *res in [[self itemSource] resource])
    {
        if (res.type == 2) {
            continue;
        }
        MyPhoto *photo = [[MyPhoto alloc] initWithImageURL:[res absoluteUrl320] name:nil];
        [photoArray addObject:photo];
    }
    MyPhotoSource *source = [[MyPhotoSource alloc] initWithPhotos:photoArray];
    EGOPhotoViewController *photoController = [[EGOPhotoViewController alloc] initWithPhotoSource:source];
    int width = 100;
    photoController.beginRect = CGRectMake((APP_WIDTH-width)/2, (APP_HIGH-width)/2, width, width);
    photoController.source = self;
    //[self.navigationController pushViewController:photoController animated:NO];
    [self presentModalViewController:photoController animated:YES];
    
    
    return;
    /*
    FSImageBrowserView *view = [[FSImageBrowserView alloc] initWithFrame:self.view.frame];
    view.photos = [[self itemSource] resource];
    [self.view addSubview:view];
    [self.view bringSubviewToFront:view];
    UITapGestureRecognizer * tap = (UITapGestureRecognizer*)sender;
    view.scrollView.frame = tap.view.frame;//CGRectMake(self.view.center.x, self.view.center.y, 0, 0);
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [UIView animateWithDuration:0.3 animations:^{
        view.scrollView.frame = view.frame;
    } completion:^(BOOL finished) {
        ;
    }];
    
    UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImages:)];
    imgTap.numberOfTapsRequired = 1;
    [view addGestureRecognizer:imgTap];
     */
}

-(void)didTapImages:(id) sender
{
    UITapGestureRecognizer * tap = (UITapGestureRecognizer*)sender;
    FSDetailBaseView * view = (FSDetailBaseView*)self.paginatorView.currentPage;
    UIImageView *prodImage = (UIImageView *)[(id)view imgView];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [UIView animateWithDuration:0.3 animations:^{
        tap.view.frame = prodImage.frame;
    } completion:^(BOOL finished) {
        [tap.view removeFromSuperview];
    }];
}

- (void) displayCommentInputView:(id)parent
{
    FSProCommentInputView *commentInput = (FSProCommentInputView*)[self.view viewWithTag:PRO_DETAIL_COMMENT_INPUT_TAG];
    if (!commentInput)
    {
        commentInput = [[[NSBundle mainBundle] loadNibNamed:@"FSProCommentInputView" owner:self options:nil] lastObject];
        CGFloat height = PRO_DETAIL_COMMENT_INPUT_HEIGHT;
        commentInput.frame = CGRectMake(0, self.view.frame.size.height-TOOLBAR_HEIGHT-height, self.view.frame.size.width, height);
        commentInput.txtComment.delegate = self;
        
        [commentInput.btnComment addTarget:self action:@selector(saveComment:) forControlEvents:UIControlEventTouchUpInside];
        [commentInput.btnCancel addTarget:self action:@selector(clearComment:) forControlEvents:UIControlEventTouchUpInside];
        [commentInput.btnChange addTarget:self action:@selector(changeCommentType:) forControlEvents:UIControlEventTouchUpInside];
        commentInput.btnChange.showsTouchWhenHighlighted = YES;
        
        //设置按钮背景图片
        UIImage *image = [UIImage imageNamed:@"audio_btn_normal.png"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 50, image.size.height, image.size.width-50)];
        [commentInput.btnAudio setBackgroundImage:image forState:UIControlStateNormal];
        
        image = [UIImage imageNamed:@"audio_btn_sel.png"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 50, image.size.height, image.size.width-50)];
        [commentInput.btnAudio setBackgroundImage:image forState:UIControlStateHighlighted];
        
        [commentInput.btnAudio addTarget:self action:@selector(recordTouchDown:) forControlEvents:UIControlEventTouchDown];
        [commentInput.btnAudio addTarget:self action:@selector(recordTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [commentInput.btnAudio addTarget:self action:@selector(recordTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [commentInput.btnAudio addTarget:self action:@selector(recordTouchDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
        [commentInput.btnAudio addTarget:self action:@selector(recordTouchDragExit:) forControlEvents:UIControlEventTouchDragExit];
    
        [self.view addSubview:commentInput];
        
        commentInput.tag = PRO_DETAIL_COMMENT_INPUT_TAG;
        if  (commentInput.opaque!=1)
        {
            commentInput.layer.opacity = 0;
            [UIView beginAnimations:@"fadein" context:(__bridge void *)([NSNumber numberWithFloat:commentInput.layer.opacity])];
            [UIView setAnimationDuration:0.5];
            commentInput.layer.opacity = 1;
            [UIView commitAnimations];
            commentInput.opaque = 1;
            [self.view bringSubviewToFront:commentInput];
        }

    }
    else if(isReplyToAll)
    {
        [self hideCommentInputView:parent];
    }
    [self changeCommentType:nil];
}

-(void) hideCommentInputView:(id)parent
{
    FSProCommentInputView *commentInput = (FSProCommentInputView*)[self.view viewWithTag:PRO_DETAIL_COMMENT_INPUT_TAG];
    //如果commentInput不为空，则
    if (commentInput)
    {
        commentInput.txtComment.text = @"";
        [commentInput.txtComment resignFirstResponder];
        [commentInput removeFromSuperview];
        if (commentInput.opaque!=0)
        {
            commentInput.layer.opacity = 1;
            [UIView beginAnimations:@"fadeout" context:(__bridge void *)([NSNumber numberWithFloat:commentInput.layer.opacity])];
            [UIView setAnimationDuration:0.3];
            commentInput.layer.opacity = 0;
            [UIView commitAnimations];
            [commentInput removeFromSuperview];
        }
    }
}
-(void)clearComment:(UIButton *)sender
{
    //隐藏输入区域
    [self hideCommentInputView:self.view];
    //取消任何回复特定用户的选项
    replyIndex = -1;
    id currentView =  self.paginatorView.currentPage;
    [[currentView tbComment] reloadData];
}

//当点击语音和文字的切换按钮时，更新显示元素
-(void)changeCommentType:(UIButton*)sender
{
    FSProCommentInputView *commentInput = (FSProCommentInputView*)[self.view viewWithTag:PRO_DETAIL_COMMENT_INPUT_TAG];
    if (commentInput) {
        if (commentInput.txtComment.isFirstResponder) {
            if (sender) {
                [commentInput.txtComment resignFirstResponder];
                [commentInput.btnChange setImage:[UIImage imageNamed:@"text_change_icon.png"] forState:UIControlStateNormal];
                [commentInput updateControls:2];
                _isAudio = YES;
            }
            else{
                [commentInput.btnChange setImage:[UIImage imageNamed:@"audio_change_icon.png"] forState:UIControlStateNormal];
                [commentInput updateControls:1];
                _isAudio = NO;
            }
        }
        else{
            if (sender) {
                [commentInput.txtComment becomeFirstResponder];
                [commentInput.btnChange setImage:[UIImage imageNamed:@"audio_change_icon.png"] forState:UIControlStateNormal];
                [commentInput updateControls:1];
                _isAudio = NO;
            }
            else{
                [commentInput.btnChange setImage:[UIImage imageNamed:@"text_change_icon.png"] forState:UIControlStateNormal];
                [commentInput updateControls:2];
                _isAudio = YES;
            }
        }
        if (isReplyToAll) {
            commentInput.replyLabel.text = NSLocalizedString(@"Reply All", nil);
        }
        else{
            //获取选中用户的ID；
            id currentView =  self.paginatorView.currentPage;
            FSDetailBaseView *parentView = (FSDetailBaseView *)[currentView tbComment].superview.superview.superview;
            FSComment *item = (FSComment*)[[parentView.data comments] objectAtIndex:replyIndex];
            commentInput.replyLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Reply %@", nil), item.inUser.nickie];
        }
    }
}

-(NSString *)transformCommentText
{
    FSProCommentInputView *commentView = (FSProCommentInputView*)[self.view viewWithTag:PRO_DETAIL_COMMENT_INPUT_TAG];
    NSString *trimedText = [[commentView.txtComment.text stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    return trimedText;
}

-(void)saveComment:(UIButton *)sender
{
    FSProCommentInputView *commentView = (FSProCommentInputView*)[self.view viewWithTag:PRO_DETAIL_COMMENT_INPUT_TAG];
    [commentView.txtComment resignFirstResponder];
    if (!_isAudio) {
        NSString *trimedText = commentView.txtComment.text;//[self transformCommentText];
        if (trimedText.length>40 ||trimedText.length<1)
        {
            [self clearComment:nil];
            [self reportError:NSLocalizedString(@"PRO_COMMENT_LENGTH_NOTCORRECT", Nil)];
            return;
        }
    }
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
                    [self startProgress:NSLocalizedString(@"FS_PRODETAIL_COMMING",nil)withExeBlock:^(dispatch_block_t callback){
                        [self internalDoComent:callback];
                    } completeCallbck:^{
                        [self endProgress];
                    }];
                }
            }];
        };
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
        [self presentViewController:navController animated:YES completion:nil];
        
    }
    else
    {
        [self startProgress:NSLocalizedString(@"FS_PRODETAIL_COMMING",nil)withExeBlock:^(dispatch_block_t callback){
            [self internalDoComent:callback];
        } completeCallbck:^{
            [self endProgress];
        }];
    }
}

-(void) internalDoComent:(dispatch_block_t)callback
{
    FSProCommentInputView *commentView = (FSProCommentInputView*)[self.view viewWithTag:PRO_DETAIL_COMMENT_INPUT_TAG];
    NSString *commentText = commentView.txtComment.text;
    FSCommonCommentRequest *request = [[FSCommonCommentRequest alloc] init];
    request.userToken = [FSModelManager sharedModelManager].loginToken;
    request.sourceid = [[(FSDetailBaseView *)self.paginatorView.currentPage data] valueForKey:@"id"];
    request.sourceType = [NSNumber numberWithInt:_sourceType];
    request.routeResourcePath = RK_REQUEST_COMMENT_SAVE;
    request.pageSize = [NSNumber numberWithInt:COMMON_PAGE_SIZE];
    if (_recordFileName && ![_recordFileName isEqualToString:@""]) {
        request.audioName = [kRecorderDirectory stringByAppendingPathComponent:_recordFileName];
    }
    else{
        request.comment = commentText;
    }
    //回复特用户
    if (!isReplyToAll) {
        //获取选中用户的ID；
        id currentView =  self.paginatorView.currentPage;
        FSDetailBaseView *parentView = (FSDetailBaseView *)[currentView tbComment].superview.superview.superview;
        FSComment *item = (FSComment*)[[parentView.data comments] objectAtIndex:replyIndex];
        request.replyuserID = item.inUser.uid;
    }
    
    __block FSProDetailViewController *blockSelf = self;
    FSDetailBaseView *view = (FSDetailBaseView*)blockSelf.paginatorView.currentPage;
    [request upload:^(id data){
        [blockSelf updateProgress:NSLocalizedString(@"COMM_OPERATE_COMPL",nil)];
        //删除评论语音文件
        NSLock* tempLock = [[NSLock alloc]init];
        [tempLock lock];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_recordFileName])
        {
            [[NSFileManager defaultManager] removeItemAtPath:_recordFileName error:nil];
        }
        [tempLock unlock];
        
        replyIndex = -1;
        _recordFileName = @"";
        if (callback) {
            callback();
        }
        
        if (data) {
            //创建FSComment对象
            NSMutableArray *oldComments = [[(FSDetailBaseView *)blockSelf.paginatorView.currentPage data] comments];
            if (!oldComments)
                oldComments = [@[] mutableCopy];
            FSComment *_comment = [[FSComment alloc] init];
            _comment.id = [[data objectForKey:@"commentid"] intValue];
            if (isReplyToAll) {
                _comment.replyUserID = nil;
                _comment.replyUserName = nil;
            }
            else{
                _comment.replyUserName = [data objectForKey:@"replycustomer_nickname"];
                _comment.replyUserID = [[data objectForKey:@"replycustomer_id"] intValue];
            }
            FSUser *user = [[FSUser alloc] init];
            id customer = [data objectForKey:@"customer"];
            if (customer) {
                user.uid = [NSNumber numberWithInt:[[customer objectForKey:@"id"] intValue]];
                user.thumnail = [customer objectForKey:@"logo"];
                user.nickie = [customer objectForKey:@"nickname"];
                user.userLevelId = [[customer objectForKey:@"level"] intValue];
                _comment.inUser = user;
            }
            
            _comment.indate = [NSDate date];
            if (_isAudio) {
                _comment.comment = nil;
                id items = [data objectForKey:@"resources"];
                NSLog(@"items:%@", items);
                if ([items count] > 0) {
                    id resources = [items objectAtIndex:0];
                    NSLog(@"resources:%@", resources);
                    FSResource *_resource = [[FSResource alloc] init];
                    _resource.domain = [resources objectForKey:@"domain"];
                    _resource.relativePath = [resources objectForKey:@"name"];
                    _resource.width = [[resources objectForKey:@"width"] intValue];
                    _resource.type = [[resources objectForKey:@"type"] intValue];
                    _comment.resources = [[NSMutableArray alloc] initWithObjects:_resource, nil];
                }
            }
            else{
                _comment.comment = commentView.txtComment.text;//[self transformCommentText];
            }
            [oldComments insertObject:_comment atIndex:0];
        }
        
        [[(id)blockSelf.paginatorView.currentPage tbComment] reloadData];
        __block FSDetailBaseView * blockViewForRefresh = (FSDetailBaseView*)self.paginatorView.currentPage;
        CGRect _rect = [(id)blockViewForRefresh tbComment].frame;
        if ([self IsBindPromotionOrProduct:blockViewForRefresh.data]) {
            _rect.size.height = 160;
        }
        else{
            _rect.size.height = 120;
        }
        [[(id)blockViewForRefresh svContent] scrollRectToVisible:_rect animated:YES];
        
        //隐藏输入框
        [self clearComment:nil];
        
    } error:^(id error){
        [blockSelf updateProgress:error];//NSLocalizedString(@"upload failed!", nil)
        if (callback) {
            callback();
        }
    }];
    
    //统计
    NSString *_name;
    if (_sourceType == FSSourceProduct) {
        _name = [NSString stringWithFormat:@"商品-评论  %@", [view.data valueForKey:@"title"]];
    }
    else {
        _name = [NSString stringWithFormat:@"活动-评论  %@", [view.data valueForKey:@"title"]];
    }
    [[FSAnalysis instance] logEvent:_name withParameters:nil];
}

-(BOOL)IsBindPromotionOrProduct:(id)_item
{
    if (!_item) {
        return NO;
    }
    if ([_item isKindOfClass:[FSProdItemEntity class]]) {
        if (((FSProdItemEntity*)_item).promotions.count > 0) {
            return YES;
        }
    }
    else if([_item isKindOfClass:[FSProItemEntity class]]) {
        return [((FSProItemEntity*)_item).isProductBinded boolValue];
    }
    
    return NO;
}

-(BOOL)hasNextPage
{
    if (self.currentPageIndex == navContext.count - 1) {
        return NO;
    }
    return YES;
}

-(BOOL)hasPrePage
{
    if (self.currentPageIndex == 0) {
        return NO;
    }
    return YES;
}

#pragma mark - FSImageSlide datasource
-(int)numberOfImagesInSlides:(EGOPhotoViewController *)view
{
    return [[self itemSource] resource].count;
}
-(NSURL *)imageSlide:(EGOPhotoViewController *)view imageNameForIndex:(int)index
{
    return [(FSResource *)[[[self itemSource] resource] objectAtIndex:index] absoluteUrl320];
}
-(void)imageSlide:(EGOPhotoViewController *)view didShareTap:(BOOL)shared
{
    NSMutableArray *shareItems = [@[] mutableCopy];
    id curView = self.paginatorView.currentPage;
    NSString *title = [self.itemSource valueForKey:@"title"];
    [shareItems addObject:title?title:@""];
    if ([curView imgView].image != nil)
    {
        [shareItems addObject:[curView imgView].image];
    }
    
    [[FSShareView instance] shareBegin:view withShareItems:shareItems  completeHander:^(NSString *activityType, BOOL completed){
        if (completed)
        {
            [view reportError:NSLocalizedString(@"COMM_OPERATE_COMPL", nil)];
        }
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

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSDetailBaseView *parentView = (FSDetailBaseView *)tableView.superview.superview.superview;
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (_sourceType == FSSourceProduct) {
            if ([self IsBindPromotionOrProduct:parentView.data]) {
                //去活动详情
                FSProdItemEntity *_item = parentView.data;
                if (_item.promotions && _item.promotions.count > 0) {
                    FSProDetailViewController *detailView = [[FSProDetailViewController alloc] initWithNibName:@"FSProDetailViewController" bundle:nil];
                    detailView.navContext = _item.promotions;
                    NSLog(@"count:%d",_item.promotions.count);
                    detailView.sourceType = FSSourcePromotion;
                    detailView.indexInContext = 0;
                    detailView.dataProviderInContext = self;
                    UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:detailView];
                    [self presentViewController:navControl animated:true completion:nil];
                }
            }
        }
        else {
            if ([self IsBindPromotionOrProduct:parentView.data]) {
                //去商品列表
                FSProItemEntity *_item = parentView.data;
                FSProductListViewController *dr = [[FSProductListViewController alloc] initWithNibName:@"FSProductListViewController" bundle:nil];
                dr.titleName = NSLocalizedString(@"Product List", nil);
                dr.commonID = _item.id;
                dr.pageType = FSPageTypeCommon;
                [self.navigationController pushViewController:dr animated:TRUE];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewSource delegate

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    FSDetailBaseView *parentView = (FSDetailBaseView *)tableView.superview.superview.superview;
    if ([self IsBindPromotionOrProduct:parentView.data]) {
        if (section == 0) {
            return nil;
        }
    }
    FSProCommentHeader * view = [[[NSBundle mainBundle] loadNibNamed:@"FSProCommentHeader" owner:self options:nil] lastObject];
    view.count = [[parentView.data comments] count];
    return view;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [self resetScrollViewSize:(FSDetailBaseView*)tableView.superview.superview.superview];
    FSDetailBaseView *parentView = (FSDetailBaseView *)tableView.superview.superview.superview;
    if ([self IsBindPromotionOrProduct:parentView.data]) {
        return 2;
    }
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    FSDetailBaseView *parentView = (FSDetailBaseView *)tableView.superview.superview.superview;
    if (!parentView.data) {
        return 0;
    }
    int yOffset = PRO_DETAIL_COMMENT_HEADER_HEIGHT;
    if ([self IsBindPromotionOrProduct:parentView.data]) {
        if (section == 0) {
            return 1;
        }
        yOffset += 40;
    }
    NSMutableArray *comments = [parentView.data comments];
    if (!comments ||
        comments.count<=0)
        [self showNoResult:tableView withText:NSLocalizedString(@"no comments", Nil) originOffset:yOffset];
    else
        [self hideNoResult:tableView];
    return comments?comments.count:0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSDetailBaseView *parentView = (FSDetailBaseView *)tableView.superview.superview.superview;
    if ([self IsBindPromotionOrProduct:parentView.data]) {
        if (indexPath.section == 0) {
            UITableViewCell *_cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            if (_sourceType == FSSourceProduct) {
                _cell.textLabel.text = NSLocalizedString(@"Browse Promotion Detail", nil);
            }
            else {
                _cell.textLabel.text = NSLocalizedString(@"Browse Products List", nil);
            }
            _cell.textLabel.font = ME_FONT(14);
            _cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            _cell.selectionStyle = UITableViewCellSelectionStyleGray;
            UILabel *_line = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
            _line.backgroundColor = RGBCOLOR(213, 213, 213);
            [_cell addSubview:_line];
            return _cell;
        }
    }
    FSProCommentCell *detailCell =  [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    detailCell.selectionStyle = UITableViewCellSelectionStyleNone;
    [detailCell setData:[[parentView.data comments] objectAtIndex:indexPath.row]];
    detailCell.btnComment.tag = indexPath.row;
    [detailCell.btnComment addTarget:self action:@selector(replyComment:) forControlEvents:UIControlEventTouchUpInside];
    if (replyIndex != indexPath.row) {
        [detailCell.btnComment setImage:[UIImage imageNamed:@"comment_icon.png"] forState:UIControlStateNormal];
    }
    else{
        [detailCell.btnComment setImage:[UIImage imageNamed:@"comment_sel_icon.png"] forState:UIControlStateNormal];
    }
    if (!detailCell.audioButton.audioDelegate) {
        detailCell.audioButton.audioDelegate = self;
    }
    detailCell.imgThumb.delegate = self;
    [detailCell updateFrame];
   
    return detailCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSDetailBaseView *parentView = (FSDetailBaseView *)tableView.superview.superview.superview;
    if ([self IsBindPromotionOrProduct:parentView.data]) {
        if (indexPath.section == 0) {
            return 40;
        }
    }
    FSProCommentCell *cell = (FSProCommentCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.cellHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    FSDetailBaseView *parentView = (FSDetailBaseView *)tableView.superview.superview.superview;
    if ([self IsBindPromotionOrProduct:parentView.data]) {
        if (section == 0) {
            return 0;
        }
    }
    return PRO_DETAIL_COMMENT_HEADER_HEIGHT;
}

-(void)replyComment:(UIButton*)sender
{
    if(replyIndex == sender.tag) {
        replyIndex = -1;
        isReplyToAll = YES;
    }
    else{
        replyIndex = sender.tag;
        isReplyToAll = NO;
    }
    id currentView =  self.paginatorView.currentPage;
    [[currentView tbComment] reloadData];
    //[(UIScrollView *)[currentView tbComment].superview scrollRectToVisible:[currentView tbComment].frame animated:TRUE];
    [self displayCommentInputView:currentView];
}

#pragma mark - UITEXTFIELD DELEGATE
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([textView.superview.superview isKindOfClass:[FSProCommentInputView class]]) {
        if ([text isEqualToString:@""]) {
            return YES;
        }
        if (textView.text.length > 39) {
            return NO;
        }
    }
    return YES;
}

- (void)viewDidUnload {
    if (lastButton) {
        [lastButton stop];
    }
    theApp.audioRecoder.clAudioDelegate = nil;
    [self set_thumView:nil];
    [self setArrowLeft:nil];
    [self setArrowRight:nil];
    [super viewDidUnload];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (lastButton) {
        [lastButton stop];
    }
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
    return FSSourcePromotion;
}

-(BOOL)proDetailViewNeedRefreshFromContext:(FSProDetailViewController *)view forIndex:(NSInteger)index
{
    return TRUE;
}

#pragma mark record function

- (void)startToRecord
{
    if (!theApp.audioRecoder) {
        [theApp initAudioRecoder];
    }
    if (_isRecording == NO)
    {
        _isRecording = YES;
        _recordFileName = [NSString stringWithFormat:@"%f.m4a", [[NSDate date] timeIntervalSince1970]];
        theApp.audioRecoder.recorderingFileName = _recordFileName;
        [theApp.audioRecoder startRecord];
    }
}

- (void)endRecord
{
    NSLog(@"1:%@",[NSDate date]);
    _isRecording = NO;
    dispatch_queue_t stopQueue;
    stopQueue = dispatch_queue_create("stopQueue", NULL);
    dispatch_async(stopQueue, ^(void){
        //run in main thread
        NSLog(@"2:%@",[NSDate date]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [theApp.audioRecoder stopRecord];
        });
    });
    dispatch_release(stopQueue);
}

-(void)endRecordAndDelete
{
    _isRecording = NO;
    dispatch_queue_t stopQueue;
    stopQueue = dispatch_queue_create("stopQueue", NULL);
    dispatch_async(stopQueue, ^(void){
        //run in main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [theApp.audioRecoder stopAndDeleteRecord];
        });
    });
    dispatch_release(stopQueue);
}

#pragma mark button action

- (IBAction)recordTouchDown:(id)sender
{
    _downTime = [NSDate date];
    [sender setTitle:NSLocalizedString(@"Up To End Record", nil) forState:UIControlStateNormal];
    [self startToRecord];
    _recordState = PTRecording;
    if (lastButton) {
        [lastButton pause];
    }
    [_audioShowView showAudioView];
    [self startShowAnimation];
}

- (IBAction)recordTouchUpInside:(id)sender
{
    [self endTouch:sender];
}

- (IBAction)recordTouchUpOutside:(id)sender
{
    //删除录音
    [sender setTitle:NSLocalizedString(@"Down To Start Comment", nil) forState:UIControlStateNormal];
    _recordState = PTStartRecord;
    [self endRecordAndDelete];
    [self endShowAnimation];
}

- (IBAction)recordTouchDragEnter:(id)sender
{
    //显示语音动画按钮，隐藏回收按钮
    [_audioShowView showAudioView];
}

- (IBAction)recordTouchDragExit:(id)sender
{
    //显示回收按钮，隐藏语音动画按钮
    [_audioShowView showTrashView];
}

-(void)endTouch:(id)sender
{
    if(_recordState == PTRecording){
        NSInteger gap = [[NSDate date] timeIntervalSinceDate:_downTime];
        if (gap < _minRecordGap) {
            //显示提示时间太短对话框
            [self reportError:NSLocalizedString(@"Speak Too Short, Please Say Again", nil)];
            //重新设置为起始状态
            [sender setTitle:NSLocalizedString(@"Down To Start Comment", nil) forState:UIControlStateNormal];
            _recordState = PTStartRecord;
            [self endRecordAndDelete];
        }
        else{
            [sender setTitle:NSLocalizedString(@"Down To Start Comment", nil) forState:UIControlStateNormal];
            [self endRecord];
            id currentView =  self.paginatorView.currentPage;
            [[currentView tbComment] reloadData];
        }
    }
}

-(void)sendToService
{
    //直接发送
    [self saveComment:nil];
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

#pragma mark - Record Animation

-(void)startShowAnimation
{
    //开启音量检测
    theApp.audioRecoder.audioRecorder.meteringEnabled = YES;
    //设置定时检测
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                         target: self
                                       selector: @selector( levelTimerCallback:)
                                       userInfo: nil
                                        repeats: YES];
    }
    [_timer fire];
    _audioShowView.hidden = NO;
}

#define AudioLabel_Height 47

//音量检测
- (void)levelTimerCallback:(NSTimer *)timer
{
    //刷新音量数据
    [theApp.audioRecoder.audioRecorder updateMeters];
    //获取音量的平均值
    CGFloat averagePower = [theApp.audioRecoder.audioRecorder averagePowerForChannel:0];
    averagePower = abs(averagePower);
    if (averagePower > AudioLabel_Height) {
        averagePower = AudioLabel_Height;
    }
    averagePower = AudioLabel_Height - averagePower;
    if (averagePower < 5) {
        averagePower = 5;
    }
    
    //更改UI的图形效果
    [_audioShowView updateAudioLabelFrame:averagePower];
}

-(void)endShowAnimation
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _audioShowView.hidden = YES;
}

#pragma mark - FSCL_AudioDelegate

-(void)stopRecorderEnd:(CL_AudioRecorder *)_record
{
    [self endShowAnimation];
    [self sendToService];
}

-(void)stopAndDelRecorderEnd:(CL_AudioRecorder *)_record
{
    [self endShowAnimation];
}

-(void)errorRecorderDidOccur:(CL_AudioRecorder*)_record
{
    [self endShowAnimation];
}

@end
