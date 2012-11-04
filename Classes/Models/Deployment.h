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

#import <Foundation/Foundation.h>

@class Location;

@interface Deployment : NSObject<NSCoding> {

@public
	NSString *identifier;
	NSString *name;
	NSString *description;
	NSString *url;
	NSString *domain;
	NSString *lastIncidentId;
	NSString *lastCheckinId;
	NSDate *synced;
	NSDate *added;
	NSDate *discovered;
	NSString *version;
	
	BOOL supportsCheckins;
	
	NSMutableDictionary *categories;
	NSMutableDictionary *locations;
	NSMutableDictionary *incidents;
	NSMutableDictionary *checkins;
	NSMutableDictionary *users;
	NSMutableArray *pending;
    
}

@property(nonatomic, retain) NSString *identifier;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *description;
@property(nonatomic, retain) NSString *url;
@property(nonatomic, retain) NSString *domain;
@property(nonatomic, retain) NSString *lastIncidentId;
@property(nonatomic, retain) NSString *lastCheckinId;
@property(nonatomic, retain) NSDate *synced;
@property(nonatomic, retain) NSDate *added;
@property(nonatomic, retain) NSDate *discovered;
@property(nonatomic, retain) NSString *version;

@property(nonatomic, retain) NSMutableDictionary *categories;
@property(nonatomic, retain) NSMutableDictionary *locations;
@property(nonatomic, retain) NSMutableDictionary *incidents;
@property(nonatomic, retain) NSMutableDictionary *checkins;
@property(nonatomic, retain) NSMutableDictionary *users;
@property(nonatomic, retain) NSMutableArray *pending;
@property(nonatomic, retain) NSMutableArray *customFormFields;

@property(nonatomic, assign) BOOL supportsCheckins;

- (id) initWithDictionary:(NSDictionary *)dictionary;
- (id) initWithName:(NSString *)name url:(NSString *)url;

- (void) archive;
- (void) unarchive;
- (void) purge;
- (NSString *) archiveFolder;

- (BOOL) matchesString:(NSString *)string;
- (BOOL) containsLocation:(Location *)location;

- (NSString *) getUrlForCheckins;
- (NSString *) getUrlForCheckinsBySinceID:(NSString *)sinceID;

- (NSString *) getUrlForCategories;
- (NSString *) getUrlForCategoryByID:(NSString *)categoryID;

- (NSString *) getUrlForLocations;
- (NSString *) getUrlForLocationByID:(NSString *)locationID;
- (NSString *) getUrlForLocationsByCountryID:(NSString *)countryID;

- (NSString *) getUrlForIncidents;
- (NSString *) getUrlForIncidentsByCategoryID:(NSString *)categoryID;
- (NSString *) getUrlForIncidentsByCategoryName:(NSString *)categoryName;
- (NSString *) getUrlForIncidentsByLocationID:(NSString *)locationID;
- (NSString *) getUrlForIncidentsByLocationName:(NSString *)locationName;
- (NSString *) getUrlForIncidentsBySinceID:(NSString *)sinceID;

- (NSString *) getUrlForIncidentCount;
- (NSString *) getUrlForGeoGraphicMidPoint;
- (NSString *) getUrlForDeploymentVersion;

- (NSString *) getUrlForPostReport;
- (NSString *) getUrlForPostNews;
- (NSString *) getUrlForPostVideo;
- (NSString *) getUrlForPostPhoto;
- (NSString *) getUrlForPostCheckin;
- (NSString *) getUrlForCustomForms;

- (NSComparisonResult)compareByName:(Deployment *)deployment;
- (NSComparisonResult)compareByDate:(Deployment *)deployment;
- (NSComparisonResult)compareByDiscovered:(Deployment *)deployment;

@end
