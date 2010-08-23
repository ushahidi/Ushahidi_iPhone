//
//  IncidentsViewController.h
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-09.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "TableViewController.h"
#import "SearchTableCell.h"

@class AddIncidentViewController;
@class ViewIncidentViewController;

@interface IncidentsViewController : TableViewController<SearchTableCellDelegate, UIActionSheetDelegate, MKMapViewDelegate>  {
	
@public
	AddIncidentViewController *addIncidentViewController;
	ViewIncidentViewController *viewIncidentViewController;
	MKMapView *mapView;
}

@property(nonatomic,retain) IBOutlet AddIncidentViewController *addIncidentViewController;
@property(nonatomic,retain) IBOutlet ViewIncidentViewController *viewIncidentViewController;
@property(nonatomic,retain) IBOutlet MKMapView *mapView;

- (IBAction) add:(id)sender;
- (IBAction) refresh:(id)sender;
- (IBAction) action:(id)sender;
- (IBAction) toggleReportsAndMap:(id)sender;

@end
