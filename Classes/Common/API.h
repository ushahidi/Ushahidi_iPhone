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

@interface API : NSObject {

@private
	NSString *domain;
}

- (id) initWithDomain:(NSString *)domain;

+ (BOOL) isApiKeyUrl:(NSString *)url;
- (NSString *) getGoogleApiKey;
- (NSString *) getYahooApiKey;
- (NSString *) getMicrosoftApiKey;

+ (BOOL) isCategoriesUrl:(NSString *)url;
- (NSString *) getCategories;
- (NSString *) getCategoryByID:(NSString *)categoryID;

+ (BOOL) isCountriesUrl:(NSString *)url;
- (NSString *) getCountries;
- (NSString *) getCountryByID:(NSString *)countryID;
- (NSString *) getCountryByISO:(NSString *)countryISO;
- (NSString *) getCountryByName:(NSString *)countryName;

+ (BOOL) isLocationsUrl:(NSString *)url;
- (NSString *) getLocations;
- (NSString *) getLocationByID:(NSString *)locationID;
- (NSString *) getLocationsByCountryID:(NSString *)countryID;

+ (BOOL) isIncidentsUrl:(NSString *)url;
- (NSString *) getIncidents;
- (NSString *) getIncidentsByCategoryID:(NSString *)categoryID;
- (NSString *) getIncidentsByCategoryName:(NSString *)categoryName;
- (NSString *) getIncidentsByLocationID:(NSString *)locationID;
- (NSString *) getIncidentsByLocationName:(NSString *)locationName;
- (NSString *) getIncidentsBySinceID:(NSString *)sinceID;

- (NSString *) getIncidentCount;
- (NSString *) getGeoGraphicMidPoint;
- (NSString *) getDeploymentVersion;

- (NSString *) getPostReport;
- (NSString *) getPostNews;
- (NSString *) getPostVideo;
- (NSString *) getPostPhoto;

@end
