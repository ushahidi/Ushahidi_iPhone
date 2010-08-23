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

#import "AppDelegate_iPad.h"
#import "Settings.h"
#import "Ushahidi.h"

@implementation AppDelegate_iPad

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {  
	DLog(@"");
	[window addSubview:navigationController.view];
	[window makeKeyAndVisible];
	return YES;
}

/*
 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
 */
- (void)applicationWillResignActive:(UIApplication *)application {
	DLog(@"");
	[[Settings sharedSettings] save];
	[[Ushahidi sharedUshahidi] save];
}

/*
 Restart any tasks that were paused (or not yet started) while the application was inactive.
 */
- (void)applicationDidBecomeActive:(UIApplication *)application {
	DLog(@"");
}

/**
 Superclass implementation saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	DLog(@"");
	[super applicationWillTerminate:application];
}

#pragma mark -
#pragma mark Memory management

/*
 Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
 */
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	DLog(@"");
    [super applicationDidReceiveMemoryWarning:application];
}

- (void)dealloc {
	DLog(@"");
	[super dealloc];
}

@end
