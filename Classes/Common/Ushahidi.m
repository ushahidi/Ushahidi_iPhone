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
#import "NSString+Extension.h"
#import "JSON.h"
#import "Deployment.h"
#import "Category.h"
#import "Location.h"
#import "Country.h"
#import "Incident.h"
#import "Photo.h"
#import "Settings.h"

@interface Ushahidi ()

@property(nonatomic, retain) NSMutableDictionary *deployments;
@property(nonatomic, retain) NSMutableDictionary *delegates;

- (ASIHTTPRequest *) startAsynchronousRequest:(NSString *)url;
- (void) notifyDelegate:(id<UshahidiDelegate>)delegate;
- (void) downloadIncidentMapsInBackground;

@end

@implementation Ushahidi

@synthesize delegates, deployments, deployment;

NSString * const kGoogleStaticMaps = @"http://maps.google.com/maps/api/staticmap";

SYNTHESIZE_SINGLETON_FOR_CLASS(Ushahidi);

- (id) init {
	if ((self = [super init])) {
		self.deployments = [NSKeyedUnarchiver unarchiveObjectWithKey:@"deployments"];
		if (self.deployments == nil) self.deployments = [[NSMutableDictionary alloc] init];
		
		self.delegates = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {
	[deployments release];
	[delegates release];
	[super dealloc];
}

- (void) save {
	DLog(@"");
	[NSKeyedArchiver archiveObject:self.deployments forKey:@"deployments"];
}

#pragma mark -
#pragma mark Deployments

- (BOOL)addDeployment:(Deployment *)theDeployment {
	if (theDeployment != nil) {
		[self.deployments setObject:theDeployment forKey:theDeployment.url];
		return YES;
	}
	return NO;
}

- (BOOL)addDeploymentByName:(NSString *)name andUrl:(NSString *)url {
	if (name != nil && [name length] > 0 && url != nil && [url length] > 0) {
		Deployment *theDeployment = [[Deployment alloc] initWithName:name 
																 url:url];
		[self.deployments setObject:theDeployment forKey:url];
		return YES;
	}
	return NO;
}

- (Deployment *) getDeploymentWithUrl:(NSString *)url {
	return [self.deployments objectForKey:url];
}

#pragma mark -
#pragma mark Map Image

- (void) downloadIncidentMaps {
	DLog(@"downloadIncidentMaps");
	[self performSelectorInBackground:@selector(downloadIncidentMapsInBackground) withObject:nil];
}

- (void) downloadIncidentMapsInBackground {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	DLog(@"downloadIncidentMapsInBackground...");
	for(Incident *incident in [self.deployment.incidents allValues]) {
		@try {
			if (incident.map == nil && incident.latitude != nil && incident.longitude != nil) {
				CGRect screen = [[UIScreen mainScreen] bounds];
				NSMutableString *url = [NSMutableString stringWithString:kGoogleStaticMaps];
				[url appendFormat:@"?center=%@,%@", incident.latitude, incident.longitude];
				[url appendFormat:@"&markers=%@,%@", incident.latitude, incident.longitude];
				[url appendFormat:@"&size=%dx%d", (int)CGRectGetWidth(screen), (int)CGRectGetWidth(screen)/2];
				[url appendFormat:@"&zoom=%@", @"12"];
				[url appendFormat:@"&sensor=false"];
				DLog(@"REQUEST: %@", url);
				ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
				[request setShouldRedirect:YES];
				[request startSynchronous];
				if ([request error] != nil) {
					DLog(@"ERROR: %@", [[request error] localizedDescription]);
				} 
				else if ([request responseData] != nil) {
					DLog(@"RESPONSE: BINARY IMAGE");
					incident.map = [UIImage imageWithData:[request responseData]];
				}
				else {
					DLog(@"RESPONSE: %@", [request responseString]);
				}
			}
		}
		@catch (NSException *e) {
			DLog(@"NSException: %@", e);
		}
	}
	DLog(@"...downloadIncidentMapsInBackground");
	[pool release];
}

#pragma mark -
#pragma mark Add/Upload Incidents

- (BOOL)addIncident:(Incident *)incident withDelegate:(id<UshahidiDelegate>)delegate {
	if (incident != nil) {
		if (incident.identifier == nil) {
			incident.identifier = [NSString getUUID];
		}
		[self.deployment.incidents setObject:incident forKey:incident.identifier];
		return [self uploadIncident:incident withDelegate:delegate];
	}
	return NO;
}

- (BOOL) uploadIncident:(Incident *)incident withDelegate:(id<UshahidiDelegate>)delegate {
	@try {
		NSString *postUrl = [self.deployment getPostReport];
		[self.delegates setObject:delegate forKey:postUrl];
		DLog(@"POST: %@", postUrl);
		ASIFormDataRequest *post = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:postUrl]];
		[post setDelegate:self];
		[post setUserInfo:[NSDictionary dictionaryWithObject:incident.identifier forKey:@"incident"]];
		//[post setShouldRedirect:YES];
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
		NSInteger filename = 1;
		for(Photo *photo in incident.photos) {
			[post addData:[photo getJpegData] withFileName:[NSString stringWithFormat:@"photo%d.jpg", filename++] 
											andContentType:@"image/jpeg" 
													forKey:@"incident_photo[]"];
		}
		[post startAsynchronous];
		return YES;
	}
	@catch (NSException *e) {
		DLog(@"%@", e);
	}
	return NO;
}

- (void) uploadIncidents:(id<UshahidiDelegate>)delegate {
	for(Incident *incident in self.deployment.incidents) {
		if (incident.pending) {
			[self uploadIncident:incident withDelegate:delegate];
		}
	}
}

#pragma mark -
#pragma mark Categories

- (NSArray *) getDeploymentsWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", delegate);
	if ([self.deployments count] == 0) {
		[self.deployments setObject:[[Deployment alloc] initWithName:@"Demo Ushahidi" 
																 url:@"http://demo.ushahidi.com"] 
							 forKey:@"http://demo.ushahidi.com"];
	}
	[self performSelector:@selector(notifyDelegate:) withObject:delegate afterDelay:2.0];
	
	return [[self.deployments allValues] sortedArrayUsingSelector:@selector(compareByName:)];
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
	NSString *requestURL = [self.deployment getCategories];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [[self.deployment.categories allValues] sortedArrayUsingSelector:@selector(compareByTitle:)];
}

- (Category *) getCategoryByID:(NSString *)categoryID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ category:%@", delegate, categoryID);
	NSString *requestURL = [self.deployment getCategoryByID:categoryID];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.deployment.categories objectForKey:categoryID];
}

#pragma mark -
#pragma mark Countries

- (NSArray *) getCountriesWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", delegate);
	NSString *requestURL = [self.deployment getCountries];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [[self.deployment.countries allValues] sortedArrayUsingSelector:@selector(compareByName:)];
}

- (Country *) getCountryByID:(NSString *)countryId withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ countryId:%@", delegate, countryId);
	NSString *requestURL = [self.deployment getCountryByID:countryId];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.deployment.countries objectForKey:countryId];
}

- (Country *) getCountryByISO:(NSString *)countryISO withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ countryISO:%@", delegate, countryISO);
	NSString *requestURL = [self.deployment getCountryByISO:countryISO];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	for (Country *country in [self.deployment.countries allValues]) {
		if ([country.iso isEqualToString:countryISO]) {
			return country;
		}
	}
	return nil;
}

- (Country *) getCountryByName:(NSString *)countryName withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ countryName:%@", delegate, countryName);
	NSString *requestURL = [self.deployment getCountryByName:countryName];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	for (Country *country in [self.deployment.countries allValues]) {
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
	NSString *requestURL = [self.deployment getLocations];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [[self.deployment.locations allValues] sortedArrayUsingSelector:@selector(compareByName:)];
}

- (Location *) getLocationByID:(NSString *)locationID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ locationID:%@", delegate, locationID);
	NSString *requestURL = [self.deployment getLocationByID:locationID];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.deployment.locations objectForKey:locationID];
}

- (NSArray *) getLocationsByCountryID:(NSString *)countryID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ countryID:%@", delegate, countryID);
	NSString *requestURL = [self.deployment getLocationsByCountryID:countryID];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [[self.deployment.locations allValues] sortedArrayUsingSelector:@selector(compareByName:)];
}

#pragma mark -
#pragma mark Incidents

- (void) getGeoGraphicMidPointWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", delegate);
	NSString *requestURL = [self.deployment getGeoGraphicMidPoint];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
}

- (NSArray *) getIncidents {
	return [self.deployment.incidents allValues];
}

- (NSArray *) getIncidentsWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", delegate);
	NSString *requestURL = [self.deployment getIncidents];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.deployment.incidents allValues];
}

- (NSInteger) getIncidentsCountWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", delegate);
	NSString *requestURL = [self.deployment getIncidentCount];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.deployment.incidents count];
}

- (NSArray *) getIncidentsByCategoryID:(NSString *)categoryID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ categoryID:%@", delegate, categoryID);
	NSString *requestURL = [self.deployment getIncidentsByCategoryID:categoryID];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.deployment.incidents allValues];
}

- (NSArray *) getIncidentsByCategoryName:(NSString *)categoryName withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ categoryName:%@", delegate, categoryName);
	NSString *requestURL = [self.deployment getIncidentsByCategoryName:categoryName];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.deployment.incidents allValues];
}

- (NSArray *) getIncidentsByLocationID:(NSString *)locationID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ locationID:%@", delegate, locationID);
	NSString *requestURL = [self.deployment getIncidentsByLocationID:locationID];
	[self startAsynchronousRequest:requestURL];
	return [self.deployment.incidents allValues];
}

- (NSArray *) getIncidentsByLocationName:(NSString *)locationName withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ locationName:%@", delegate, locationName);
	NSString *requestURL = [self.deployment getIncidentsByLocationName:locationName];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];
	return [self.deployment.incidents allValues];
}

- (NSArray *) getIncidentsBySinceID:(NSString *)sinceID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ sinceID:%@", delegate, sinceID);
	NSString *requestURL = [self.deployment getIncidentsBySinceID:sinceID];
	[self.delegates setObject:delegate forKey:requestURL];
	[self startAsynchronousRequest:requestURL];	
	return [self.deployment.incidents allValues];
}

#pragma mark -
#pragma mark ASIHTTPRequest

- (ASIHTTPRequest *) startAsynchronousRequest:(NSString *)url {
	DLog(@"url: %@", url);
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	[request setDelegate:self];
	[request setShouldRedirect:YES];
	[request startAsynchronous];
	return request;
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSString *requestURL = [request.originalURL absoluteString];
	DLog(@"request: %@", requestURL);
	DLog(@"status: %@", [request responseStatusMessage]);
	DLog(@"header: %@", [request responseHeaders]);
	id<UshahidiDelegate> delegate = [self.delegates objectForKey:requestURL];
	NSDictionary *json = [[request responseString] JSONValue];
	NSDictionary *payload = nil;
	NSError *error = nil;
	if (json == nil) {
		error = [NSError errorWithDomain:self.deployment.domain code:500 userInfo:nil];
	}
	else {
		payload = [json	objectForKey:@"payload"];
		//DLog(@"payload: %@ %@", [payload class], payload);
	}
	if ([request isKindOfClass:[ASIFormDataRequest class]]) {
		DLog(@"#################### POST ####################");
		DLog(@"response: %@", [request responseString]);
		Incident *incident = nil;
		if ([request userInfo] != nil) {
			NSString *identifer = [[request userInfo] objectForKey:@"incident"];
			if (identifer != nil) {
				incident = [self.deployment.incidents objectForKey:identifer];
				if ([@"true" isEqualToString:[payload objectForKey:@"success"]]) {
					incident.pending = NO;
					incident.errors = nil;
					DLog(@"Setting Pending=NO for Incident: %@", incident.title);
				}
				else {
					NSDictionary *messages = [json objectForKey:@"error"];
					if (messages != nil) {
						incident.errors = [messages objectForKey:@"message"];
					}
				}
			}
		}
		SEL selector = @selector(uploadedToUshahidi:incident:error:);
		if (delegate != NULL && [delegate respondsToSelector:selector]) {
			[delegate uploadedToUshahidi:self incident:incident error:error];
		}
	}
	else if ([Deployment isApiKeyUrl:requestURL]) {
		SEL selector = @selector(downloadedFromUshahidi:apiKey:error:hasChanges:);
		if (delegate != NULL && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self apiKey:nil error:error hasChanges:YES];
		}
	}
	else if ([Deployment isCountriesUrl:requestURL]) {
		NSArray *countriesArray = [payload objectForKey:@"countries"]; 
		//DLog(@"countries: %@ %@", [countriesArray class], countriesArray);
		BOOL hasChanges = NO;
		for (NSDictionary *countryDictionary in countriesArray) {
			Country *country = [[Country alloc] initWithDictionary:[countryDictionary objectForKey:@"country"]];
			if (country.identifier != nil && [self.deployment.countries objectForKey:country.identifier] == nil) {
				[self.deployment.countries setObject:country forKey:country.identifier];
				hasChanges = YES;
			}
			[country release];
		}
		if (hasChanges) {
			DLog(@"Has New Countries");
		}
		SEL selector = @selector(downloadedFromUshahidi:countries:error:hasChanges:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self 
								   countries:[self.deployment.countries allValues] 
									   error:error 
								  hasChanges:hasChanges];
		}
	}
	else if ([Deployment isCategoriesUrl:requestURL]) {
		NSArray *categoriesArray = [payload objectForKey:@"categories"]; 
		//DLog(@"categories: %@ %@", [categoriesArray class], categoriesArray);
		BOOL hasChanges = NO;
		for (NSDictionary *categoryDictionary in categoriesArray) {
			Category *category = [[Category alloc] initWithDictionary:[categoryDictionary objectForKey:@"category"]];
			if (category.identifier != nil && [self.deployment.categories objectForKey:category.identifier] == nil) {
				[self.deployment.categories setObject:category forKey:category.identifier];
				hasChanges = YES;
			}
			[category release];
		}
		if (hasChanges) {
			DLog(@"Has New Categories");
		}
		SEL selector = @selector(downloadedFromUshahidi:categories:error:hasChanges:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self 
								  categories:[[self.deployment.categories allValues] sortedArrayUsingSelector:@selector(compareByTitle:)] 
									   error:error 
								  hasChanges:hasChanges];
		}
	}
	else if ([Deployment isLocationsUrl:requestURL]) {
		NSArray *locationsArray = [payload objectForKey:@"locations"]; 
		//DLog(@"locations: %@ %@", [locationsArray class], locationsArray);
		BOOL hasChanges = NO;
		for (NSDictionary *locationDictionary in locationsArray) {
			Location *location = [[Location alloc] initWithDictionary:[locationDictionary objectForKey:@"location"]];
			if (location.identifier != nil && [self.deployment.locations objectForKey:location.identifier] == nil) {
				[self.deployment.locations setObject:location forKey:location.identifier];
				hasChanges = YES;
			}
			[location release];
		}
		if (hasChanges) {
			DLog(@"Has New Locations");
		}
		SEL selector = @selector(downloadedFromUshahidi:locations:error:hasChanges:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self 
								   locations:[[self.deployment.locations allValues] sortedArrayUsingSelector:@selector(compareByName:)] 
									   error:error 
								  hasChanges:hasChanges];
		}
	}
	else if ([Deployment isIncidentsUrl:requestURL]) {
		NSArray *incidentsArray = [payload objectForKey:@"incidents"]; 
		//DLog(@"incidents: %@ %@", [incidentsArray class], incidentsArray);
		BOOL hasChanges = NO;
		for (NSDictionary *incidentDictionary in incidentsArray) {
			DLog(@"incident: %@ %@", [incidentDictionary class], incidentDictionary);
			Incident *incident = [[Incident alloc] initWithDictionary:[incidentDictionary objectForKey:@"incident"] 
													  mediaDictionary:[incidentDictionary objectForKey:@"media"]];
			if (incident.identifier != nil && [self.deployment.incidents objectForKey:incident.identifier] == nil) {
				[self.deployment.incidents setObject:incident forKey:incident.identifier];
				hasChanges = YES;
			}
			[incident release];
		}
		if (hasChanges) {
			DLog(@"Has New Incidents");
		}
		SEL selector = @selector(downloadedFromUshahidi:incidents:error:hasChanges:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self 
								   incidents:[self.deployment.incidents allValues] 
									   error:error 
								  hasChanges:hasChanges];
		}
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	NSString *requestURL = [request.originalURL absoluteString];
	DLog(@"request:%@", requestURL);
	DLog(@"error: %@", [[request error] localizedDescription]);
	id<UshahidiDelegate> delegate = [self.delegates objectForKey:requestURL];
	if ([Deployment isApiKeyUrl:requestURL]) {
		SEL selector = @selector(downloadedFromUshahidi:apiKey:error:hasChanges:);
		if (delegate != NULL && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self apiKey:nil error:[request error] hasChanges:NO];
		}
	}
	else if ([Deployment isCountriesUrl:requestURL]) {
		SEL selector = @selector(downloadedFromUshahidi:countries:error:hasChanges:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self countries:nil error:[request error] hasChanges:NO];
		}
	}
	else if ([Deployment isCategoriesUrl:requestURL]) {
		SEL selector = @selector(downloadedFromUshahidi:categories:error:hasChanges:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self categories:nil error:[request error] hasChanges:NO];
		}
	}
	else if ([Deployment isLocationsUrl:requestURL]) {
		SEL selector = @selector(downloadedFromUshahidi:locations:error:hasChanges:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self locations:nil error:[request error] hasChanges:NO];
		}
	}
	else if ([Deployment isIncidentsUrl:requestURL]) {
		SEL selector = @selector(downloadedFromUshahidi:incidents:error:hasChanges:);
		if (delegate != nil && [delegate respondsToSelector:selector]) {
			[delegate downloadedFromUshahidi:self incidents:nil error:[request error] hasChanges:NO];
		}
	}
}

@end
