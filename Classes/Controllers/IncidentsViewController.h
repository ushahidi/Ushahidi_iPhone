/*****************************************************************************
 ** Copyright (c) 2010 Ushahidi Inc
 ** All rights reserved
 ** Contact: team@ushahidi.com
 ** Website: http://www.ushahidi.com
 **
 ** GNU Lesser General Public License Usage
 ** This file may be used under the terms of the GNU Lesser
 ** General Public License version 3 as published by the Free Software
 ** Foundation and appearing in the file LICENSE.LGPL included in the
 ** packaging of this file. Please review the following information to
 ** ensure the GNU Lesser General Public License version 3 requirements
 ** will be met: http://www.gnu.org/licenses/lgpl.html.
 **
 **
 ** If you have questions regarding the use of this file, please contact
 ** Ushahidi developers at team@ushahidi.com.
 **
 *****************************************************************************/

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "TableViewController.h"
#import "Ushahidi.h"
#import "Photo.h"

@class AddIncidentViewController;
@class ViewIncidentViewController;
@class MapViewController;
@class Deployment;
@class IncidentTableView;
@class IncidentMapView;

@interface IncidentsViewController : TableViewController<UshahidiDelegate, 
														 MKMapViewDelegate>  {
	
@public
	AddIncidentViewController *addIncidentViewController;
	ViewIncidentViewController *viewIncidentViewController;
	MKMapView *mapView;
	Deployment *deployment;
	UISegmentedControl *tableSort;
	UISegmentedControl *mapType;
	IncidentTableView *incidentTableView;
	IncidentMapView *incidentMapView;
															 
@private
	NSMutableArray *pending;
}

@property(nonatomic,retain) IBOutlet AddIncidentViewController *addIncidentViewController;
@property(nonatomic,retain) IBOutlet ViewIncidentViewController *viewIncidentViewController;
@property(nonatomic,retain) IBOutlet MKMapView *mapView;
@property(nonatomic,retain) IBOutlet UISegmentedControl *tableSort;
@property(nonatomic,retain) IBOutlet UISegmentedControl *mapType;
@property(nonatomic,retain) IBOutlet IncidentTableView *incidentTableView;
@property(nonatomic,retain) IBOutlet IncidentMapView *incidentMapView;
@property(nonatomic,retain) Deployment *deployment;

- (IBAction) add:(id)sender;
- (IBAction) refresh:(id)sender;
- (IBAction) toggleReportsAndMap:(id)sender;
- (IBAction) tableSortChanged:(id)sender;
- (IBAction) mapTypeChanged:(id)sender;

@end
