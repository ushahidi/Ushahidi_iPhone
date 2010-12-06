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
#import "NSURL+Extension.h"
#import "NSDictionary+Extension.h"
#import "JSON.h"
#import "Deployment.h"
#import "Category.h"
#import "Location.h"
#import "Country.h"
#import "Incident.h"
#import "Photo.h"
#import "News.h"
#import "Sound.h"
#import "Video.h"
#import "Settings.h"

@interface Ushahidi ()

@property(nonatomic, retain) NSMutableDictionary *deployments;
@property(nonatomic, retain) ASINetworkQueue *mapQueue;
@property(nonatomic, retain) ASINetworkQueue *photoQueue;

- (ASIHTTPRequest *) startAsynchronousRequest:(NSString *)url 
								  forDelegate:(id<UshahidiDelegate>)delegate 
							   finishSelector:(SEL)finishSelector
								 failSelector:(SEL)failSelector;

- (void) mapQueueFinished:(ASINetworkQueue *)queue;
- (void) photoQueueFinished:(ASINetworkQueue *)queue;

- (void) getDeploymentsFinished:(id<UshahidiDelegate>)delegate;

- (void) downloadMap:(Incident *)incident forDelegate:(id<UshahidiDelegate>)delegate;
- (void) downloadMapFinished:(ASIHTTPRequest *)request;
- (void) downloadMapFailed:(ASIHTTPRequest *)request;

- (void) uploadFinished:(ASIHTTPRequest *)request;
- (void) uploadFailed:(ASIHTTPRequest *)request;

- (void) getIncidentsFinished:(ASIHTTPRequest *)request;
- (void) getIncidentsFailed:(ASIHTTPRequest *)request;

- (void) getCategoriesFinished:(ASIHTTPRequest *)request;
- (void) getCategoriesFailed:(ASIHTTPRequest *)request;

- (void) getCountriesFinished:(ASIHTTPRequest *)request;
- (void) getCountriesFailed:(ASIHTTPRequest *)request;

- (void) getLocationsFinished:(ASIHTTPRequest *)request;
- (void) getLocationsFailed:(ASIHTTPRequest *)request;

- (void) downloadPhotoFinished:(ASIHTTPRequest *)request;
- (void) downloadPhotoFailed:(ASIHTTPRequest *)request;

@end

@implementation Ushahidi

@synthesize deployments, deployment, mapQueue, photoQueue;

typedef enum {
	MediaTypeUnkown,
	MediaTypePhoto,
	MediaTypeVideo,
	MediaTypeSound,
	MediaTypeNews
} MediaType;

typedef enum {
	HttpStatusContinue = 100,
	HttpStatusOK = 200,
	HttpStatusCreate = 201,
	HttpStatusAccepted = 202,
	HttpStatusNoContent = 204,
	HttpStatusMovedPermanently = 301,
	HttpStatusNotModified = 304,
	HttpStatusBadRequest = 400,
	HttpStatusNoauthorized = 401,
	HttpStatusForbidden = 403,
	HttpStatusNotFound = 404,
	HttpStatusTimeout = 408,
	HttpStatusInternalServerError = 500,
	HttpStatusNotImplemented = 501,
	HttpStatusBadGateway = 502,
	HttpStatusServiceUnavailable = 503
} HttpStatus;

NSString * const kGoogleStaticMaps = @"http://maps.google.com/maps/api/staticmap";
NSInteger const kGoogleOverCapacitySize = 100;

SYNTHESIZE_SINGLETON_FOR_CLASS(Ushahidi);

- (id) init {
	if ((self = [super init])) {
		self.deployments = [NSKeyedUnarchiver unarchiveObjectWithKey:@"deployments"];
		if (self.deployments == nil) self.deployments = [[NSMutableDictionary alloc] init];
		self.mapQueue = [ASINetworkQueue queue];
		[self.mapQueue setDelegate:self];
		[self.mapQueue setQueueDidFinishSelector:@selector(mapQueueFinished:)];
		self.photoQueue = [ASINetworkQueue queue];
		[self.photoQueue setDelegate:self];
		[self.photoQueue setQueueDidFinishSelector:@selector(photoQueueFinished:)];
	}
	return self;
}

- (void)dealloc {
	[deployment release];
	[deployments release];
	[mapQueue release];
	[photoQueue release];
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

- (BOOL)removeDeployment:(Deployment *)theDeployment {
	if (theDeployment != nil) {
		[self.deployments removeObjectForKey:theDeployment.url];
		return YES;
	}
	return NO;
}

- (Deployment *) getDeploymentWithUrl:(NSString *)url {
	return [self.deployments objectForKey:url];
}

#pragma mark -
#pragma mark Add/Upload Incidents

- (BOOL)addIncident:(Incident *)incident forDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", [delegate class]);
	if (incident != nil) {
		if (incident.identifier == nil) {
			incident.identifier = [NSString getUUID];
		}
		[self.deployment.pending addObject:incident];
		return [self uploadIncident:incident forDelegate:delegate];
	}
	return NO;
}

- (void) uploadIncidentsForDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", [delegate class]);
	for(Incident *incident in self.deployment.pending) {
		[self uploadIncident:incident forDelegate:delegate];
	}
}

- (BOOL) uploadIncident:(Incident *)incident forDelegate:(id<UshahidiDelegate>)delegate {
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
		[post setTimeOutSeconds:180];
		[post setShouldRedirect:YES];
		[post setAllowCompressedResponse:NO];
		[post setShouldCompressRequestBody:NO];
		[post setValidatesSecureCertificate:NO];
		[post addRequestHeader:@"Accept" value:@"*/*"];
		[post addRequestHeader:@"Cache-Control" value:@"no-cache"];
		[post addRequestHeader:@"Connection" value:@"Keep-Alive"];
		[post setDidFinishSelector:@selector(uploadFinished:)];
		[post setDidFailSelector:@selector(uploadFailed:)];
		[post setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:delegate, @"delegate",
																	 incident, @"incident", nil]];
		[post addPostValue:@"report" forKey:@"task"];
		[post addPostValue:@"json" forKey:@"resp"];
		[post addPostValue:[incident title] forKey:@"incident_title"];
		[post addPostValue:[incident description] forKey:@"incident_description"];
		[post addPostValue:[incident dateDayMonthYear] forKey:@"incident_date"];
		[post addPostValue:[incident dateHour] forKey:@"incident_hour"];
		[post addPostValue:[incident dateMinute] forKey:@"incident_minute"];
		[post addPostValue:[incident dateAmPm] forKey:@"incident_ampm"];
		[post addPostValue:[incident categoryNames] forKey:@"incident_category"];
		[post addPostValue:[incident location] forKey:@"location_name"];
		[post addPostValue:[incident latitude] forKey:@"latitude"];
		[post addPostValue:[incident longitude] forKey:@"longitude"];
		[post addPostValue:[[Settings sharedSettings] firstName] forKey:@"person_first"];
		[post addPostValue:[[Settings sharedSettings] lastName] forKey:@"person_last"];
		[post addPostValue:[[Settings sharedSettings] email] forKey:@"person_email"];
		NSInteger filename = 1;
		for(Photo *photo in incident.photos) {
			[post addData:[photo getJpegData] withFileName:[NSString stringWithFormat:@"incident_photo%d.jpg", filename++] 
											andContentType:@"image/jpeg" 
													forKey:@"incident_photo[]"];
		}
		[post startAsynchronous];
		return YES;
	}
	@catch (NSException *e) {
		DLog(@"NSException: %@", e);
		incident.uploading = NO;
		[self dispatchSelector:@selector(uploadedToUshahidi:incident:error:) 
						target:delegate 
					   objects:self, incident, [NSError errorWithDomain:self.deployment.domain code:HttpStatusInternalServerError userInfo:[e userInfo]], nil];
	}
	return NO;
}

- (void)uploadFinished:(ASIHTTPRequest *)request {
	DLog(@"request: %@", [request.originalURL absoluteString]);
	DLog(@"status: %@", [request responseStatusMessage]);
	DLog(@"response: %@", [request responseString]);
	id<UshahidiDelegate> delegate = [request.userInfo objectForKey:@"delegate"];
	Incident *incident = [[request userInfo] objectForKey:@"incident"];
	if ([request responseStatusCode] != HttpStatusOK) {
		NSError *error = [NSError errorWithDomain:self.deployment.domain code:[request responseStatusCode] message:[request responseStatusMessage]];
		[self dispatchSelector:@selector(uploadedToUshahidi:incident:error:) 
						target:delegate 
					   objects:self, incident, error, nil];
	}
	else {
		NSDictionary *json = [[request responseString] JSONValue];
		if (json == nil) {
			DLog(@"response: %@", [request responseString]);
			NSError *error = [NSError errorWithDomain:self.deployment.domain code:HttpStatusInternalServerError message:NSLocalizedString(@"Invalid response", nil)];
			[self dispatchSelector:@selector(uploadedToUshahidi:incident:error:) 
							target:delegate 
						   objects:self, incident, error, nil];
		}
		else {
			NSDictionary *payload = [json objectForKey:@"payload"];
			DLog(@"response: %@", payload);
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
					incident.errors = NSLocalizedString(@"Unable to upload report.", nil);
				}
				NSError *error = [NSError errorWithDomain:self.deployment.domain code:HttpStatusInternalServerError message:incident.errors];
				[self dispatchSelector:@selector(uploadedToUshahidi:incident:error:) 
								target:delegate 
							   objects:self, incident, error, nil];
			}
		}	
	}
}

- (void)uploadFailed:(ASIHTTPRequest *)request {
	DLog(@"request: %@", [request.originalURL absoluteString]);
	DLog(@"error: %@", [[request error] localizedDescription]);
	id<UshahidiDelegate> delegate = [request.userInfo objectForKey:@"delegate"];
	Incident *incident = [[request userInfo] objectForKey:@"incident"];
	[self dispatchSelector:@selector(uploadedToUshahidi:incident:error:) 
					target:delegate 
				   objects:self, incident, [request error], nil];
}

#pragma mark -
#pragma mark Deployments

- (NSArray *) getDeploymentsForDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", [delegate class]);
	if ([self.deployments count] == 0) {
		[self.deployments setObject:[[Deployment alloc] initWithName:NSLocalizedString(@"Demo Ushahidi", nil) 
																 url:@"http://demo.ushahidi.com"] 
							 forKey:@"http://demo.ushahidi.com"];
	}
	//TODO load Ushahidi deployments from server
	[self performSelector:@selector(getDeploymentsFinished:) withObject:delegate afterDelay:0.5];
	return [[self.deployments allValues] sortedArrayUsingSelector:@selector(compareByName:)];
}

- (void) getDeploymentsFinished:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", [delegate class]);
	[self dispatchSelector:@selector(downloadedFromUshahidi:deployments:error:hasChanges:) 
					target:delegate 
				   objects:self, [self.deployments allValues], nil, NO, nil];
}

#pragma mark -
#pragma mark Categories

- (NSArray *) getCategoriesForDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", [delegate class]);
	[self startAsynchronousRequest:[self.deployment getCategories] 
					   forDelegate:delegate
					finishSelector:@selector(getCategoriesFinished:)
					  failSelector:@selector(getCategoriesFailed:)];
	return [[self.deployment.categories allValues] sortedArrayUsingSelector:@selector(compareByTitle:)];
}

- (void) getCategoriesFinished:(ASIHTTPRequest *)request {
	DLog(@"request: %@", [request.originalURL absoluteString]);
	DLog(@"status: %@", [request responseStatusMessage]);
	id<UshahidiDelegate> delegate = [request.userInfo objectForKey:@"delegate"];
	if ([request responseStatusCode] != HttpStatusOK) {
		NSError *error = [NSError errorWithDomain:self.deployment.domain code:[request responseStatusCode] message:[request responseStatusMessage]];
		[self dispatchSelector:@selector(downloadedFromUshahidi:categories:error:hasChanges:) 
						target:delegate 
					   objects:self, [[self.deployment.categories allValues] sortedArrayUsingSelector:@selector(compareByTitle:)], error, NO, nil];
	}
	else {
		NSDictionary *json = [[request responseString] JSONValue];
		if (json == nil) {
			NSError *error = [NSError errorWithDomain:self.deployment.domain code:HttpStatusInternalServerError message:NSLocalizedString(@"Invalid Server Response", nil)];
			[self dispatchSelector:@selector(downloadedFromUshahidi:categories:error:hasChanges:) 
							target:delegate 
						   objects:self, [[self.deployment.categories allValues] sortedArrayUsingSelector:@selector(compareByTitle:)], error, NO, nil];
			
		}
		else {
			NSDictionary *payload = [json objectForKey:@"payload"];
			NSArray *categories = [payload objectForKey:@"categories"]; 
			BOOL hasChanges = NO;
			for (NSDictionary *dictionary in categories) {
				Category *category = [[Category alloc] initWithDictionary:[dictionary objectForKey:@"category"]];
				if (category.identifier != nil) {
					Category *existing = [self.deployment.categories objectForKey:category.identifier];
					if (existing == nil) {
						[self.deployment.categories setObject:category forKey:category.identifier];
						hasChanges = YES;
					}
					else if ([existing updateWithDictionary:[dictionary objectForKey:@"category"]]) {
						hasChanges = YES;
					}
				}
				[category release];
			}
			if (hasChanges) {
				DLog(@"Has New Categories");
			}
			[self dispatchSelector:@selector(downloadedFromUshahidi:categories:error:hasChanges:) 
							target:delegate 
						   objects:self, [[self.deployment.categories allValues] sortedArrayUsingSelector:@selector(compareByTitle:)], nil, hasChanges, nil];
		}		
	}
}

- (void) getCategoriesFailed:(ASIHTTPRequest *)request {
	DLog(@"request:%@", [request.originalURL absoluteString]);
	DLog(@"error: %@", [[request error] localizedDescription]);
	id<UshahidiDelegate> delegate = [request.userInfo objectForKey:@"delegate"];
	[self dispatchSelector:@selector(downloadedFromUshahidi:categories:error:hasChanges:) 
					target:delegate 
				   objects:self, nil, [request error], NO, nil];
}

#pragma mark -
#pragma mark Countries

- (NSArray *) getCountriesForDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", [delegate class]);
	[self startAsynchronousRequest:[self.deployment getCountries] 
					   forDelegate:delegate
					finishSelector:@selector(getCountriesFinished:)
					  failSelector:@selector(getCountriesFailed:)];
	return [[self.deployment.countries allValues] sortedArrayUsingSelector:@selector(compareByName:)];
}

- (void)getCountriesFinished:(ASIHTTPRequest *)request {
	DLog(@"request: %@", [request.originalURL absoluteString]);
	DLog(@"status: %@", [request responseStatusMessage]);
	id<UshahidiDelegate> delegate = [request.userInfo objectForKey:@"delegate"];
	if ([request responseStatusCode] != HttpStatusOK) {
		NSError *error = [NSError errorWithDomain:self.deployment.domain code:[request responseStatusCode] message:[request responseStatusMessage]];
		[self dispatchSelector:@selector(downloadedFromUshahidi:countries:error:hasChanges:) 
						target:delegate 
					   objects:self, [self.deployment.countries allValues], error, NO, nil];
	}
	else {
		NSDictionary *json = [[request responseString] JSONValue];
		if (json == nil) {
			NSError *error = [NSError errorWithDomain:self.deployment.domain code:HttpStatusInternalServerError message:NSLocalizedString(@"Invalid server response", nil)];
			[self dispatchSelector:@selector(downloadedFromUshahidi:countries:error:hasChanges:) 
							target:delegate 
						   objects:self, [self.deployment.countries allValues], error, NO, nil];
		}
		else {
			NSDictionary *payload = [json	objectForKey:@"payload"];
			NSArray *countries = [payload objectForKey:@"countries"]; 
			BOOL hasChanges = NO;
			for (NSDictionary *dictionary in countries) {
				Country *country = [[Country alloc] initWithDictionary:[dictionary objectForKey:@"country"]];
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
						   objects:self, [self.deployment.countries allValues], nil, hasChanges, nil];
		}	
	}
}

- (void)getCountriesFailed:(ASIHTTPRequest *)request {
	DLog(@"request:%@", [request.originalURL absoluteString]);
	DLog(@"error: %@", [[request error] localizedDescription]);
	id<UshahidiDelegate> delegate = [request.userInfo objectForKey:@"delegate"];
	[self dispatchSelector:@selector(downloadedFromUshahidi:countries:error:hasChanges:) 
				target:delegate 
			   objects:self, nil, [request error], NO, nil];
}

#pragma mark -
#pragma mark Locations

- (NSArray *) getLocationsForDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", [delegate class]);
	[self startAsynchronousRequest:[self.deployment getLocations] 
					   forDelegate:delegate
					finishSelector:@selector(getLocationsFinished:)
					  failSelector:@selector(getLocationsFailed:)];
	return [[self.deployment.locations allValues] sortedArrayUsingSelector:@selector(compareByName:)];
}

- (void)getLocationsFinished:(ASIHTTPRequest *)request {
	DLog(@"request: %@", [request.originalURL absoluteString]);
	DLog(@"status: %@", [request responseStatusMessage]);
	id<UshahidiDelegate> delegate = [request.userInfo objectForKey:@"delegate"];
	if ([request responseStatusCode] != HttpStatusOK) {
		NSError *error = [NSError errorWithDomain:self.deployment.domain code:[request responseStatusCode] message:[request responseStatusMessage]];
		[self dispatchSelector:@selector(downloadedFromUshahidi:locations:error:hasChanges:)
						target:delegate
					   objects:self, [[self.deployment.locations allValues] sortedArrayUsingSelector:@selector(compareByName:)], error, NO, nil];
	}
	else {
		NSDictionary *json = [[request responseString] JSONValue];
		if (json == nil) {
			NSError *error = [NSError errorWithDomain:self.deployment.domain code:HttpStatusInternalServerError message:NSLocalizedString(@"Invalid server response", nil)];
			[self dispatchSelector:@selector(downloadedFromUshahidi:locations:error:hasChanges:)
							target:delegate
						   objects:self, [[self.deployment.locations allValues] sortedArrayUsingSelector:@selector(compareByName:)], error, NO, nil];
		}
		else {
			NSDictionary *payload = [json	objectForKey:@"payload"];
			NSArray *locations = [payload objectForKey:@"locations"]; 
			BOOL hasChanges = NO;
			for (NSDictionary *dictionary in locations) {
				Location *location = [[Location alloc] initWithDictionary:[dictionary objectForKey:@"location"]];
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
						   objects:self, [[self.deployment.locations allValues] sortedArrayUsingSelector:@selector(compareByName:)], nil, hasChanges, nil];
		}	
	}
}

- (void)getLocationsFailed:(ASIHTTPRequest *)request {
	DLog(@"request:%@", [request.originalURL absoluteString]);
	DLog(@"error: %@", [[request error] localizedDescription]);
	id<UshahidiDelegate> delegate = [request.userInfo objectForKey:@"delegate"];
	[self dispatchSelector:@selector(downloadedFromUshahidi:locations:error:hasChanges:) 
					target:delegate 
				   objects:self, nil, [request error], NO, nil];	
}

#pragma mark -
#pragma mark Incidents

- (NSArray *) getIncidents {
	return [self.deployment.incidents allValues];
}

- (NSArray *) getIncidentsPending {
	return self.deployment.pending;
}

- (NSArray *) getIncidentsForDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@", [delegate class]);
	if ([[Settings sharedSettings] downloadMaps]) {
		for (Incident *incident in [self.deployment.incidents allValues]) {
			[self downloadMap:incident forDelegate:delegate];
		}
		[self.mapQueue go];
	}
	NSString *requestURL = self.deployment.sinceID != nil
		? [self.deployment getIncidentsBySinceID:self.deployment.sinceID] : [self.deployment getIncidents];
	[self startAsynchronousRequest:requestURL 
					   forDelegate:delegate
					finishSelector:@selector(getIncidentsFinished:)
					  failSelector:@selector(getIncidentsFailed:)];	
	return [self.deployment.incidents allValues];
}

- (NSArray *) getIncidentsByCategoryID:(NSString *)categoryID forDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ categoryID:%@", [delegate class], categoryID);
	[self startAsynchronousRequest:[self.deployment getIncidentsByCategoryID:categoryID] 
					   forDelegate:delegate
					finishSelector:@selector(getIncidentsFinished:)
					  failSelector:@selector(getIncidentsFailed:)];
	return [self.deployment.incidents allValues];
}

- (NSArray *) getIncidentsByCategoryName:(NSString *)categoryName forDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ categoryName:%@", [delegate class], categoryName);
	[self startAsynchronousRequest:[self.deployment getIncidentsByCategoryName:categoryName] 
					   forDelegate:delegate
					finishSelector:@selector(getIncidentsFinished:)
					  failSelector:@selector(getIncidentsFailed:)];
	return [self.deployment.incidents allValues];
}

- (NSArray *) getIncidentsByLocationID:(NSString *)locationID forDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ locationID:%@", [delegate class], locationID);
	[self startAsynchronousRequest:[self.deployment getIncidentsByLocationID:locationID] 
					   forDelegate:delegate
					finishSelector:@selector(getIncidentsFinished:)
					  failSelector:@selector(getIncidentsFailed:)];
	return [self.deployment.incidents allValues];
}

- (NSArray *) getIncidentsByLocationName:(NSString *)locationName forDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ locationName:%@", [delegate class], locationName);
	[self startAsynchronousRequest:[self.deployment getIncidentsByLocationName:locationName] 
					   forDelegate:delegate
					finishSelector:@selector(getIncidentsFinished:)
					  failSelector:@selector(getIncidentsFailed:)];
	return [self.deployment.incidents allValues];
}

- (NSArray *) getIncidentsBySinceID:(NSString *)sinceID forDelegate:(id<UshahidiDelegate>)delegate {
	DLog(@"delegate: %@ sinceID:%@", [delegate class], sinceID);
	[self startAsynchronousRequest:[self.deployment getIncidentsBySinceID:sinceID] 
					   forDelegate:delegate
					finishSelector:@selector(getIncidentsFinished:)
					  failSelector:@selector(getIncidentsFailed:)];	
	return [self.deployment.incidents allValues];
}

- (void)getIncidentsFinished:(ASIHTTPRequest *)request {
	DLog(@"request: %@", [request.originalURL absoluteString]);
	DLog(@"status: %@", [request responseStatusMessage]);
	id<UshahidiDelegate> delegate = [request.userInfo objectForKey:@"delegate"];
	if ([request responseStatusCode] != HttpStatusOK) {
		NSError *error = [NSError errorWithDomain:self.deployment.domain code:[request responseStatusCode] message:[request responseStatusMessage]];
		[self dispatchSelector:@selector(downloadedFromUshahidi:incidents:pending:error:hasChanges:) 
						target:delegate 
					   objects:self, [self.deployment.incidents allValues], self.deployment.pending, error, NO, nil];
	}
	else {
		NSDictionary *json = [[request responseString] JSONValue];
		if (json == nil) {
			DLog(@"response: %@", [request responseString]);
			NSError *error = [NSError errorWithDomain:self.deployment.domain code:HttpStatusInternalServerError message:NSLocalizedString(@"Invalid Server Response", nil)];
			[self dispatchSelector:@selector(downloadedFromUshahidi:incidents:pending:error:hasChanges:) 
							target:delegate 
						   objects:self, [self.deployment.incidents allValues], self.deployment.pending, error, NO, nil];
		}
		else {
			DLog(@"response: %@", json);
			BOOL hasChanges = NO;
			NSDictionary *payload = [json objectForKey:@"payload"];
			NSArray *incidents = [payload objectForKey:@"incidents"]; 
			for (NSDictionary *dictionary in incidents) {
				Incident *incident = [[Incident alloc] initWithDictionary:[dictionary objectForKey:@"incident"]];
				if (incident.identifier != nil) {
					if ([self.deployment.incidents objectForKey:incident.identifier] == nil) {
						[self.deployment.incidents setObject:incident forKey:incident.identifier];
						hasChanges = YES;
					}
					if (self.deployment.sinceID == nil) {
						self.deployment.sinceID = incident.identifier;
					}
					else if ([self.deployment.sinceID intValue] < [incident.identifier intValue]) {
						self.deployment.sinceID = incident.identifier;
					}
				}
				NSDictionary *media = [dictionary objectForKey:@"media"];
				if (media != nil && [media isKindOfClass:[NSArray class]]) {
					for (NSDictionary *item in media) {
						DLog(@"media: %@", item);
						NSInteger mediatype = [item intForKey:@"type"];
						if (mediatype == MediaTypePhoto) {
							Photo *photo = [[[Photo alloc] initWithDictionary:item] autorelease];
							[incident addPhoto:photo];
							if (photo.url != nil && photo.image == nil && photo.downloading == NO) {
								[self downloadPhoto:incident photo:photo forDelegate:delegate];
							}
						}
						else if (mediatype == MediaTypeVideo) {
							[incident addVideo:[[Video alloc] initWithDictionary:item]];
						}
						else if (mediatype == MediaTypeSound) {
							[incident addSound:[[Sound alloc] initWithDictionary:item]];
						}
						else if (mediatype == MediaTypeNews) {
							[incident addNews:[[News alloc] initWithDictionary:item]];
						}	
					}
					[self.photoQueue go];
				}
				NSDictionary *categories = [dictionary objectForKey:@"categories"];
				if (categories != nil && [categories isKindOfClass:[NSArray class]]) {
					DLog(@"categories: %@ - %@", [categories class], categories);
					for (NSDictionary *item in categories) {
						Category *category = [[Category alloc] initWithDictionary:[item objectForKey:@"category"]];
						if ([incident hasCategory:category] == NO) {
							[incident addCategory:category];
						}
						if (category.identifier != nil && [self.deployment.categories objectForKey:category.identifier] == nil) {
							[self.deployment.categories setObject:category forKey:category.identifier];
						}
						[category release];
					}
				}
				if ([[Settings sharedSettings] downloadMaps] && incident.map == nil) {
					[self downloadMap:incident forDelegate:delegate];
				}
				[incident release];
			}
			if (hasChanges) {
				DLog(@"Has New Incidents");
			}
			if ([[Settings sharedSettings] downloadMaps]) {
				[self.mapQueue go];
			}
			self.deployment.lastSync = [NSDate date];
			[self dispatchSelector:@selector(downloadedFromUshahidi:incidents:pending:error:hasChanges:) 
							target:delegate 
						   objects:self, [self.deployment.incidents allValues], self.deployment.pending, nil, hasChanges, nil];
		}	
	}
}

- (void)getIncidentsFailed:(ASIHTTPRequest *)request {
	DLog(@"request:%@", [request.originalURL absoluteString]);
	DLog(@"error: %@", [[request error] localizedDescription]);
	id<UshahidiDelegate> delegate = [request.userInfo objectForKey:@"delegate"];
	[self dispatchSelector:@selector(downloadedFromUshahidi:incidents:pending:error:hasChanges:) 
					target:delegate 
				   objects:self, nil, nil, [request error], NO, nil];
}
#pragma mark -
#pragma mark Photo

- (void) downloadPhoto:(Incident *)incident photo:(Photo *)photo forDelegate:(id<UshahidiDelegate>)delegate {
	if (photo.url != nil && photo.image == nil && photo.downloading == NO) {
		photo.downloading = YES;
		NSURL *url = [NSURL URLWithStrings:self.deployment.url	, 
										   @"/media/uploads/",
										   photo.url, nil];
		DLog(@"downloadPhoto: %@", [url absoluteString]);
		ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
		[request setDelegate:self];
		[request setDidFinishSelector:@selector(downloadPhotoFinished:)];
		[request setDidFailSelector:@selector(downloadPhotoFailed:)];
		[request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:delegate, @"delegate",
																		incident, @"incident",
																		photo, @"photo", nil]];
		[self.photoQueue addOperation:request];
	}
}

- (void)downloadPhotoFinished:(ASIHTTPRequest *)request {
	id<UshahidiDelegate> delegate = [request.userInfo objectForKey:@"delegate"];
	Incident *incident = (Incident *)[request.userInfo objectForKey:@"incident"];
	Photo *photo = (Photo *)[request.userInfo objectForKey:@"photo"];
	if (photo != nil) {
		photo.downloading = NO;	
	}
	if ([request error] != nil) {
		DLog(@"ERROR: %@", [[request error] localizedDescription]);
	} 
	else if ([request responseData] != nil) {
		DLog(@"RESPONSE: BINARY IMAGE %@", [request.originalURL absoluteString]);
		photo.image = [UIImage imageWithData:[request responseData]];
		[self dispatchSelector:@selector(downloadedFromUshahidi:incident:photo:) 
						target:delegate 
					   objects:self, incident, photo, nil];
	}
	else {
		DLog(@"RESPONSE: %@", [request responseString]);
	}
}

- (void)downloadPhotoFailed:(ASIHTTPRequest *)request {
	DLog(@"REQUEST:%@", [request.originalURL absoluteString]);
	DLog(@"ERROR: %@", [[request error] localizedDescription]);
	Photo *photo = (Photo *)[request.userInfo objectForKey:@"photo"];
	if (photo != nil) {
		photo.downloading = NO;
	}
}

- (void)photoQueueFinished:(ASINetworkQueue *)queue {
	DLog(@"photoQueueFinished");
}

#pragma mark -
#pragma mark Maps

- (void) downloadMap:(Incident *)incident forDelegate:(id<UshahidiDelegate>)delegate {
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
		[request setDelegate:self];
		[request setDidFinishSelector:@selector(downloadMapFinished:)];
		[request setDidFailSelector:@selector(downloadMapFailed:)];
		[request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:delegate, @"delegate",
																		incident, @"incident", nil]];
		[self.mapQueue addOperation:request];	
	}
}

- (void)downloadMapFinished:(ASIHTTPRequest *)request {
	id<UshahidiDelegate> delegate = [request.userInfo objectForKey:@"delegate"];
	Incident *incident = (Incident *)[request.userInfo objectForKey:@"incident"];
	if ([request error] != nil) {
		DLog(@"ERROR: %@", [[request error] localizedDescription]);
	} 
	else if ([request responseData] != nil) {
		DLog(@"RESPONSE: MAP IMAGE %@", [request.originalURL absoluteString]);
		UIImage *map = [UIImage imageWithData:[request responseData]];
		if (map.size.width == kGoogleOverCapacitySize && map.size.height == kGoogleOverCapacitySize) {
			DLog(@"Over Capacity, Cancelling Map Queue!!");
			[self.mapQueue cancelAllOperations];	
		}
		else {
			incident.map = map;
			[self dispatchSelector:@selector(downloadedFromUshahidi:incident:map:) 
							target:delegate 
						   objects:self, incident, incident.map, nil];
		}
	}
	else {
		DLog(@"RESPONSE: %@", [request responseString]);
	}
}

- (void)downloadMapFailed:(ASIHTTPRequest *)request {
	DLog(@"REQUEST: %@", [request.originalURL absoluteString]);
	DLog(@"ERROR: %@", [[request error] localizedDescription]);
}

- (void)mapQueueFinished:(ASINetworkQueue *)queue {
	DLog(@"mapQueueFinished");
}

#pragma mark -
#pragma mark ASIHTTPRequest

- (ASIHTTPRequest *) startAsynchronousRequest:(NSString *)url 
								  forDelegate:(id<UshahidiDelegate>)delegate 
							   finishSelector:(SEL)finishSelector
								 failSelector:(SEL)failSelector {
	DLog(@"url: %@", url);
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	[request setDelegate:self];
	[request setShouldRedirect:YES];
	[request setDidFinishSelector:finishSelector];
	[request setDidFailSelector:failSelector];
	[request setUserInfo:[NSDictionary dictionaryWithObject:delegate forKey:@"delegate"]];
	[request startAsynchronous];
	return request;
}

@end
