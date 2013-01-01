//
//  FSSuggestViewController.m
//  FashionShop
//
//  Created by gong yi on 11/14/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSSuggestViewController.h"
#import "Product.h"
#import "FSSuggestCell.h"
#import "FSSuggestProductCell.h"
#import "FSDataController.h"
#import "RestKit.h"
#import "FSSuggestEntity.h"
#import "CommonResponseHeader.h"
#import "FSSuggestListRequest.h"

#define SELECTED_VIEW_NEWEST @"newest"
#define SELECTED_VIEW_HOTEST @"hotest"
#define SELECTED_VIEW_BRAND @"brand"
typedef void(^DataSourceProviderBlock)(int nextPage,int pageSize);


@interface FSSuggestViewController ()
{
    NSMutableDictionary *_dataSource;
    NSMutableDictionary *_dataSourceType;
    NSMutableDictionary *_dataSourceProvider;
    NSString *_currentSelectSearch;
    RKObjectManager *_modelManager;
}
@end

@implementation FSSuggestViewController

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
	// Do any additional setup after loading the view.
    _modelManager = [RKObjectManager sharedManager];
    [[self navigationController] setNavigationBarHidden:true];
    [[self contentView] registerNib:[UINib nibWithNibName:@"FSSuggestCell" bundle:nil] forCellWithReuseIdentifier:@"suggestPromotionCell"];
   [[self contentView] registerNib:[UINib nibWithNibName:@"FSSuggestProductCell" bundle:nil] forCellWithReuseIdentifier:@"suggestProductCell"];
    [self initDataSource];
    [self currentSelectedSearchIndex:SELECTED_VIEW_NEWEST];
}

-(void) initDataSource{
    _dataSource = [@{} mutableCopy];
    _dataSourceType = [@{} mutableCopy];;
    _dataSourceProvider = [@{} mutableCopy];;
    [_dataSourceType setValue:[NSMutableDictionary class] forKey:SELECTED_VIEW_NEWEST];
    [_dataSourceType setValue:[NSMutableDictionary class] forKey:SELECTED_VIEW_HOTEST];
    [_dataSourceType setValue:[NSMutableDictionary class] forKey:SELECTED_VIEW_BRAND];
    __block RKObjectManager *blockModelManager = _modelManager;
    __block FSSuggestViewController *blockSelf = self;
    [_dataSourceProvider setValue:^(int nextPage,int pageSize){
        //step1:load product list more page
        //[[FSDataController shareController] productListPageNext:nextPage listType:Suggested];
        //step1:set response map
        RKObjectMapping *sugestlistMap = [RKObjectMapping mappingForClass:[FSSuggestEntity class]];
        [FSSuggestEntity setMappingAttribute:sugestlistMap];
        [blockModelManager.mappingProvider setMapping:sugestlistMap forKeyPath:@""];
        //step2:set request map
        RKObjectMapping *requestMapping = [RKObjectMapping mappingForClass:[FSSuggestListRequest class]];
        [FSSuggestEntity setMappingListRequestAttribute:requestMapping];
        [blockModelManager.mappingProvider setSerializationMapping:[requestMapping inverseMapping] forClass:[FSSuggestEntity class]];
        //step3:set common query string
        NSString *url = nil;//[request appendCommonRequestQueryPara:blockModelManager];
        
        
        } forKey:SELECTED_VIEW_NEWEST];
    [_dataSourceProvider setValue:^(int nextPage,int pageSize){} forKey:SELECTED_VIEW_HOTEST];
    [_dataSourceProvider setValue:^(int nextPage,int pageSize){} forKey:SELECTED_VIEW_BRAND];

    
}
- (void) currentSelectedSearchIndex:(NSString *)searchTag{
    _currentSelectSearch = searchTag;
    if ([searchTag isEqualToString:SELECTED_VIEW_NEWEST]){
        
    
    }
    [self loadDataSourceIfNeed];

}

- (void) loadDataSourceIfNeed{
    id dataInMemory = [_dataSource objectForKey:_currentSelectSearch];
    if (dataInMemory == nil){
        DataSourceProviderBlock block = [_dataSourceProvider objectForKey:_currentSelectSearch];
        block(0,20);
    }
    
}


#pragma mark RKObjectLoaderDelegate methods

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    NSLog(@"Loaded payload: %@", [response bodyAsString]);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    NSLog(@"Loaded statuses: %@", objects);
    if ([_currentSelectSearch isEqualToString:SELECTED_VIEW_NEWEST]){
    FSSuggestEntity *resp = [objects objectAtIndex:0];
    //step2:insert into datasource instance
    NSMutableArray * currentSource = [_dataSource objectForKey:SELECTED_VIEW_NEWEST];
    if (currentSource== nil){
        currentSource = [@[] mutableCopy];
    }
    [currentSource addObjectsFromArray:resp.products];
    [currentSource addObjectsFromArray:resp.promotions];
    [_dataSource setValue:currentSource forKey:SELECTED_VIEW_NEWEST];
    //step3:reload collectionview
    [_contentView reloadData];
    
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    UIAlertView *alert = nil;//[[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]];
    [alert show];
    NSLog(@"Hit error: %@", error);
}


#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSMutableArray *currentSource = [_dataSource objectForKey:_currentSelectSearch];
    int rowCount = (int)((currentSource.count)/[self numberOfSectionsInCollectionView:view]);
    int modIndex = currentSource.count % [self numberOfSectionsInCollectionView:view];
    if (modIndex>0 && section>=modIndex)
    {
        rowCount-=1;
    }
    rowCount = rowCount<0?0:rowCount;
    return rowCount;

}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 2;
}
// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    int index = indexPath.row * [self numberOfSectionsInCollectionView:cv]+indexPath.section;
    NSMutableArray *currentSource = [_dataSource objectForKey:_currentSelectSearch];

    id cellData = [[_dataSource objectForKey:_currentSelectSearch] objectAtIndex:index];
    UICollectionViewCell *cell = nil;
    if (cellData == nil){
        return cell;
    }
    if ([[cellData class] isSubclassOfClass:[Product class]]) {
        cell = [cv dequeueReusableCellWithReuseIdentifier:@"suggestProductCell" forIndexPath:indexPath];
        ((FSSuggestProductCell *)cell).data = cellData;
    } else {
        cell = [cv dequeueReusableCellWithReuseIdentifier:@"suggestPromotionCell" forIndexPath:indexPath];
        ((FSSuggestCell *)cell).data = cellData;
    }

    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark – UICollectionViewDelegateFlowLayout

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize retva ;
    retva.width = self.view.frame.size.width/[self numberOfSectionsInCollectionView:collectionView]-20;
    retva.height = retva.width;
    return retva;
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2, 2, 2, 2);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)searchNewest:(id)sender {
}
- (IBAction)searchHotest:(id)sender {
}
- (IBAction)searchByBrand:(id)sender {
}
@end
