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

@interface Settings : NSObject {

@public
	NSString *email;
	NSString *firstName;
	NSString *lastName;
	NSString *lastDeployment;
	NSString *lastIncident;
	NSString *mapDistance;
	BOOL downloadMaps;
	BOOL becomeDiscrete;
	BOOL resizePhotos;
	CGFloat imageWidth;
	NSInteger mapZoomLevel;
	
	BOOL hasFirstName;
	BOOL hasLastName;
	BOOL hasEmail;
	
	NSString *mapName;
	NSString *mapURL;
	
	UIColor *navBarTintColor;
	UIColor *toolBarTintColor;
	UIColor *searchBarTintColor;
	UIColor *tablePlainBackColor;
	UIColor *tableGroupedBackColor;
	UIColor *tableOddRowColor;
	UIColor *tableEvenRowColor;
	UIColor *tableSelectRowColor;
	UIColor *tableHeaderBackColor;
	UIColor *tableHeaderTextColor;
	UIColor *verifiedTextColor;
	UIColor *unverifiedTextColor;
	
	BOOL showReportNewsURL;
	
}

@property(nonatomic, retain) NSString *email;
@property(nonatomic, retain) NSString *firstName;
@property(nonatomic, retain) NSString *lastName;
@property(nonatomic, retain) NSString *lastDeployment;
@property(nonatomic, retain) NSString *lastIncident;
@property(nonatomic, retain) NSString *mapDistance;
@property(nonatomic, assign) BOOL downloadMaps;
@property(nonatomic, assign) BOOL becomeDiscrete;
@property(nonatomic, assign) BOOL resizePhotos;
@property(nonatomic, assign) CGFloat imageWidth;
@property(nonatomic, assign) NSInteger mapZoomLevel;

@property(nonatomic, readonly) BOOL hasFirstName;
@property(nonatomic, readonly) BOOL hasLastName;
@property(nonatomic, readonly) BOOL hasEmail;

@property(nonatomic, retain) NSString *mapName;
@property(nonatomic, retain) NSString *mapURL;

@property(nonatomic, retain) UIColor *navBarTintColor;
@property(nonatomic, retain) UIColor *toolBarTintColor;
@property(nonatomic, retain) UIColor *searchBarTintColor;

@property(nonatomic, retain) UIColor *tablePlainBackColor;
@property(nonatomic, retain) UIColor *tableGroupedBackColor;
@property(nonatomic, retain) UIColor *tableOddRowColor;
@property(nonatomic, retain) UIColor *tableEvenRowColor;
@property(nonatomic, retain) UIColor *tableSelectRowColor;
@property(nonatomic, retain) UIColor *tableHeaderBackColor;
@property(nonatomic, retain) UIColor *tableHeaderTextColor;
@property(nonatomic, retain) UIColor *verifiedTextColor;
@property(nonatomic, retain) UIColor *unverifiedTextColor;

@property(nonatomic, assign) BOOL showReportNewsURL;

+ (Settings *) sharedSettings;

- (void) save;

@end
