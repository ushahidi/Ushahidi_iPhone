//
//  USHAnalytics.m
//  App
//
//  Created by Isaac Lim on 4/22/14.
//  Copyright (c) 2014 Ushahidi. All rights reserved.
//

#import "USHAnalytics.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

NSString * const USHAnalyticsMapTableVCName = @"Map Table View Controller";
NSString * const USHAnalyticsReportTableVCName = @"Report Table View Controller";
NSString * const USHAnalyticsReportMapVCName = @"Report Map View Controller";
NSString * const USHAnalyticsMapAddVCName = @"Map Add View Controller";
NSString * const USHAnalyticsReportDetailsVCName = @"Report Details View Controller";
NSString * const USHAnalyticsReportAddVCName = @"Report Add View Controller";
NSString * const USHAnalyticsCheckinTableVCName = @"Checkin Table View Controller";
NSString * const USHAnalyticsCheckinDetailsVCName = @"Checkin Details View Controller";
NSString * const USHAnalyticsCategoryTableVCName = @"Category Table View Controller";
NSString * const USHAnalyticsFilterVCName = @"Filter View Controller";
NSString * const USHAnalyticsImageVCName = @"Image View Controller";
NSString * const USHAnalyticsWebVCName = @"Web View Controller";
NSString * const USHAnalyticsLocationVCName = @"Location View Controller";
NSString * const USHAnalyticsLocationAddVCName = @"Location Add View Controller";
NSString * const USHAnalyticsSettingsVCName = @"Settings View Controller";
NSString * const USHAnalyticsCommentAddVCName = @"Comment Add View Controller";

@implementation USHAnalytics

+ (void) sendScreenView:(NSString *)screenName {
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

@end
