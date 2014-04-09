/*****************************************************************************
 ** Copyright (c) 2012 Ushahidi Inc
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
#import <Ushahidi/USHDefaults.h>
#import <objc/runtime.h>

@interface USHSettings : USHDefaults

@property(nonatomic, weak, readonly) NSString *appName;
@property(nonatomic, weak, readonly) NSString *appVersion;
@property(nonatomic, weak, readonly) NSString *appDescription;

@property(nonatomic, weak, readonly) NSString *mapName;
@property(nonatomic, weak, readonly) NSString *mapURL;
@property(nonatomic, assign, readonly) BOOL hasMapURL;

@property(nonatomic, weak, readonly) NSDictionary *mapURLs;
@property(nonatomic, assign, readonly) BOOL hasMapURLS;

@property(nonatomic, weak, readonly) NSString *supportURL;
@property(nonatomic, weak, readonly) NSString *supportEmail;
@property(nonatomic, weak, readonly) NSString *appStoreURL;

@property(nonatomic, weak, readonly) NSString *termsOfServiceURL;
@property(nonatomic, weak, readonly) NSString *privacyPolicyURL;
@property(nonatomic, assign, readwrite) BOOL termsOfService;

@property(nonatomic, weak, readwrite) NSString *contactFirstName;
@property(nonatomic, weak, readwrite) NSString *contactLastName;
@property(nonatomic, weak, readwrite) NSString *contactEmailAddress;
@property(nonatomic, weak, readonly) NSString *contactFullName;

@property(nonatomic, assign, readwrite) BOOL hideStatusBar;
@property(nonatomic, assign, readwrite) BOOL showBadgeNumber;

@property(nonatomic, assign, readwrite) BOOL downloadMaps;
@property(nonatomic, assign, readwrite) NSInteger mapZoomLevel;

@property(nonatomic, assign, readwrite) NSInteger downloadLimit;

@property(nonatomic, assign, readwrite) BOOL downloadPhotos;
@property(nonatomic, assign, readwrite) BOOL resizePhotos;
@property(nonatomic, assign, readwrite) CGFloat imageWidth;

@property(nonatomic, assign, readwrite) BOOL openGeoSMS;

@property(nonatomic, weak, readonly) UIColor *navBarColor;
@property(nonatomic, weak, readonly) UIColor *tabBarColor;
@property(nonatomic, weak, readonly) UIColor *toolBarColor;
@property(nonatomic, weak, readonly) UIColor *searchBarColor;

@property(nonatomic, weak, readonly) UIColor *tableBackColor;
@property(nonatomic, weak, readonly) UIColor *tableRowColor;
@property(nonatomic, weak, readonly) UIColor *tableHeaderColor;
@property(nonatomic, weak, readonly) UIColor *tableSelectColor;

@property(nonatomic, weak, readonly) UIColor *buttonDoneColor;
@property(nonatomic, weak, readonly) UIColor *refreshControlColor;

@property(nonatomic, weak, readonly) NSString *youtubeUsername;
@property(nonatomic, weak, readonly) NSString *youtubePassword;
@property(nonatomic, weak, readonly) NSString *youtubeDeveloperKey;
@property(nonatomic, assign, readonly) BOOL youtubeCredentials;

@property(nonatomic, assign, readonly) BOOL showReportList;
@property(nonatomic, assign, readonly) BOOL showReportButton;
@property(nonatomic, assign, readonly) BOOL sortReportsByDate;

+ (id) sharedInstance;

@end
