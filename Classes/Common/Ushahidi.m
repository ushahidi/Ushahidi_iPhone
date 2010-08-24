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

#import "Ushahidi.h"
#import "SynthesizeSingleton.h"
#import "NSKeyedArchiver+Extension.h"
#import "NSKeyedUnarchiver+Extension.h"
#import "API.h"
#import "JSON.h"
#import "Instance.h"
#import "Category.h"
#import "Location.h"

@interface Ushahidi ()

@property(nonatomic, retain) API *api;
@property(nonatomic, retain) NSString *domain;

@property(nonatomic, retain) NSMutableDictionary *instances;
@property(nonatomic, retain) NSMutableDictionary *countries;
@property(nonatomic, retain) NSMutableDictionary *categories;
@property(nonatomic, retain) NSMutableDictionary *locations;
@property(nonatomic, retain) NSMutableDictionary *incidents;
@property(nonatomic, retain) NSMutableDictionary *delegates;

- (void) startAsynchronousRequest:(NSString *)url;

@end

@implementation Ushahidi

@synthesize domain, api, delegates, instances, countries, categories, locations, incidents;

SYNTHESIZE_SINGLETON_FOR_CLASS(Ushahidi);

- (id) init {
	if ((self = [super init])) {
		self.instances = [NSKeyedUnarchiver unarchiveObjectWithKey:@"instances"];
		if (self.instances == nil) self.instances = [[NSMutableDictionary alloc] init];
		
		self.countries = [NSKeyedUnarchiver unarchiveObjectWithKey:@"countries"];
		if (self.countries == nil) self.countries = [[NSMutableDictionary alloc] init];
		
		self.categories = [NSKeyedUnarchiver unarchiveObjectWithKey:@"categories"];
		if (self.categories == nil) self.categories = [[NSMutableDictionary alloc] init];
		
		self.locations = [NSKeyedUnarchiver unarchiveObjectWithKey:@"locations"];
		if (self.locations == nil) self.locations = [[NSMutableDictionary alloc] init];
		
		self.incidents = [NSKeyedUnarchiver unarchiveObjectWithKey:@"incidents"];
		if (self.incidents == nil) self.incidents = [[NSMutableDictionary alloc] init];
		
		self.delegates = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {
	[domain release];
	[instances release];
	[countries release];
	[categories release];
	[locations release];
	[incidents release];
	[self.delegates release];
	[super dealloc];
}

- (void) save {
	DLog(@"");
	[NSKeyedArchiver archiveObject:self.instances forKey:@"instances"];
	[NSKeyedArchiver archiveObject:self.countries forKey:@"countries"];
	[NSKeyedArchiver archiveObject:self.categories forKey:@"categories"];
	[NSKeyedArchiver archiveObject:self.locations forKey:@"locations"];
	[NSKeyedArchiver archiveObject:self.incidents forKey:@"incidents"];
}

- (void) loadForDomain:(NSString *)theDomain {
	if ([theDomain hasPrefix:@"http://"]) {
		self.domain = [theDomain stringByReplacingOccurrencesOfString:@"http://" withString:@""];
	}
	else if ([theDomain hasPrefix:@"https://"]) {
		self.domain = [theDomain stringByReplacingOccurrencesOfString:@"https://" withString:@""];
	}
	else {
		self.domain = theDomain;
	} 
	self.api = [[API alloc] initWithDomain:self.domain];
	DLog(@"domain: %@", self.domain);
}

#pragma mark -
#pragma mark Categories

- (NSArray *) getInstancesWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", delegate);
	if ([self.instances count] == 0) {
		[self.instances setObject:[[Instance alloc] initWithName:@"Demo Ushahidi" 
															 url:@"http://demo.ushahidi.com"
															logo:[UIImage imageNamed:@"logo_image.png"]] 
						   forKey:@"http://demo.ushahidi.com"];
		[self.instances setObject:[[Instance alloc] initWithName:@"Swine Flu Ushahidi" 
															 url:@"http://swineflu.ushahidi.com"
															logo:[UIImage imageNamed:@"logo_image.png"]] 
						   forKey:@"http://swineflu.ushahidi.com"];
	}
	return [self.instances allValues];
}

#pragma mark -
#pragma mark Categories

- (NSArray *) getCategoriesWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", delegate);
	NSString *requestURL = [self.api getCategories];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.categories allValues];
}

- (void) getCategoryByID:(NSString *)categoryID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ category:%@", delegate, categoryID);
	NSString *requestURL = [self.api getCategoryByID:categoryID];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
}

#pragma mark -
#pragma mark Countries

- (NSArray *) getCountriesWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", delegate);
	NSString *requestURL = [self.api getCountries];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.countries allValues];
}

- (void) getCountryByID:(NSString *)countryId withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ countryId:%@", delegate, countryId);
	NSString *requestURL = [self.api getCountryByID:countryId];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
}

- (void) getCountryByISO:(NSString *)countryISO withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ countryISO:%@", delegate, countryISO);
	NSString *requestURL = [self.api getCountryByISO:countryISO];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
}

- (void) getCountryByName:(NSString *)countryName withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ countryName:%@", delegate, countryName);
	NSString *requestURL = [self.api getCountryByName:countryName];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
}

#pragma mark -
#pragma mark Locations

- (NSArray *) getLocationsWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", delegate);
	NSString *requestURL = [self.api getLocations];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.locations allValues];
}

- (void) getLocationByID:(NSString *)locationID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ locationID:%@", delegate, locationID);
	NSString *requestURL = [self.api getLocationByID:locationID];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
}

- (NSArray *) getLocationsByCountryID:(NSString *)countryID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ countryID:%@", delegate, countryID);
	NSString *requestURL = [self.api getLocationsByCountryID:countryID];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.locations allValues];
}

#pragma mark -
#pragma mark Incidents

- (NSArray *) getIncidentsWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", delegate);
	NSString *requestURL = [self.api getIncidents];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.locations allValues];
}

- (void) getIncidentsCountWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", delegate);
	NSString *requestURL = [self.api getIncidentCount];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
}

- (void) getGeoGraphicMidPointWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", delegate);
	NSString *requestURL = [self.api getGeoGraphicMidPoint];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
}

- (NSArray *) getIncidentsByCategoryID:(NSString *)categoryID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ categoryID:%@", delegate, categoryID);
	NSString *requestURL = [self.api getIncidentsByCategoryID:categoryID];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.locations allValues];
}

- (NSArray *) getIncidentsByCategoryName:(NSString *)categoryName withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ categoryName:%@", delegate, categoryName);
	NSString *requestURL = [self.api getIncidentsByCategoryName:categoryName];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.locations allValues];
}

- (NSArray *) getIncidentsByLocationID:(NSString *)locationID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ locationID:%@", delegate, locationID);
	NSString *requestURL = [self.api getIncidentsByLocationID:locationID];
	[self startAsynchronousRequest:requestURL];
	return [self.locations allValues];
}

- (NSArray *) getIncidentsByLocationName:(NSString *)locationName withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ locationName:%@", delegate, locationName);
	NSString *requestURL = [self.api getIncidentsByLocationName:locationName];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.locations allValues];
}

- (NSArray *) getIncidentsBySinceID:(NSString *)sinceID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ sinceID:%@", delegate, sinceID);
	NSString *requestURL = [self.api getIncidentsBySinceID:sinceID];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.locations allValues];
}

#pragma mark -
#pragma mark ASIHTTPRequest

- (void) startAsynchronousRequest:(NSString *)url {
	DLog(@"url: %@", url);
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	[request setDelegate:self];
	[request setShouldRedirect:YES];
	[request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSString *requestURL = [request.originalURL absoluteString];
	DLog(@"request:%@", requestURL);
	DLog(@"status:%@", [request responseStatusMessage]);
	DLog(@"header: %@", [request responseHeaders]);
	DLog(@"response:%@", [request responseString]);
	id<UshahidiDelegate> delegate = [self.delegates objectForKey:requestURL];
	NSDictionary *json = [[request responseString] JSONValue];
	NSDictionary *payload = nil;
	NSError *error = nil;
	if (json == nil) {
		error = [NSError errorWithDomain:self.domain code:500 userInfo:nil];
	}
	else {
		payload = [json	objectForKey:@"payload"];
		DLog(@"payload: %@ %@", [payload class], payload);
	}
	if ([API isApiKeyUrl:requestURL]) {
		SEL selector = @selector(downloadedFromUshahidi:apiKey:error:);
		if (delegate != NULL && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self apiKey:nil error:error];
		}
	}
	else if ([API isCountriesUrl:requestURL]) {
		SEL selector = @selector(downloadedFromUshahidi:countries:error:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self countries:[self.countries allValues] error:error];
		}
	}
	else if ([API isCategoriesUrl:requestURL]) {
		NSArray *categoriesArray = [payload objectForKey:@"categories"]; 
		DLog(@"categories: %@ %@", [categoriesArray class], categoriesArray);
		for (NSDictionary *categoryDictionary in categoriesArray) {
			Category *category = [[Category alloc] initWithDictionary:[categoryDictionary objectForKey:@"category"]];
			if ([self.categories objectForKey:category.identifier] == nil) {
				[self.categories setObject:category forKey:category.identifier];
			}
			[category release];
		}
		SEL selector = @selector(downloadedFromUshahidi:categories:error:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self categories:[self.categories allValues] error:error];
		}
	}
	else if ([API isLocationsUrl:requestURL]) {
		NSArray *locationsArray = [payload objectForKey:@"locations"]; 
		DLog(@"locations: %@ %@", [locationsArray class], locationsArray);
		for (NSDictionary *locationDictionary in locationsArray) {
			Location *location = [[Location alloc] initWithDictionary:[locationDictionary objectForKey:@"location"]];
			if ([self.locations objectForKey:location.identifier] == nil) {
				[self.locations setObject:location forKey:location.identifier];
			}
			[location release];
		}
		SEL selector = @selector(downloadedFromUshahidi:locations:error:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self locations:[self.locations allValues] error:error];
		}
	}
	else if ([API isIncidentsUrl:requestURL]) {
		SEL selector = @selector(downloadedFromUshahidi:incidents:error:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self incidents:[self.incidents allValues] error:error];
		}
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	NSString *requestURL = [request.originalURL absoluteString];
	DLog(@"request:%@", requestURL);
	DLog(@"error: %@", [[request error] localizedDescription]);
	id<UshahidiDelegate> delegate = [self.delegates objectForKey:requestURL];
	if ([API isApiKeyUrl:requestURL]) {
		SEL selector = @selector(downloadedFromUshahidi:apiKey:error:);
		if (delegate != NULL && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self apiKey:nil error:[request error]];
		}
	}
	else if ([API isCountriesUrl:requestURL]) {
		SEL selector = @selector(downloadedFromUshahidi:countries:error:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self countries:nil error:[request error]];
		}
	}
	else if ([API isCategoriesUrl:requestURL]) {
		SEL selector = @selector(downloadedFromUshahidi:categories:error:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self categories:nil error:[request error]];
		}
	}
	else if ([API isLocationsUrl:requestURL]) {
		SEL selector = @selector(downloadedFromUshahidi:locations:error:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self locations:nil error:[request error]];
		}
	}
	else if ([API isIncidentsUrl:requestURL]) {
		SEL selector = @selector(downloadedFromUshahidi:incidents:error:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self incidents:nil error:[request error]];
		}
	}
}

@end
