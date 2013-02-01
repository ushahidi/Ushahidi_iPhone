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

#import "USHLocator.h"
#import "NSObject+USH.h"
#import "NSString+USH.h"
#import "NSError+USH.h"
#import "NSDictionary+USH.h"
#import "SBJson.h"

@interface USHLocator ()

@property(nonatomic, retain) CLLocationManager *locationManager;
@property(nonatomic, retain) CLGeocoder *geoCoder;
@property(nonatomic, retain) NSObject<USHLocatorDelegate> *delegate;

@end

SYNTHESIZE_SINGLETON_FOR_CLASS_PROTOTYPE(USHLocator);

@implementation USHLocator

SYNTHESIZE_SINGLETON_FOR_CLASS(USHLocator);

@synthesize delegate = _delegate;
@synthesize locationManager = _locationManager;
@synthesize geoCoder = _geoCoder;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize address = _address;

- (id) init {
	if ((self = [super init])) {
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self;
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.geoCoder = [[CLGeocoder alloc] init];
	}
	return self;
}

- (void)dealloc {
	[_delegate release];
	[_locationManager release];
	[_geoCoder release];
	[_latitude release];
	[_longitude release];
    [_address release];
	[super dealloc];
}

- (BOOL) hasLocation {
	return self.latitude != nil && self.longitude != nil;
}

- (BOOL) hasAddress {
	return [NSString isNilOrEmpty:self.address] == NO;
}

- (void)locateForDelegate:(id<USHLocatorDelegate>)delegate {
	DLog(@"");
	self.delegate = delegate;
	[self.locationManager startUpdatingLocation];
}

- (void)lookupForDelegate:(id<USHLocatorDelegate>)delegate {
	DLog(@"latitude:%@ longitude:%@", self.latitude, self.longitude);
	self.delegate = delegate;
    [self.geoCoder reverseGeocodeLocation:self.locationManager.location completionHandler: 
     ^(NSArray *placemarks, NSError *error) {
         if (error) {
             [self.delegate performSelectorOnMainThread:@selector(lookupFailed:error:) 
                                          waitUntilDone:YES 
                                            withObjects:self, error, nil];
         }
         else {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             DLog(@"Placemark:%@", placemark);
             NSMutableArray *items = [NSMutableArray array];
             if ([NSString isNilOrEmpty:placemark.name] == NO) {
                 [items addObject:placemark.name];
             }
             if ([NSString isNilOrEmpty:placemark.locality] == NO) {
                 [items addObject:placemark.locality];
             }
             if ([NSString isNilOrEmpty:placemark.administrativeArea] == NO) {
                 [items addObject:placemark.administrativeArea];
             }
             if ([NSString isNilOrEmpty:placemark.country] == NO) {
                 [items addObject:placemark.country];
             }
             self.address = [items componentsJoinedByString:@", "];
             [self.delegate performSelectorOnMainThread:@selector(lookupFinished:address:) 
                                          waitUntilDone:YES 
                                            withObjects:self, self.address, nil];
         }
     }];
}

- (void) stopLocate {
    DLog(@"");
    [self.locationManager stopUpdatingLocation];
}

- (void) stopLookup {
    DLog(@"");
    [self.geoCoder cancelGeocode];
}

- (void) geocodeForDelegate:(NSObject<USHLocatorDelegate>*)delegate {
    self.delegate = delegate;
    if (NSClassFromString(@"CLGeocoder")) {
        DLog(@"CLGeocoder:%@", self.address);
        CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
        [geocoder geocodeAddressString:self.address
                     completionHandler:^(NSArray *placemarks, NSError *error) {
                         if (error) {
                             [self.delegate performSelectorOnMainThread:@selector(geocodeFailed:error:)
                                                          waitUntilDone:YES
                                                            withObjects:self, error, nil];
                         }
                         else if (placemarks.count > 0) {
                             CLPlacemark *placemark = (CLPlacemark *)[placemarks objectAtIndex:0];
                             self.latitude = [NSNumber numberWithFloat:placemark.location.coordinate.latitude];
                             self.longitude = [NSNumber numberWithFloat:placemark.location.coordinate.longitude];
                             [self.delegate performSelectorOnMainThread:@selector(geocodeFinished:latitude:longitude:address:)
                                                          waitUntilDone:YES
                                                            withObjects:self, self.latitude, self.longitude, self.address, nil];
                         }
                         else {
                             NSString *message = NSLocalizedString(@"Unable to find address", nil);
                             NSError *noresults = [NSError errorWithDomain:nil code:0 message:message];
                             [self.delegate performSelectorOnMainThread:@selector(geocodeFailed:error:)
                                                          waitUntilDone:YES
                                                            withObjects:self, noresults, nil];
                         }
                     }];
    }
    else {
        DLog(@"Google:%@", self.address);
        NSString *escaped = [self.address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=%@", escaped];
        NSError *error = nil;
        NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            DLog(@"Error:%@", error);
            [self.delegate performSelectorOnMainThread:@selector(geocodeFailed:error:)
                                         waitUntilDone:YES
                                           withObjects:self, error, nil];
        }
        else {
            NSDictionary *json = [result JSONValue];
            if (json != nil) {
                DLog(@"JSON:%@", json);
                NSArray *results = [json objectForKey:@"results"];
                if (results.count > 0) {
                    NSDictionary *address = [results objectAtIndex:0];
                    NSDictionary *geometry = [address objectForKey:@"geometry"];
                    NSDictionary *location = [geometry objectForKey:@"location"];
                    NSString *latitude = [location stringForKey:@"lat"];
                    NSString *longitude = [location stringForKey:@"lng"];
                    DLog(@"%@,%@", latitude, longitude);
                    self.latitude = [NSNumber numberWithFloat:latitude.floatValue];
                    self.longitude = [NSNumber numberWithFloat:longitude.floatValue];
                    [self.delegate performSelectorOnMainThread:@selector(geocodeFinished:latitude:longitude:address:)
                                                 waitUntilDone:YES
                                                   withObjects:self, self.latitude, self.longitude, self.address, nil];
                }
            }
            else {
                NSString *message = NSLocalizedString(@"Unable to find address", nil);
                NSError *noresults = [NSError errorWithDomain:nil code:0 message:message];
                [self.delegate performSelectorOnMainThread:@selector(geocodeFailed:error:)
                                             waitUntilDone:YES
                                               withObjects:self, noresults, nil];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    DLog(@"%@", newLocation);
	if (newLocation != nil && abs([newLocation.timestamp timeIntervalSinceNow]) < 15.0) {
		self.latitude = [NSNumber numberWithDouble:newLocation.coordinate.latitude];
        self.longitude = [NSNumber numberWithDouble:newLocation.coordinate.longitude];
        [self.delegate performSelectorOnMainThread:@selector(locateFinished:latitude:longitude:) 
                                     waitUntilDone:YES 
                                       withObjects:self, self.latitude, self.longitude, nil];
		[self.locationManager stopUpdatingLocation];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	DLog(@"Error: %@", [error localizedDescription]);
	[self.locationManager stopUpdatingLocation];
    [self.delegate performSelectorOnMainThread:@selector(locateFailed:error:) 
                                 waitUntilDone:YES 
                                   withObjects:self, error, nil];
}

@end
