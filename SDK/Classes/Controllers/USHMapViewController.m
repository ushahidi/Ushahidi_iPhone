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

#import "USHMapViewController.h"
#import "UIViewController+USH.h"
#import "MKMapView+USH.h"
#import "UIActionSheet+USH.h"
#import "USHLoadingView.h"
#import "USHDevice.h"

@interface USHMapViewController ()

@property (strong, nonatomic) NSString *textRoadMap;
@property (strong, nonatomic) NSString *textSatelliteMap;
@property (strong, nonatomic) NSString *textHybridMap;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

- (void)doubleTapGesture:(UIGestureRecognizer *)gestureRecognizer;

@end

@implementation USHMapViewController

@synthesize mapView = _mapView;
@synthesize flipView = _flipView;
@synthesize titleView = _titleView;
@synthesize mapType = _mapType;
@synthesize infoButton = _infoButton;

@synthesize textRoadMap = _textRoadMap;
@synthesize textSatelliteMap = _textSatelliteMap;
@synthesize textHybridMap = _textHybridMap;

@synthesize tapGestureRecognizer = _tapGestureRecognizer;

#pragma mark - UIToolBar

- (void) adjustToolBarHeight {
    if ([USHDevice isIPad] && self.toolBar != nil && self.mapView != nil) {
        NSInteger tabBarHeight = 49;
        CGRect toolBarFrame = self.toolBar.frame;
        toolBarFrame.size.height = tabBarHeight;
        toolBarFrame.origin.y = self.view.frame.size.height - tabBarHeight;
        self.toolBar.frame = toolBarFrame;
        CGRect mapViewFrame = self.mapView.frame;
        mapViewFrame.size.height = self.view.frame.size.height - self.mapView.frame.origin.y - tabBarHeight;
        self.mapView.frame = mapViewFrame;
    }
}

#pragma mark - IBActions

- (IBAction)locate:(id)sender event:(UIEvent*)event { 
    DLog(@"");
    [self showLoadingWithMessage:NSLocalizedString(@"Locating...", nil)];
    [[USHLocator sharedInstance] locateForDelegate:self];
//    [self.mapView.userLocation addObserver:self forKeyPath:@"location" options:NSKeyValueObservingOptionNew context:nil];
//    [self showLoadingWithMessage:NSLocalizedString(@"Locating...", nil)];
//    if ([self.mapView respondsToSelector:@selector(userTrackingMode)]) {
//        self.mapView.userTrackingMode = MKUserTrackingModeNone;
//    }
//    self.mapView.showsUserLocation = NO;
//    self.mapView.showsUserLocation = YES;
//    if (self.mapView.userLocationVisible) {
//        [self hideLoadingAfterDelay:2.0];
//    }
}

- (IBAction)style:(id)sender event:(UIEvent*)event {
    [UIActionSheet showWithTitle:nil 
                        delegate:self 
                           event:event 
                          cancel:NSLocalizedString(@"Cancel", nil) 
                         buttons:self.textRoadMap, self.textSatelliteMap, self.textHybridMap, nil];
}

- (IBAction) mapTypeChanged:(id)sender event:(UIEvent*)event {
    DLog(@"");
	self.mapView.mapType = self.mapType.selectedSegmentIndex;
    [self animatePageCurlDown:0.5];
}

- (IBAction) mapTypeCancelled:(id)sender event:(UIEvent*)event {
    DLog(@"");
    [self animatePageCurlDown:0.5];
}

- (IBAction) showMapType:(id)sender event:(UIEvent*)event {
    DLog(@"");
    self.mapType.selectedSegmentIndex = self.mapView.mapType;
    [self animatePageCurlUp:0.5];
}

#pragma mark - UIViewController

- (void)dealloc {
    [_mapView release];
    [_titleView release];
    [_flipView release];
    [_mapType release];
    [_infoButton release];
    [_textHybridMap release];
    [_textRoadMap release];
    [_textSatelliteMap release];
    [_tapGestureRecognizer release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.flipView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern.png"]]];
    self.textRoadMap = NSLocalizedString(@"Road Map", nil);
    self.textSatelliteMap = NSLocalizedString(@"Satellite Map", nil);
    self.textHybridMap = NSLocalizedString(@"Hybrid Map", nil);
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesture:)];
    self.tapGestureRecognizer.numberOfTapsRequired = 2;
    self.tapGestureRecognizer.numberOfTouchesRequired = 1;
    self.tapGestureRecognizer.cancelsTouchesInView = NO;
    self.tapGestureRecognizer.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.mapView addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self isTopView:self.flipView]) {
        [self animatePageCurlDown:0.0];
    }
    [self.mapView removeGestureRecognizer:self.tapGestureRecognizer];
    self.mapView.showsUserLocation = NO;
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"location"] && self.mapView.userLocation.location != nil) {
        DLog(@"%@ :%@", keyPath, change);
        [self hideMessageIfEquals:NSLocalizedString(@"Locating...", nil)];
        [self.mapView.userLocation removeObserver:self forKeyPath:@"location"];
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    DLog(@"%f,%f", userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    NSNumber *latitude = [NSNumber numberWithFloat:userLocation.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithFloat:userLocation.coordinate.longitude];
    [self userLocatedAtLatitude:latitude longitude:longitude];
	[mapView resizeRegionToFitAllPins:YES animated:YES];
    [self hideLoading];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:self.textRoadMap]) {
        self.mapView.mapType = MKMapTypeStandard;
    }
    else if ([title isEqualToString:self.textSatelliteMap]) {
        self.mapView.mapType = MKMapTypeSatellite;
    }
    else if ([title isEqualToString:self.textHybridMap]) {
        self.mapView.mapType = MKMapTypeHybrid;
    }
}

#pragma mark - Helpers

- (UIImage*) imageFromMapView {
    UIGraphicsBeginImageContext(self.mapView.bounds.size);
    [self.mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - UIGestureRecognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)doubleTapGesture:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [gestureRecognizer locationInView:self.mapView];
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
        DLog("%f, %f", coordinate.latitude, coordinate.longitude);
        NSNumber *latitude = [NSNumber numberWithFloat:coordinate.latitude];
        NSNumber *longitude = [NSNumber numberWithFloat:coordinate.longitude];
        [self mapTappedAtLatitude:latitude longitude:longitude];
    }
}

- (void) userLocatedAtLatitude:(NSNumber*)latitude longitude:(NSNumber*)longitude {
    //Child will override this method
}

- (void) mapTappedAtLatitude:(NSNumber*)latitude longitude:(NSNumber*)longitude {
    //Child will override this method
}

#pragma mark - USHLocatorDelegate

- (void) locateFinished:(USHLocator *)locator latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude {
    DLog(@"%@,%@", latitude, longitude);
    [self hideMessageIfEquals:NSLocalizedString(@"Locating...", nil)];
    [self userLocatedAtLatitude:latitude longitude:longitude];
}

- (void) locateFailed:(USHLocator *)locator error:(NSError *)error {
    DLog(@"Error:%@", error.localizedDescription);
    [self showMessage:error.localizedDescription hide:2.0];
}

- (void) lookupFinished:(USHLocator *)locator address:(NSString *)address {
    DLog(@"Address:%@", address);
}

- (void) lookupFailed:(USHLocator *)locator error:(NSError *)error {
    DLog(@"Error:%@", error.localizedDescription);
    [self hideLoading];
    [self showMessage:error.localizedDescription hide:2.0];
}

@end
