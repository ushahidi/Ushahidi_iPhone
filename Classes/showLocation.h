//
//  showLocation.h
//  UshahidiProj
//
//  Created by iSoft Solutions on 31/03/10.
//  Copyright 2010 iSoft Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <MapKit/MKReverseGeocoder.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>

@interface showLocation : UIViewController <MKMapViewDelegate, MKReverseGeocoderDelegate> {

	MKMapView *mk;
	MKReverseGeocoder *geoCoder;
	CLLocationCoordinate2D locate;
	MKPlacemark *mPlacemark;
	NSMutableDictionary *dictForLocation;
	
}

@property (nonatomic,retain)NSMutableDictionary *dictForLocation;
@end
