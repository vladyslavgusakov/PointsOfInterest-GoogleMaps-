//
//  ViewController.h
//  GoogleMapsPlaceFinder
//
//  Created by Vladyslav Gusakov on 3/21/16.
//  Copyright © 2016 Vladyslav Gusakov. All rights reserved.
//

@import UIKit;
@import GoogleMaps;
#import "AFNetworking.h"
#import "myMarker.h"

@interface ViewController : UIViewController <GMSMapViewDelegate>

@property (strong, nonatomic) IBOutlet GMSMapView *mapView;

@end

