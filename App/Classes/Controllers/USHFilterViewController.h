//
//  USHFilterViewController.h
//  App
//
//  Created by Dale Zak on 2012-12-04.
//  Copyright (c) 2012 Ushahidi. All rights reserved.
//

#import <Ushahidi/USHTableViewController.h>

@class USHSettingsViewController;
@class USHReportTabBarController;
@class USHFilterViewController;
@class USHMap;

@interface USHFilterViewController : USHTableViewController

@property (strong, nonatomic) IBOutlet USHSettingsViewController *settingsViewController;
@property (strong, nonatomic) IBOutlet USHReportTabBarController *reportTabBarController;

@property (strong, nonatomic) USHMap *map;

- (IBAction)info:(id)sender event:(UIEvent*)event;

- (void) reloadFilters;

@end
