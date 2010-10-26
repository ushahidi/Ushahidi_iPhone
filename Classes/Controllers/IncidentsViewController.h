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

@interface IncidentsViewController : TableViewController<UshahidiDelegate, 
														 UIActionSheetDelegate, 
														 MKMapViewDelegate, 
														 PhotoDelegate>  {
	
@public
	AddIncidentViewController *addIncidentViewController;
	ViewIncidentViewController *viewIncidentViewController;
	MapViewController *mapViewController;
	MKMapView *mapView;
	Deployment *deployment;
	UISegmentedControl *sortOrder;
}

@property(nonatomic,retain) IBOutlet AddIncidentViewController *addIncidentViewController;
@property(nonatomic,retain) IBOutlet ViewIncidentViewController *viewIncidentViewController;
@property(nonatomic,retain) IBOutlet MapViewController *mapViewController;
@property(nonatomic,retain) IBOutlet MKMapView *mapView;
@property(nonatomic,retain) IBOutlet UISegmentedControl *sortOrder;
@property(nonatomic,retain) Deployment *deployment;

- (IBAction) add:(id)sender;
- (IBAction) refresh:(id)sender;
- (IBAction) action:(id)sender;
- (IBAction) map:(id)sender;
- (IBAction) toggleReportsAndMap:(id)sender;
- (IBAction) sortOrder:(id)sender;

@end
