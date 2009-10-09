//
//  RootViewController.h
//  Ushahidi
//
//  Created by Wilfred Mworia on 9/19/09.
//  Copyright African Pixel 2009. All rights reserved.
//
#import "IncidentMapViewController.h"
#import "CategoriesViewController.h"
#import "AboutViewController.h"
#import "UshahidiAppDelegate.h"
#import "IncidentDetailViewController.h"

@interface RootViewController : UIViewController </*NSFetchedResultsControllerDelegate, */UITableViewDelegate> {
	/*
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	*/
	UISegmentedControl *segmentedControl;
	IncidentMapViewController *mapView;
	IBOutlet UITableView *tableView;
	
	IBOutlet UIBarButtonItem *settingsButton;
	IBOutlet UIBarButtonItem *categoriesButton;
	IBOutlet UIBarButtonItem *refreshButton;
	IBOutlet UIBarButtonItem *aboutButton;
	
	IncidentDetailViewController *detailView;
	
	UshahidiAppDelegate *delegate;
	NSMutableArray *incidents;
}

- (void)showCategoryView:(id)sender;
- (void)showAboutView:(id)sender;
- (void)showSettingsView:(id)sender;
- (void)refreshIncidents:(id)sender;
- (void)refreshData;
/*
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
*/

@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, retain) IncidentMapViewController *mapView;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *settingsButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *categoriesButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *aboutButton;

@property (nonatomic, retain) UshahidiAppDelegate *delegate;
@property (nonatomic, retain) NSMutableArray *incidents;

@property (nonatomic, retain) IncidentDetailViewController *detailView;

@end
