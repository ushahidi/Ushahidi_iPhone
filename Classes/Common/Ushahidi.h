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
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@protocol UshahidiDelegate;

@class Deployment;
@class Incident;
@class Location;
@class Category;
@class Country;

@interface Ushahidi : NSObject<ASIHTTPRequestDelegate> {

@public
	Deployment *deployment;
	
@private
	NSMutableDictionary *deployments;
	NSMutableDictionary *delegates;
}

@property(nonatomic, retain) Deployment *deployment;

+ (Ushahidi *) sharedUshahidi;

- (void) save;

- (BOOL)addDeployment:(Deployment *)deployment;
- (BOOL)addDeploymentByName:(NSString *)name andUrl:(NSString *)url;

- (BOOL)addIncident:(Incident *)incident;
- (BOOL)uploadIncident:(Incident *)incident;

- (NSArray *) getDeploymentsWithDelegate:(id<UshahidiDelegate>)delegate;

- (NSArray *) getCategoriesWithDelegate:(id<UshahidiDelegate>)delegate;
- (Category *) getCategoryByID:(NSString *)categoryID withDelegate:(id<UshahidiDelegate>)delegate;

- (NSArray *) getCountriesWithDelegate:(id<UshahidiDelegate>)delegate;
- (Country *) getCountryByID:(NSString *)countryId withDelegate:(id<UshahidiDelegate>)delegate;
- (Country *) getCountryByISO:(NSString *)countryISO withDelegate:(id<UshahidiDelegate>)delegate;
- (Country *) getCountryByName:(NSString *)countryName withDelegate:(id<UshahidiDelegate>)delegate;

- (NSArray *) getLocationsWithDelegate:(id<UshahidiDelegate>)delegate;
- (Location *) getLocationByID:(NSString *)locationID withDelegate:(id<UshahidiDelegate>)delegate;
- (NSArray *) getLocationsByCountryID:(NSString *)countryID withDelegate:(id<UshahidiDelegate>)delegate;

- (NSArray *) getIncidentsWithDelegate:(id<UshahidiDelegate>)delegate;
- (NSInteger) getIncidentsCountWithDelegate:(id<UshahidiDelegate>)delegate;
- (void) getGeoGraphicMidPointWithDelegate:(id<UshahidiDelegate>)delegate;
- (NSArray *) getIncidentsByCategoryID:(NSString *)categoryID withDelegate:(id<UshahidiDelegate>)delegate;
- (NSArray *) getIncidentsByCategoryName:(NSString *)categoryName withDelegate:(id<UshahidiDelegate>)delegate;
- (NSArray *) getIncidentsByLocationID:(NSString *)locationID withDelegate:(id<UshahidiDelegate>)delegate;
- (NSArray *) getIncidentsByLocationName:(NSString *)locationName withDelegate:(id<UshahidiDelegate>)delegate;
- (NSArray *) getIncidentsBySinceID:(NSString *)sinceID withDelegate:(id<UshahidiDelegate>)delegate;

@end
			 
@protocol UshahidiDelegate <NSObject>

@optional

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi apiKey:(NSString *)apiKey error:(NSError *)error hasChanges:(BOOL)hasChanges;
- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi deployments:(NSArray *)deployments error:(NSError *)error hasChanges:(BOOL)hasChanges;
- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi categories:(NSArray *)categories error:(NSError *)error hasChanges:(BOOL)hasChanges;
- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi countries:(NSArray *)countries error:(NSError *)error hasChanges:(BOOL)hasChanges;
- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi locations:(NSArray *)locations error:(NSError *)error hasChanges:(BOOL)hasChanges;
- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi incidents:(NSArray *)incidents error:(NSError *)error hasChanges:(BOOL)hasChanges;
- (void) uploadedToUshahidi:(Ushahidi *)ushahidi incident:(Incident *)incident;

@end
