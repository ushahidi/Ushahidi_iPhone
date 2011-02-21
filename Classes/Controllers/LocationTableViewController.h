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
#import "TableViewController.h"
#import "Ushahidi.h"
#import "CheckBoxTableCell.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "Locator.h"

@class Incident;

@interface LocationTableViewController : TableViewController<UshahidiDelegate,
															 LocatorDelegate,
															 MKMapViewDelegate,
															 CheckBoxTableCellDelegate> {
@public
	UIBarButtonItem *cancelButton;
	UIBarButtonItem *doneButton;
	MKMapView *mapView;
	UISegmentedControl *viewMode;
	UIView *containerView;
	Incident *incident;
															 
@private
	NSString *location;
	NSString *latitude;
	NSString *longitude;
	NSString *currentLatitude;
	NSString *currentLongitude;
}

@property(nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) IBOutlet UISegmentedControl *viewMode;
@property(nonatomic, retain) IBOutlet UIView *containerView;
@property(nonatomic, retain) Incident *incident;

- (IBAction) cancel:(id)sender;
- (IBAction) done:(id)sender;
- (IBAction) viewModeChanged:(id)sender;

@end
