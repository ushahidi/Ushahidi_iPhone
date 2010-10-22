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
#import "Deployment.h"
#import "Category.h"
#import "Location.h"
#import "Country.h"
#import "Incident.h"
#import "Photo.h"
#import "Settings.h"

@interface Ushahidi ()

@property(nonatomic, retain) API *api;
@property(nonatomic, retain) NSString *domain;

@property(nonatomic, retain) NSMutableDictionary *deployments;
@property(nonatomic, retain) NSMutableDictionary *countries;
@property(nonatomic, retain) NSMutableDictionary *categories;
@property(nonatomic, retain) NSMutableDictionary *locations;
@property(nonatomic, retain) NSMutableDictionary *incidents;
@property(nonatomic, retain) NSMutableArray *pending;
@property(nonatomic, retain) NSMutableDictionary *delegates;

- (void) startAsynchronousRequest:(NSString *)url;
- (void) notifyDelegate:(id<UshahidiDelegate>)delegate;

@end

@implementation Ushahidi

@synthesize domain, api, delegates, deployments, countries, categories, locations, incidents, pending;

SYNTHESIZE_SINGLETON_FOR_CLASS(Ushahidi);

- (id) init {
	if ((self = [super init])) {
		self.deployments = [NSKeyedUnarchiver unarchiveObjectWithKey:@"deployments"];
		if (self.deployments == nil) self.deployments = [[NSMutableDictionary alloc] init];
		
		self.countries = [NSKeyedUnarchiver unarchiveObjectWithKey:@"countries"];
		if (self.countries == nil) self.countries = [[NSMutableDictionary alloc] init];
		
		self.categories = [NSKeyedUnarchiver unarchiveObjectWithKey:@"categories"];
		if (self.categories == nil) self.categories = [[NSMutableDictionary alloc] init];
		
		self.locations = [NSKeyedUnarchiver unarchiveObjectWithKey:@"locations"];
		if (self.locations == nil) self.locations = [[NSMutableDictionary alloc] init];
		
		self.incidents = [NSKeyedUnarchiver unarchiveObjectWithKey:@"incidents"];
		if (self.incidents == nil) self.incidents = [[NSMutableDictionary alloc] init];
		
		self.pending = [NSKeyedUnarchiver unarchiveObjectWithKey:@"pending"];
		if (self.pending == nil) self.pending = [[NSMutableArray alloc] init];
		
		self.delegates = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {
	[domain release];
	[deployments release];
	[countries release];
	[categories release];
	[locations release];
	[incidents release];
	[delegates release];
	[super dealloc];
}

- (void) save {
	DLog(@"");
	[NSKeyedArchiver archiveObject:self.deployments forKey:@"deployments"];
	[NSKeyedArchiver archiveObject:self.countries forKey:@"countries"];
	[NSKeyedArchiver archiveObject:self.categories forKey:@"categories"];
	[NSKeyedArchiver archiveObject:self.locations forKey:@"locations"];
	[NSKeyedArchiver archiveObject:self.incidents forKey:@"incidents"];
	[NSKeyedArchiver archiveObject:self.pending forKey:@"pending"];
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

- (BOOL)addDeployment:(Deployment *)deployment {
	if (deployment != nil) {
		[self.deployments setObject:deployment forKey:deployment.url];
		return YES;
	}
	return NO;
}

- (BOOL)addDeploymentByName:(NSString *)name andUrl:(NSString *)url {
	if (name != nil && [name length] > 0 && url != nil && [url length] > 0) {
		Deployment *deployment = [[Deployment alloc] initWithName:name 
															  url:url
															 logo:[UIImage imageNamed:@"logo_image.png"]];
		[self.deployments setObject:deployment forKey:url];
		return YES;
	}
	return NO;
}

- (BOOL)addIncident:(Incident *)incident {
	if (incident != nil) {
		[self.pending addObject:incident];
		//[self.incidents setObject:incident forKey:incident.identifier];
		return [self uploadIncident:incident];
	}
	return NO;
}

- (BOOL) uploadIncident:(Incident *)incident {
	@try {
		NSString *postUrl = [self.api getPostReport];
		DLog(@"POST: %@", postUrl);
		ASIFormDataRequest *post = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:postUrl]];
		[post setDelegate:self];
		[post setShouldRedirect:YES];
		[post setPostValue:@"report" forKey:@"task"];
		[post setPostValue:@"json" forKey:@"resp"];
		[post setPostValue:[incident title] forKey:@"incident_title"];
		[post setPostValue:[incident description] forKey:@"incident_description"];
		[post setPostValue:[incident dateDayMonthYear] forKey:@"incident_date"];
		[post setPostValue:[incident dateHour] forKey:@"incident_hour"];
		[post setPostValue:[incident dateMinute] forKey:@"incident_minute"];
		[post setPostValue:[incident dateAmPm] forKey:@"incident_ampm"];
		[post setPostValue:[incident categoryNames] forKey:@"incident_category"];
		[post setPostValue:[incident location] forKey:@"location_name"];
		[post setPostValue:[incident latitude] forKey:@"latitude"];
		[post setPostValue:[incident longitude] forKey:@"longitude"];
		[post setPostValue:[[Settings sharedSettings] firstName] forKey:@"person_first"];
		[post setPostValue:[[Settings sharedSettings] lastName] forKey:@"person_last"];
		[post setPostValue:[[Settings sharedSettings] email] forKey:@"person_email"];
		
		DLog(@"dateDayMonthYear: %@", [incident dateDayMonthYear]);
		DLog(@"dateHour: %@", [incident dateHour]);
		DLog(@"dateMinute: %@", [incident dateMinute]);
		DLog(@"dateAmPm: %@", [incident dateAmPm]);
		
		for(Photo *photo in incident.photos) {
			[post addData:[photo getData] forKey:@"incident_photo[]"];
		}
		[post startAsynchronous];
		return YES;
	}
	@catch (NSException *e) {
		DLog(@"%@", e);
	}
	return NO;
}

#pragma mark -
#pragma mark Categories

- (NSArray *) getDeploymentsWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", delegate);
	if ([self.deployments count] == 0) {
		[self.deployments setObject:[[Deployment alloc] initWithName:@"Demo Ushahidi" 
																 url:@"http://demo.ushahidi.com"
																logo:[UIImage imageNamed:@"logo_image.png"]] 
															  forKey:@"http://demo.ushahidi.com"];
	}
	[self performSelector:@selector(notifyDelegate:) withObject:delegate afterDelay:2.0];
	return [self.deployments allValues];
}

- (void) notifyDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"");
	SEL selector = @selector(downloadedFromUshahidi:deployments:error:hasChanges:);
	if (delegate != NULL && [delegate respondsToSelector:selector]) {
		[delegate downloadedFromUshahidi:self deployments:[self.deployments allValues] error:nil hasChanges:NO];
	}
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

- (Category *) getCategoryByID:(NSString *)categoryID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ category:%@", delegate, categoryID);
	NSString *requestURL = [self.api getCategoryByID:categoryID];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.categories objectForKey:categoryID];
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

- (Country *) getCountryByID:(NSString *)countryId withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ countryId:%@", delegate, countryId);
	NSString *requestURL = [self.api getCountryByID:countryId];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.countries objectForKey:countryId];
}

- (Country *) getCountryByISO:(NSString *)countryISO withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ countryISO:%@", delegate, countryISO);
	NSString *requestURL = [self.api getCountryByISO:countryISO];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	for (Country *country in [self.countries allValues]) {
		if ([country.iso isEqualToString:countryISO]) {
			return country;
		}
	}
	return nil;
}

- (Country *) getCountryByName:(NSString *)countryName withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ countryName:%@", delegate, countryName);
	NSString *requestURL = [self.api getCountryByName:countryName];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	for (Country *country in [self.countries allValues]) {
		if ([country.name isEqualToString:countryName]) {
			return country;
		}
	}
	return nil;
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

- (Location *) getLocationByID:(NSString *)locationID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ locationID:%@", delegate, locationID);
	NSString *requestURL = [self.api getLocationByID:locationID];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.locations objectForKey:locationID];
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

- (void) getGeoGraphicMidPointWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", delegate);
	NSString *requestURL = [self.api getGeoGraphicMidPoint];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
}

- (NSArray *) getIncidentsWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", delegate);
	NSString *requestURL = [self.api getIncidents];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.incidents allValues];
}

- (NSInteger) getIncidentsCountWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", delegate);
	NSString *requestURL = [self.api getIncidentCount];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.incidents count];
}

- (NSArray *) getIncidentsByCategoryID:(NSString *)categoryID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ categoryID:%@", delegate, categoryID);
	NSString *requestURL = [self.api getIncidentsByCategoryID:categoryID];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.incidents allValues];
}

- (NSArray *) getIncidentsByCategoryName:(NSString *)categoryName withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ categoryName:%@", delegate, categoryName);
	NSString *requestURL = [self.api getIncidentsByCategoryName:categoryName];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.incidents allValues];
}

- (NSArray *) getIncidentsByLocationID:(NSString *)locationID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ locationID:%@", delegate, locationID);
	NSString *requestURL = [self.api getIncidentsByLocationID:locationID];
	[self startAsynchronousRequest:requestURL];
	return [self.incidents allValues];
}

- (NSArray *) getIncidentsByLocationName:(NSString *)locationName withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ locationName:%@", delegate, locationName);
	NSString *requestURL = [self.api getIncidentsByLocationName:locationName];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.incidents allValues];
}

- (NSArray *) getIncidentsBySinceID:(NSString *)sinceID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ sinceID:%@", delegate, sinceID);
	NSString *requestURL = [self.api getIncidentsBySinceID:sinceID];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.incidents allValues];
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
	id<UshahidiDelegate> delegate = [self.delegates objectForKey:requestURL];
	NSDictionary *json = [[request responseString] JSONValue];
	NSDictionary *payload = nil;
	NSError *error = nil;
	if (json == nil) {
		error = [NSError errorWithDomain:self.domain code:500 userInfo:nil];
	}
	else {
		payload = [json	objectForKey:@"payload"];
		//DLog(@"payload: %@ %@", [payload class], payload);
	}
	if ([request isKindOfClass:[ASIFormDataRequest class]]) {
		DLog(@"#################### POST ####################");
		DLog(@"response: %@", [request responseString]);
	}
	else if ([API isApiKeyUrl:requestURL]) {
		SEL selector = @selector(downloadedFromUshahidi:apiKey:error:hasChanges:);
		if (delegate != NULL && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self apiKey:nil error:error hasChanges:YES];
		}
	}
	else if ([API isCountriesUrl:requestURL]) {
		NSArray *countriesArray = [payload objectForKey:@"countries"]; 
		//DLog(@"countries: %@ %@", [countriesArray class], countriesArray);
		BOOL hasChanges = NO;
		for (NSDictionary *countryDictionary in countriesArray) {
			Country *country = [[Country alloc] initWithDictionary:[countryDictionary objectForKey:@"country"]];
			if (country.identifier != nil && [self.countries objectForKey:country.identifier] == nil) {
				[self.countries setObject:country forKey:country.identifier];
				hasChanges = YES;
			}
			[country release];
		}
		if (hasChanges) {
			DLog(@"Has New Countries");
		}
		SEL selector = @selector(downloadedFromUshahidi:countries:error:hasChanges:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self countries:[self.countries allValues] error:error hasChanges:hasChanges];
		}
	}
	else if ([API isCategoriesUrl:requestURL]) {
		NSArray *categoriesArray = [payload objectForKey:@"categories"]; 
		//DLog(@"categories: %@ %@", [categoriesArray class], categoriesArray);
		BOOL hasChanges = NO;
		for (NSDictionary *categoryDictionary in categoriesArray) {
			Category *category = [[Category alloc] initWithDictionary:[categoryDictionary objectForKey:@"category"]];
			if (category.identifier != nil && [self.categories objectForKey:category.identifier] == nil) {
				[self.categories setObject:category forKey:category.identifier];
				hasChanges = YES;
			}
			[category release];
		}
		if (hasChanges) {
			DLog(@"Has New Categories");
		}
		SEL selector = @selector(downloadedFromUshahidi:categories:error:hasChanges:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self categories:[self.categories allValues] error:error hasChanges:hasChanges];
		}
	}
	else if ([API isLocationsUrl:requestURL]) {
		NSArray *locationsArray = [payload objectForKey:@"locations"]; 
		//DLog(@"locations: %@ %@", [locationsArray class], locationsArray);
		BOOL hasChanges = NO;
		for (NSDictionary *locationDictionary in locationsArray) {
			Location *location = [[Location alloc] initWithDictionary:[locationDictionary objectForKey:@"location"]];
			if (location.identifier != nil && [self.locations objectForKey:location.identifier] == nil) {
				[self.locations setObject:location forKey:location.identifier];
				hasChanges = YES;
			}
			[location release];
		}
		if (hasChanges) {
			DLog(@"Has New Locations");
		}
		SEL selector = @selector(downloadedFromUshahidi:locations:error:hasChanges:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self locations:[self.locations allValues] error:error hasChanges:hasChanges];
		}
	}
	else if ([API isIncidentsUrl:requestURL]) {
		NSArray *incidentsArray = [payload objectForKey:@"incidents"]; 
		//DLog(@"incidents: %@ %@", [incidentsArray class], incidentsArray);
		BOOL hasChanges = NO;
		for (NSDictionary *incidentDictionary in incidentsArray) {
			DLog(@"incident: %@ %@", [incidentDictionary class], incidentDictionary);
			Incident *incident = [[Incident alloc] initWithDictionary:[incidentDictionary objectForKey:@"incident"] 
													  mediaDictionary:[incidentDictionary objectForKey:@"media"]];
			if (incident.identifier != nil && [self.incidents objectForKey:incident.identifier] == nil) {
				[self.incidents setObject:incident forKey:incident.identifier];
				hasChanges = YES;
			}
			[incident release];
		}
		if (hasChanges) {
			DLog(@"Has New Incidents");
		}
		SEL selector = @selector(downloadedFromUshahidi:incidents:error:hasChanges:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self incidents:[self.incidents allValues] error:error hasChanges:hasChanges];
		}
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	NSString *requestURL = [request.originalURL absoluteString];
	DLog(@"request:%@", requestURL);
	DLog(@"error: %@", [[request error] localizedDescription]);
	id<UshahidiDelegate> delegate = [self.delegates objectForKey:requestURL];
	if ([API isApiKeyUrl:requestURL]) {
		SEL selector = @selector(downloadedFromUshahidi:apiKey:error:hasChanges:);
		if (delegate != NULL && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self apiKey:nil error:[request error] hasChanges:NO];
		}
	}
	else if ([API isCountriesUrl:requestURL]) {
		SEL selector = @selector(downloadedFromUshahidi:countries:error:hasChanges:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self countries:nil error:[request error] hasChanges:NO];
		}
	}
	else if ([API isCategoriesUrl:requestURL]) {
		SEL selector = @selector(downloadedFromUshahidi:categories:error:hasChanges:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self categories:nil error:[request error] hasChanges:NO];
		}
	}
	else if ([API isLocationsUrl:requestURL]) {
		SEL selector = @selector(downloadedFromUshahidi:locations:error:hasChanges:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self locations:nil error:[request error] hasChanges:NO];
		}
	}
	else if ([API isIncidentsUrl:requestURL]) {
		SEL selector = @selector(downloadedFromUshahidi:incidents:error:hasChanges:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self incidents:nil error:[request error] hasChanges:NO];
		}
	}
}

@end
