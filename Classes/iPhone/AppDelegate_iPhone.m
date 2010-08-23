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
#import "Settings.h"

@implementation AppDelegate_iPhone

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
}

/*
 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
 If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
 */
- (void)applicationDidEnterBackground:(UIApplication *)application {
	DLog(@"");
}

/*
 Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
 */
- (void)applicationWillEnterForeground:(UIApplication *)application {
	DLog(@"");
}

/*
 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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

