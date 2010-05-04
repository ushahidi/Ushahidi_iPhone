//
//  API.h
//  Ushahidi
//
//  Created by Wilfred Mworia on 9/21/09.
//  Copyright 2009 African Pixel. All rights reserved.
//

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
