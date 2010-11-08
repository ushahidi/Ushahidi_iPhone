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
#import "NSObject+Extension.h"
#import "NSError+Extension.h"
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

- (ASIHTTPRequest *) startAsynchronousRequest:(NSString *)url withDelegate:(id<UshahidiDelegate>)delegate;
- (void) notifyDelegate:(id<UshahidiDelegate>)delegate;
- (void) downloadMapsWithDelegate:(id<UshahidiDelegate>)delegate;

@end

@implementation Ushahidi

@synthesize deployments, deployment;

NSString * const kGoogleStaticMaps = @"http://maps.google.com/maps/api/staticmap";

SYNTHESIZE_SINGLETON_FOR_CLASS(Ushahidi);

- (id) init {
	if ((self = [super init])) {
		self.deployments = [NSKeyedUnarchiver unarchiveObjectWithKey:@"deployments"];
		if (self.deployments == nil) self.deployments = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {
	[deployments release];
	[super dealloc];
}

- (void) save {
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

- (void) downloadMapsWithDelegate:(id<UshahidiDelegate>)delegate {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	for(Incident *incident in [self.deployment.incidents allValues]) {
		@try {
			if (incident.map == nil && incident.latitude != nil && incident.longitude != nil) {
				CGRect screen = [[UIScreen mainScreen] bounds];
				NSMutableString *url = [NSMutableString stringWithString:kGoogleStaticMaps];
				[url appendFormat:@"?center=%@,%@", incident.latitude, incident.longitude];
				[url appendFormat:@"&markers=%@,%@", incident.latitude, incident.longitude];
				[url appendFormat:@"&size=%dx%d", (int)CGRectGetWidth(screen), (int)CGRectGetWidth(screen)];
				[url appendFormat:@"&zoom=%d", [[Settings sharedSettings] mapZoomLevel]];
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
					[self dispatchSelector:@selector(downloadedFromUshahidi:incident:map:) 
									target:delegate 
								   objects:self, incident, incident.map, nil];
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
	[pool release];
}

#pragma mark -
#pragma mark Add/Upload Incidents

- (BOOL)addIncident:(Incident *)incident withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", [delegate class]);
	if (incident != nil) {
		if (incident.identifier == nil) {
			incident.identifier = [NSString getUUID];
		}
		[self.deployment.pending addObject:incident];
		return [self uploadIncident:incident withDelegate:delegate];
	}
	return NO;
}

- (BOOL) uploadIncident:(Incident *)incident withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", [delegate class]);
	@try {
		incident.uploading = YES;
		[self dispatchSelector:@selector(uploadingToUshahidi:incident:) 
						target:delegate 
					   objects:self, incident, nil];
		NSString *postUrl = [self.deployment getPostReport];
		DLog(@"POST: %@", postUrl);
		ASIFormDataRequest *post = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:postUrl]];
		[post setDelegate:self];
		[post setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:delegate, @"delegate",
																	 incident, @"incident", nil]];
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
		incident.uploading = NO;
		[self dispatchSelector:@selector(uploadedToUshahidi:incident:error:) 
						target:delegate 
					   objects:self, incident, [NSError errorWithDomain:self.deployment.domain code:500 userInfo:[e userInfo]], nil];
	}
	return NO;
}

- (void) uploadIncidents:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", [delegate class]);
	for(Incident *incident in self.deployment.pending) {
		[self uploadIncident:incident withDelegate:delegate];
	}
}

#pragma mark -
#pragma mark Categories

- (NSArray *) getDeploymentsWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", [delegate class]);
	if ([self.deployments count] == 0) {
		[self.deployments setObject:[[Deployment alloc] initWithName:@"Demo Ushahidi" 
																 url:@"http://demo.ushahidi.com"] 
							 forKey:@"http://demo.ushahidi.com"];
	}
	[self performSelector:@selector(notifyDelegate:) withObject:delegate afterDelay:2.0];
	
	return [[self.deployments allValues] sortedArrayUsingSelector:@selector(compareByName:)];
}

- (void) notifyDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", [delegate class]);
	[self dispatchSelector:@selector(downloadedFromUshahidi:deployments:error:hasChanges:) 
					target:delegate 
				   objects:self, [self.deployments allValues], nil, NO, nil];
}

#pragma mark -
#pragma mark Categories

- (NSArray *) getCategoriesWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", [delegate class]);
	[self startAsynchronousRequest:[self.deployment getCategories] withDelegate:delegate];
	return [[self.deployment.categories allValues] sortedArrayUsingSelector:@selector(compareByTitle:)];
}

- (Category *) getCategoryByID:(NSString *)categoryID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ category:%@", [delegate class], categoryID);
	[self startAsynchronousRequest:[self.deployment getCategoryByID:categoryID] withDelegate:delegate];
	return [self.deployment.categories objectForKey:categoryID];
}

#pragma mark -
#pragma mark Countries

- (NSArray *) getCountriesWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", [delegate class]);
	[self startAsynchronousRequest:[self.deployment getCountries] withDelegate:delegate];
	return [[self.deployment.countries allValues] sortedArrayUsingSelector:@selector(compareByName:)];
}

- (Country *) getCountryByID:(NSString *)countryId withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ countryId:%@", [delegate class], countryId);
	[self startAsynchronousRequest:[self.deployment getCountryByID:countryId] withDelegate:delegate];
	return [self.deployment.countries objectForKey:countryId];
}

- (Country *) getCountryByISO:(NSString *)countryISO withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ countryISO:%@", [delegate class], countryISO);
	[self startAsynchronousRequest:[self.deployment getCountryByISO:countryISO] withDelegate:delegate];
	for (Country *country in [self.deployment.countries allValues]) {
		if ([country.iso isEqualToString:countryISO]) {
			return country;
		}
	}
	return nil;
}

- (Country *) getCountryByName:(NSString *)countryName withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ countryName:%@", [delegate class], countryName);
	[self startAsynchronousRequest:[self.deployment getCountryByName:countryName] withDelegate:delegate];
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
	DLog(@"delegate: %@", [delegate class]);
	[self startAsynchronousRequest:[self.deployment getLocations] withDelegate:delegate];
	return [[self.deployment.locations allValues] sortedArrayUsingSelector:@selector(compareByName:)];
}

- (Location *) getLocationByID:(NSString *)locationID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ locationID:%@", [delegate class], locationID);
	[self startAsynchronousRequest:[self.deployment getLocationByID:locationID] withDelegate:delegate];
	return [self.deployment.locations objectForKey:locationID];
}

- (NSArray *) getLocationsByCountryID:(NSString *)countryID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ countryID:%@", [delegate class], countryID);
	[self startAsynchronousRequest:[self.deployment getLocationsByCountryID:countryID] withDelegate:delegate];
	return [[self.deployment.locations allValues] sortedArrayUsingSelector:@selector(compareByName:)];
}

#pragma mark -
#pragma mark Incidents

- (NSArray *) getIncidents {
	return [self.deployment.incidents allValues];
}

- (NSArray *) getPending {
	return self.deployment.pending;
}

- (NSArray *) getIncidentsWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", [delegate class]);
	[self startAsynchronousRequest:[self.deployment getIncidents] withDelegate:delegate];
	return [self.deployment.incidents allValues];
}

- (NSInteger) getIncidentsCountWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", [delegate class]);
	[self startAsynchronousRequest:[self.deployment getIncidentCount] withDelegate:delegate];
	return [self.deployment.incidents count];
}

- (NSArray *) getIncidentsByCategoryID:(NSString *)categoryID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ categoryID:%@", [delegate class], categoryID);
	[self startAsynchronousRequest:[self.deployment getIncidentsByCategoryID:categoryID] withDelegate:delegate];
	return [self.deployment.incidents allValues];
}

- (NSArray *) getIncidentsByCategoryName:(NSString *)categoryName withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ categoryName:%@", [delegate class], categoryName);
	[self startAsynchronousRequest:[self.deployment getIncidentsByCategoryName:categoryName] withDelegate:delegate];
	return [self.deployment.incidents allValues];
}

- (NSArray *) getIncidentsByLocationID:(NSString *)locationID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ locationID:%@", [delegate class], locationID);
	[self startAsynchronousRequest:[self.deployment getIncidentsByLocationID:locationID] withDelegate:delegate];
	return [self.deployment.incidents allValues];
}

- (NSArray *) getIncidentsByLocationName:(NSString *)locationName withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ locationName:%@", [delegate class], locationName);
	[self startAsynchronousRequest:[self.deployment getIncidentsByLocationName:locationName] withDelegate:delegate];
	return [self.deployment.incidents allValues];
}

- (NSArray *) getIncidentsBySinceID:(NSString *)sinceID withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ sinceID:%@", [delegate class], sinceID);
	[self startAsynchronousRequest:[self.deployment getIncidentsBySinceID:sinceID] withDelegate:delegate];	
	return [self.deployment.incidents allValues];
}

- (void) getGeoGraphicMidPointWithDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", [delegate class]);
	[self startAsynchronousRequest:[self.deployment getGeoGraphicMidPoint] withDelegate:delegate];
}

#pragma mark -
#pragma mark ASIHTTPRequest

- (ASIHTTPRequest *) startAsynchronousRequest:(NSString *)url withDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"url: %@", url);
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	[request setUserInfo:[NSDictionary dictionaryWithObject:delegate forKey:@"delegate"]];
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
	id<UshahidiDelegate> delegate = [request.userInfo objectForKey:@"delegate"];
	NSDictionary *json = [[request responseString] JSONValue];
	NSDictionary *payload = nil;
	NSError *error = nil;
	if (json == nil) {
		error = [NSError errorWithDomain:self.deployment.domain code:500 message:@"Invalid response."];
	}
	else {
		payload = [json	objectForKey:@"payload"];
		//DLog(@"payload: %@ %@", [payload class], payload);
	}
	if ([request isKindOfClass:[ASIFormDataRequest class]]) {
		DLog(@"#################### POST ####################");
		DLog(@"response: %@", [request responseString]);
		if ([request userInfo] != nil) {
			Incident *incident = [[request userInfo] objectForKey:@"incident"];
			if (incident != nil) {
				incident.uploading = NO;
				if ([@"true" isEqualToString:[payload objectForKey:@"success"]]) {
					incident.errors = nil;
					DLog(@"Incident Uploaded: %@", incident.title);
					[self.deployment.incidents setObject:incident forKey:incident.identifier];
					[self.deployment.pending removeObject:incident];
					[self dispatchSelector:@selector(downloadedFromUshahidi:incidents:pending:error:hasChanges:) 
									target:delegate 
								   objects:self, [self.deployment.incidents allValues], self.deployment.pending, nil, YES, nil];
				}
				else {
					NSDictionary *messages = [json objectForKey:@"error"];
					if (messages != nil) {
						incident.errors = [messages objectForKey:@"message"];
					}
					else {
						incident.errors = @"Unable to upload incident.";
					}
					error = [NSError errorWithDomain:self.deployment.domain code:500 message:incident.errors];
					[self dispatchSelector:@selector(uploadedToUshahidi:incident:error:) 
									target:delegate 
								   objects:self, incident, error, nil];
				}
			}
		}
	}
	else if ([Deployment isApiKeyUrl:requestURL]) {
		[self dispatchSelector:@selector(downloadedFromUshahidi:apiKey:error:hasChanges:) 
						target:delegate 
					   objects:self, @"", error, NO, nil];
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
		[self dispatchSelector:@selector(downloadedFromUshahidi:countries:error:hasChanges:) 
						target:delegate 
					   objects:self, [self.deployment.countries allValues], error, hasChanges, nil];
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
		[self dispatchSelector:@selector(downloadedFromUshahidi:categories:error:hasChanges:) 
						target:delegate 
					   objects:self, [[self.deployment.categories allValues] sortedArrayUsingSelector:@selector(compareByTitle:)], error, hasChanges, nil];
	}
	else if ([Deployment isLocationsUrl:requestURL]) {
		NSArray *locationsArray = [payload objectForKey:@"locations"]; 
		//DLog(@"locations: %@ %@", [locationsArray class], locationsArray);
		BOOL hasChanges = NO;
		for (NSDictionary *locationDictionary in locationsArray) {
			Location *location = [[Location alloc] initWithDictionary:[locationDictionary objectForKey:@"location"]];
			if ([self.deployment containsLocation:location] == NO) {
				[self.deployment.locations setObject:location forKey:location.identifier];
				hasChanges = YES;
			}
			[location release];
		}
		if (hasChanges) {
			DLog(@"Has New Locations");
		}
		[self dispatchSelector:@selector(downloadedFromUshahidi:locations:error:hasChanges:)
						target:delegate
					   objects:self, [[self.deployment.locations allValues] sortedArrayUsingSelector:@selector(compareByName:)], error, hasChanges, nil];
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
		[self dispatchSelector:@selector(downloadedFromUshahidi:incidents:pending:error:hasChanges:) 
						target:delegate 
					   objects:self, [self.deployment.incidents allValues], self.deployment.pending, error, hasChanges, nil];
		if ([[Settings sharedSettings] downloadMaps]) {
			[self performSelectorInBackground:@selector(downloadMapsWithDelegate:) withObject:delegate];
		}
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	NSString *requestURL = [request.originalURL absoluteString];
	DLog(@"request:%@", requestURL);
	DLog(@"error: %@", [[request error] localizedDescription]);
	id<UshahidiDelegate> delegate = [request.userInfo objectForKey:@"delegate"];
	if ([Deployment isApiKeyUrl:requestURL]) {
		[self dispatchSelector:@selector(downloadedFromUshahidi:apiKey:error:hasChanges:) 
						target:delegate 
					   objects:self, nil, [request error], NO, nil];
	}
	else if ([Deployment isCountriesUrl:requestURL]) {
		[self dispatchSelector:@selector(downloadedFromUshahidi:countries:error:hasChanges:) 
						target:delegate 
					   objects:self, nil, [request error], NO, nil];
	}
	else if ([Deployment isCategoriesUrl:requestURL]) {
		[self dispatchSelector:@selector(downloadedFromUshahidi:categories:error:hasChanges:) 
						target:delegate 
					   objects:self, nil, [request error], NO, nil];
	}
	else if ([Deployment isLocationsUrl:requestURL]) {
		[self dispatchSelector:@selector(downloadedFromUshahidi:locations:error:hasChanges:) 
						target:delegate 
					   objects:self, nil, [request error], NO, nil];
	}
	else if ([Deployment isIncidentsUrl:requestURL]) {
		[self dispatchSelector:@selector(downloadedFromUshahidi:incidents:pending:error:hasChanges:) 
						target:delegate 
					   objects:self, nil, nil, [request error], NO, nil];
	}
}

@end
