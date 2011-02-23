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

#import "IncidentMapViewController.h"
#import "IncidentTabViewController.h"
#import "IncidentAddViewController.h"
#import "IncidentDetailsViewController.h"
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

@interface IncidentMapViewController ()

@property(nonatomic,retain) NSMutableArray *incidents;
@property(nonatomic,retain) NSMutableArray *pending;
@property(nonatomic,retain) ItemPicker *itemPicker;
@property(nonatomic,retain) NSMutableArray *categories;
@property(nonatomic,retain) Category *category;

- (void) mainQueueFinished;
- (void) mapQueueFinished;
- (void) photoQueueFinished;
- (void) uploadQueueFinished;

@end

@implementation IncidentMapViewController

@synthesize incidentTabViewController, incidentAddViewController, incidentDetailsViewController;
@synthesize refreshButton, filterButton, mapType, itemPicker, mapView, filterLabel;
@synthesize incidents, deployment, pending, categories, category;

#pragma mark -
#pragma mark Handlers

- (IBAction) addReport:(id)sender {
	DLog(@"");
	self.incidentAddViewController.incident = nil;
	[self.incidentTabViewController presentModalViewController:self.incidentAddViewController animated:YES];
}

- (IBAction) refresh:(id)sender {
	DLog(@"");
	self.refreshButton.enabled = NO;
	[self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];
	[[Ushahidi sharedUshahidi] getIncidentsForDelegate:self];
	[[Ushahidi sharedUshahidi] uploadIncidentsForDelegate:self];
}

- (IBAction) mapTypeChanged:(id)sender {
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	DLog(@"reportsMapTypeChanged: %d", segmentedControl.selectedSegmentIndex);
	self.mapView.mapType = segmentedControl.selectedSegmentIndex;
}

- (IBAction) filterChanged:(id)sender event:(UIEvent*)event {
	DLog(@"");
	NSMutableArray *items = [NSMutableArray arrayWithObject:NSLocalizedString(@" --- ALL CATEGORIES --- ", nil)];
	for (Category *theCategory in self.categories) {
		if ([NSString isNilOrEmpty:[theCategory title]] == NO) {
			[items addObject:theCategory.title];
		}
	}
	if (event != nil) {
		UIView *toolbar = [[event.allTouches anyObject] view];
		CGRect rect = CGRectMake(toolbar.frame.origin.x, self.view.frame.size.height - toolbar.frame.size.height, toolbar.frame.size.width, toolbar.frame.size.height);
		[self.itemPicker showWithItems:items 
						  withSelected:[self.category title] 
							   forRect:rect 
								   tag:0];
	}
	else {
		[self.itemPicker showWithItems:items 
						  withSelected:[self.category title] 
							   forRect:CGRectMake(100, self.view.frame.size.height, 0, 0) 
								   tag:0];	
	}
}

- (void) populate:(BOOL)refresh resize:(BOOL)resize {
	[self.incidents removeAllObjects];
	if (refresh) {
		[self.incidents addObjectsFromArray:[[Ushahidi sharedUshahidi] getIncidentsForDelegate:self]];
		self.category = nil;
		[self.filterLabel setText:NSLocalizedString(@"All Categories", nil)];
	}
	else {
		[self.incidents addObjectsFromArray:[[Ushahidi sharedUshahidi] getIncidents]];
		if (self.category != nil) {
			[self.filterLabel setText:self.category.title];
		}
		else {
			[self.filterLabel setText:NSLocalizedString(@"All Categories", nil)];
		}
	}
	[self.categories removeAllObjects];
	if ([[Ushahidi sharedUshahidi] hasCategories]) {
		[self.categories addObjectsFromArray:[[Ushahidi sharedUshahidi] getCategories]];
	}
	else {
		[self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];
		[self.categories addObjectsFromArray:[NSMutableArray arrayWithArray:[[Ushahidi sharedUshahidi] getCategoriesForDelegate:self]]];
	}
	if ([[Ushahidi sharedUshahidi] hasLocations] == NO) {
		[[Ushahidi sharedUshahidi] getLocationsForDelegate:self];
	}
	self.mapView.showsUserLocation = NO;
	[self.mapView removeAllPins];
	self.mapView.showsUserLocation = YES;
	
	for (Incident *incident in self.incidents) {
		if (self.category == nil || [incident hasCategory:self.category]) {
			[self.mapView addPinWithTitle:incident.title 
								 subtitle:incident.dateString 
								 latitude:incident.latitude 
								longitude:incident.longitude
								   object:incident
								 pinColor:MKPinAnnotationColorRed];
		}
	}
	for (Incident *incident in self.pending) {
		[self.mapView addPinWithTitle:incident.title 
							 subtitle:incident.dateString 
							 latitude:incident.latitude 
							longitude:incident.longitude 
							   object:incident
							 pinColor:MKPinAnnotationColorPurple];
	}
	if (resize) {
		[self.mapView resizeRegionToFitAllPins:NO animated:YES];
	}
	self.filterButton.enabled = [self.categories count] > 0;
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.incidents = [[NSMutableArray alloc] initWithCapacity:0];
	self.pending = [[NSMutableArray alloc] initWithCapacity:0];
	self.categories = [[NSMutableArray alloc] initWithCapacity:0];
	self.itemPicker = [[ItemPicker alloc] initWithDelegate:self forController:self];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.incidentTabViewController = nil;
	self.incidentAddViewController = nil;
	self.incidentDetailsViewController = nil;
	self.mapType = nil;
	self.pending = nil;
	self.itemPicker = nil;
	self.incidents = nil;
	self.pending = nil;
	self.categories = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.incidents removeAllObjects];
	[self.incidents addObjectsFromArray:[[Ushahidi sharedUshahidi] getIncidents]];
	
	[self.pending removeAllObjects];
	[self.pending addObjectsFromArray:[[Ushahidi sharedUshahidi] getIncidentsPending]];
	
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
	[incidentAddViewController release];
	[incidentDetailsViewController release];
	[deployment release];
	[mapType release];
	[pending release];
	[itemPicker release];
	[categories release];
	[category release];
	[super dealloc];
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadingFromUshahidi:(Ushahidi *)ushahidi categories:(NSArray *)theCategories {
	DLog(@"Downloading Categories...");
	[self.loadingView showWithMessage:NSLocalizedString(@"Categories...", nil)];
}

- (void) downloadingFromUshahidi:(Ushahidi *)ushahidi locations:(NSArray *)locations {
	DLog(@"Downloading Locations...");
	[self.loadingView showWithMessage:NSLocalizedString(@"Locations...", nil)];
}

- (void) downloadingFromUshahidi:(Ushahidi *)ushahidi incidents:(NSArray *)incidents pending:(NSArray *)thePending {
	DLog(@"Downloading Incidents...");
	[self.loadingView showWithMessage:NSLocalizedString(@"Incidents...", nil)];
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi incidents:(NSArray *)theIncidents pending:(NSArray *)thePending error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if (error != nil) {
		DLog(@"error: %d %@", [error code], [error localizedDescription]);
		if ([error code] == UnableToCreateRequest) {
			[self.loadingView hide];
			[self.alertView showOkWithTitle:NSLocalizedString(@"Request Error", nil) 
								 andMessage:[error localizedDescription]];
		}
		else if ([error code] == NoInternetConnection) {
			if ([self.loadingView isShowing]) {
				[self.loadingView hide];
				[self.alertView showOkWithTitle:NSLocalizedString(@"No Internet", nil) 
									 andMessage:[error localizedDescription]];
			}
		}
		else if ([self.loadingView isShowing]){
			[self.loadingView hide];
			[self.alertView showOkWithTitle:NSLocalizedString(@"Server Error", nil) 
								 andMessage:[error localizedDescription]];
		}
	}
	else if (hasChanges) {
		DLog(@"incidents: %d", [theIncidents count]);
		[self.incidents removeAllObjects];
		[self.incidents addObjectsFromArray:theIncidents];
		[self.pending removeAllObjects];
		[self.pending addObjectsFromArray:thePending];
		[self populate:NO resize:YES];
		DLog(@"Re-Adding Incidents");
	}
	else {
		DLog(@"No Changes Incidents");
	}
	self.refreshButton.enabled = YES;
}

- (void) uploadingToUshahidi:(Ushahidi *)ushahidi incident:(Incident *)incident {
	if (incident != nil){
		DLog(@"Incident: %@", incident.title);
		
	}
	else {
		DLog(@"Incident is NULL");
	}
}

- (void) uploadedToUshahidi:(Ushahidi *)ushahidi incident:(Incident *)incident error:(NSError *)error {
	if (error != nil) {
		DLog(@"error: %d %@", [error code], [error localizedDescription]);
		if ([error code] > NoInternetConnection) {
			[self.loadingView hide];
			[self.alertView showOkWithTitle:NSLocalizedString(@"Upload Error", nil) 
								 andMessage:[error localizedDescription]];
		}
	}
	if (incident != nil) {
		DLog(@"Incident: %@", incident.title);
		[self.loadingView showWithMessage:NSLocalizedString(@"Uploaded", nil)];
		[self.loadingView hideAfterDelay:1.0];
	}
	else {
		DLog(@"Incident is NULL");
	}
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi categories:(NSArray *)theCategories error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if (error != nil) {
		DLog(@"error: %d %@", [error code], [error localizedDescription]);
	}
	else if(hasChanges) {
		[self.categories removeAllObjects];
		for (Category *theCategory in theCategories) {
			[self.categories addObject:theCategory];
		}
		[self populate:NO resize:YES];
		DLog(@"Re-Adding Categories");
	}
	else {
		DLog(@"No Changes Categories");
	}
	self.filterButton.enabled = [self.categories count] > 0;
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
		Incident *incident = (Incident *)mapAnnotation.object; 
		if (incident.pending) {
			self.incidentAddViewController.incident = incident;
			[self.incidentTabViewController presentModalViewController:self.incidentAddViewController animated:YES];
		}
		else {
			self.incidentDetailsViewController.incident = (Incident *)mapAnnotation.object; 
			self.incidentDetailsViewController.incidents = self.incidents;
			self.incidentTabViewController.navigationItem.backBarButtonItem.title = NSLocalizedString(@"Reports", nil);
			[self.incidentTabViewController.navigationController pushViewController:self.incidentDetailsViewController animated:YES];
		}
	}
}

- (void)mapView:(MKMapView *)theMapView didUpdateUserLocation:(MKUserLocation *)userLocation {
	[theMapView resizeRegionToFitAllPins:NO animated:YES];
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)theMapView withError:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
}

#pragma mark -
#pragma mark ItemPickerDelegate

- (void) itemPickerReturned:(ItemPicker *)theItemPicker item:(NSString *)item {
	DLog(@"itemPickerReturned: %@", item);
	self.category = nil;
	for (Category *theCategory in self.categories) {
		if ([theCategory.title isEqualToString:item]) {
			self.category = theCategory;
			DLog(@"Category: %@", theCategory.title);
			break;
		}
	}
	if (self.category != nil) {
		[self.filterLabel setText:self.category.title];
	}
	else {
		[self.filterLabel setText:NSLocalizedString(@"All Categories", nil)];
	}
	[self populate:NO resize:YES];
	if ([self.incidents count] == 0) {
		[self.loadingView showWithMessage:NSLocalizedString(@"No Reports", nil)];
		[self.loadingView hideAfterDelay:1.0];					 
	}	
}

@end
