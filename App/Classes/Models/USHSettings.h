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

@property(nonatomic, assign, readonly) NSString *appName;
@property(nonatomic, assign, readonly) NSString *appVersion;
@property(nonatomic, assign, readonly) NSString *appDescription;

@property(nonatomic, assign, readonly) NSString *mapName;
@property(nonatomic, assign, readonly) NSString *mapURL;
@property(nonatomic, assign, readonly) BOOL hasMapURL;

@property(nonatomic, assign, readonly) NSDictionary *mapURLs;
@property(nonatomic, assign, readonly) BOOL hasMapURLS;

@property(nonatomic, assign, readonly) NSString *supportURL;
@property(nonatomic, assign, readonly) NSString *supportEmail;
@property(nonatomic, assign, readonly) NSString *appStoreURL;

@property(nonatomic, assign, readonly) NSString *termsOfServiceURL;
@property(nonatomic, assign, readonly) NSString *privacyPolicyURL;
@property(nonatomic, assign, readwrite) BOOL termsOfService;

@property(nonatomic, assign, readwrite) NSString *contactFirstName;
@property(nonatomic, assign, readwrite) NSString *contactLastName;
@property(nonatomic, assign, readwrite) NSString *contactEmailAddress;
@property(nonatomic, assign, readonly) NSString *contactFullName;

@property(nonatomic, assign, readwrite) BOOL hideStatusBar;
@property(nonatomic, assign, readwrite) BOOL showBadgeNumber;

@property(nonatomic, assign, readwrite) BOOL downloadMaps;
@property(nonatomic, assign, readwrite) NSInteger mapZoomLevel;

@property(nonatomic, assign, readwrite) NSInteger downloadLimit;

@property(nonatomic, assign, readwrite) BOOL downloadPhotos;
@property(nonatomic, assign, readwrite) BOOL resizePhotos;
@property(nonatomic, assign, readwrite) CGFloat imageWidth;

@property(nonatomic, assign, readwrite) BOOL openGeoSMS;

@property(nonatomic, assign, readonly) UIColor *navBarColor;
@property(nonatomic, assign, readonly) UIColor *tabBarColor;
@property(nonatomic, assign, readonly) UIColor *toolBarColor;
@property(nonatomic, assign, readonly) UIColor *searchBarColor;

@property(nonatomic, assign, readonly) UIColor *tableBackColor;
@property(nonatomic, assign, readonly) UIColor *tableRowColor;
@property(nonatomic, assign, readonly) UIColor *tableHeaderColor;
@property(nonatomic, assign, readonly) UIColor *tableSelectColor;

@property(nonatomic, assign, readonly) UIColor *buttonDoneColor;
@property(nonatomic, assign, readonly) UIColor *refreshControlColor;

@property(nonatomic, assign, readonly) NSString *youtubeUsername;
@property(nonatomic, assign, readonly) NSString *youtubePassword;
@property(nonatomic, assign, readonly) NSString *youtubeDeveloperKey;
@property(nonatomic, assign, readonly) BOOL youtubeCredentials;

@property(nonatomic, assign, readonly) BOOL showReportList;
@property(nonatomic, assign, readonly) BOOL showReportButton;
@property(nonatomic, assign, readonly) BOOL sortReportsByDate;

+ (id) sharedInstance;

@end
