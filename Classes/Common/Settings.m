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
#import "NSDictionary+Extension.h"

@interface Settings ()

- (void) loadUserDefaults;
- (void) loadInfoDictionary;

@end

@implementation Settings

SYNTHESIZE_SINGLETON_FOR_CLASS(Settings);

@synthesize email;
@synthesize firstName;
@synthesize lastName;
@synthesize lastDeployment;
@synthesize lastIncident; 
@synthesize downloadMaps;
@synthesize becomeDiscrete;
@synthesize resizePhotos;
@synthesize imageWidth;

@synthesize mapZoomLevel;
@synthesize mapName;
@synthesize mapURL;
@synthesize mapDistance;

@synthesize navBarTintColor;
@synthesize toolBarTintColor;
@synthesize searchBarTintColor;
@synthesize tablePlainBackColor;
@synthesize tableGroupedBackColor;
@synthesize tableOddRowColor;
@synthesize tableEvenRowColor;
@synthesize tableSelectRowColor;
@synthesize tableHeaderBackColor;
@synthesize tableHeaderTextColor;
@synthesize verifiedTextColor;
@synthesize unverifiedTextColor;
@synthesize showReportNewsURL;
@synthesize doneButtonColor;

@synthesize supportURL;
@synthesize supportEmail;
@synthesize appStoreURL;

@synthesize twitterUsername;
@synthesize twitterPassword;
@synthesize twitterUserKey;
@synthesize twitterUserSecret;
@synthesize twitterApiKey;
@synthesize twitterApiSecret;

@synthesize bitlyApiLogin;
@synthesize bitlyApiKey;

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
    
    self.twitterUsername = [userDefaults stringForKey:@"twitterUsername"];
	self.twitterPassword = [userDefaults stringForKey:@"twitterPassword"];
    self.twitterUserKey = [userDefaults stringForKey:@"twitterUserKey"];
	self.twitterUserSecret = [userDefaults stringForKey:@"twitterUserSecret"];
}

- (void) loadInfoDictionary {
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	self.mapName = [infoDictionary stringForKey:@"CFBundleName"];
	self.mapURL = [infoDictionary stringForKey:@"USHMapURL"];
	
    self.supportURL = [infoDictionary stringForKey:@"USHSupportURL"];
	self.supportEmail = [infoDictionary stringForKey:@"USHSupportEmail"];
	self.appStoreURL = [infoDictionary stringForKey:@"USHAppStoreURL"];
    
	self.navBarTintColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"USHNavBarColor"]];
	self.toolBarTintColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"USHToolBarColor"]];
	self.searchBarTintColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"USHSearchBarColor"]];
	
	self.tablePlainBackColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"USHTablePlainColor"]];
	self.tableGroupedBackColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"USHTableGroupedColor"]];
	self.tableOddRowColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"USHTableOddRowColor"]];
	self.tableEvenRowColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"USHTableEvenRowColor"]];
	self.tableSelectRowColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"USHTableSelectedRowColor"]];
	self.tableHeaderBackColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"USHTableHeaderColor"]];
	self.tableHeaderTextColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"USHTableHeaderTextColor"]];
    self.doneButtonColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"USHDoneButtonColor"]];
	
	self.verifiedTextColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"USHVerifiedTextColor"]];
	self.unverifiedTextColor = [UIColor colorFromHexString:[infoDictionary objectForKey:@"USHUnverifiedTextColor"]];
	
	self.twitterApiKey = [infoDictionary stringForKey:@"USHTwitterApiKey"];
    self.twitterApiSecret = [infoDictionary stringForKey:@"USHTwitterApiSecret"];

    self.bitlyApiLogin = [infoDictionary stringForKey:@"USHBitlyApiLogin"];
    self.bitlyApiKey = [infoDictionary stringForKey:@"USHBitlyApiKey"];
    
	if ([infoDictionary objectForKey:@"USHReportNewsURL"] != nil) {
		self.showReportNewsURL = [infoDictionary boolForKey:@"USHReportNewsURL"];
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
	[mapName release];
	[mapURL release];
    [supportURL release];
	[supportEmail release];
    [appStoreURL release];
	[navBarTintColor release];
	[toolBarTintColor release];
	[searchBarTintColor release];
	[tablePlainBackColor release];
	[tableGroupedBackColor release];
	[tableOddRowColor release];
	[tableEvenRowColor release];
	[tableSelectRowColor release];
	[tableHeaderBackColor release];
	[tableHeaderTextColor release];
	[verifiedTextColor release];
	[unverifiedTextColor release];
    [doneButtonColor release];
    
	[twitterUsername release];
    [twitterPassword release];
    [twitterApiKey release];
    [twitterApiSecret release];
    [twitterUserKey release];
    [twitterUserSecret release];
    
    [bitlyApiLogin release];
    [bitlyApiKey release];
	[super dealloc];
}

- (void) save {
	DLog(@"");
    DLog(@"LastDeployment:%@", self.lastDeployment);
    DLog(@"LastIncident:%@", self.lastIncident);
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
    [[NSUserDefaults standardUserDefaults] setObject:self.twitterUsername forKey:@"twitterUsername"];
    [[NSUserDefaults standardUserDefaults] setObject:self.twitterPassword forKey:@"twitterPassword"];
    [[NSUserDefaults standardUserDefaults] setObject:self.twitterUserKey forKey:@"twitterUserKey"];
    [[NSUserDefaults standardUserDefaults] setObject:self.twitterUserSecret forKey:@"twitterUserSecret"];
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

- (BOOL) hasMapURL {
	return [NSString isNilOrEmpty:self.mapURL] == NO;
}

- (BOOL) isWhiteLabel {
	return [NSString isNilOrEmpty:self.mapName] == NO ||
           [NSString isNilOrEmpty:self.mapURL] == NO;
}

@end
