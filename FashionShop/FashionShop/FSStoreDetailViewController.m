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
#import "UIViewController+Loading.h"
#import "UIImageView+WebCache.h"


#define BAIDU_MAP_URL @"http://api.map.baidu.com/marker?location=%f,%f&title=%@&content=%@&output=html"
@interface FSStoreDetailViewController ()
{

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
    [self prepareLayout];
}
-(void)prepareLayout
{
    UIBarButtonItem *baritemCancel = [self createPlainBarButtonItem:@"goback_icon.png" target:self action:@selector(onButtonBack:)];
    [self.navigationItem setLeftBarButtonItem:baritemCancel];
    self.title = _store.name;
    int xOff = 10;

    int yOff = 10;
    int yOff2 = 15;
    int curYOff =0;
    if (_store.resource &&
        _store.resource.count>0)
    {
        UIImageView *storeLogo = [[UIImageView alloc] initWithFrame:CGRectMake(xOff, yOff, 320, 35)];
        storeLogo.contentMode = UIViewContentModeScaleAspectFit;
        [storeLogo setImageWithURL:[(FSResource *)[_store.resource lastObject] absoluteUrlOrigin]];
        [self.view addSubview:storeLogo];
        curYOff = storeLogo.frame.size.height +storeLogo.frame.origin.y;
    }
    UIImage *locImg = [UIImage imageNamed:@"location_icon"];
    UIImageView *locImgView = [[UIImageView alloc] initWithFrame:CGRectMake(xOff, curYOff+yOff, locImg.size.width, locImg.size.height)];
    [locImgView setContentMode:UIViewContentModeScaleAspectFit];
    [locImgView setImage:locImg];
    [self.view addSubview:locImgView];
    
    int addressStartX = locImgView.frame.origin.x+locImgView.frame.size.width+2;
    NSString *addText = [NSString stringWithFormat:NSLocalizedString(@"address: %@", nil),_store.address];
    int addWidth = SCREEN_WIDTH-xOff-addressStartX;
    UILabel *lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(addressStartX, locImgView.frame.origin.y+2, SCREEN_WIDTH-xOff-addressStartX, 0)];
    lblAddress.text = addText;
    lblAddress.font = ME_FONT(12);
    lblAddress.adjustsFontSizeToFitWidth = YES;
    lblAddress.numberOfLines = 0;
    int height = [addText sizeWithFont:lblAddress.font constrainedToSize:CGSizeMake(addWidth, 1000) lineBreakMode:UILineBreakModeCharacterWrap].height;
    lblAddress.frame = CGRectMake(addressStartX, locImgView.frame.origin.y, addWidth, height);
    lblAddress.lineBreakMode = UILineBreakModeCharacterWrap;
    lblAddress.textColor =[UIColor colorWithRed:102 green:102 blue:102];
    [self.view addSubview:lblAddress];
    curYOff=lblAddress.frame.size.height+lblAddress.frame.origin.y;
    
    UIImage *phoneImg = [UIImage imageNamed:@"phone_icon"];
    UIImageView *phImgView = [[UIImageView alloc] initWithFrame:CGRectMake(xOff, curYOff+yOff2, phoneImg.size.width, phoneImg.size.height)];
    [phImgView setContentMode:UIViewContentModeScaleAspectFit];
    [phImgView setImage:phoneImg];
    [self.view addSubview:phImgView];
    UILabel *lblPhone = [[UILabel alloc] initWithFrame:CGRectMake(phImgView.frame.origin.x+phImgView.frame.size.width+2, phImgView.frame.origin.y, 300, phImgView.frame.size.height)];
    lblPhone.text = [NSString stringWithFormat:NSLocalizedString(@"phone: %@", nil),_store.phone];
    lblPhone.font = ME_FONT(12);
    lblPhone.textColor =[UIColor colorWithRed:102 green:102 blue:102];
    [lblPhone sizeToFit];
    [self.view addSubview:lblPhone];

    
    curYOff=phImgView.frame.size.height+phImgView.frame.origin.y;
    
    if (_store.descrip)
    {
        UILabel *lblDesTitle = [[UILabel alloc] initWithFrame:CGRectMake(xOff, curYOff+yOff2, 320, 20)];
        lblDesTitle.text = NSLocalizedString(@"detail descritpion", nil);
        lblDesTitle.font = ME_FONT(14);
        lblDesTitle.textColor =[UIColor colorWithRed:51 green:51 blue:51];
        [lblDesTitle sizeToFit];
        [self.view addSubview:lblDesTitle];
        curYOff=lblDesTitle.frame.size.height+lblDesTitle.frame.origin.y;
        UILabel *lblDes = [[UILabel alloc] initWithFrame:CGRectMake(xOff, curYOff, 320-xOff*2, 320)];
        lblDes.text = _store.descrip;
        lblDes.font = ME_FONT(10);
        lblDes.textColor = [UIColor colorWithRed:102 green:102 blue:102];
        lblDes.numberOfLines = 0;
        [lblDes sizeToFit];
        [self.view addSubview:lblDes];
        curYOff=lblDes.frame.size.height+lblDes.frame.origin.y;
    }
    _detailContainer.frame = CGRectMake(_detailContainer.frame.origin.x,_detailContainer.frame.origin.y,_detailContainer.frame.size.width,curYOff+yOff);

    CGRect mapFrame = _mapView.frame;
    mapFrame.origin.y = _detailContainer.frame.size.height;
    mapFrame.origin.x = 0;
    mapFrame.size.width = 320;
    _mapView.frame = mapFrame;
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [_mapView setDelegate:self];
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:[self generateMapUrl]]
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:60.0];
    [_mapView loadRequest:request];
   
}
- (IBAction)onButtonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(NSString *)generateMapUrl
{
    NSString *url =  [NSString stringWithFormat:BAIDU_MAP_URL,
                      [_store.lantit floatValue],
                      [_store.longit floatValue],
                      _store.name,
                      _store.address];
    return [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}


#pragma mark - UIWebViewDelegate Methods


- (void)webViewDidStartLoad:(UIWebView *)aWebView{
    if (self)
	[self beginLoading:_mapView];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView{
    if (self)
	[self endLoading:_mapView];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error{
    if (self)
    [self endLoading:_mapView];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (self)
        return YES;
    return NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [_mapView setDelegate:nil];
}
- (void)viewDidUnload {

    [self setMapView:nil];
    [self setDetailContainer:nil];
    [super viewDidUnload];
}
@end
