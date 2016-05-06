//
//  myMarker.h
//  GoogleMapsPlaceFinder
//
//  Created by Vladyslav Gusakov on 3/22/16.
//  Copyright © 2016 Vladyslav Gusakov. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>

@interface myMarker : GMSMarker

@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *photoReference;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSString *placeId;

@end
