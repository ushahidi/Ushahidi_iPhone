//
//  UshahidiAppDelegate.h
//  Ushahidi
//
//  Created by Wilfred Mworia on 9/19/09.
//  Copyright African Pixel 2009. All rights reserved.
//

#import "CategoriesViewController.h"
#import "AboutViewController.h"
#import "SettingsViewController.h"
#import "ReportViewController.h"
#import "API.h"

@interface UshahidiAppDelegate : NSObject <UIApplicationDelegate> {
    /*
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	*/ 
    UIWindow *window;
    UINavigationController *navigationController;
	
	CategoriesViewController *categoryView;
	AboutViewController *aboutView;
	SettingsViewController *settingsView;
	ReportViewController *reportView;
	
	API *instanceAPI;
}

- (IBAction)saveAction:sender;
- (void)showCategories;
- (void)showAbout;
- (void)showSettings;
- (void)showReport;

//API calls
- (NSArray *)getCategories;
- (NSArray *)getAllIncidents;

/*
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
*/
@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain) CategoriesViewController *categoryView;
@property (nonatomic, retain) AboutViewController *aboutView;
@property (nonatomic, retain) SettingsViewController *settingsView;
@property (nonatomic, retain) ReportViewController *reportView;

@property (nonatomic, retain) API *instanceAPI;

@end

