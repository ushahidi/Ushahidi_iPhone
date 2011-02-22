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
#import "BaseViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>

@interface MapViewController : BaseViewController<MKMapViewDelegate> {
	
@public
	MKMapView *mapView;
	UISearchBar *searchBar;
	UISegmentedControl *mapType;
	NSString *locationName;
	NSString *locationLatitude;
	NSString *locationLongitude;
}

@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property(nonatomic, retain) IBOutlet UISegmentedControl *mapType;
@property(nonatomic, retain) NSString *locationName;
@property(nonatomic, retain) NSString *locationLatitude;
@property(nonatomic, retain) NSString *locationLongitude;

- (IBAction) search:(id)sender;
- (IBAction) findLocation:(id)sender;
- (IBAction) mapTypeChanged:(id)sender;

@end
