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

@synthesize identifier, name, description, url, domain;
@synthesize categories, locations, incidents;
@synthesize discovered, synced, added, sinceID, pending;

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
	[encoder encodeObject:self.identifier forKey:@"identifier"];
	[encoder encodeObject:self.name forKey:@"name"];
	[encoder encodeObject:self.description forKey:@"description"];
	[encoder encodeObject:self.url forKey:@"url"];
	[encoder encodeObject:self.domain forKey:@"domain"];
	[encoder encodeObject:self.sinceID forKey:@"sinceID"];
	[encoder encodeObject:self.synced forKey:@"synced"];
	[encoder encodeObject:self.added forKey:@"added"];
	[encoder encodeObject:self.discovered forKey:@"discovered"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]){
		self.identifier = [decoder decodeObjectForKey:@"identifier"];
		self.name = [decoder decodeObjectForKey:@"name"];
		self.description = [decoder decodeObjectForKey:@"description"];
		self.url = [decoder decodeObjectForKey:@"url"];
		self.domain = [decoder decodeObjectForKey:@"domain"];
		self.sinceID = [decoder decodeObjectForKey:@"sinceID"];
		self.synced = [decoder decodeObjectForKey:@"synced"];
		self.added = [decoder decodeObjectForKey:@"added"];
		self.discovered = [decoder decodeObjectForKey:@"discovered"];
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
	
	[NSKeyedArchiver archiveObject:self.pending forPath:path andKey:@"pending"];
	DLog(@"pending: %d", [self.pending count]);
}

- (void) purge {
	[self.categories removeAllObjects];
	[self.locations removeAllObjects];
	[self.incidents removeAllObjects];
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
	[identifier release];
	[name release];
	[url release];
	[description release];
	[domain release];
	[categories release];
	[locations release];
	[incidents release];
	[pending release];
	[sinceID release];
	[synced release];
	[added release];
	[discovered release];
    [super dealloc];
}

#pragma mark -
#pragma mark Categories

- (NSString *) getCategories {
	return [self.url appendUrlStringWithFormat:@"api?task=categories&resp=json"];
}

- (NSString *) getCategoryByID:(NSString *)categoryID {
	return [self.url appendUrlStringWithFormat:@"api?task=categories&by=%@&resp=json", categoryID];
}

#pragma mark -
#pragma mark Countries

- (NSString *) getCountries {
	return [self.url appendUrlStringWithFormat:@"api?task=countries&resp=json"];
}

- (NSString *) getCountryByID:(NSString *)countryID {
	return [self.url appendUrlStringWithFormat:@"api?task=country&by=%@&resp=json", countryID];
}

- (NSString *) getCountryByISO:(NSString *)countryISO {
	return [self.url appendUrlStringWithFormat:@"api?task=country&by=countryiso&iso=%@&resp=json", countryISO];
}

- (NSString *) getCountryByName:(NSString *)countryName {
	return [self.url appendUrlStringWithFormat:@"api?task=country&by=countryname&name=%@&resp=json", countryName];
}

#pragma mark -
#pragma mark Locations

- (NSString *) getLocations {
	return	[self.url appendUrlStringWithFormat:@"api?task=locations&resp=json"];
}

- (NSString *) getLocationByID:(NSString *)locationID {
	return [self.url appendUrlStringWithFormat:@"api?task=location&by=locid&id=%@&resp=json", locationID];
}

- (NSString *) getLocationsByCountryID:(NSString *)countryID {
	return [self.url appendUrlStringWithFormat:@"api?task=location&by=country&id=%@&resp=json", countryID];
}

#pragma mark -
#pragma mark Incidents

- (NSString *) getIncidents {
	return [self.url appendUrlStringWithFormat:@"api?task=incidents&by=all&resp=json"];
}

- (NSString *) getIncidentsByCategoryID:(NSString *)categoryID {
	return [self.url appendUrlStringWithFormat:@"api?task=incidents&by=catid&id=%@&resp=json", categoryID];
}

- (NSString *) getIncidentsByCategoryName:(NSString *)categoryName {
	return [self.url appendUrlStringWithFormat:@"api?task=incidents&by=catname&name=%@&resp=json", categoryName];
}

- (NSString *) getIncidentsByLocationID:(NSString *)locationID {
	return [self.url appendUrlStringWithFormat:@"api?task=incidents&by=locid&id=%@&resp=json", locationID];
}

- (NSString *) getIncidentsByLocationName:(NSString *)locationName {
	return [self.url appendUrlStringWithFormat:@"api?task=incidents&by=locname&name=%@&resp=json", locationName];
}

- (NSString *) getIncidentsBySinceID:(NSString *)theSinceID {
	return [self.url appendUrlStringWithFormat:@"api?task=incidents&by=sinceid&id=%@&resp=json", theSinceID];
}

- (NSString *) getIncidentCount {
	return [self.url appendUrlStringWithFormat:@"api?task=incidentcount&resp=json"];
}

- (NSString *) getGeoGraphicMidPoint {
	return [self.url appendUrlStringWithFormat:@"api?task=geographicmidpoint&resp=json"];
}

#pragma mark -
#pragma mark System

- (NSString *) getDeploymentVersion {
	return [self.url appendUrlStringWithFormat:@"api?task=version&resp=json"];
}

#pragma mark -
#pragma mark Posts

- (NSString *) getPostReport {
	return [self.url appendUrlStringWithFormat:@"api?task=report&resp=json"];
}

- (NSString *) getPostNews {
	return [self.url appendUrlStringWithFormat:@"api?task=tagnews&resp=json"];
}

- (NSString *) getPostVideo {
	return [self.url appendUrlStringWithFormat:@"api?task=tagvideo&resp=json"];
}

- (NSString *) getPostPhoto {
	return [self.url appendUrlStringWithFormat:@"api?task=tagphoto&resp=json"];
}

@end
