//
//  MapViewController.h
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-10.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>

@interface MapViewController : UIViewController<MKMapViewDelegate, UISearchBarDelegate> {
	
@public
	MKMapView *mapView;
	UISearchBar *searchBar;
	UISegmentedControl *mapType;
	NSString *address;
}

@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property(nonatomic, retain) IBOutlet UISegmentedControl *mapType;
@property(nonatomic, retain) NSString *address;

- (IBAction) search:(id)sender;
- (IBAction) findLocation:(id)sender;
- (IBAction) mapTypeChanged:(id)sender;

@end
