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

#import "Locator.h"
#import "SynthesizeSingleton.h"
#import "NSObject+Extension.h"
#import "NSError+Extension.h"
#import "NSString+Extension.h"
#import "JSON.h"

@interface Locator ()

@property(nonatomic, retain) CLLocationManager *locationManager;
@property(nonatomic, retain) MKReverseGeocoder *reverseGeocoder;
@property(nonatomic, assign) id<LocatorDelegate> delegate;

- (void) reverseGeocoderFinished:(ASIHTTPRequest *)request;
- (void) reverseGeocoderFailed:(ASIHTTPRequest *)request;
- (void) reverseGeocoderViaGoogleApi;

@end

@implementation Locator

@synthesize delegate, locationManager, reverseGeocoder, latitude, longitude, address;

SYNTHESIZE_SINGLETON_FOR_CLASS(Locator);

- (id) init {
	if ((self = [super init])) {
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self;
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	}
	return self;
}

- (void)dealloc {
	delegate = nil;
	[locationManager release];
	[reverseGeocoder release];
	[latitude release];
	[longitude release];
	[super dealloc];
}

- (BOOL) hasLocation {
	return [NSString isNilOrEmpty:self.latitude] == NO && [NSString isNilOrEmpty:self.longitude] == NO;
}

- (BOOL) hasAddress {
	return [NSString isNilOrEmpty:self.address] == NO;
}

- (void)detectLocationForDelegate:(id<LocatorDelegate>)theDelegate {
	DLog(@"");
	self.delegate = theDelegate;
	[self.locationManager startUpdatingLocation];
}

- (void)lookupAddressForDelegate:(id<LocatorDelegate>)theDelegate {
	DLog(@"latitude:%@ longitude:%@", self.latitude, self.longitude);
	self.delegate = theDelegate;
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = [self.latitude floatValue];
	coordinate.longitude = [self.longitude floatValue];
	self.reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:coordinate];
	[self.reverseGeocoder setDelegate:self];
	[self.reverseGeocoder start];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if (newLocation != nil && abs([newLocation.timestamp timeIntervalSinceNow]) < 15.0) {
		self.latitude = [NSString stringWithFormat:@"%.6f", newLocation.coordinate.latitude];
		self.longitude = [NSString stringWithFormat:@"%.6f", newLocation.coordinate.longitude];
        [self dispatchSelector:@selector(locatorFinished:latitude:longitude:)
						target:self.delegate 
					   objects:self, self.latitude, self.longitude, nil];
		[self.locationManager stopUpdatingLocation];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
	[self.locationManager stopUpdatingLocation];
	[self dispatchSelector:@selector(locatorFailed:error:)
					target:self.delegate 
				   objects:self, error, nil];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
	if (placemark != nil) {
		@try {
			NSMutableString *addressString = [NSMutableString string];
			if ([NSString isNilOrEmpty:placemark.subThoroughfare] == NO) {
				[addressString appendString:placemark.subThoroughfare];
			}
			if ([NSString isNilOrEmpty:placemark.thoroughfare] == NO) {
				if ([addressString length] > 0) {
					[addressString appendString:@" "];
				}
				[addressString appendString:placemark.thoroughfare];
			}
			if ([NSString isNilOrEmpty:placemark.locality] == NO) {
				if ([addressString length] > 0) {
					[addressString appendString:@", "];
				}
				[addressString appendString:placemark.locality];
			}
			if ([NSString isNilOrEmpty:placemark.subAdministrativeArea] == NO) {
				if ([addressString length] > 0) {
					[addressString appendString:@", "];
				}
				[addressString appendString:placemark.subAdministrativeArea];
			}
			if ([NSString isNilOrEmpty:placemark.administrativeArea] == NO) {
				if ([addressString length] > 0) {
					[addressString appendString:@", "];
				}
				[addressString appendString:placemark.administrativeArea];
			}
			if ([NSString isNilOrEmpty:placemark.country] == NO) {
				if ([addressString length] > 0) {
					[addressString appendString:@", "];
				}
				[addressString appendString:placemark.country];
			}
			self.address = addressString;
			[self dispatchSelector:@selector(lookupFinished:address:)
							target:self.delegate 
						   objects:self, self.address, nil];	
		}
		@catch (NSException *e) {
			DLog(@"NSException: %@", e);
			[self reverseGeocoderViaGoogleApi];
			[self dispatchSelector:@selector(lookupFailed:error:)
							target:self.delegate 
						   objects:self, nil, nil];
		}
	}
	else {
		DLog(@"Placemark is NIL");
		[self reverseGeocoderViaGoogleApi];
		[self dispatchSelector:@selector(lookupFailed:error:)
						target:self.delegate 
					   objects:self, nil, nil];
	}
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
	[self reverseGeocoderViaGoogleApi];
	[self dispatchSelector:@selector(lookupFailed:error:)
					target:self.delegate 
				   objects:self, error, nil];
}

- (void)reverseGeocoderViaGoogleApi {
	NSString *url = [NSString stringWithFormat:
					 @"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=true",
					 self.latitude, self.longitude];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    request.delegate = self;
	[request setDidFinishSelector:@selector(reverseGeocoderFinished:)];
	[request setDidFailSelector:@selector(reverseGeocoderFailed:)];
    [request startAsynchronous];
}

- (void) reverseGeocoderFinished:(ASIHTTPRequest *)request {
	NSDictionary *json = [[request responseString] JSONValue];
	DLog(@"");
	if (json != nil && [@"OK" isEqualToString:[json objectForKey:@"status"]]) {
		NSArray *results = [json objectForKey:@"results"];
		NSDictionary *result = [results objectAtIndex:0];
		self.address = [result objectForKey:@"formatted_address"];
		[self dispatchSelector:@selector(lookupFinished:address:)
						target:self.delegate 
					   objects:self, self.address, nil];
	}
	else {
		[self dispatchSelector:@selector(lookupFailed:error:)
						target:self.delegate 
					   objects:self, nil, nil];
	}
}

- (void) reverseGeocoderFailed:(ASIHTTPRequest *)request {
	DLog(@"error: %@", [request error] != nil ? [[request error] localizedDescription] : @"NIL");
	[self dispatchSelector:@selector(lookupFailed:error:)
					target:self.delegate 
				   objects:self, [request error], nil];
}

@end
