//
//  FSMeViewController.m
//  FashionShop
//
//  Created by gong yi on 11/8/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSMeViewController.h"
#import "FSLocalPersist.h"
#import "FSConfiguration.h"
#import "FSUserLoginRequest.h"
#import "FSUserProfileRequest.h"
#import "FSFavorRequest.h"
#import "FSUser.h"
#import "FSFavor.h"
#import "FSPagedFavor.h"
#import "FSBothItems.h"
#import "FSFavorProCell.h"
#import "FSCoupon.h"
#import "FSCouponViewController.h"
#import "FSPointViewController.h"
#import "FSLikeViewController.h"
#import "FSCommonUserRequest.h"
#import "FSThumnailRequest.h"
#import "FSProPostMainViewController.h"
#import "FSCommonProRequest.h"
#import "FSLoadMoreRefreshFooter.h"
#import "EGORefreshTableHeaderView.h"

#import "FSModelManager.h"
#import "FSLocationManager.h"
#import "UIImageView+WebCache.h"
#import "UIViewController+Loading.h"
#import "TCWBEngine.h"
#import "FSConfiguration.h"
#import <PassKit/PassKit.h>

#define LOGIN_FROM_3RDPARTY_ACTION @"LOGIN_FROM_3RDPARTY"
#define LOGIN_GET_USER_PROFILE @"LOGIN_GET_USERPROFILE"
#define LOGIN_GET_USER_LIKE @"LOGIN_GET_USERLIKEPRO"
#define I_LIKE_COLUMNS 3;
#define ITEM_CELL_WIDTH 100;
#define LOADINGVIEW_HEIGHT 44
#define REFRESHINGVIEW_HEIGHT 60

@interface FSMeViewController ()<EGORefreshTableHeaderDelegate>
{
    UIView *_loginView;
    UIView *_userProfileView;
    SinaWeibo *_weibo;
    TCWBEngine *_qq;
    NSMutableDictionary *_dataSourceProvider;
    bool _isLogined;
    
    FSUser *_userProfile;
    NSMutableArray *_likePros;
    bool _isFirstLoad;
    BOOL isDeletionModeActive;
    BOOL _isInLoading;
    BOOL _isInRefreshing;
    BOOL _isInPhotoing;
    int _favorPageIndex;
    BOOL _noMoreFavor;
    EGORefreshTableHeaderView *refreshHeaderView;
    UIActivityIndicatorView *moreIndicator;
    UIImagePickerController *_camera;
}

@end

@implementation FSMeViewController
@synthesize completeCallBack;
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
   
    _dataSourceProvider = [@{} mutableCopy];
    
    __block FSMeViewController *blockSelf = self;
    [_dataSourceProvider setValue:^(FSUserLoginRequest *request){
        [request send:[FSUser class] withRequest:request completeCallBack:^(FSEntityBase *response) {
            
            if (!response.isSuccess)
            {
                if (blockSelf->completeCallBack!=nil)
                {
                    blockSelf->completeCallBack(false);
                }
            }
            else
            {
                blockSelf->_userProfile = (FSUser *)response.responseData;
                [blockSelf->_userProfile save];
                
                if (blockSelf->completeCallBack!=nil)
                {
                    blockSelf->completeCallBack(true);
                }
                else
                {
                    [blockSelf displayUserProfile];
                }
            }
            
        }];
        
        
    } forKey:LOGIN_FROM_3RDPARTY_ACTION];
    
    [_dataSourceProvider setValue:^(FSUserProfileRequest *request){
        [request send:[FSUser class] withRequest:request completeCallBack:^(FSEntityBase *response) {
            if (!response.isSuccess)
            {
                [FSUser removeUserProfile];
                [blockSelf displayUserLogin];
                
                if (blockSelf->completeCallBack!=nil)
                {
                    blockSelf->completeCallBack(false);
                }
            }
            else
            {
                blockSelf->_userProfile = (FSUser *)response.responseData;
                
                [blockSelf->_userProfile save];
                [blockSelf displayUserProfile];
                
            }
            
        }];
        
        
    } forKey:LOGIN_GET_USER_PROFILE];
    
    [_dataSourceProvider setValue:^(FSFavorRequest *request,dispatch_block_t uicallback){
        [request send:[FSPagedFavor class] withRequest:request completeCallBack:^(FSEntityBase *response) {

            if (!response.isSuccess)
            {
                [FSUser removeUserProfile];
                [blockSelf displayUserLogin];
                
                if (blockSelf->completeCallBack!=nil)
                {
                    blockSelf->completeCallBack(false);
                }
            }
            else
            {
                FSPagedFavor *innerResp = response.responseData;
                if (innerResp.totalPageCount<=blockSelf->_favorPageIndex+1)
                    blockSelf->_noMoreFavor = TRUE;
                [blockSelf fillFavorList:innerResp.items isInsert:blockSelf->_isInRefreshing];
            }
            if (uicallback)
                uicallback();
          
            
        }];
        
        
    } forKey:LOGIN_GET_USER_LIKE];
    
    NSArray *views =[[NSBundle mainBundle] loadNibNamed:@"FSLoginView" owner:self options:nil];
    _loginView = [views objectAtIndex:0];
    
    views = [[NSBundle mainBundle] loadNibNamed:@"FSUserProfileView" owner:self options:nil];
   

    _userProfileView = [views objectAtIndex:0];
    _isFirstLoad = true;
    [self switchView];
       
}

-(void) switchView
{
    if (_isFirstLoad)
        _isFirstLoad = false;
     _isLogined = [FSModelManager sharedModelManager].isLogined;
    if(!_isLogined)
    {
        
        [self displayUserLogin];
    }
    else
    {
        _userProfile = [FSUser localProfile];
        if (_userProfile == nil)
        {
            FSUserProfileRequest *request = [[FSUserProfileRequest alloc] init];
            request.userToken = [FSModelManager sharedModelManager].loginToken;
            ((DataSourceProviderRequestBlock)[_dataSourceProvider objectForKey:LOGIN_GET_USER_PROFILE])(request);
            
        }
    }

}


-(void) displayUserLogin
{
    [self configThirdPatyEngine];
    [_loginView removeFromSuperview];
    [self.view addSubview:_loginView];
    if (self.presentingViewController)
    {
        UIBarButtonItem *baritemCancel = [self createPlainBarButtonItem:@"goback_icon" target:self action:@selector(onButtonCancel)];
        [self.navigationItem setLeftBarButtonItem:baritemCancel];
    }
    if (_userProfileView!=nil){
        [_userProfileView removeFromSuperview];
    }
    if (self.navigationItem)
    {
        [self.navigationItem setRightBarButtonItem:nil];
        self.navigationItem.title = NSLocalizedString(@"Login title", nil);
    }
    
}

- (void) configThirdPatyEngine{
    if (_weibo==nil)
    {
        _weibo =[[FSModelManager sharedModelManager] instantiateWeiboClient:self];
        
    }
    if (!_qq)
    {
        _qq = [[TCWBEngine alloc] initWithAppKey:WiressSDKDemoAppKey andSecret:WiressSDKDemoAppSecret andRedirectUrl:@"http://www.ying7wang7.com"];
        _qq.rootViewController = self;
        
    }
    
}


- (IBAction)doLogin:(id)sender {
    [_weibo logIn];
    
}

- (IBAction)doSuggest:(id)sender {
    UIActionSheet *suggestSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Publish product", nil),NSLocalizedString(@"Publish promotion", nil),nil];
    suggestSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [suggestSheet showInView:_btnSuggest];
   
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            FSProPostMainViewController *uploadController = [[FSProPostMainViewController alloc] initWithNibName:@"FSProPostMainViewController" bundle:nil];
            uploadController.currentUser = _userProfile;
            [uploadController setAvailableFields:ImageField|TitleField|BrandField|TagField|StoreField];
            [uploadController setRoute:RK_REQUEST_PROD_UPLOAD];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:uploadController];
            [self presentViewController:navController animated:TRUE completion:nil];
            break;
        }
        case 1:
        {
            FSProPostMainViewController *uploadController = [[FSProPostMainViewController alloc] initWithNibName:@"FSProPostMainViewController" bundle:nil];
            uploadController.currentUser = _userProfile;
            [uploadController setAvailableFields:ImageField|TitleField|DurationField|StoreField];
            [uploadController setRoute:RK_REQUEST_PRO_UPLOAD];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:uploadController];
            [self presentViewController:navController animated:TRUE completion:nil];
            break;
        }
        default:
            break;
    }
}

- (IBAction)doLoginQQ:(id)sender {
    [_qq logInWithDelegate:self onSuccess:@selector(onQQLoginSuccess) onFailure:@selector(onQQLoginFail:)];
}

- (void)removeAuthData
{
    [[FSModelManager sharedModelManager] removeWeiboAuthCache];
}

- (void) displayUserProfile{
    
    UIBarButtonItem *baritemSet= [self createPlainBarButtonItem:@"set_icon.png" target:self action:@selector(onSetting)];
    [self.navigationItem setRightBarButtonItem:baritemSet];
    [_userProfileView removeFromSuperview];
    [self.view addSubview:_userProfileView];
    [self bindUserProfile];
    if (_loginView!=nil)
    {
        [_loginView removeFromSuperview];
    }
    
}

-(void) bindUserProfile
{
    self.navigationItem.title = NSLocalizedString(@"Homepage title", nil);
    _lblNickie.text = _userProfile.nickie;
    _lblNickie.font = ME_FONT(18);
    [_lblNickie sizeToFit];
    CGRect origFrame = _imgLevel.frame;
    origFrame.origin.x = _lblNickie.frame.origin.x+_lblNickie.frame.size.width+4;
    _imgLevel.frame = origFrame;
    _thumbImg.ownerUser = _userProfile;
    _thumbImg.showCamera = true;
    _thumbImg.delegate = self;
  
    _btnLike.titleLabel.font = ME_FONT(9);
    _btnLike.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_btnLike setTitle:[NSString stringWithFormat:@"%d",_userProfile.likeTotal] forState:UIControlStateNormal];
    
    _btnFans.titleLabel.font = ME_FONT(9);
    _btnFans.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_btnFans setTitle:[NSString stringWithFormat:@"%d",_userProfile.fansTotal] forState:UIControlStateNormal];
    _btnPoints.titleLabel.font = ME_FONT(9);
    _btnPoints.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_btnPoints setTitle:[NSString stringWithFormat:@"%d",_userProfile.pointsTotal] forState:UIControlStateNormal];
    _btnCoupons.titleLabel.font = ME_FONT(9);
    _btnCoupons.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_btnCoupons setTitle:[NSString stringWithFormat:@"%d",_userProfile.couponsTotal] forState:UIControlStateNormal];
    
    _vLikeHeader.backgroundColor = [UIColor colorWithRed:229 green:229 blue:229];
    _lblLikeHeader.font = ME_FONT(12);
    
    SpringboardLayout *layout = [[SpringboardLayout alloc] init];
    layout.itemWidth = ITEM_CELL_WIDTH;
    layout.columnCount = I_LIKE_COLUMNS;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 0, 5);
    layout.delegate = self;
    _likeView = [[PSUICollectionView alloc] initWithFrame:_likeContainer.bounds collectionViewLayout:layout];
    _likeView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _likeView.backgroundColor = [UIColor whiteColor];
    [_likeContainer addSubview:_likeView];
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f,  -REFRESHINGVIEW_HEIGHT, _likeView.frame.size.width,REFRESHINGVIEW_HEIGHT)];
    refreshHeaderView.backgroundColor = [UIColor whiteColor];
    [_likeView addSubview:refreshHeaderView];
    refreshHeaderView.delegate = self;

    [_likeView registerNib:[UINib nibWithNibName:@"FSFavorProCell" bundle:nil] forCellWithReuseIdentifier:@"FSFavorProCell"];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(activateDeletionMode:)];
    longPress.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endDeletionMode:)];
    tap.delegate = self;
    [_likeView addGestureRecognizer:longPress];
    [_likeView addGestureRecognizer:tap];
  
    _likeView.delegate = self;
    _likeView.dataSource = self;

    
    [self loadILike];

}

-(void) loadILike
{
    _favorPageIndex = 1;
    [self loadILike:true nextPage:_favorPageIndex  withCallback:nil];
}
-(void) loadILike:(BOOL)showProgress nextPage:(int)pageIndex withCallback:(dispatch_block_t)callback
{
    if (showProgress)
        [self beginLoading:_likeView];
    FSFavorRequest *request = [self createRequest:pageIndex];
    ((DataSourceProviderRequest2Block)[_dataSourceProvider objectForKey:LOGIN_GET_USER_LIKE])(request,^{
        if (showProgress)
            [self endLoading:_likeView];
        if (callback)
            callback();
    });
 
}

-(FSFavorRequest *)createRequest:(int)page
{
    FSFavorRequest *request = [[FSFavorRequest alloc] init];
    request.userToken = _userProfile.uToken;
    request.productType = FSSourceAll;
    request.routeResourcePath = RK_REQUEST_FAVOR_LIST;
    request.longit =[NSNumber numberWithFloat:[FSLocationManager sharedLocationManager].currentCoord.longitude];
    request.lantit =[NSNumber numberWithFloat:[FSLocationManager sharedLocationManager].currentCoord.latitude];
    request.pageSize = [NSNumber numberWithInt:20] ;
    request.nextPage =[NSNumber numberWithInt:page];
    return request;
}

-(void)loadMore
{
    if (!moreIndicator)
        moreIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    moreIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.bounds.size.height-44);
    [moreIndicator startAnimating];
    [self.view addSubview:moreIndicator];
    [self loadILike:FALSE nextPage:++_favorPageIndex withCallback:^{
        [moreIndicator removeFromSuperview];
        _isInLoading = FALSE;
        
    }];
    
}
-(void)doChangeSetting:(UITapGestureRecognizer *)gesture
{

       _camera = [[UIImagePickerController alloc] init];
        _camera.delegate = self;

        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            _camera.sourceType = UIImagePickerControllerSourceTypeCamera;
            _camera.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            _camera.allowsEditing = false;
            _isInPhotoing = true;
            [self decorateOverlayToCamera:_camera];
            [self presentViewController:_camera animated:YES completion:nil];
            
        }
    
    
}

-(void)fillFavorList:(NSArray *)list isInsert:(BOOL)isInsert
{
    if (!_likePros)
    {
        _likePros = [@[] mutableCopy];
    }
    if (list)
    {
        [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            int index = [_likePros indexOfObjectPassingTest:^BOOL(id obj1, NSUInteger idx1, BOOL *stop1) {
                if ([[(FSFavor *)obj1 valueForKey:@"id"] isEqualToValue:[(FSFavor *)obj valueForKey:@"id"]])
                {
                    return TRUE;
                    *stop1 = TRUE;
                }
                return FALSE;
            }];
            if (index== NSNotFound)
            {
                if (isInsert)
                    [_likePros insertObject:obj atIndex:0];
                else
                    [_likePros addObject:obj];
                
            }
        }];
        [_likeView reloadData];
        if (_likePros.count<1)
        {
            [self showNoResult:_likeView withText:NSLocalizedString(@"no likes added", nil)];
        }
        
    }
}

-(void)filterAccount:(int)index
{
    switch (index) {
        case 0:
        {
            FSLikeViewController *likeView = [[FSLikeViewController alloc] initWithNibName:@"FSLikeViewController" bundle:nil];
            likeView.likeType = 0;
            likeView.navigationItem.title = NSLocalizedString(@"Me likes persons", nil);
            [self.navigationController pushViewController:likeView animated:TRUE];
            break;
        }
        case 1:
        {
            FSLikeViewController *likeView = [[FSLikeViewController alloc] initWithNibName:@"FSLikeViewController" bundle:nil];
            likeView.likeType = 1;
            likeView.navigationItem.title = NSLocalizedString(@"Me fans", nil);
            [self.navigationController pushViewController:likeView animated:TRUE];
            break;
        }
        case 2:
        {
            //just goto passbook here, we can embed the custom url schema in pass, so user can return back.
            /*
            if ([PKPass class])
            {
            NSString *passUrl = @"shoebox://card";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:passUrl]];
            }
            else
             */
            {
            
            FSCouponViewController *couponView = [[FSCouponViewController alloc] initWithNibName:@"FSCouponViewController" bundle:nil];
            couponView.currentUser = _userProfile;
            [self.navigationController pushViewController:couponView animated:true];
             
            }
            break;
        }
        case 3:
        {
            FSPointViewController *pointView = [[FSPointViewController alloc] initWithNibName:@"FSPointViewController" bundle:nil];
            pointView.currentUser = _userProfile;
            [self.navigationController pushViewController:pointView animated:TRUE];
            break;
        }
        
        default:
            break;
    } 

}

-(void) bindContentView
{
    [_likeView reloadData];
}

-(void)onButtonCancel
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

-(void)onSetting
{
    FSSettingViewController *controller = [[FSSettingViewController alloc] initWithNibName:@"FSSettingViewController" bundle:nil];
    controller.currentUser = _userProfile;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:true];
}

-(void)uploadThumnail:(UIImage *)image
{
    [self startProgress:NSLocalizedString(@"upload thumnail now", nil) withExeBlock:^(dispatch_block_t callback){
        [self internalUploadThumnail:image CallBack:callback];
    } completeCallbck:^{
        [self endProgress];

    }];

}

-(void)internalUploadThumnail:(UIImage *)image CallBack:(dispatch_block_t)callback
{
     FSThumnailRequest *request = [[FSThumnailRequest alloc] init];
    request.uToken = _userProfile.uToken;
    request.image = image;
    request.routeResourcePath = RK_REQUEST_THUMNAIL_UPLOAD;
    [request upload:^(id result){
        callback();
        _userProfile.thumnail = result;
        [_thumbImg reloadThumb:_userProfile.thumnailUrl];
        
    } error:^(id error){
        callback();
        [self updateProgress:error];
    }];
}
#pragma UIImagePicker delegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	
	if([mediaType isEqualToString:@"public.image"])
	{
		UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        [NSThread detachNewThreadSelector:@selector(cropImage:) toTarget:self withObject:image];
    }
	else
	{
		NSLog(@"Error media type");
		return;
	}
}
- (void)cropImage:(UIImage *)image {
    // Create a graphics image context
    CGSize newSize = CGSizeMake(50, 50);
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    [self uploadThumnail:newImage];
    
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(UIImagePickerController *)inUserCamera
{
    return _camera;
}
#pragma mark - PSUICollectionView Datasource

- (NSInteger)collectionView:(PSUICollectionView *)view numberOfItemsInSection:(NSInteger)section {

    return _likePros?_likePros.count:0;
    
}

- (NSInteger)numberOfSectionsInCollectionView: (PSUICollectionView *)collectionView {
    
    return 1;
}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    int index = indexPath.row * [self numberOfSectionsInCollectionView:cv]+indexPath.section;
    int totalCount = _likePros.count;
    if (index>=totalCount)
        return nil;
    PSUICollectionViewCell *cell = nil;
    FSFavor *item = [_likePros objectAtIndex:index];
        cell = [cv dequeueReusableCellWithReuseIdentifier:@"FSFavorProCell" forIndexPath:indexPath];
        [[(FSFavorProCell *)cell deleteButton] addTarget:self action:@selector(didRemoveClick:) forControlEvents:UIControlEventTouchUpInside];
        ((FSFavorProCell *)cell).data = item;;
    cell.layer.borderWidth = 1;
    cell.layer.borderColor = [UIColor colorWithRed:151 green:151 blue:151].CGColor;
        if (_likeView.dragging == NO && _likeView.decelerating == NO)
        {
            int width = ITEM_CELL_WIDTH;
            int height = cell.frame.size.height - 40;
            [(id<ImageContainerDownloadDelegate>)cell imageContainerStartDownload:cell withObject:indexPath andCropSize:CGSizeMake(width, height) ];
        }
        

    
    return cell;
}


#pragma mark - PSUICollectionViewDelegate
- (void)collectionView:(PSUICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (isDeletionModeActive)
    {
        [self endDeletionMode:nil];
        return;
    }
    FSProDetailViewController *detailView = [[FSProDetailViewController alloc] initWithNibName:@"FSProDetailViewController" bundle:nil];
    detailView.navContext = _likePros;
    detailView.indexInContext = indexPath.row* [self numberOfSectionsInCollectionView:collectionView] + indexPath.section;
    detailView.sourceType = [(FSFavor *)[_likePros objectAtIndex:detailView.indexInContext] sourceType];
    detailView.dataProviderInContext = self;
    UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:detailView];
    [self presentViewController:navControl animated:true completion:nil];
}

-(void)collectionView:(PSUICollectionView *)collectionView didEndDisplayingCell:(PSUICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSFavorProCell *hideCell = (FSFavorProCell *)cell;
    [hideCell willRemoveFromView];
}



-(void)didRemoveClick:(UIButton *)sender
{
    FSFavorProCell * cell = (FSFavorProCell *)sender.superview.superview;
    if (cell)
    {
        FSFavorRequest *removeRequest = [[FSFavorRequest alloc] init];
        removeRequest.userToken = _userProfile.uToken;
        removeRequest.id = [NSNumber numberWithInt:[(FSFavorProCell *)cell data].id];
        removeRequest.routeResourcePath = RK_REQUEST_FAVOR_REMOVE;
        [self beginLoading:cell];
        [removeRequest send:[FSModelBase class] withRequest:removeRequest completeCallBack:^(FSEntityBase * resp){
            [self endLoading:cell];
            if (!resp.isSuccess)
            {
                [self reportError:NSLocalizedString(@"COMM_OPERATE_FAILED", nil)];
            }
            else
            {
                [_likePros removeObject:[(FSFavorProCell *)cell data]];
                [_likeView deleteItemsAtIndexPaths:@[[_likeView indexPathForCell:cell]]];
                
            }
        }];
    }
}

- (void)loadImagesForOnscreenRows
{
    if ([_likePros count] > 0)
    {
        NSArray *visiblePaths = [_likeView indexPathsForVisibleItems];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            id<ImageContainerDownloadDelegate> cell = (id<ImageContainerDownloadDelegate>)[_likeView cellForItemAtIndexPath:indexPath];
            int width = ITEM_CELL_WIDTH;
            int height = [(PSUICollectionViewCell *)cell frame].size.height - 40;
            [cell imageContainerStartDownload:cell withObject:indexPath andCropSize:CGSizeMake(width, height) ];
            
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
      
    [refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
	[refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    [self loadImagesForOnscreenRows];
  
    if (!_noMoreFavor &&
        !_isInLoading &&
        (scrollView.contentOffset.y+scrollView.frame.size.height) > scrollView.contentSize.height
        && scrollView.contentSize.height>scrollView.frame.size.height
        &&scrollView.contentOffset.y>0)
    {
        _isInLoading = true;
        [self loadMore];
    }
     
	
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    if (!_isInLoading &&!_isInRefreshing)
    {
        _isInLoading = TRUE;
        _isInRefreshing = TRUE;
        [self loadILike:FALSE nextPage:1 withCallback:^{
            _isInLoading = FALSE;
            _isInRefreshing = FALSE;
            [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_likeView];
        }];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _isInLoading; 
}



#pragma mark - gesture-recognition action methods


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    CGPoint touchPoint = [touch locationInView:_likeView];
    NSIndexPath *indexPath = [_likeView indexPathForItemAtPoint:touchPoint];
    if (indexPath && ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class] ]))
    {
        return NO;
    }
     
    return YES;
}


- (void)activateDeletionMode:(UILongPressGestureRecognizer *)gr
{
    if (gr.state == UIGestureRecognizerStateBegan)
    {
        NSIndexPath *indexPath = [_likeView indexPathForItemAtPoint:[gr locationInView:_likeView]];
        if (indexPath)
        {
            isDeletionModeActive = YES;
            if ([NSLayoutConstraint class]) //use this trick to check ios6+
            {
                //[_likeView reloadData];
                SpringboardLayout *layout = (SpringboardLayout *)_likeView.collectionViewLayout;
                [layout invalidateLayout];
            } else
            {
                [_likeView reloadData];
            }
        }
    }
}

- (void)endDeletionMode:(UITapGestureRecognizer *)gr
{
    if (isDeletionModeActive)
    {
        NSIndexPath *indexPath = [_likeView indexPathForItemAtPoint:[gr locationInView:_likeView]];
        if (!indexPath)
        {
            isDeletionModeActive = NO;
            if ([NSLayoutConstraint class]) //use this trick to check ios6+
            {
                
                SpringboardLayout *layout = (SpringboardLayout *)_likeView.collectionViewLayout;
                [layout invalidateLayout];
            } else
            {
                [_likeView reloadData];
            }
        }
    }
    
}

#pragma mark - spring board layout delegate

- (BOOL) isDeletionModeActiveForCollectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout
{
    return isDeletionModeActive;
}

- (CGFloat)collectionView:(PSUICollectionView *)collectionView
                   layout:(SpringboardLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FSFavor * data = [_likePros objectAtIndex:indexPath.row];
    FSResource * resource = data.resources&&data.resources.count>0?[data.resources objectAtIndex:0]:nil;
    float totalHeight = 40.0f;
    if (resource)
    {
        int cellWidth = ITEM_CELL_WIDTH;
        float imgHeight = (cellWidth * resource.height)/(resource.width);
        totalHeight = totalHeight+imgHeight;
    }
    return totalHeight;
}


#pragma FSProDetailItemSourceProvider
-(void)proDetailViewDataFromContext:(FSProDetailViewController *)view forIndex:(NSInteger)index completeCallback:(UICallBackWith1Param)block errorCallback:(dispatch_block_t)errorBlock

{
    __block FSFavor * favorCurrent = [view.navContext objectAtIndex:index];
    FSCommonProRequest *request = [[FSCommonProRequest alloc] init];
    request.routeResourcePath = RK_REQUEST_PRO_DETAIL;
    request.id = [NSNumber numberWithInt:favorCurrent.sourceId];
    request.longit =[NSNumber numberWithFloat:[FSLocationManager sharedLocationManager].currentCoord.longitude];
    request.lantit = [NSNumber numberWithFloat:[FSLocationManager sharedLocationManager].currentCoord.latitude];
    request.uToken = [FSModelManager sharedModelManager].loginToken;
    Class respClass;
    
    if (favorCurrent.sourceType == FSSourceProduct)
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
    FSFavor * favorCurrent = [view.navContext objectAtIndex:index];
    return favorCurrent.sourceType;
}

#pragma FSThumbView Delegate
-(void)didTapThumView:(id)sender
{
    [self doChangeSetting:nil];
}

#pragma mark - QQ weibo delegate

-(void) onQQLoginSuccess
{
    [_qq getUserInfoWithFormat:@"json" parReserved:nil delegate:self onSuccess:@selector(onQQUserInfoGet:) onFailure:@selector(onQQUserInfoFail:)];
    
}

-(void) onQQLoginFail:(NSError *)error
{
   // [self reportError:error.description];
}


- (void)onQQUserInfoGet:(id)result{
    
    NSDictionary *homeDic = (NSDictionary *)result;
    FSUserLoginRequest *request = [[FSUserLoginRequest alloc] init];
    request.accessToken = _qq.accessToken;
    request.thirdPartySourceType = @2;
    request.thirdPartyUid = [homeDic valueForKeyPath:@"data.openid"];
    request.nickie = [homeDic valueForKeyPath:@"data.nick"];
    ((DataSourceProviderRequestBlock)[_dataSourceProvider objectForKey:LOGIN_FROM_3RDPARTY_ACTION])(request);

}

- (void)onQQUserInfoFail:(NSError *)error{
   [self reportError:error.description];
}



#pragma mark - SinaWeibo Delegate

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogIn userID = %@ accesstoken = %@ expirationDate = %@ refresh_token = %@", sinaweibo.userID, sinaweibo.accessToken, sinaweibo.expirationDate,sinaweibo.refreshToken);
    _weibo = sinaweibo;
    [[FSModelManager sharedModelManager] storeWeiboAuth:sinaweibo];
    
    [sinaweibo requestWithURL:@"users/show.json"
                       params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
                   httpMethod:@"GET"
                     delegate:self];
    
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogOut");
    [self removeAuthData];
    
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboLogInDidCancel");
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"sinaweibo logInDidFailWithError %@", error);
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    NSLog(@"sinaweiboAccessTokenInvalidOrExpired %@", error);
    [self removeAuthData];
}




#pragma mark - SinaWeiboRequest Delegate

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        _userProfile = nil;
    }
    
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        
        //step2: create account in app by weibo user profile
        NSMutableDictionary * weiboUserProfile = [result mutableCopy];
        //step3: use the account info from new created account
        
        FSUserLoginRequest *request = [[FSUserLoginRequest alloc] init];
        request.nickie = [weiboUserProfile objectForKey:@"screen_name"];
        request.accessToken = _weibo.accessToken;
        request.thirdPartySourceType = @1;
        request.thirdPartyUid = _weibo.userID;
        ((DataSourceProviderRequestBlock)[_dataSourceProvider objectForKey:LOGIN_FROM_3RDPARTY_ACTION])(request);
        
    }
    
}

#pragma FSSettingViewCompleteDelegate

-(void)settingView:(FSSettingViewController *)view didLogOut:(BOOL)flag
{
    if (flag)
    {
        [self displayUserLogin];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}




- (IBAction)doShowLikes:(id)sender {
    [self filterAccount:0];
}

- (IBAction)doShowFans:(id)sender {
    [self filterAccount:1];
}

- (IBAction)doShowPoints:(id)sender {
    [self filterAccount:3];
}

- (IBAction)doShowCoupons:(id)sender {
    [self filterAccount:2];
}
- (void)viewDidUnload {
    [self setLikeView:nil];
    [self setLikeContainer:nil];
    [self setThumbImg:nil];
    [self setImgLevel:nil];
    [super viewDidUnload];
}
@end
