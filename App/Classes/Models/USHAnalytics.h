//
//  USHAnalytics.h
//  App
//
//  Created by Isaac Lim on 4/22/14.
//  Copyright (c) 2014 Ushahidi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define USHAnalyticsTrackingID @"UA-42721355-4"

NSString * const USHAnalyticsMapTableVCName;
NSString * const USHAnalyticsReportTableVCName;
NSString * const USHAnalyticsReportMapVCName;
NSString * const USHAnalyticsMapAddVCName;
NSString * const USHAnalyticsReportDetailsVCName;
NSString * const USHAnalyticsReportAddVCName;
NSString * const USHAnalyticsCheckinTableVCName;
NSString * const USHAnalyticsCheckinDetailsVCName;
NSString * const USHAnalyticsCategoryTableVCName;
NSString * const USHAnalyticsFilterVCName;
NSString * const USHAnalyticsImageVCName;
NSString * const USHAnalyticsWebVCName;
NSString * const USHAnalyticsLocationVCName;
NSString * const USHAnalyticsLocationAddVCName;
NSString * const USHAnalyticsSettingsVCName;
NSString * const USHAnalyticsCommentAddVCName;

@interface USHAnalytics : NSObject

+ (void)sendScreenView:(NSString *)screenName;

@end
