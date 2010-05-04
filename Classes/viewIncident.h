//
//  viewIncident.h
//  UshahidiProj
//
//  Created by iSoft Solutions on 23/02/10.
//  Copyright 2010 iSoft Solutions. All rights reserved.
//

// Import All the Necessary Files and Frameworks

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
