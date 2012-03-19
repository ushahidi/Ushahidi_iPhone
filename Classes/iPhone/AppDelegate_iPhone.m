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

#import "AppDelegate_iPhone.h"
#import "AppDelegate.h"
#import "Settings.h"
#import "Ushahidi.h"
#import "DeploymentTableViewController.h"
#import "IncidentTabViewController.h"
#import "CheckinTabViewController.h"
#import "IncidentDetailsViewController.h"
#import "Deployment.h"
#import "Settings.h"
#import "Device.h"
#import "NSString+Extension.h"
#import "Ushahidi.h"
#import "Device.h"

@implementation AppDelegate_iPhone

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationWillResignActive:(UIApplication *)application {
	DLog(@"");
	[[Settings sharedSettings] save];
	[[Ushahidi sharedUshahidi] archive];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	DLog(@"");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	DLog(@"");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	DLog(@"");
}

- (void)applicationWillTerminate:(UIApplication *)application {
	DLog(@"");
	[super applicationWillTerminate:application];
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	DLog(@"");
    [super applicationDidReceiveMemoryWarning:application];
}

- (void)dealloc {
	DLog(@"");
	[super dealloc];
}

@end

