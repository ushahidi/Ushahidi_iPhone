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
	if (self.latitude != nil && self.longitude != nil) {
		[self dispatchSelector:@selector(locatorFinished:latitude:longitude:)
						target:self.delegate 
					   objects:self, self.latitude, self.longitude, nil];	
	}
	[self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (abs([newLocation.timestamp timeIntervalSinceNow]) < 15.0) {
		self.latitude = [NSString stringWithFormat:@"%.6f", newLocation.coordinate.latitude];
		self.longitude = [NSString stringWithFormat:@"%.6f", newLocation.coordinate.longitude];
        [self dispatchSelector:@selector(locatorFinished:latitude:longitude:)
						target:self.delegate 
					   objects:self, self.latitude, self.longitude, nil];
		[self.locationManager stopUpdatingLocation];
	}
}

- (void)lookupAddressForDelegate:(id<LocatorDelegate>)theDelegate {
	DLog(@"latitude:%@ longitude:%@", self.latitude, self.longitude);
	self.delegate = theDelegate;
	if (self.address != nil) {
		[self dispatchSelector:@selector(lookupFinished:address:)
						target:self.delegate 
					   objects:self, self.address, nil];	
	}
	CLLocationCoordinate2D coordinate;
	coordinate.longitude = [self.latitude floatValue];
	coordinate.latitude = [self.longitude floatValue];
	self.reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:coordinate];
	[self.reverseGeocoder setDelegate:self];
	[self.reverseGeocoder start];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	[self.locationManager stopUpdatingLocation];
	[self dispatchSelector:@selector(locatorFailed:error:)
					target:self.delegate 
				   objects:self, error, nil];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
	DLog(@"%@", [placemark addressDictionary]);
	if (placemark != nil) {
		NSDictionary *addressDictionary = [placemark addressDictionary];
		if (addressDictionary != nil) {
			NSString *street = [addressDictionary objectForKey:@"street"];
			NSString *city = [addressDictionary objectForKey:@"city"];
			NSString *state = [addressDictionary objectForKey:@"state"];
			NSString *country = [addressDictionary objectForKey:@"country"];
			NSMutableString *addressString = [NSMutableString string];
			if ([NSString isNilOrEmpty:street]) {
				[addressString appendString:street];
			}
			if ([NSString isNilOrEmpty:city]) {
				if ([addressString length] > 0) {
					[addressString appendString:@", "];
				}
				[addressString appendString:city];
			}
			if ([NSString isNilOrEmpty:state]) {
				if ([addressString length] > 0) {
					[addressString appendString:@", "];
				}
				[addressString appendString:state];
			}
			if ([NSString isNilOrEmpty:country]) {
				if ([addressString length] > 0) {
					[addressString appendString:@", "];
				}
				[addressString appendString:country];
			}
			self.address = addressString;
			[self dispatchSelector:@selector(lookupFinished:street:city:state:country:)
							target:self.delegate 
						   objects:self, self.address, nil];	
		}
		else {
			[self dispatchSelector:@selector(lookupFailed:error:)
							target:self.delegate 
						   objects:self, nil, nil];
		}
	}
	else {
		[self reverseGeocoderViaGoogleApi];
		[self dispatchSelector:@selector(lookupFailed:error:)
						target:self.delegate 
					   objects:self, nil, nil];
	}
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	DLog(@"%@", [error localizedDescription]);
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
		[self dispatchSelector:@selector(lookupFinished:address:)
						target:self.delegate 
					   objects:self, [result objectForKey:@"formatted_address"], nil];
	}
	else {
		[self dispatchSelector:@selector(lookupFailed:error:)
						target:self.delegate 
					   objects:self, nil, nil];
	}
}

- (void) reverseGeocoderFailed:(ASIHTTPRequest *)request {
	DLog(@"%@", [[request error] localizedDescription]);
	[self dispatchSelector:@selector(lookupFailed:error:)
					target:self.delegate 
				   objects:self, [request error], nil];
}

@end
