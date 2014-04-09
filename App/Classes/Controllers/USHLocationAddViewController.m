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

#import "USHLocationAddViewController.h"
#import <Ushahidi/MKMapView+USH.h>
#import <Ushahidi/MKPinAnnotationView+USH.h>
#import <Ushahidi/UIAlertView+USH.h>
#import <Ushahidi/UIActionSheet+USH.h>
#import <Ushahidi/NSString+USH.h>
#import <Ushahidi/USHReport.h>
#import <Ushahidi/USHMap.h>

@interface USHLocationAddViewController ()

@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;

- (void) updateTitleWithLatitude:(NSNumber*)latitude longitude:(NSNumber*)longitude;

@end

@implementation USHLocationAddViewController

@synthesize map = _map;
@synthesize address = _address;
@synthesize report = _report;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize searchField = _searchField;
@synthesize cancelButton = _cancelButton;
@synthesize doneButton = _doneButton;

#pragma mark - IBActions

- (IBAction)done:(id)sender event:(UIEvent*)event {
    self.report.latitude = self.latitude;
    self.report.longitude = self.longitude;
    if (self.address != nil) {
        self.report.location = self.address;
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender event:(UIEvent*)event {
    [self dismissModalViewControllerAnimated:YES];
}

- (void) updateTitleWithLatitude:(NSNumber*)latitude longitude:(NSNumber*)longitude {
    self.navigationItem.title = [NSString stringWithFormat:@"%.4f, %.4f", latitude.floatValue, longitude.floatValue];
}

#pragma mark - UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.cancelButton.title = NSLocalizedString(@"Cancel", nil);
    self.doneButton.title = NSLocalizedString(@"Done", nil);
    self.navigationItem.title = NSLocalizedString(@"Find Location", nil);
    self.searchField.placeholder = NSLocalizedString(@"Search address...", nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.latitude = self.report.latitude;
    self.longitude = self.report.longitude;
    self.address = nil;
    if ([self.report.latitude intValue] == 0.0) {
        self.navigationItem.title = NSLocalizedString(@"Locating...", nil);
        [[USHLocator sharedInstance] locateForDelegate:self];
    }
    else {
        [self updateTitleWithLatitude:self.latitude longitude:self.longitude];
        [self.mapView removeAllPins];
        [self.mapView addPinWithTitle:self.report.location
                             subtitle:[NSString stringWithFormat:@"%@,%@", self.latitude, self.longitude]
                             latitude:self.latitude.stringValue
                            longitude:self.longitude.stringValue
                               object:nil
                             pinColor:MKPinAnnotationColorGreen];
        [self.mapView resizeRegionToFitAllPins:YES animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showMessage:NSLocalizedString(@"Double tap to move map pin to new location", nil) hide:1.5];
}

#pragma mark - USHMapViewController

- (void) mapTappedAtLatitude:(NSNumber*)latitude longitude:(NSNumber*)longitude {
    DLog(@"%@,%@", latitude, longitude);
    self.latitude = latitude;
    self.longitude = longitude;
    [self updateTitleWithLatitude:latitude longitude:longitude];
    [self.mapView removeAllPins];
    [self.mapView addPinWithTitle:self.report.location
                         subtitle:[NSString stringWithFormat:@"%@,%@", self.latitude, self.longitude]
                         latitude:self.latitude.stringValue
                        longitude:self.longitude.stringValue
                           object:nil
                         pinColor:MKPinAnnotationColorGreen];
}

- (void) userLocatedAtLatitude:(NSNumber*)latitude longitude:(NSNumber*)longitude {
    self.latitude = latitude;
    self.longitude = longitude;
    [self updateTitleWithLatitude:latitude longitude:longitude];
    [self.mapView removeAllPins];
    [self.mapView addPinWithTitle:self.report.location
                         subtitle:[NSString stringWithFormat:@"%@,%@", self.latitude, self.longitude]
                         latitude:self.latitude.stringValue
                        longitude:self.longitude.stringValue
                           object:nil
                         pinColor:MKPinAnnotationColorGreen];
    [self.mapView resizeRegionToFitAllPins:YES animated:NO];
}

#pragma mark - UIViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([NSString isNilOrEmpty:textField.text] == NO) {
        [self showLoadingWithMessage:NSLocalizedString(@"Searching...", nil)];
        [[USHLocator sharedInstance] setAddress:textField.text];
        [[USHLocator sharedInstance] geocodeForDelegate:self];
    }
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - USHLocatorDelegate

- (void) geocodeFinished:(USHLocator *)locator latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude address:(NSString *)address {
    DLog(@"%@,%@ %@", latitude, longitude, address);
    self.latitude = latitude;
    self.longitude = longitude;
    self.address = address;
    [self showLoadingWithMessage:NSLocalizedString(@"Found", nil) hide:1.0];
    [self updateTitleWithLatitude:latitude longitude:longitude];
    [self.mapView removeAllPins];
    [self.mapView addPinWithTitle:address
                         subtitle:[NSString stringWithFormat:@"%@,%@", self.latitude, self.longitude]
                         latitude:self.latitude.stringValue
                        longitude:self.longitude.stringValue
                           object:nil
                         pinColor:MKPinAnnotationColorGreen];
    [self.mapView resizeRegionToFitAllPins:YES animated:NO];
}

- (void) geocodeFailed:(USHLocator *)locator error:(NSError *)error {
    [self hideLoading];
    [self showMessage:error.localizedDescription hide:2.0];
}

@end
