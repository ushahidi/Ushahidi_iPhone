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

@implementation USHAnalytics

+ (void) sendScreenView:(NSString *)screenName {
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

@end
