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
#import "JSON.h"
@class UshahidiProjAppDelegate;
@interface API : NSObject {
	NSString *endPoint;
	NSString *errorCode;
	NSString *errorDesc;
	
	NSData *responseData;
	NSMutableArray *arrData;
	NSString *responseJSON;
	UshahidiProjAppDelegate *app;
	NSMutableArray *arrImage;
}

- (NSMutableArray *)categoryNames;
- (NSMutableArray *)incidentsByCategoryId:(int)catid;
- (NSMutableArray *)allIncidents;
-(NSMutableArray *)mapLocation;

- (BOOL)postIncidentWithDictionary:(NSMutableDictionary *)incidentinfo;
- (BOOL)postIncidentWithDictionary:(NSMutableDictionary *)incidentinfo andPhotoDataDictionary:(NSMutableDictionary *) photoData;
- (NSString *)urlEncode:(NSString *)string;
- (BOOL)postIncidentWithDictionaryWithPhoto:(NSMutableDictionary *)incidentinfo;

@property (nonatomic, retain) NSString *endPoint;
@property (nonatomic, retain, readonly) NSString *errorCode;
@property (nonatomic, retain, readonly) NSString *errorDesc;
@property (nonatomic, retain, readonly) NSData *responseData;
@property (nonatomic, retain, readonly) NSString *responseJSON;

@end
