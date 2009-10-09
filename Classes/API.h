//
//  API.h
//  Ushahidi
//
//  Created by Wilfred Mworia on 9/21/09.
//  Copyright 2009 African Pixel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"

@interface API : NSObject {
	NSString *endPoint;
	NSString *errorCode;
	NSString *errorDesc;
	
	NSData *responseData;
	NSString *responseJSON;
}

- (NSMutableArray *)categoryNames;
- (NSMutableArray *)incidentsByCategoryId:(int)catid;
- (NSMutableArray *)allIncidents;
- (BOOL)postIncidentWithDictionary:(NSMutableDictionary *)incidentinfo;
- (BOOL)postIncidentWithDictionary:(NSMutableDictionary *)incidentinfo andPhotoDataDictionary:(NSMutableDictionary *) photoData;
- (NSString *)urlEncode:(NSString *)string;

@property (nonatomic, retain) NSString *endPoint;
@property (nonatomic, retain, readonly) NSString *errorCode;
@property (nonatomic, retain, readonly) NSString *errorDesc;

@property (nonatomic, retain, readonly) NSData *responseData;
@property (nonatomic, retain, readonly) NSString *responseJSON;

@end
