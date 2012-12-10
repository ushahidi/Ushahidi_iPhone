//
//  USHFilterViewController.m
//  App
//
//  Created by Dale Zak on 2012-12-04.
//  Copyright (c) 2012 Ushahidi. All rights reserved.
//

#import "USHFilterViewController.h"
#import "USHSettingsViewController.h"
#import "USHReportTabBarController.h"
#import <Ushahidi/USHCategory.h>
#import <Ushahidi/UIColor+USH.h>
#import <Ushahidi/USHMap.h>
#import "USHTableCellFactory.h"
#import "USHTextTableCell.h"
#import <UShahidi/USHDevice.h>

@interface USHFilterViewController ()

@end

@implementation USHFilterViewController

typedef enum {
    TableSectionCategories,
    TableSections
} TableSection;

@synthesize map = _map;
@synthesize settingsViewController = _settingsViewController;
@synthesize reportTabBarController = _reportTabBarController;

#pragma mark - IBActions

- (IBAction)info:(id)sender event:(UIEvent*)event {
    if ([USHDevice isIPad]) {
        self.settingsViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        self.settingsViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    else {
        self.settingsViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        self.settingsViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    [self presentModalViewController:self.settingsViewController animated:YES];
}

#pragma mark - helpers

- (void) reloadFilters {
    DLog(@"");
    [self.tableView reloadData];
    [self.tableView flashScrollIndicators];
    if (self.reportTabBarController.category != nil) {
        NSInteger row = 0;
        for (USHCategory *category in [self.map categoriesSortedByPosition]) {
            if ([category.identifier isEqualToString:self.reportTabBarController.category.identifier]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                break;
            }
            row++;
        }
    }
}

#pragma mark - UIViewController

- (void)dealloc {
    [_map release];
    [_settingsViewController release];
    [_reportTabBarController release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Categories", nil);
}

#pragma mark - UITableViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TableSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.map.categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    USHCategory *category = [[self.map categoriesSortedByPosition] objectAtIndex:indexPath.row];
    //UIColor *color = [NSString isNilOrEmpty:category.color] ? [UIColor blackColor] : [UIColor colorFromHexString:category.color];
    return [USHTableCellFactory textTableCellForTable:tableView
                                            indexPath:indexPath
                                                 text:category.title
                                            accessory:[USHDevice isIPhone]
                                            selection:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    USHCategory *category = [[self.map categoriesSortedByPosition] objectAtIndex:indexPath.row];
    if (self.reportTabBarController.category == category) {
        self.reportTabBarController.category = nil;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
         self.reportTabBarController.category = category;
    }
}

@end
