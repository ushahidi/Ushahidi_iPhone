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

#import "Settings.h"
#import "SynthesizeSingleton.h"
#import "UIColor+Extension.h"
#import "NSString+Extension.h"

@interface Settings ()

- (void) loadUserDefaults;
- (void) loadInfoDictionary;

@end

@implementation Settings

SYNTHESIZE_SINGLETON_FOR_CLASS(Settings);

@synthesize email, firstName, lastName, lastDeployment, lastIncident, mapDistance, downloadMaps, becomeDiscrete, resizePhotos, imageWidth, mapZoomLevel;
@synthesize mapName, mapURL;
@synthesize navBarTintColor, toolBarTintColor, searchBarTintColor, tablePlainBackColor, tableGroupedBackColor, tableOddRowColor, tableEvenRowColor, tableSelectRowColor, tableHeaderBackColor, tableHeaderTextColor, verifiedTextColor, unverifiedTextColor;
@synthesize showReportNewsURL;

- (id) init {
	if ((self = [super init])) {
		[self loadUserDefaults];
		[self loadInfoDictionary];
	}
	return self;
}

- (void) loadUserDefaults {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	self.email = [userDefaults stringForKey:@"email"];
	self.firstName = [userDefaults stringForKey:@"firstName"];
	self.lastName = [userDefaults stringForKey:@"lastName"];
	self.lastDeployment = [userDefaults stringForKey:@"lastDeployment"];
	self.lastIncident = [userDefaults stringForKey:@"lastIncident"];
	self.downloadMaps = [userDefaults boolForKey:@"downloadMaps"];
	self.becomeDiscrete = [userDefaults boolForKey:@"becomeDiscrete"];
	if ([userDefaults objectForKey:@"resizePhotos"] != nil) {
		self.resizePhotos = [userDefaults boolForKey:@"resizePhotos"];
	}
	else {
		self.resizePhotos = YES;
	}
	self.imageWidth = [userDefaults floatForKey:@"imageWidth"];
	if (self.imageWidth == 0) self.imageWidth = 600;
	self.mapZoomLevel = [userDefaults integerForKey:@"mapZoomLevel"];
	if (self.mapZoomLevel == 0) self.mapZoomLevel = 12;
	self.mapDistance = [userDefaults stringForKey:@"mapDistance"];
	if (self.mapDistance == nil) self.mapDistance = @"500";
}

- (void) loadInfoDictionary {
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	self.mapName = [infoDictionary objectForKey:@"CFBundleName"];
	self.mapURL = [infoDictionary objectForKey:@"MapURL"];
	
	self.navBarTintColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"NavBarColor"]];
	self.toolBarTintColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"ToolBarColor"]];
	self.searchBarTintColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"SearchBarColor"]];
	
	self.tablePlainBackColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"TablePlainColor"]];
	self.tableGroupedBackColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"TableGroupedColor"]];
	self.tableOddRowColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"TableOddRowColor"]];
	self.tableEvenRowColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"TableEvenRowColor"]];
	self.tableSelectRowColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"TableSelectedRowColor"]];
	self.tableHeaderBackColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"TableHeaderColor"]];
	self.tableHeaderTextColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"TableHeaderTextColor"]];
	
	self.verifiedTextColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"VerifiedTextColor"]];
	self.unverifiedTextColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"UnverifiedTextColor"]];
	
	if ([infoDictionary objectForKey:@"ReportNewsURL"] != nil) {
		self.showReportNewsURL = [infoDictionary boolForKey:@"ReportNewsURL"];
	}
	else {
		self.showReportNewsURL = YES;
	}
}

- (void)dealloc {
	[email release];
	[firstName release];
	[lastName release];
	[lastDeployment release];
	[lastIncident release];
	[mapDistance release];
	[mapURL release];
	[mapName release];
	[super dealloc];
}

- (void) save {
	DLog(@"");
	[[NSUserDefaults standardUserDefaults] setObject:self.email forKey:@"email"];
	[[NSUserDefaults standardUserDefaults] setObject:self.firstName forKey:@"firstName"];
	[[NSUserDefaults standardUserDefaults] setObject:self.lastName forKey:@"lastName"];
	[[NSUserDefaults standardUserDefaults] setObject:self.lastDeployment forKey:@"lastDeployment"];
	[[NSUserDefaults standardUserDefaults] setObject:self.lastIncident forKey:@"lastIncident"];
	[[NSUserDefaults standardUserDefaults] setBool:self.downloadMaps forKey:@"downloadMaps"];
	[[NSUserDefaults standardUserDefaults] setBool:self.becomeDiscrete forKey:@"becomeDiscrete"];
	[[NSUserDefaults standardUserDefaults] setFloat:self.imageWidth forKey:@"imageWidth"];
	[[NSUserDefaults standardUserDefaults] setInteger:self.mapZoomLevel forKey:@"mapZoomLevel"];
	[[NSUserDefaults standardUserDefaults] setObject:self.mapDistance forKey:@"mapDistance"];
	[[NSUserDefaults standardUserDefaults] setBool:self.resizePhotos forKey:@"resizePhotos"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) hasFirstName {
	return [NSString isNilOrEmpty:self.firstName] == NO;
}

- (BOOL) hasLastName {
	return [NSString isNilOrEmpty:self.lastName] == NO;
}

- (BOOL) hasEmail {
	return [NSString isNilOrEmpty:self.email] == NO;
}

@end
