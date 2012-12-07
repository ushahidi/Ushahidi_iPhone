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
#import "NSObject+Extension.h"
#import "NSKeyedArchiver+Extension.h"
#import "NSKeyedUnarchiver+Extension.h"
#import "NSDictionary+Extension.h"

@interface Deployment ()

@end

@implementation Deployment

@synthesize identifier, name, description, url, domain, version;
@synthesize categories, locations, incidents, checkins, users;
@synthesize discovered, synced, added, lastIncidentId, lastCheckinId, pending;
@synthesize supportsCheckins, incidentCustomFields;

- (id)initWithName:(NSString *)theName url:(NSString *)theUrl {
	if (self = [super init]){
		self.name = theName;
		self.url = theUrl;
		self.added = [NSDate date];
		if ([self.url hasPrefix:@"http://"]) {
			self.domain = [self.url stringByReplacingOccurrencesOfString:@"http://" withString:@""];
		}
		else if ([self.url hasPrefix:@"https://"]) {
			self.domain = [self.url stringByReplacingOccurrencesOfString:@"https://" withString:@""];
		}
		else {
			self.domain = self.url;
		} 
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]){
		self.identifier = [dictionary stringForKey:@"id"];
		self.url = [dictionary stringForKey:@"url"];
		
		self.name = [NSString stringByEscapingCharacters:[dictionary stringForKey:@"name"]];
		self.description = [NSString stringByEscapingCharacters:[dictionary stringForKey:@"description"]];
		
		self.discovered = [dictionary dateForKey:@"discovery_date"];
		self.added = [NSDate date];
		if ([self.url hasPrefix:@"http://"]) {
			self.domain = [self.url stringByReplacingOccurrencesOfString:@"http://" withString:@""];
		}
		else if ([self.url hasPrefix:@"https://"]) {
			self.domain = [self.url stringByReplacingOccurrencesOfString:@"https://" withString:@""];
		}
		else {
			self.domain = self.url;
		} 
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    DLog(@"%@", self.domain);
	[encoder encodeObject:self.identifier forKey:@"identifier"];
	[encoder encodeObject:self.name forKey:@"name"];
	[encoder encodeObject:self.description forKey:@"description"];
	[encoder encodeObject:self.url forKey:@"url"];
	[encoder encodeObject:self.domain forKey:@"domain"];
	[encoder encodeObject:self.lastIncidentId forKey:@"lastIncidentId"];
	[encoder encodeObject:self.lastCheckinId forKey:@"lastCheckinId"];
	[encoder encodeObject:self.synced forKey:@"synced"];
	[encoder encodeObject:self.added forKey:@"added"];
	[encoder encodeObject:self.discovered forKey:@"discovered"];
	[encoder encodeObject:self.version forKey:@"version"];
	[encoder encodeBool:self.supportsCheckins forKey:@"supportsCheckins"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]){
		self.identifier = [decoder decodeObjectForKey:@"identifier"];
		self.name = [decoder decodeObjectForKey:@"name"];
		self.description = [decoder decodeObjectForKey:@"description"];
		self.url = [decoder decodeObjectForKey:@"url"];
		self.domain = [decoder decodeObjectForKey:@"domain"];
		self.lastIncidentId = [decoder decodeObjectForKey:@"lastIncidentId"];
		self.lastCheckinId = [decoder decodeObjectForKey:@"lastCheckinId"];
		self.synced = [decoder decodeObjectForKey:@"synced"];
		self.added = [decoder decodeObjectForKey:@"added"];
		self.discovered = [decoder decodeObjectForKey:@"discovered"];
		self.version = [decoder decodeObjectForKey:@"version"];
		self.supportsCheckins = [decoder decodeBoolForKey:@"supportsCheckins"];
	}
	return self;
}

- (void) archive {
	DLog(@"Archiving %@", self.domain);
	NSString *path = [self archiveFolder];
	
	[NSKeyedArchiver archiveObject:self.categories forPath:path andKey:@"categories"];
	DLog(@"categories: %d", [self.categories count]);
	
	[NSKeyedArchiver archiveObject:self.locations forPath:path andKey:@"locations"];
	DLog(@"locations: %d", [self.locations count]);
	
	[NSKeyedArchiver archiveObject:self.incidents forPath:path andKey:@"incidents"];
	DLog(@"incidents: %d", [self.incidents count]);
	
	[NSKeyedArchiver archiveObject:self.checkins forPath:path andKey:@"checkins"];
	DLog(@"checkins: %d", [self.checkins count]);
	
	[NSKeyedArchiver archiveObject:self.users forPath:path andKey:@"users"];
	DLog(@"users: %d", [self.users count]);
	
	[NSKeyedArchiver archiveObject:self.pending forPath:path andKey:@"pending"];
	DLog(@"pending: %d", [self.pending count]);
}

- (void) purge {
    DLog(@"%@", self.domain);
	[self.categories removeAllObjects];
	[self.locations removeAllObjects];
	[self.incidents removeAllObjects];
	[self.checkins removeAllObjects];
	[self.users removeAllObjects];
	[self.pending removeAllObjects];
}

- (void) unarchive {
	DLog(@"Un-archiving %@", self.domain);
	NSString *path = [self archiveFolder];
	
	self.categories = [NSKeyedUnarchiver unarchiveObjectWithPath:path andKey:@"categories"];
	if (self.categories == nil) self.categories = [[NSMutableDictionary alloc] init];
	DLog(@"categories: %d", [self.categories count]);
	
	self.locations = [NSKeyedUnarchiver unarchiveObjectWithPath:path andKey:@"locations"];
	if (self.locations == nil) self.locations = [[NSMutableDictionary alloc] init];
	DLog(@"locations: %d", [self.locations count]);
	
	self.incidents = [NSKeyedUnarchiver unarchiveObjectWithPath:path andKey:@"incidents"];
	if (self.incidents == nil) self.incidents = [[NSMutableDictionary alloc] init];
	DLog(@"incidents: %d", [self.incidents count]);
	
	self.checkins = [NSKeyedUnarchiver unarchiveObjectWithPath:path andKey:@"checkins"];
	if (self.checkins == nil) self.checkins = [[NSMutableDictionary alloc] init];
	DLog(@"checkins: %d", [self.checkins count]);
	
	self.users = [NSKeyedUnarchiver unarchiveObjectWithPath:path andKey:@"users"];
	if (self.users == nil) self.users = [[NSMutableDictionary alloc] init];
	DLog(@"users: %d", [self.users count]);
	
	self.pending = [NSKeyedUnarchiver unarchiveObjectWithPath:path andKey:@"pending"];
	if (self.pending == nil) self.pending = [[NSMutableArray alloc] init];
	DLog(@"pending: %d", [self.pending count]);
}

- (NSString *) archiveFolder {
	return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:self.domain];
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

- (NSComparisonResult)compareByDiscovered:(Deployment *)deployment {
	return [deployment.discovered compare:self.discovered];
}

- (void)dealloc {
    DLog(@"%@", self.domain);
	[identifier release];
	[name release];
	[url release];
	[description release];
	[domain release];
	[categories release];
	[locations release];
	[incidents release];
	[checkins release];
	[pending release];
	[lastIncidentId release];
	[lastCheckinId release];
	[synced release];
	[added release];
	[discovered release];
	[version release];
    [incidentCustomFields release];
    [super dealloc];
}

#pragma mark -
#pragma mark Checkins

- (NSString *) getUrlForCheckins {
	return [self.url appendUrlStringWithFormat:@"api/?task=checkin&action=get_ci&sort=desc&sqllimit=100"];
}

- (NSString *) getUrlForCheckinsBySinceID:(NSString *)theSinceID {
	return [self.url appendUrlStringWithFormat:@"api/?task=checkin&action=get_ci&sort=desc&sqllimit=100&sinceid=%@", theSinceID];
}

#pragma mark -
#pragma mark Categories

- (NSString *) getUrlForCategories {
	return [self.url appendUrlStringWithFormat:@"api?task=categories&resp=json"];
}

- (NSString *) getUrlForCategoryByID:(NSString *)categoryID {
	return [self.url appendUrlStringWithFormat:@"api?task=categories&by=%@&resp=json", categoryID];
}

#pragma mark -
#pragma mark Countries

- (NSString *) getUrlForCountries {
	return [self.url appendUrlStringWithFormat:@"api?task=countries&resp=json"];
}

- (NSString *) getUrlForCountryByID:(NSString *)countryID {
	return [self.url appendUrlStringWithFormat:@"api?task=country&by=%@&resp=json", countryID];
}

- (NSString *) getUrlForCountryByISO:(NSString *)countryISO {
	return [self.url appendUrlStringWithFormat:@"api?task=country&by=countryiso&iso=%@&resp=json", countryISO];
}

- (NSString *) getUrlForCountryByName:(NSString *)countryName {
	return [self.url appendUrlStringWithFormat:@"api?task=country&by=countryname&name=%@&resp=json", countryName];
}

#pragma mark -
#pragma mark Locations

- (NSString *) getUrlForLocations {
	return	[self.url appendUrlStringWithFormat:@"api?task=locations&resp=json"];
}

- (NSString *) getUrlForLocationByID:(NSString *)locationID {
	return [self.url appendUrlStringWithFormat:@"api?task=location&by=locid&id=%@&resp=json", locationID];
}

- (NSString *) getUrlForLocationsByCountryID:(NSString *)countryID {
	return [self.url appendUrlStringWithFormat:@"api?task=location&by=country&id=%@&resp=json", countryID];
}

#pragma mark -
#pragma mark Incidents

- (NSString *) getUrlForIncidents {
	return [self.url appendUrlStringWithFormat:@"api?task=incidents&by=all&resp=json"];
}

- (NSString *) getUrlForIncidentsByCategoryID:(NSString *)categoryID {
	return [self.url appendUrlStringWithFormat:@"api?task=incidents&by=catid&id=%@&resp=json", categoryID];
}

- (NSString *) getUrlForIncidentsByCategoryName:(NSString *)categoryName {
	return [self.url appendUrlStringWithFormat:@"api?task=incidents&by=catname&name=%@&resp=json", categoryName];
}

- (NSString *) getUrlForIncidentsByLocationID:(NSString *)locationID {
	return [self.url appendUrlStringWithFormat:@"api?task=incidents&by=locid&id=%@&resp=json", locationID];
}

- (NSString *) getUrlForIncidentsByLocationName:(NSString *)locationName {
	return [self.url appendUrlStringWithFormat:@"api?task=incidents&by=locname&name=%@&resp=json", locationName];
}

- (NSString *) getUrlForIncidentsBySinceID:(NSString *)theSinceID {
	return [self.url appendUrlStringWithFormat:@"api?task=incidents&by=sinceid&id=%@&resp=json", theSinceID];
}

- (NSString *) getUrlForIncidentCount {
	return [self.url appendUrlStringWithFormat:@"api?task=incidentcount&resp=json"];
}

- (NSString *) getUrlForGeoGraphicMidPoint {
	return [self.url appendUrlStringWithFormat:@"api?task=geographicmidpoint&resp=json"];
}

- (NSString *) getURlForIncidentCustomFields{
    return [self.url appendUrlStringWithFormat:@"api?task=customforms&by=fields&id=2&resp=json"];
}

- (NSString *) getUrlforIncidentByID:(NSString *)ID {
    return [self.url appendUrlStringWithFormat:@"api?task=incidents&by=incidentid&id=%@&resp=json", ID];
}

#pragma mark -
#pragma mark System

- (NSString *) getUrlForDeploymentVersion {
	return [self.url appendUrlStringWithFormat:@"api?task=version&resp=json"];
}

#pragma mark -
#pragma mark Posts

- (NSString *) getUrlForPostReport {
	return [self.url appendUrlStringWithFormat:@"api?task=report&resp=json"];
}

- (NSString *) getUrlForPostNews {
	return [self.url appendUrlStringWithFormat:@"api?task=tagnews&resp=json"];
}

- (NSString *) getUrlForPostVideo {
	return [self.url appendUrlStringWithFormat:@"api?task=tagvideo&resp=json"];
}

- (NSString *) getUrlForPostPhoto {
	return [self.url appendUrlStringWithFormat:@"api?task=tagphoto&resp=json"];
}

- (NSString *) getUrlForPostCheckin {
	return [self.url appendUrlStringWithFormat:@"api?task=checkin&action=ci"];
}

@end
