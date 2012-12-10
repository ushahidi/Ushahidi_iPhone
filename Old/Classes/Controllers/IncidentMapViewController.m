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
#import "Settings.h"

@interface IncidentMapViewController ()

@end

@implementation IncidentMapViewController

@synthesize incidentAddViewController;
@synthesize incidentDetailsViewController;
@synthesize incidentTabViewController;

#pragma mark -
#pragma mark Handlers

- (void) populate:(NSArray*)items filter:(NSObject*)theFilter {
    DLog(@"");
    self.filter = theFilter;
    [self.allPins removeAllObjects];
    [self.allPins addObjectsFromArray:items];
    
    [self.pendingPins removeAllObjects];
    [self.pendingPins addObjectsFromArray:[[Ushahidi sharedUshahidi] getIncidentsPending]];
    
    self.mapView.showsUserLocation = NO;
	[self.mapView removeAllPins];
	self.mapView.showsUserLocation = YES;
	
    if (self.filter != nil) {
        Category *category = (Category*)self.filter;
        [self.filterLabel setText:category.title]; 
    }
    else {
        [self.filterLabel setText:NSLocalizedString(@"All Categories", nil)];
    }
    
	for (Incident *incident in self.allPins) {
        if (self.filter == nil || [incident hasCategory:(Category*)self.filter]) {
			[self.mapView addPinWithTitle:incident.title 
								 subtitle:incident.dateString 
								 latitude:incident.latitude 
								longitude:incident.longitude
								   object:incident
								 pinColor:MKPinAnnotationColorRed];
		}
	}
	for (Incident *incident in self.pendingPins) {
		[self.mapView addPinWithTitle:incident.title 
							 subtitle:incident.dateString 
							 latitude:incident.latitude 
							longitude:incident.longitude 
							   object:incident
							 pinColor:MKPinAnnotationColorPurple];
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
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)dealloc {
	[super dealloc];
}

#pragma mark -
#pragma mark MKMapView

- (MKAnnotationView *) mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation {
	MKPinAnnotationView *annotationView = [MKPinAnnotationView getPinForMap:map andAnnotation:annotation];
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
            [self.incidentAddViewController load:incident];
            self.incidentAddViewController.modalPresentationStyle = UIModalPresentationPageSheet;
            self.incidentAddViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            self.incidentAddViewController.navigationItem.backBarButtonItem.title = NSLocalizedString(@"Reports", nil);
			[self.incidentTabViewController presentModalViewController:self.incidentAddViewController animated:YES];
		}
		else {
			self.incidentDetailsViewController.incident = (Incident *)mapAnnotation.object; 
			self.incidentDetailsViewController.incidents = self.allPins;
			self.incidentTabViewController.navigationItem.backBarButtonItem.title = NSLocalizedString(@"Reports", nil);
			[self.incidentTabViewController.navigationController pushViewController:self.incidentDetailsViewController animated:YES];
		}
	}
}

- (void)mapView:(MKMapView *)map didUpdateUserLocation:(MKUserLocation *)userLocation {
	[map resizeRegionToFitAllPins:NO animated:YES];
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)map withError:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
}

@end
