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

@interface Settings ()

@end

@implementation Settings

SYNTHESIZE_SINGLETON_FOR_CLASS(Settings);

@synthesize email, firstName, lastName, lastDeployment, lastIncident, mapDistance, downloadMaps, becomeDiscrete, imageWidth, mapZoomLevel;
@synthesize mapName, mapURL, navBarTintColor, toolBarTintColor, searchBarTintColor, tablePlainBackColor, tableGroupedBackColor, tableOddRowColor, tableEvenRowColor, tableSelectRowColor, tableHeaderBackColor, tableHeaderTextColor, verifiedTextColor, unverifiedTextColor;

- (id) init {
	if ((self = [super init])) {
		self.email = [[NSUserDefaults standardUserDefaults] stringForKey:@"email"];
		self.firstName = [[NSUserDefaults standardUserDefaults] stringForKey:@"firstName"];
		self.lastName = [[NSUserDefaults standardUserDefaults] stringForKey:@"lastName"];
		self.lastDeployment = [[NSUserDefaults standardUserDefaults] stringForKey:@"lastDeployment"];
		self.lastIncident = [[NSUserDefaults standardUserDefaults] stringForKey:@"lastIncident"];
		self.downloadMaps = [[NSUserDefaults standardUserDefaults] boolForKey:@"downloadMaps"];
		self.becomeDiscrete = [[NSUserDefaults standardUserDefaults] boolForKey:@"becomeDiscrete"];
		self.imageWidth = [[NSUserDefaults standardUserDefaults] floatForKey:@"imageWidth"];
		if (self.imageWidth == 0) self.imageWidth = 600;
		self.mapZoomLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"mapZoomLevel"];
		if (self.mapZoomLevel == 0) self.mapZoomLevel = 12;
		self.mapDistance = [[NSUserDefaults standardUserDefaults] stringForKey:@"mapDistance"];
		if (self.mapDistance == nil) self.mapDistance = @"500";
		
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
		NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:filePath];
		self.mapName = [settings objectForKey:@"MapName"];
		self.mapURL = [settings objectForKey:@"MapURL"];
		
		self.navBarTintColor = [UIColor colorFromHexString:[settings objectForKey:@"NavBarTintColor"]];
		self.toolBarTintColor = [UIColor colorFromHexString:[settings objectForKey:@"ToolBarTintColor"]];
		self.searchBarTintColor = [UIColor colorFromHexString:[settings objectForKey:@"SearchBarTintColor"]];
		
		self.tablePlainBackColor = [UIColor colorFromHexString:[settings objectForKey:@"TablePlainBackColor"]];
		self.tableGroupedBackColor = [UIColor colorFromHexString:[settings objectForKey:@"TableGroupedBackColor"]];
		self.tableOddRowColor = [UIColor colorFromHexString:[settings objectForKey:@"TableOddRowColor"]];
		self.tableEvenRowColor = [UIColor colorFromHexString:[settings objectForKey:@"TableEvenRowColor"]];
		self.tableSelectRowColor = [UIColor colorFromHexString:[settings objectForKey:@"TableSelectRowColor"]];
		self.tableHeaderBackColor = [UIColor colorFromHexString:[settings objectForKey:@"TableHeaderBackColor"]];
		self.tableHeaderTextColor = [UIColor colorFromHexString:[settings objectForKey:@"TableHeaderTextColor"]];
		self.verifiedTextColor = [UIColor colorFromHexString:[settings objectForKey:@"VerifiedTextColor"]];
		self.unverifiedTextColor = [UIColor colorFromHexString:[settings objectForKey:@"UnverifiedTextColor"]];
	}
	return self;
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
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
