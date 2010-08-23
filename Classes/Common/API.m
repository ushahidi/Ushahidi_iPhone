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

#import "API.h"

@interface API ()

@property(nonatomic, retain) NSString *domain;

@end

@implementation API

@synthesize domain;

- (id) initWithDomain:(NSString *)theDomain {
	if (self = [super init]) {
		if ([theDomain hasPrefix:@"http://"]) {
			self.domain = [theDomain stringByReplacingOccurrencesOfString:@"http://" withString:@""];
		}
		else if ([theDomain hasPrefix:@"https://"]) {
			self.domain = [theDomain stringByReplacingOccurrencesOfString:@"https://" withString:@""];
		}
		else {
			self.domain = theDomain;
		} 
	}
    return self;
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
	return [NSString stringWithFormat:@"http://%@/api?task=countries&by=%@&resp=json", self.domain, countryID];
}

- (NSString *) getCountryByISO:(NSString *)countryISO {
	return [NSString stringWithFormat:@"http://%@/api?task=countries&by=countryiso&iso=%@&resp=json", self.domain, countryISO];
}

- (NSString *) getCountryByName:(NSString *)countryName {
	return [NSString stringWithFormat:@"http://%@/api?task=countries&by=countryname&name=%@&resp=json", self.domain, countryName];
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
	return [NSString stringWithFormat:@"http://%@/api?task=incidents&resp=json", self.domain];
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

- (NSString *) getIncidentsBySinceID:(NSString *)sinceID {
	return [NSString stringWithFormat:@"http://%@/api?task=incidents&by=sinceid&id=%@&resp=json", self.domain, sinceID];
}

- (NSString *) getIncidentCount {
	return [NSString stringWithFormat:@"http://%@/api?task=incidentcount&resp=json", self.domain];
}

- (NSString *) getGeoGraphicMidPoint {
	return [NSString stringWithFormat:@"http://%@/api?task=geographicmidpoint&resp=json", self.domain];
}

#pragma mark -
#pragma mark System

- (NSString *) getServerVersion {
	return [NSString stringWithFormat:@"http://%@/api?task=version&resp=json", self.domain];
}

@end
