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

@interface USHAnalytics : NSObject

+ (void)sendScreenView:(NSString *)screenName;

@end
