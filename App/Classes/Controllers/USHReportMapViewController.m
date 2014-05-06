/*****************************************************************************
 ** Copyright (c) 2012 Ushahidi Inc
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

#import "USHReportMapViewController.h"
#import "USHReportDetailsViewController.h"
#import <Ushahidi/UIViewController+USH.h>
#import <Ushahidi/USHMap.h>
#import <Ushahidi/USHReport.h>
#import <Ushahidi/USHCategory.h>
#import <Ushahidi/MKMapView+USH.h>
#import <Ushahidi/UIAlertView+USH.h>
#import <Ushahidi/MKPinAnnotationView+USH.h>
#import <Ushahidi/USHMapAnnotation.h>
#import "USHAnalytics.h"

@interface USHReportMapViewController ()

@property (strong, nonatomic) USHMap *_map;
@property (strong, nonatomic) USHCategory *_category;

@end

@implementation USHReportMapViewController

@synthesize _map = __map;
@synthesize _category = __category;
@synthesize filterLabel = _filterLabel;
@synthesize detailsController = _detailsController;

#pragma mark - IBActions

- (IBAction)locate:(id)sender event:(UIEvent*)event {
    DLog(@"");
    if ([self.mapView respondsToSelector:@selector(userTrackingMode)]) {
        [self.mapView setUserTrackingMode:MKUserTrackingModeNone];
    }
    [self.mapView setShowsUserLocation:NO];
    [self.mapView setShowsUserLocation:YES];
}

#pragma mark - USHMap

- (USHMap*)map {
    return self._map;
}

- (void) setMap:(USHMap *)map {
    self._map = map;
    [self.mapView removeAllPins];
    for (USHReport *report in [map reportsWithCategory:self.category]) {
        [self.mapView addPinWithTitle:report.title 
                             subtitle:[report categoryTitles:@", "] 
                             latitude:[report.latitude stringValue]
                            longitude:[report.longitude stringValue]
                               object:report 
                             pinColor:MKPinAnnotationColorRed];
    }
    [self.mapView resizeRegionToFitAllPins:YES animated:NO];
}

#pragma mark - USHCategory

- (USHCategory*)category {
    return self._category;
}

- (void) setCategory:(USHCategory *)category {
    self._category = category;
    self.filterLabel.text = category != nil ? category.title : NSLocalizedString(@"All Categories", nil);
    [self.mapView removeAllPins];
    for (USHReport *report in [self.map reportsWithCategory:category]) {
        [self.mapView addPinWithTitle:report.title 
                             subtitle:[report categoryTitles:@", "] 
                             latitude:[report.latitude stringValue]
                            longitude:[report.longitude stringValue]
                               object:report 
                             pinColor:MKPinAnnotationColorRed];
    }
    [self.mapView resizeRegionToFitAllPins:YES animated:NO];
}

#pragma mark - UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.filterLabel.text = NSLocalizedString(@"All Categories", nil);
    [self.mapView removeAllPins];
    for (USHReport *report in [self.map reportsWithCategory:self.category]) {
        [self.mapView addPinWithTitle:report.title 
                             subtitle:[report categoryTitles:@", "] 
                             latitude:[report.latitude stringValue]
                            longitude:[report.longitude stringValue]
                               object:report 
                             pinColor:MKPinAnnotationColorRed];
    }
    [self.mapView resizeRegionToFitAllPins:YES animated:NO];
    
    [USHAnalytics sendScreenView:USHAnalyticsReportMapVCName];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *) mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation {
	MKPinAnnotationView *annotationView = [MKPinAnnotationView getPinForMap:map andAnnotation:annotation];
    DLog(@"%@", annotation.title);
	if ([annotation class] != MKUserLocation.class) {
		annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	}
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	USHMapAnnotation *mapAnnotation = (USHMapAnnotation *)view.annotation;
	if ([mapAnnotation class] == MKUserLocation.class) {
        [UIAlertView showWithTitle:NSLocalizedString(@"User Location", nil)
                           message:[NSString stringWithFormat:@"%f,%f", mapAnnotation.coordinate.latitude, mapAnnotation.coordinate.longitude]
                          delegate:self
                               tag:0
                            cancel:NSLocalizedString(@"OK", nil)
                           buttons:nil];
	}
	else {
		self.detailsController.map = self.map;
        self.detailsController.report = (USHReport*)mapAnnotation.object;
        self.detailsController.reports = [self.map reportsWithCategory:self.category];
        [self.navigationController pushViewController:self.detailsController animated:YES];
	}
}

- (void)mapView:(MKMapView *)map didUpdateUserLocation:(MKUserLocation *)userLocation {
	[map resizeRegionToFitAllPins:YES animated:YES];
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)map withError:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
}

@end
