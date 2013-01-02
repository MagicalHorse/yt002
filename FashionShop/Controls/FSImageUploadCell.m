//
//  FSImageUploadCell.m
//  FashionShop
//
//  Created by gong yi on 1/2/13.
//  Copyright (c) 2013 Fashion. All rights reserved.
//

#import "FSImageUploadCell.h"
#import "FSImageCollectionCell.h"
#define I_LIKE_COLUMNS 3;
#define ITEM_CELL_WIDTH 100;
@interface FSImageUploadCell()
{
    PSUICollectionView *imageView;
}

@end
@implementation FSImageUploadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self prepareLayout];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self prepareLayout];
    }
    return self;
}
-(void)prepareLayout
{
    SpringboardLayout *layout = [[SpringboardLayout alloc] init];
    layout.itemWidth = ITEM_CELL_WIDTH;
    layout.columnCount = I_LIKE_COLUMNS;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 0, 5);
    layout.delegate = self;

    imageView= [[PSUICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    imageView.backgroundColor = [UIColor whiteColor];
    [self addSubview:imageView];
    imageView.delegate = self;
    imageView.dataSource = self;
    imageView.scrollEnabled = FALSE;
       
    [imageView registerNib:[UINib nibWithNibName:@"FSImageCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"FSImageCollectionCell"];

}
-(void)refreshImages
{
    [imageView reloadData];
}
-(void)setImages:(NSMutableArray *)images
{
    _images = images;
    [self refreshImages];
}

#pragma mark - PSUICollectionView Datasource

- (NSInteger)collectionView:(PSUICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    return _images?_images.count:0;
    
}

- (NSInteger)numberOfSectionsInCollectionView: (PSUICollectionView *)collectionView {
    
    return 1;
}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    int index = indexPath.row * [self numberOfSectionsInCollectionView:cv]+indexPath.section;
    int totalCount = _images.count;
    if (index>=totalCount)
        return nil;
    UIImage *item = [_images objectAtIndex:index];
     FSImageCollectionCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"FSImageCollectionCell" forIndexPath:indexPath];
    cell.imageView.image = item;
    [cell.btnRemove addTarget:self action:@selector(doRemoveImage:) forControlEvents:UIControlEventTouchUpInside];
    cell.layer.borderWidth = 1;
    cell.layer.borderColor = [UIColor colorWithRed:151 green:151 blue:151].CGColor;
    
    return cell;
}
-(void)doRemoveImage:(UIButton *)sender
{
    FSImageCollectionCell *container = sender.superview.superview;
    NSIndexPath *indexPath = [imageView indexPathForCell:container ];
    if (indexPath)
    {
        [_images removeObjectAtIndex:indexPath.row];
        [imageView deleteItemsAtIndexPaths:@[indexPath]];
        if (_images.count<=0 &&
            _imageRemoveDelegate &&
            [_imageRemoveDelegate respondsToSelector:@selector(didImageRemoveAll)])
        {
            [_imageRemoveDelegate performSelector:@selector(didImageRemoveAll)];
        }
            
    }
    
}
#pragma mark - spring board layout delegate

- (BOOL) isDeletionModeActiveForCollectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout
{
    return NO;
}

- (CGFloat)collectionView:(PSUICollectionView *)collectionView
                   layout:(SpringboardLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage * data = [_images objectAtIndex:indexPath.row];
    
    int cellWidth = ITEM_CELL_WIDTH;
    return (cellWidth * data.size.height)/(data.size.width);
   
}

@end
