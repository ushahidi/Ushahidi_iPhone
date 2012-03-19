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

@interface CheckinMapViewController ()

@end

@implementation CheckinMapViewController

@synthesize checkinTabViewController;
@synthesize checkinAddViewController;
@synthesize checkinDetailsViewController;
@synthesize deployment;

#pragma mark -
#pragma mark Handlers

- (void) populate:(NSArray*)items filter:(NSObject*)theFilter {
    self.filter = theFilter;
    User *user = (User*)self.filter;
    [self.allPins removeAllObjects];
    [self.allPins addObjectsFromArray:items];
    [self.filteredPins removeAllObjects];
	if (user != nil) {
		[self.filterLabel setText:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"All Checkins By", nil), user.name]];
        for (Checkin *checkin in self.allPins) {
			if ([user.identifier isEqualToString:[checkin user]]) {
				[self.filteredPins addObject:checkin];
			}
		}
	}
	else {
		[self.filterLabel setText:NSLocalizedString(@"Last Checkin For Each User", nil)];
        NSMutableDictionary *checkins = [NSMutableDictionary dictionary];
		for (Checkin *checkin in self.allPins) {
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
		[self.filteredPins addObjectsFromArray:[checkins allValues]];
	}
    [self.mapView removeAllPins];
    NSArray *users = [[Ushahidi sharedUshahidi] getUsers];
    for (Checkin *checkin in self.filteredPins) {
        NSMutableString *subtitle = [NSMutableString string];
        for (User *user in users) {
            if ([user.identifier isEqualToString:[checkin user]]) {
                if ([NSString isNilOrEmpty:user.name]) {
                    [subtitle appendFormat:@"%@ - ", NSLocalizedString(@"Unknown", nil)];
                }
                else {
                    [subtitle appendFormat:@"%@ - ", user.name]; 
                }
                break;
            }
        }
        [subtitle appendString:checkin.dateTimeString];
        [self.mapView addPinWithTitle:checkin.message 
							 subtitle:subtitle 
							 latitude:checkin.latitude 
							longitude:checkin.longitude 
							   object:checkin
							 pinColor:MKPinAnnotationColorRed];
	}
	[self.mapView resizeRegionToFitAllPins:NO animated:YES];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)dealloc {
	[checkinAddViewController release];
	[checkinDetailsViewController release];
	[deployment release];
	[super dealloc];
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
		self.checkinDetailsViewController.checkins = self.filteredPins;
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

@end
