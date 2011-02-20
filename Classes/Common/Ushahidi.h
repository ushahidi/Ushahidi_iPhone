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
@class Photo;
@class Checkin;

#define kMainQueueFinished @"mainQueueFinished"
#define kMapQueueFinished @"mapQueueFinished"
#define kPhotoQueueFinished @"photoQueueFinished"
#define kUploadQueueFinished @"uploadQueueFinished"

@interface Ushahidi : NSObject<ASIHTTPRequestDelegate> {
	
@private
	Deployment *deployment;
	NSMutableDictionary *maps;
	NSMutableDictionary *deployments;
	NSOperationQueue *mainQueue;
	NSOperationQueue *mapQueue;
	NSOperationQueue *photoQueue;
	NSOperationQueue *uploadQueue;
	NSString *mapDistance;
}

+ (Ushahidi *) sharedUshahidi;

- (void) archive;

- (NSArray *) getMaps;
- (NSArray *) getMapsForDelegate:(id<UshahidiDelegate>)delegate latitude:(NSString *)latitude longitude:(NSString *)longitude distance:(NSString *)distance;

- (BOOL) hasUsers;
- (NSArray *) getUsers;

- (NSArray *) getDeploymentsUsingSorter:(SEL)sorter;
- (void) loadDeployment:(Deployment *)deployment inBackground:(BOOL)inBackground;
- (BOOL) addDeployment:(Deployment *)deployment;
- (BOOL) addDeploymentByName:(NSString *)name andUrl:(NSString *)url;
- (BOOL) removeDeployment:(Deployment *)deployment;
- (Deployment *) getDeploymentWithUrl:(NSString *)url;
- (NSString *) deploymentName;

- (Incident *) getIncidentWithIdentifer:(NSString *)identifer;
- (BOOL) addIncident:(Incident *)incident forDelegate:(id<UshahidiDelegate>)delegate;
- (BOOL) uploadIncident:(Incident *)incident forDelegate:(id<UshahidiDelegate>)delegate;
- (void) uploadIncidentsForDelegate:(id<UshahidiDelegate>)delegate;

- (NSArray *) getCheckinsForDelegate:(id<UshahidiDelegate>)delegate;
- (BOOL) uploadCheckin:(Checkin *)checkin forDelegate:(id<UshahidiDelegate>)delegate;
- (BOOL) deploymentSupportsCheckins;

- (BOOL) hasCategories;
- (NSArray *) getCategories;
- (NSArray *) getCategoriesForDelegate:(id<UshahidiDelegate>)delegate;

- (BOOL) hasLocations;
- (NSArray *) getLocations;
- (NSArray *) getLocationsForDelegate:(id<UshahidiDelegate>)delegate;

- (NSArray *) getIncidents;
- (NSArray *) getIncidentsPending;
- (NSArray *) getIncidentsForDelegate:(id<UshahidiDelegate>)delegate;
- (NSURL *) getUrlForIncident:(Incident *)incident;

- (void) downloadPhoto:(Incident *)incident photo:(Photo *)photo forDelegate:(id<UshahidiDelegate>)delegate;

@end
			 
@protocol UshahidiDelegate <NSObject>

@optional

- (void) downloadingFromUshahidi:(Ushahidi *)ushahidi categories:(NSArray *)categories;
- (void) downloadingFromUshahidi:(Ushahidi *)ushahidi locations:(NSArray *)locations;
- (void) downloadingFromUshahidi:(Ushahidi *)ushahidi incidents:(NSArray *)incidents pending:(NSArray *)pending;
- (void) downloadingFromUshahidi:(Ushahidi *)ushahidi checkins:(NSArray *)checkins;

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi maps:(NSArray *)maps error:(NSError *)error hasChanges:(BOOL)hasChanges;
- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi deployments:(NSArray *)deployments error:(NSError *)error hasChanges:(BOOL)hasChanges;
- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi categories:(NSArray *)categories error:(NSError *)error hasChanges:(BOOL)hasChanges;
- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi locations:(NSArray *)locations error:(NSError *)error hasChanges:(BOOL)hasChanges;
- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi incidents:(NSArray *)incidents pending:(NSArray *)pending error:(NSError *)error hasChanges:(BOOL)hasChanges;
- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi incident:(Incident *)incident map:(UIImage *)map;
- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi incident:(Incident *)incident photo:(Photo *)photo;
- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi checkins:(NSArray *)checkins error:(NSError *)error hasChanges:(BOOL)hasChanges;
- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi users:(NSArray *)users hasChanges:(BOOL)hasChanges;

- (void) uploadingToUshahidi:(Ushahidi *)ushahidi incident:(Incident *)incident;
- (void) uploadedToUshahidi:(Ushahidi *)ushahidi incident:(Incident *)incident error:(NSError *)error;

- (void) uploadingToUshahidi:(Ushahidi *)ushahidi checkin:(Checkin *)checkin;
- (void) uploadedToUshahidi:(Ushahidi *)ushahidi checkin:(Checkin *)checkin error:(NSError *)error;

@end
