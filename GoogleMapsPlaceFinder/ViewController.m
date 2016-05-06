//
//  ViewController.m
//  GoogleMapsPlaceFinder
//
//  Created by Vladyslav Gusakov on 3/21/16.
//  Copyright © 2016 Vladyslav Gusakov. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

static NSString const * kNormalType = @"Normal";
static NSString const * kSatelliteType = @"Satellite";
static NSString const * kHybridType = @"Hybrid";
static NSString const * kTerrainType = @"Terrain";

@interface ViewController () <UISearchBarDelegate, UISearchDisplayDelegate> {
    
    BOOL firstLocationUpdate;
    NSArray *mapTypes;
    AFHTTPSessionManager *manager;
}


@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
- (IBAction)dissmissKeyBoard:(UIBarButtonItem *)sender;

@property (strong, nonatomic) IBOutlet UISegmentedControl *switcher;
- (IBAction)setMap:(UISegmentedControl *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.mapView.mapType = kGMSTypeNormal;
    self.switcher.selectedSegmentIndex = 0;
    
    self.mapView.settings.compassButton = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.userInteractionEnabled = YES;
    
    self.mapView.delegate = self;
    
    [self.mapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context:NULL];
    
    mapTypes = @[kNormalType, kSatelliteType, kHybridType, kTerrainType];
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mapView.myLocationEnabled = YES;
    });
    
    // Creates a TTT marker.
    [self createTurnToTechMarker];
    
    //Get nearby restaurants
    self.searchBar.delegate = self;
    manager = [AFHTTPSessionManager manager];
    
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    [self.mapView clear];
    [self makeURLRequest];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    if (!firstLocationUpdate) {
        // If the first location update has been recieved, then jump to that
        // location.
        firstLocationUpdate = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        self.mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                                zoom:14];
    }
}

-(void) createTurnToTechMarker {
    myMarker *marker = [[myMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(40.741434,-73.990039);
    marker.title = @"TurnToTech";
    marker.snippet = @"184 5th Ave, New York, NY 10010";
    marker.image = [UIImage imageNamed:@"ttt"];
    marker.website = @"http://turntotech.io";
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = self.mapView;
}

-(UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    
    CGFloat iwWidth = 320;
    CGFloat iwHeight = 70;
    CGFloat offset = 5;
    
    UIView *infoWindow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iwWidth, iwHeight)];
    infoWindow.backgroundColor = [UIColor whiteColor];
    infoWindow.layer.cornerRadius = 7.0;
    infoWindow.layer.masksToBounds = YES;
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(iwHeight, iwHeight/2, iwWidth-iwHeight-offset, 1)];
    
    CAShapeLayer *shapeView = [[CAShapeLayer alloc] init];
    shapeView.path = rectanglePath.CGPath;
    [infoWindow.layer addSublayer:shapeView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(iwHeight, iwHeight/2-20-offset, iwWidth-iwHeight-offset, 20)];
    [infoWindow addSubview:titleLabel];
    titleLabel.text = marker.title;
    
    UILabel *snippetLabel = [[UILabel alloc] initWithFrame:CGRectMake(iwHeight, (iwHeight+offset)/2, iwWidth-iwHeight-offset, 32)];
    [infoWindow addSubview:snippetLabel];
    snippetLabel.text = marker.snippet;
    snippetLabel.font = [snippetLabel.font fontWithSize: 12];
    snippetLabel.lineBreakMode = NSLineBreakByWordWrapping;
    snippetLabel.numberOfLines = 2;
    
     UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(offset, offset, iwHeight-2*offset, iwHeight-2*offset)];
    
    
    [infoWindow addSubview:backgroundImage];

    
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?key=AIzaSyBg8HI6sH1Rxyhn1Mno_hhgDawuF1KAfq0&placeid=%@", ((myMarker *)marker).placeId]]];
//    
//    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//    
//    ((myMarker *)marker).website = [jsonData valueForKeyPath:@"result.website"];
//    
//    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/s2/favicons?domain_url=%@",((myMarker *)marker).website]];
//    
//    [backgroundImage setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]]];
        [backgroundImage setImage: ((myMarker *) marker).image];
    
        backgroundImage.contentMode = UIViewContentModeCenter;

    
    return infoWindow;
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    
    //get request
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?key=AIzaSyBg8HI6sH1Rxyhn1Mno_hhgDawuF1KAfq0&placeid=%@", ((myMarker *)marker).placeId]]];
    
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    ((myMarker *)marker).website = [jsonData valueForKeyPath:@"result.website"];
    
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/s2/favicons?domain_url=%@",((myMarker *)marker).website]];
    
    [((myMarker *)marker) setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]]];

    
    return NO;
}

-(void) mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width*0.2, self.view.bounds.size.height*0.2, self.view.bounds.size.width*0.6, self.view.bounds.size.height*0.6)];
    
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:[NSURL URLWithString:((myMarker *)marker).website]];
    
    [webView loadRequest:requestURL];
    [self.view addSubview:webView];

    
    }

-(void) mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    
    if (gesture == YES) {
        [self.searchBar resignFirstResponder];
        
        for (UIView *tmp in self.view.subviews) {
            if ([tmp isKindOfClass:UIWebView.class]) {
                [tmp removeFromSuperview];
            }
        }

    }
}

-(void) makeURLRequest {
    
    NSString *requestURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=%@&location=%f,%f&radius=200&sensor=true&key=AIzaSyBg8HI6sH1Rxyhn1Mno_hhgDawuF1KAfq0", self.searchBar.text, self.mapView.myLocation.coordinate.latitude, self.mapView.myLocation.coordinate.longitude];
    
    [manager GET:requestURL parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
//        NSLog(@"%@", responseObject);
        
        for (id result in [responseObject valueForKey:@"results"]) {
            CLLocationDegrees latitude = [[result valueForKeyPath:@"geometry.location.lat"] doubleValue];
            CLLocationDegrees longitude = [[result valueForKeyPath:@"geometry.location.lng"] doubleValue];
            
            myMarker *marker = [[myMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake(latitude,longitude);
            marker.title =  [result valueForKey:@"name"];
            marker.snippet = [result valueForKey:@"formatted_address"];
            marker.placeId = [result valueForKey:@"place_id"];
            marker.appearAnimation = kGMSMarkerAnimationPop;
            marker.map = self.mapView;
            
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *failureErr) {
        NSLog(@"Error: %@", failureErr);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dissmissKeyBoard:(UIBarButtonItem *)sender {
    
    [self.searchBar resignFirstResponder];
    
    for (UIView *tmp in self.view.subviews) {
        if ([tmp isKindOfClass:UIWebView.class]) {
            [tmp removeFromSuperview];
        }
    }
    
}

- (IBAction)setMap:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = kGMSTypeNormal;
            break;
        case 1:
            self.mapView.mapType = kGMSTypeSatellite;
            break;
        case 2:
            self.mapView.mapType = kGMSTypeHybrid;
            break;
        case 3:
            self.mapView.mapType = kGMSTypeTerrain;
            break;
        default:
            break;
    }

}

@end
