//
//  UshahidiAppDelegate.m
//  Ushahidi
//
//  Created by Wilfred Mworia on 9/19/09.
//  Copyright African Pixel 2009. All rights reserved.
//

#import "UshahidiAppDelegate.h"
#import "RootViewController.h"
#import "IncidentMapViewController.h"


@implementation UshahidiAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize categoryView;
@synthesize aboutView;
@synthesize settingsView;
@synthesize instanceAPI;
@synthesize reportView;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch 
	instanceAPI = [[API alloc] init];

	//RootViewController *rootViewController = (RootViewController *)[navigationController topViewController];
	//rootViewController.managedObjectContext = self.managedObjectContext;
	
	if(self.categoryView == nil) {
		CategoriesViewController *view = [[CategoriesViewController alloc] initWithNibName:@"CategoriesView" bundle:[NSBundle mainBundle]];
		self.categoryView = view;
		[view release];
	}
	
	if(self.aboutView == nil) {
		AboutViewController *view = [[AboutViewController alloc] initWithNibName:@"AboutView" bundle:[NSBundle mainBundle]];
		self.aboutView = view;
		[view release];
	}
	
	if(self.settingsView == nil) {
		SettingsViewController *view = [[SettingsViewController alloc] init];
		self.settingsView = view;
		[view release];
	}
	
	if(self.reportView == nil) {
		ReportViewController *view = [[ReportViewController alloc] init];
		self.reportView = view;
		[view release];
	}
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}

- (void)showCategories {
	[self.navigationController pushViewController:self.categoryView animated:YES];
}

- (void)showAbout {
	[self.navigationController pushViewController:self.aboutView animated:YES];
}

- (void)showSettings {
	[self.navigationController pushViewController:self.settingsView animated:YES];
}

- (void)showReport {
	[self.navigationController pushViewController:self.reportView animated:YES];
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    /*NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
        } 
    }*/
}


#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender {
	/*
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }*/
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
/*
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}
*/

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
/*
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}
*/

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
/*
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Ushahidi.sqlite"]];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Handle error
    }    
	
    return persistentStoreCoordinator;
}
*/

#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

//API

- (NSArray *)getCategories {
	return [instanceAPI categoryNames];
}

- (NSArray *)getAllIncidents {
	return [instanceAPI allIncidents];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
    //[managedObjectContext release];
    //[managedObjectModel release];
    //[persistentStoreCoordinator release];
    
	[navigationController release];
	[categoryView release];
	[aboutView release];
	[settingsView release];
	
	[instanceAPI release];
	
	[window release];
	[super dealloc];
}


@end

