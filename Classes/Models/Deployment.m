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

#import "Deployment.h"
#import "Location.h"
#import "NSString+Extension.h"

@interface Deployment ()

@end

@implementation Deployment

@synthesize name, url, domain, countries, categories, locations, incidents, pending, sinceID, synced, added;

- (id)initWithName:(NSString *)theName url:(NSString *)theUrl {
	if (self = [super init]){
		self.name = theName;
		self.url = theUrl;
		if ([[theUrl lowercaseString] hasPrefix:@"http://"]) {
			self.domain = [theUrl stringByReplacingOccurrencesOfString:@"http://" withString:@""];
		}
		else if ([[theUrl lowercaseString] hasPrefix:@"https://"]) {
			self.domain = [theUrl stringByReplacingOccurrencesOfString:@"https://" withString:@""];
		}
		else {
			self.domain = theUrl;
		} 
		self.countries = [[NSMutableDictionary alloc] init];
		self.categories = [[NSMutableDictionary alloc] init];
		self.locations = [[NSMutableDictionary alloc] init];
		self.incidents = [[NSMutableDictionary alloc] init];
		self.pending = [[NSMutableArray alloc] init];
		self.added = [NSDate date];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.name forKey:@"name"];
	[encoder encodeObject:self.url forKey:@"url"];
	[encoder encodeObject:self.domain forKey:@"domain"];
	[encoder encodeObject:self.sinceID forKey:@"sinceID"];
	[encoder encodeObject:self.countries forKey:@"countries"];
	[encoder encodeObject:self.categories forKey:@"categories"];
	[encoder encodeObject:self.locations forKey:@"locations"];
	[encoder encodeObject:self.incidents forKey:@"incidents"];
	[encoder encodeObject:self.pending forKey:@"pending"];
	[encoder encodeObject:self.synced forKey:@"synced"];
	[encoder encodeObject:self.added forKey:@"added"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]){
		self.name = [decoder decodeObjectForKey:@"name"];
		self.url = [decoder decodeObjectForKey:@"url"];
		self.domain = [decoder decodeObjectForKey:@"domain"];
		self.sinceID = [decoder decodeObjectForKey:@"sinceID"];
		
		self.countries = [decoder decodeObjectForKey:@"countries"];
		if (self.countries == nil) self.countries = [[NSMutableDictionary alloc] init];
		
		self.categories = [decoder decodeObjectForKey:@"categories"];
		if (self.categories == nil) self.categories = [[NSMutableDictionary alloc] init];
		
		self.locations = [decoder decodeObjectForKey:@"locations"];
		if (self.locations == nil) self.locations = [[NSMutableDictionary alloc] init];
		
		self.incidents = [decoder decodeObjectForKey:@"incidents"];
		if (self.incidents == nil) self.incidents = [[NSMutableDictionary alloc] init];
		
		self.pending = [decoder decodeObjectForKey:@"pending"];
		if (self.pending == nil) self.pending = [[NSMutableArray alloc] init];
		
		self.synced = [decoder decodeObjectForKey:@"synced"];
		self.added = [decoder decodeObjectForKey:@"added"];
	}
	return self;
}

- (BOOL) matchesString:(NSString *)string {
	NSString *lowercaseString = [string lowercaseString];
	return	[[self.name lowercaseString] anyWordHasPrefix:lowercaseString];
}


- (BOOL) containsLocation:(Location *)location {
	for (Location *current in [self.locations allValues]) {
		if ([current equals:location.name latitude:location.latitude longitude:location.longitude]) {
			return YES;
		}
	}
	return NO;
}

- (NSComparisonResult)compareByName:(Deployment *)deployment {
	return [self.name localizedCaseInsensitiveCompare:deployment.name];
}

- (NSComparisonResult)compareByDate:(Deployment *)deployment {
		return [deployment.added compare:self.added];
}

- (void)dealloc {
	[name release];
	[url release];
	[domain release];
	[countries release];
	[categories release];
	[locations release];
	[incidents release];
	[pending release];
	[sinceID release];
	[synced release];
	[added release];
    [super dealloc];
}

#pragma mark -
#pragma mark API Keys

- (NSString *) getGoogleApiKey {
	return [NSString stringWithFormat:@"http://%@/api?task=apikeys&by=google&resp=json", self.domain];
}

- (NSString *) getYahooApiKey {
	return [NSString stringWithFormat:@"http://%@/api?task=apikeys&by=yahoo&resp=json", self.domain];
}

- (NSString *) getMicrosoftApiKey {
	return [NSString stringWithFormat:@"http://%@/api?task=apikeys&by=microsoft&resp=json", self.domain];
}

#pragma mark -
#pragma mark Categories

- (NSString *) getCategories {
	return [NSString stringWithFormat:@"http://%@/api?task=categories&resp=json", self.domain];
}

- (NSString *) getCategoryByID:(NSString *)categoryID {
	return [NSString stringWithFormat:@"http://%@/api?task=categories&by=%@&resp=json", self.domain, categoryID];
}

#pragma mark -
#pragma mark Countries

- (NSString *) getCountries {
	return [NSString stringWithFormat:@"http://%@/api?task=countries&resp=json", self.domain];
}

- (NSString *) getCountryByID:(NSString *)countryID {
	return [NSString stringWithFormat:@"http://%@/api?task=country&by=%@&resp=json", self.domain, countryID];
}

- (NSString *) getCountryByISO:(NSString *)countryISO {
	return [NSString stringWithFormat:@"http://%@/api?task=country&by=countryiso&iso=%@&resp=json", self.domain, countryISO];
}

- (NSString *) getCountryByName:(NSString *)countryName {
	return [NSString stringWithFormat:@"http://%@/api?task=country&by=countryname&name=%@&resp=json", self.domain, countryName];
}

#pragma mark -
#pragma mark Locations

- (NSString *) getLocations {
	return [NSString stringWithFormat:@"http://%@/api?task=locations&resp=json", self.domain];
}

- (NSString *) getLocationByID:(NSString *)locationID {
	return [NSString stringWithFormat:@"http://%@/api?task=location&by=locid&id=%@&resp=json", self.domain, locationID];
}

- (NSString *) getLocationsByCountryID:(NSString *)countryID {
	return [NSString stringWithFormat:@"http://%@/api?task=location&by=country&id=%@&resp=json", self.domain, countryID];
}

#pragma mark -
#pragma mark Incidents

- (NSString *) getIncidents {
	return [NSString stringWithFormat:@"http://%@/api?task=incidents&by=all&resp=json", self.domain];
}

- (NSString *) getIncidentsByCategoryID:(NSString *)categoryID {
	return [NSString stringWithFormat:@"http://%@/api?task=incidents&by=catid&id=%@&resp=json", self.domain, categoryID];
}

- (NSString *) getIncidentsByCategoryName:(NSString *)categoryName {
	return [NSString stringWithFormat:@"http://%@/api?task=incidents&by=catname&name=%@&resp=json", self.domain, categoryName];
}

- (NSString *) getIncidentsByLocationID:(NSString *)locationID {
	return [NSString stringWithFormat:@"http://%@/api?task=incidents&by=locid&id=%@&resp=json", self.domain, locationID];
}

- (NSString *) getIncidentsByLocationName:(NSString *)locationName {
	return [NSString stringWithFormat:@"http://%@/api?task=incidents&by=locname&name=%@&resp=json", self.domain, locationName];
}

- (NSString *) getIncidentsBySinceID:(NSString *)theSinceID {
	return [NSString stringWithFormat:@"http://%@/api?task=incidents&by=sinceid&id=%@&resp=json", self.domain, theSinceID];
}

- (NSString *) getIncidentCount {
	return [NSString stringWithFormat:@"http://%@/api?task=incidentcount&resp=json", self.domain];
}

- (NSString *) getGeoGraphicMidPoint {
	return [NSString stringWithFormat:@"http://%@/api?task=geographicmidpoint&resp=json", self.domain];
}

#pragma mark -
#pragma mark System

- (NSString *) getDeploymentVersion {
	return [NSString stringWithFormat:@"http://%@/api?task=version&resp=json", self.domain];
}

#pragma mark -
#pragma mark Posts

- (NSString *) getPostReport {
	return [NSString stringWithFormat:@"http://%@/api?task=report&resp=json", self.domain];
}

- (NSString *) getPostNews {
	return [NSString stringWithFormat:@"http://%@/api?task=tagnews&resp=json", self.domain];
}

- (NSString *) getPostVideo {
	return [NSString stringWithFormat:@"http://%@/api?task=tagvideo&resp=json", self.domain];
}

- (NSString *) getPostPhoto {
	return [NSString stringWithFormat:@"http://%@/api?task=tagphoto&resp=json", self.domain];
}

@end
