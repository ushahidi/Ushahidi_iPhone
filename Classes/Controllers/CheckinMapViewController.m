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
#import "CheckinTabViewController.h"
#import "CheckinAddViewController.h"
#import "CheckinDetailsViewController.h"
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

@property(nonatomic,retain) NSMutableArray *allCheckins;
@property(nonatomic,retain) NSMutableArray *filteredCheckins;
@property(nonatomic,retain) NSMutableArray *users;
@property(nonatomic,retain) User *user;

@end

@implementation CheckinMapViewController

@synthesize checkinTabViewController, checkinAddViewController, checkinDetailsViewController;
@synthesize deployment, users, user, allCheckins, filteredCheckins;

#pragma mark -
#pragma mark Handlers

- (IBAction) addCheckin:(id)sender {
	DLog(@"");
	[self presentModalViewController:self.checkinAddViewController animated:YES];
}

- (IBAction) refresh:(id)sender {
	self.refreshButton.enabled = NO;
	[self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];
	[[Ushahidi sharedUshahidi] getCheckinsForDelegate:self];
}

- (IBAction) filterChanged:(id)sender event:(UIEvent*)event {
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
	DLog(@"refresh:%d resize:%d", refresh, resize);
	if (refresh) {
		[self.allCheckins removeAllObjects];
		[self.allCheckins addObjectsFromArray:[[Ushahidi sharedUshahidi] getCheckinsForDelegate:self]];
		[self.filterLabel setText:NSLocalizedString(@"Last Checkin For Each User", nil)];
	}
	else if (self.user != nil) {
		[self.allCheckins removeAllObjects];
		[self.allCheckins addObjectsFromArray:[[Ushahidi sharedUshahidi] getCheckins]];
		[self.filterLabel setText:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"All Checkins By", nil), self.user.name]];
	}
	else {
		[self.allCheckins removeAllObjects];
		[self.allCheckins addObjectsFromArray:[[Ushahidi sharedUshahidi] getCheckins]];
		[self.filterLabel setText:NSLocalizedString(@"Last Checkin For Each User", nil)];
	}
	[self.users removeAllObjects];
	if ([[Ushahidi sharedUshahidi] hasUsers]) {
		[self.users addObjectsFromArray:[[Ushahidi sharedUshahidi] getUsers]];
	}
	[self.filteredCheckins removeAllObjects];
	if (self.user == nil) {
		NSMutableDictionary *checkins = [NSMutableDictionary dictionary];
		for (Checkin *checkin in self.allCheckins) {
			if ([NSString isNilOrEmpty:checkin.user] == NO) {
				Checkin *existing = [checkins objectForKey:checkin.user];
				if (existing == nil) {
					[checkins setObject:checkin forKey:checkin.user];
				}
				else if ([checkin.date compare:existing.date] == NSOrderedDescending) {
					[checkins setObject:checkin forKey:checkin.user];
				}
			}
		}	
		[self.filteredCheckins addObjectsFromArray:[checkins allValues]];
	}
	else {
		for (Checkin *checkin in self.allCheckins) {
			if ([self.user.identifier isEqualToString:[checkin user]]) {
				[self.filteredCheckins addObject:checkin];
			}
		}
	}
	[self.mapView removeAllPins];
	for (Checkin *checkin in self.filteredCheckins) {
		for (User *theUser in self.users) {
			if ([theUser.identifier isEqualToString:checkin.user]) {
				//DLog(@"%@ %@ by %@ on %@", checkin.identifier, checkin.message, theUser.name, checkin.dateTimeString);
				break;
			}
		}
		[self.mapView addPinWithTitle:checkin.message 
							 subtitle:checkin.dateTimeString 
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
	self.users = [[NSMutableArray alloc] initWithCapacity:0];
	self.allCheckins = [[NSMutableArray alloc] initWithCapacity:0];
	self.filteredCheckins = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.deployment != nil) {
		self.title = self.deployment.name;
	}
	else {
		self.title = NSLocalizedString(@"Checkins", nil);
	}
	[self populate:self.willBePushed resize:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainQueueFinished) name:kMainQueueFinished object:nil];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kMainQueueFinished object:nil];
}

- (void)dealloc {
	[checkinAddViewController release];
	[checkinDetailsViewController release];
	[deployment release];
	[allCheckins release];
	[filteredCheckins release];
	[users release];
	[user release];
    [super dealloc];
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadingFromUshahidi:(Ushahidi *)ushahidi checkins:(NSArray *)checkins {
	[self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi checkins:(NSArray *)theCheckins error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if (error != nil) {
		DLog(@"error: %d %@", [error code], [error localizedDescription]);
	}
	else if (hasChanges) {
		DLog(@"Re-Adding Checkins: %d", [theCheckins count]);
		[self.allCheckins removeAllObjects];
		[self.allCheckins addObjectsFromArray:theCheckins];
		[self populate:NO resize:YES];
	}
	else {
		DLog(@"No Changes Checkins");
	}
	[self.loadingView hide];
	self.refreshButton.enabled = YES;
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi users:(NSArray *)theUsers error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if (error != nil) {
		DLog(@"error: %d %@", [error code], [error localizedDescription]);
	}
	else if (hasChanges) {
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
		[self.alertView showOkWithTitle:NSLocalizedString(@"User Location", nil) 
							 andMessage:[NSString stringWithFormat:@"%f, %f", mapAnnotation.coordinate.latitude, mapAnnotation.coordinate.longitude]];
	}
	else {
		DLog(@"title:%@ latitude:%f longitude:%f", mapAnnotation.title, mapAnnotation.coordinate.latitude, mapAnnotation.coordinate.longitude);
		self.checkinDetailsViewController.checkin = (Checkin *)mapAnnotation.object; 
		self.checkinDetailsViewController.checkins = self.filteredCheckins;
		[self.checkinTabViewController.navigationController pushViewController:self.checkinDetailsViewController animated:YES];
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
	[self populate:NO resize:YES];
}

@end
