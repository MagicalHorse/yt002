//
//  FSStoreDetailViewController.m
//  FashionShop
//
//  Created by gong yi on 1/4/13.
//  Copyright (c) 2013 Fashion. All rights reserved.
//

#import "FSStoreDetailViewController.h"
#import <MapKit/MapKit.h>
#import "FSLocationManager.h"
#import "UIImageView+WebCache.h"
#import "FSStoreMapViewController.h"
#import "PositionAnnotation.h"

#define kMKCoordinateSpan 0.005

@interface FSStoreDetailViewController ()
{
    MKMapView *_mapView;
    UIImageView *_picImage;
}

@end

@implementation FSStoreDetailViewController

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
    
    UIBarButtonItem *baritemCancel = [self createPlainBarButtonItem:@"goback_icon.png" target:self action:@selector(onButtonBack:)];
    [self.navigationItem setLeftBarButtonItem:baritemCancel];
    self.title = _store.name;
    
    if (!_picImage) {
        _picImage = [[UIImageView alloc] init];
        _picImage.frame = CGRectMake(10, 10, 300, 200);
        _picImage.clipsToBounds = YES;
    }
    _picImage.contentMode = UIViewContentModeScaleAspectFill;
    _picImage.image = [UIImage imageNamed:@"default_icon320.png"];
    
    [self viewToImage];
}

//截图
- (void)viewToImage
{
    CLLocationCoordinate2D center;
    center.latitude = [_store.lantit floatValue];
    center.longitude = [_store.longit floatValue];
    
    _mapView= [[MKMapView alloc] initWithFrame:CGRectMake(0, 1000, 300, 200)];
    [self.view addSubview:_mapView];
    MKCoordinateSpan span = {kMKCoordinateSpan, kMKCoordinateSpan};
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [_mapView setRegion:region animated:NO];
    
    PositionAnnotation *annotation = [[PositionAnnotation alloc] initWithCoordinate:center title:nil subTitle:nil];
    [_mapView addAnnotation:annotation];
    
    [self performSelector:@selector(createImage:) withObject:_mapView afterDelay:3];
}

-(void)createImage:(UIView*)view
{
    if(UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(296, 196), NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(CGSizeMake(296, 196));
    }
    
    //获取图像
    [_mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (!_picImage) {
        _picImage = [[UIImageView alloc] init];
        _picImage.frame = CGRectMake(10, 10, 300, 200);
    }
    _picImage.image = image;
    
    [_mapView removeFromSuperview];
    [_tbAction reloadData];
}

- (IBAction)onButtonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickToDial:(id)sender
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", _store.phone]];
	[[UIApplication sharedApplication] openURL:url];
}

- (void)viewDidUnload {
    [self setTbAction:nil];
    [super viewDidUnload];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case CellTitle:
        {
            int height =[_store.name sizeWithFont:ME_FONT(16) constrainedToSize:CGSizeMake(310, 1000) lineBreakMode:NSLineBreakByCharWrapping].height + 26;
            return height;
        }
            break;
        case CellPicture:
        {
            return 220;
        }
            break;
        case CellAddress:
        {
            int height =[_store.address sizeWithFont:ME_FONT(14) constrainedToSize:CGSizeMake(310, 1000) lineBreakMode:NSLineBreakByCharWrapping].height + 26;
            return height;
        }
            break;
        case CellDesc:
        {
            int height =[_store.descrip sizeWithFont:ME_FONT(13) constrainedToSize:CGSizeMake(310, 1000) lineBreakMode:NSLineBreakByCharWrapping].height + 26;
            return height;
        }
            break;
        default:
            break;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case CellPicture:
        case CellAddress:
        {
            FSStoreMapViewController *controller = [[FSStoreMapViewController alloc] initWithNibName:@"FSStoreMapViewController" bundle:nil];
            controller.store = _store;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case CellPhone:
        {
            [self clickToDial:nil];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIFont *font = ME_FONT(14);
    switch (indexPath.row) {
        case CellTitle:
        {
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.text = _store.name;
            cell.textLabel.font = ME_FONT(18);
        }
            break;
        case CellPicture:
        {
            [cell addSubview:_picImage];
        }
            break;
        case CellAddress:
        {
            UIImage *locImg = [UIImage imageNamed:@"location_icon"];
            cell.imageView.image = locImg;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = _store.address;
            cell.textLabel.font = font;
            cell.textLabel.numberOfLines = 0;
        }
            break;
        case CellPhone:
        {
            UIImage *phoneImg = [UIImage imageNamed:@"phone_icon"];
            cell.imageView.image = phoneImg;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = _store.phone;
            cell.textLabel.font = font;
        }
            break;
        case CellDesc:
        {
            cell.textLabel.text = _store.descrip;
            cell.textLabel.font = ME_FONT(13);
            cell.textLabel.numberOfLines = 0;
        }
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark - MKMapViewDelegate

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    
}

@end
