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

@class Incident;
@class Location;

@interface LocationsViewController : TableViewController<UshahidiDelegate,
														 UITextFieldDelegate,
														 CheckBoxTableCellDelegate,
														 MKMapViewDelegate> {
@public
	UIBarButtonItem *cancelButton;
	UIBarButtonItem *doneButton;
	MKMapView *mapView;
	Incident *incident;
	Location *location;
	UISegmentedControl *locationType;
	UIToolbar *toolBar;
	UITextField *textField;
}

@property(nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) IBOutlet UISegmentedControl *locationType;
@property(nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property(nonatomic, retain) IBOutlet UITextField *textField;
@property(nonatomic, retain) Incident *incident;
@property(nonatomic, retain) Location *location;

- (IBAction) cancel:(id)sender;
- (IBAction) done:(id)sender;
- (IBAction) locate:(id)sender;
- (IBAction) locationTypeChanged:(id)sender;

@end
