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
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <MapKit/MKReverseGeocoder.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import "MyAnnotation.h"
// Forward Class Declaration
@class UshahidiProjAppDelegate;

@interface viewIncident : UIViewController <MKMapViewDelegate,UIPickerViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    MKMapView *mk;
	CLLocationCoordinate2D locate;
	IBOutlet UIPickerView *pickerView;
	UIToolbar *tb;
	UshahidiProjAppDelegate *app;
	NSArray *arrData;
	IBOutlet UITableView *tblView;
	UISegmentedControl *seg;
	NSArray *arrTableData;
	NSDateFormatter *df;
	UIBarButtonItem *infoButton;
	UIButton *button,*button1;
	UIBarButtonItem *btn,*btn1;
	UIBarButtonItem *flexible;
	BOOL other;
	MKPlacemark *mPlacemark;
	MKReverseGeocoder *geoCoder;
	CLLocationCoordinate2D locate1[1000];
	MyAnnotation *ann[1000];
	UIToolbar *tb1;
	int catid;
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	}
-(void)changeSegment:(id)sender;
@end
