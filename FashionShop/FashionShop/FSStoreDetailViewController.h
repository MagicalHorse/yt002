//
//  FSStoreDetailViewController.h
//  FashionShop
//
//  Created by gong yi on 1/4/13.
//  Copyright (c) 2013 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSStore.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

typedef enum {
    CellTitle,
    CellPicture,
    CellAddress,
    CellPhone,
    CellDesc,
}CellType;

@interface FSStoreDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate, MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tbAction;
@property (strong, nonatomic) FSStore *store;

@end
