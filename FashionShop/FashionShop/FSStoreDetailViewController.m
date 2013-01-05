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
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [_mapView setDelegate:self];
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:[self generateMapUrl]]
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:60.0];
    [_mapView loadRequest:request];
   
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
    [super viewDidUnload];
}
@end
