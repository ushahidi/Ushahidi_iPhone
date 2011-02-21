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

#import "CheckinMapViewController.h"
#import "CheckinAddViewController.h"
#import "IncidentTabViewController.h"
#import "MapViewController.h"
#import "IncidentTableCell.h"
#import "TableCellFactory.h"
#import "UIColor+Extension.h"
#import "LoadingViewController.h"
#import "NSDate+Extension.h"
#import "AlertView.h"
#import "InputView.h"
#import "Incident.h"
#import "Deployment.h"
#import "Category.h"
#import "MKMapView+Extension.h"
#import "MKPinAnnotationView+Extension.h"
#import "NSString+Extension.h"
#import "MapAnnotation.h"
#import "Settings.h"
#import "TableHeaderView.h"
#import "Internet.h"
#import "Checkin.h"
#import "User.h"
#import "ItemPicker.h"

@interface CheckinMapViewController ()

@property(nonatomic,retain) ItemPicker *itemPicker;
@property(nonatomic,retain) NSMutableArray *checkins;
@property(nonatomic,retain) NSMutableArray *users;
@property(nonatomic,retain) User *user;

@end

@implementation CheckinMapViewController

@synthesize incidentTabViewController, checkinAddViewController;
@synthesize deployment, users, user, checkins;
@synthesize mapView, mapType, filterLabel, itemPicker, refreshButton, filterButton;

#pragma mark -
#pragma mark Handlers

- (IBAction) addCheckin:(id)sender {
	DLog(@"");
	[self.incidentTabViewController presentModalViewController:self.checkinAddViewController animated:YES];
}

- (IBAction) refreshCheckins:(id)sender {
	self.refreshButton.enabled = NO;
	[self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];
	[[Ushahidi sharedUshahidi] getCheckinsForDelegate:self];
}

- (IBAction) reportsMapTypeChanged:(id)sender {
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	DLog(@"reportsMapTypeChanged: %d", segmentedControl.selectedSegmentIndex);
	self.mapView.mapType = segmentedControl.selectedSegmentIndex;
}

- (IBAction) checkinsMapTypeChanged:(id)sender {
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	DLog(@"checkinsMapTypeChanged: %d", segmentedControl.selectedSegmentIndex);
	self.mapView.mapType = segmentedControl.selectedSegmentIndex;
}

- (IBAction) checkinsFilterChanged:(id)sender event:(UIEvent*)event {
	DLog(@"");
	NSMutableArray *items = [NSMutableArray arrayWithObject:NSLocalizedString(@" --- ALL USERS --- ", nil)];
	for (User *theUser in self.users) {
		if ([NSString isNilOrEmpty:[theUser name]] == NO) {
			[items addObject:[theUser name]];
		}
	}
	if (event != nil) {
		UIView *toolbar = [[event.allTouches anyObject] view];
		CGRect rect = CGRectMake(toolbar.frame.origin.x, self.view.frame.size.height - toolbar.frame.size.height, toolbar.frame.size.width, toolbar.frame.size.height);
		[self.itemPicker showWithItems:items 
						  withSelected:[self.user name] 
							   forRect:rect 
								   tag:0];
	}
	else {
		[self.itemPicker showWithItems:items 
						  withSelected:[self.user name] 
							   forRect:CGRectMake(100, self.view.frame.size.height, 0, 0) 
								   tag:0];	
	}
}

- (void) populate:(BOOL)refresh resize:(BOOL)resize {
	if (refresh) {
		[self.checkins addObjectsFromArray:[[Ushahidi sharedUshahidi] getCheckinsForDelegate:self]];
		if ([[Ushahidi sharedUshahidi] hasUsers]) {
			self.users = [NSMutableArray arrayWithArray:[[Ushahidi sharedUshahidi] getUsers]];
		}
		else {
			self.users = [NSMutableArray arrayWithCapacity:0];
		}
		[self.filterLabel setText:NSLocalizedString(@"All Users", nil)];
	}
	[self.mapView removeAllPins];
	[self.checkins removeAllObjects];
	[self.checkins addObjectsFromArray:[[Ushahidi sharedUshahidi] getCheckinsForDelegate:self]];
	for (Checkin *checkin in self.checkins) {
		[self.mapView addPinWithTitle:checkin.message 
											subtitle:checkin.dateString 
											latitude:checkin.latitude 
										   longitude:checkin.longitude 
											  object:checkin
											pinColor:MKPinAnnotationColorRed];
	}
	if (resize) {
		[self.mapView resizeRegionToFitAllPins:NO animated:YES];
	}
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.checkins = [[NSMutableArray alloc] initWithCapacity:0];
	self.itemPicker = [[ItemPicker alloc] initWithDelegate:self forController:self];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.incidentTabViewController = nil;
	self.checkinAddViewController = nil;
	self.checkins = nil;
	self.mapType = nil;
	self.itemPicker = nil;
	self.refreshButton = nil;
	self.filterButton = nil;
	self.filterLabel = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.checkins removeAllObjects];
	[self.checkins addObjectsFromArray:[[Ushahidi sharedUshahidi] getCheckins]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainQueueFinished) name:kMainQueueFinished object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapQueueFinished) name:kMapQueueFinished object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoQueueFinished) name:kPhotoQueueFinished object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadQueueFinished) name:kUploadQueueFinished object:nil];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.alertView showInfoOnceOnly:NSLocalizedString(@"Click the Map button to view the report map, the Filter button to filter by category or the Compose button to create a new incident report.", nil)];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kMainQueueFinished object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kMapQueueFinished object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPhotoQueueFinished object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kUploadQueueFinished object:nil];
}

- (void)dealloc {
	[incidentTabViewController release];
	[checkinAddViewController release];
	[deployment release];
	[mapType release];
	[itemPicker release];
	[checkins release];
	[users release];
	[user release];
    [super dealloc];
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadingFromUshahidi:(Ushahidi *)ushahidi checkins:(NSArray *)checkins {
	[self.loadingView showWithMessage:NSLocalizedString(@"Checkins...", nil)];
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi checkins:(NSArray *)theCheckins error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if (error != nil) {
		DLog(@"error: %d %@", [error code], [error localizedDescription]);
	}
	else if (hasChanges) {
		DLog(@"Re-Adding Checkins: %d", [checkins count]);
		[self.checkins removeAllObjects];
		[self.checkins addObjectsFromArray:theCheckins];
		[self populate:NO resize:YES];
	}
	else {
		DLog(@"No Changes Checkins");
	}
	[self.loadingView hide];
	self.refreshButton.enabled = YES;
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi users:(NSArray *)theUsers hasChanges:(BOOL)hasChanges {
	if (hasChanges) {
		DLog(@"Re-Adding Users: %d", [theUsers count]);
		[self.users removeAllObjects];
		[self.users addObjectsFromArray:theUsers];
	}
	else {
		DLog(@"No Changes Users");
	}
	self.filterButton.enabled = YES;
}

- (void) mainQueueFinished {
	DLog(@"");
	[self.loadingView hideAfterDelay:1.0];
}

- (void) mapQueueFinished {
	DLog(@"");
}

- (void) photoQueueFinished {
	DLog(@"");
}

- (void) uploadQueueFinished {
	DLog(@"");
}

#pragma mark -
#pragma mark MKMapView

- (MKAnnotationView *) mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
	MKPinAnnotationView *annotationView = [MKPinAnnotationView getPinForMap:theMapView andAnnotation:annotation];
	if ([annotation class] != MKUserLocation.class) {
		UIButton *annotationButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[annotationButton addTarget:self action:@selector(annotationClicked:) forControlEvents:UIControlEventTouchUpInside];
		annotationView.rightCalloutAccessoryView = annotationButton;
	}
	return annotationView;
}

- (void) annotationClicked:(UIButton *)button {
	MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[[button superview] superview];
	MapAnnotation *mapAnnotation = (MapAnnotation *)annotationView.annotation;
	if ([mapAnnotation class] == MKUserLocation.class) {
		[self.alertView showOkWithTitle:NSLocalizedString(@"User Location", nil) andMessage:[NSString stringWithFormat:@"%f,%f", mapAnnotation.coordinate.latitude, mapAnnotation.coordinate.longitude]];
	}
	else {
		DLog(@"title:%@ latitude:%f longitude:%f", mapAnnotation.title, mapAnnotation.coordinate.latitude, mapAnnotation.coordinate.longitude);
	}
}

- (void)mapView:(MKMapView *)theMapView didUpdateUserLocation:(MKUserLocation *)userLocation {
	[theMapView resizeRegionToFitAllPins:NO animated:YES];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapViewDidFailLoadingMap:(MKMapView *)theMapView withError:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
}

#pragma mark -
#pragma mark ItemPickerDelegate

- (void) itemPickerReturned:(ItemPicker *)theItemPicker item:(NSString *)item {
	DLog(@"itemPickerReturned: %@", item);
	self.user = nil;
	for (User *theUser in self.users) {
		if ([theUser.name isEqualToString:item]) {
			self.user = theUser;
			DLog(@"User: %@", theUser.name);
			break;
		}
	}
	if (self.user != nil) {
		[self.filterLabel setText:[NSString stringWithFormat:@"%@ : %@", NSLocalizedString(@"Checkins", nil), self.user.name]];
	}
	else {
		[self.filterLabel setText:NSLocalizedString(@"All Users", nil)];
	}
	[self.mapView removeAllPins];
	for (Checkin *checkin in self.checkins) {
		if (self.user == nil || [self.user.identifier isEqualToString:[checkin user]]) {
			[self.mapView addPinWithTitle:checkin.message 
												subtitle:checkin.dateString 
												latitude:checkin.latitude 
											   longitude:checkin.longitude 
												  object:checkin
												pinColor:MKPinAnnotationColorRed];	
		}
	}
	[self.mapView resizeRegionToFitAllPins:NO animated:YES];
}

@end
