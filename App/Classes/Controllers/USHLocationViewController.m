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

#import "USHLocationViewController.h"
#import <Ushahidi/MKMapView+USH.h>
#import <Ushahidi/MKPinAnnotationView+USH.h>
#import <Ushahidi/UIAlertView+USH.h>
#import <Ushahidi/UIActionSheet+USH.h>

@interface USHLocationViewController ()

@property (strong, nonatomic) USHShareController *shareController;

@end

@implementation USHLocationViewController

@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize shareController = _shareController;

#pragma mark - IBActions

- (IBAction)action:(id)sender event:(UIEvent*)event {
    [self.shareController showShareForEvent:event];
}

#pragma mark - UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.shareController = [[USHShareController alloc] initWithController:self];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.shareController = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self hideLoading];
    [self.mapView removeAllPins];
    [self.mapView addPinWithTitle:self.title 
                         subtitle:[NSString stringWithFormat:@"%@,%@", self.latitude, self.longitude] 
                         latitude:[self.latitude stringValue]
                        longitude:[self.longitude stringValue]
                           object:nil 
                         pinColor:MKPinAnnotationColorRed];
    [self.mapView resizeRegionToFitAllPins:YES animated:NO];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
	[mapView resizeRegionToFitAllPins:YES animated:YES];
}

#pragma mark - USHShareController

- (void) shareOpenURL:(USHShareController*)share {
    NSString *url = [NSString stringWithFormat:@"http://maps.google.com/?q=%@,%@", self.latitude, self.longitude];
    [self.shareController openURL:url];
}

- (void) sharePrintText:(USHShareController*)share {
    UIImage *image = [self imageFromMapView];
    NSData *data = UIImageJPEGRepresentation(image, 1);
    [self.shareController printData:data title:self.title];
}

- (void) shareCopyText:(USHShareController*)share {
    NSString *url = [NSString stringWithFormat:@"http://maps.google.com/?q=%@,%@", self.latitude, self.longitude];
    [self.shareController copyText:url];
}

- (void) shareSendSMS:(USHShareController*)share {
    NSString *sms = [NSString stringWithFormat:@"%@ http://maps.google.com/?q=%@,%@", self.title, self.latitude, self.longitude];
    [self.shareController sendSMS:sms];
}

- (void) shareSendEmail:(USHShareController*)share {
    UIImage *image = [self imageFromMapView];
    NSData *data = UIImageJPEGRepresentation(image, 1);
    NSString *url = [NSString stringWithFormat:@"http://maps.google.com/?q=%@,%@", self.latitude, self.longitude];
    NSString *email = [NSString stringWithFormat:@"%@<br/><a href='%@'>%@</a>", self.title, url, url, nil];
    [self.shareController sendEmail:email subject:self.title attachment:data fileName:@"map.jpg" recipient:nil];
}

- (void) shareSendTweet:(USHShareController*)share {
    UIImage *image = [self imageFromMapView];
    NSString *url = [NSString stringWithFormat:@"http://maps.google.com/?q=%@,%@", self.latitude, self.longitude];
    [self.shareController sendTweet:self.title url:url image:image];
}

- (void) sharePostFacebook:(USHShareController*)share {
    UIImage *image = [self imageFromMapView];
    NSString *url = [NSString stringWithFormat:@"http://maps.google.com/?q=%@,%@", self.latitude, self.longitude];
    [self.shareController postFacebook:self.title url:url image:image];
}

@end
