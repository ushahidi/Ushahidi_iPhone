//
//  IncidentMapViewController.h
//  Ushahidi
//
//  Created by Wilfred Mworia on 9/19/09.
//  Copyright 2009 African Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CategoriesViewController.h"
#import "UshahidiAppDelegate.h"

@interface IncidentMapViewController : UIViewController <MKMapViewDelegate> {
	UISegmentedControl *segmentedControl;
	MKMapView *mapView;
	
	IBOutlet UIBarButtonItem *settingsButton;
	IBOutlet UIBarButtonItem *categoriesButton;
	IBOutlet UIBarButtonItem *aboutButton;
	
	UshahidiAppDelegate *delegate;
}

- (void)showCategoryView:(id)sender;
- (void)showAboutView:(id)sender;
- (void)showSettingsView:(id)sender;

@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, retain) MKMapView *mapView;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *settingsButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *categoriesButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *aboutButton;

@property (nonatomic, retain) UshahidiAppDelegate *delegate;

@end
