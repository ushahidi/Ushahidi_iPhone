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
#import "BaseMapViewController.h"
#import "Ushahidi.h"
#import "CheckBoxTableCell.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "Locator.h"

@class Incident;

@interface LocationSelectViewController : BaseMapViewController<UshahidiDelegate,
                                                                LocatorDelegate,
                                                                MKMapViewDelegate> {
@public
	UIBarButtonItem *cancelButton;
	UIBarButtonItem *doneButton;
	Incident *incident;
															 
@private
	NSString *location;
	NSString *latitude;
	NSString *longitude;
	NSString *currentLatitude;
	NSString *currentLongitude;
    NSMutableArray *locations;
}

@property(nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property(nonatomic, retain) Incident *incident;

- (IBAction) cancel:(id)sender;
- (IBAction) done:(id)sender;
- (IBAction) locate:(id)sender;

@end
