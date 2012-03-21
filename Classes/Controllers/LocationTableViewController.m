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

#import "LocationTableViewController.h"
#import "BaseMapViewController.h"
#import "LoadingViewController.h"
#import "Incident.h"
#import "Location.h"
#import "TableCellFactory.h"
#import "MKMapView+Extension.h"
#import "MKPinAnnotationView+Extension.h"
#import "MapAnnotation.h"
#import "NSString+Extension.h"
#import "Ushahidi.h"
#import "Settings.h"

@interface LocationTableViewController ()

@property(nonatomic, retain) NSString *location;
@property(nonatomic, retain) NSString *latitude;
@property(nonatomic, retain) NSString *longitude;
@property(nonatomic, retain) NSString *currentLatitude;
@property(nonatomic, retain) NSString *currentLongitude;
@property(nonatomic, retain) NSMutableArray *locations;

- (void) populateMapPins:(BOOL)centerMap;

@end

@implementation LocationTableViewController

@synthesize cancelButton, doneButton;
@synthesize incident, location, locations;
@synthesize latitude, longitude;
@synthesize currentLatitude, currentLongitude;

#pragma mark -
#pragma mark Handlers

- (IBAction) locate:(id)sender {
    DLog(@"");
    [self.loadingView showWithMessage:NSLocalizedString(@"Locating...", nil)];
    [[Locator sharedLocator] detectLocationForDelegate:self];
}

- (IBAction) cancel:(id)sender {
    DLog(@"");
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) done:(id)sender {
    DLog(@"");
	[self setEditing:NO];
	self.incident.location = self.location;
	self.incident.latitude = self.latitude;
	self.incident.longitude = self.longitude;	
	[self dismissModalViewControllerAnimated:YES];
}

- (void) populateMapPins:(BOOL)centerMap {
    DLog(@"Center:%d", centerMap);
	[self.mapView removeAllPins];
    MapAnnotation *selected = nil;
	for (Location *loc in self.locations) {
		MapAnnotation *mapAnnotation = [self.mapView addPinWithTitle:loc.name 
															subtitle:loc.coordinates 
															latitude:loc.latitude 
														   longitude:loc.longitude
															  object:loc
															pinColor:MKPinAnnotationColorRed];
		if (self.incident.userLocation == NO &&
			[loc.name isEqualToString:self.location] &&
			[loc.latitude isEqualToString:self.latitude] &&
			[loc.longitude isEqualToString:self.longitude]) {
            selected = mapAnnotation;
		}
	}
	if (self.currentLatitude != nil && self.currentLongitude != nil) {
		MapAnnotation *userAnnotation = [self.mapView addPinWithTitle:NSLocalizedString(@"Current Location", nil) 
                                                             subtitle:[NSString stringWithFormat:@"%@, %@", self.currentLatitude, self.currentLongitude] 
                                                             latitude:self.currentLatitude
                                                            longitude:self.currentLongitude
                                                               object:nil
                                                             pinColor:MKPinAnnotationColorGreen];
		if (self.incident.userLocation) {
			selected = userAnnotation;
		}
	}
    if (selected != nil) {
        if (centerMap) {
            [self.mapView centerAtCoordinate:selected.coordinate withDelta:0.4 animated:NO];
        }
        [self.mapView selectAnnotation:selected animated:NO];   
    }
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locations = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.location = self.incident.location;
	self.latitude = self.incident.latitude;
	self.longitude = self.incident.longitude;
    self.currentLatitude = [[Locator sharedLocator] latitude];
	self.currentLongitude = [[Locator sharedLocator] longitude];
    if (self.currentLatitude == nil && self.currentLongitude == nil) {
        [self.loadingView showWithMessage:NSLocalizedString(@"Locating...", nil)];
        [[Locator sharedLocator] detectLocationForDelegate:self];
    }
    [self.locations removeAllObjects];
    if ([[Ushahidi sharedUshahidi] hasLocations]) {
        [self.locations addObjectsFromArray:[[Ushahidi sharedUshahidi] getLocations]];
    }
    else {
        [self.locations addObjectsFromArray:[[Ushahidi sharedUshahidi] getLocationsForDelegate:self]];
    }
    [self populateMapPins:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)dealloc {
	[cancelButton release];
	[doneButton release];
	[incident release];
	[location release];
	[currentLatitude release];
	[currentLongitude release];
    [locations release];
    [super dealloc];
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi locations:(NSArray *)theLocations error:(NSError *)error hasChanges:(BOOL)hasChanges {
    if (error != nil) {
		DLog(@"error: %@", [error localizedDescription]);
		if (self.locations.count == 0) {
			[self.alertView showOkWithTitle:NSLocalizedString(@"Server Error", nil) andMessage:[error localizedDescription]];
		}
	}
	else if (hasChanges) {
		DLog(@"locations: %d", theLocations.count);
        [self.locations removeAllObjects];
        [self.locations addObjectsFromArray:theLocations];
    }
	else {
		DLog(@"No Changes: %d", theLocations.count);
	}
    [self populateMapPins:NO];
}

#pragma mark -
#pragma mark LocatorDelegate

- (void) locatorFinished:(Locator *)locator latitude:(NSString *)userLatitude longitude:(NSString *)userLongitude {
	DLog(@"locator: %@, %@", userLatitude, userLongitude);
	[self.loadingView hide];
	self.incident.userLocation = YES;
	self.latitude = userLatitude;
	self.longitude = userLongitude;
	self.currentLatitude = userLatitude;
	self.currentLongitude = userLongitude;
	[self populateMapPins:YES];
}

- (void) locatorFailed:(Locator *)locator error:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
	[self.loadingView showWithMessage:NSLocalizedString(@"Location Error", )];
	[self.loadingView hideAfterDelay:1.5];
}

- (void) lookupFinished:(Locator *)locator address:(NSString *)address {
	DLog(@"address:%@", address);
	self.location = address;
}

- (void) lookupFailed:(Locator *)locator error:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
}

#pragma mark -
#pragma mark MKMapView

- (void)mapViewDidFinishLoadingMap:(MKMapView *)theMapView {
	DLog(@"");
	for (NSObject<MKAnnotation> *annotation in theMapView.annotations) {
		if ([annotation isKindOfClass:[MapAnnotation class]]) {
			MapAnnotation *mapAnnotation = (MapAnnotation *)annotation;
			Location *theLocation = (Location *)mapAnnotation.object;
			if (theLocation != nil &&
				[theLocation.name isEqualToString:self.location] &&
				[theLocation.latitude isEqualToString:self.latitude] &&
				[theLocation.longitude isEqualToString:self.longitude]) {
				[self.mapView selectAnnotation:annotation animated:NO];
				break;
			}
			else if (theLocation == nil && self.incident.userLocation) {
				[self.mapView selectAnnotation:annotation animated:NO];
				break;
			}
		}
	}
}

- (void)mapView:(MKMapView *)theMapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	if (newState == MKAnnotationViewDragStateEnding) {
		DLog("%f, %f", annotationView.annotation.coordinate.latitude, annotationView.annotation.coordinate.longitude);
		self.latitude = [NSString stringWithFormat:@"%f", annotationView.annotation.coordinate.latitude];
		self.longitude = [NSString stringWithFormat:@"%f", annotationView.annotation.coordinate.longitude];
		self.currentLatitude = self.latitude;
		self.currentLongitude = self.longitude;
		MapAnnotation *mapAnnotation = (MapAnnotation *)annotationView.annotation;
		mapAnnotation.subtitle = [NSString stringWithFormat:@"%f, %f", annotationView.annotation.coordinate.latitude, annotationView.annotation.coordinate.longitude];
	}
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)theMapView withError:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
}

- (MKAnnotationView *) mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
	return [MKPinAnnotationView getPinForMap:theMapView andAnnotation:annotation];
}

- (void)mapView:(MKMapView *)theMapView didSelectAnnotationView:(MKAnnotationView *)annotationView {
	MapAnnotation *mapAnnotation = (MapAnnotation *)annotationView.annotation;
	DLog(@"title:%@ latitude:%f longitude:%f", mapAnnotation.title, mapAnnotation.coordinate.latitude, mapAnnotation.coordinate.longitude);
	Location *theLocation = (Location *)mapAnnotation.object;
	if (theLocation != nil) {
		self.incident.userLocation = NO;
		annotationView.draggable = NO;
		self.location = theLocation.name;
		self.latitude = theLocation.latitude;
		self.longitude = theLocation.longitude;	
	}
	else {
		self.incident.userLocation = YES;
		annotationView.draggable = YES;
		self.location = nil;
		self.latitude = [NSString stringWithFormat:@"%f", annotationView.annotation.coordinate.latitude];
		self.longitude = [NSString stringWithFormat:@"%f", annotationView.annotation.coordinate.longitude]; 
	}
}

- (void)mapView:(MKMapView *)theMapView didUpdateUserLocation:(MKUserLocation *)userLocation {
	DLog(@"latitude:%f longitude:%f", userLocation.coordinate.latitude, userLocation.coordinate.longitude);
	if (self.incident.userLocation) {
		[self.mapView centerAtCoordinate:userLocation.coordinate withDelta:0.4 animated:NO];
		[self.mapView selectAnnotation:userLocation animated:YES];	
	}
}

@end