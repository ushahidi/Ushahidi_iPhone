/*****************************************************************************
 ** Copyright (c) 2012 Ushahidi Inc
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

#import "USHCategoryTableViewController.h"
#import "USHReportTabBarController.h"
#import "USHSettingsViewController.h"
#import <Ushahidi/USHMap.h>
#import <Ushahidi/USHReport.h>
#import <Ushahidi/USHCategory.h>
#import <Ushahidi/NSString+USH.h>
#import <Ushahidi/UIColor+USH.h>
#import <Ushahidi/UIBarButtonItem+USH.h>
#import "USHSettings.h"
#import "USHTableCellFactory.h"
#import "USHCheckBoxTableCell.h"
#import <Ushahidi/USHDevice.h>

@interface USHCategoryTableViewController ()

@end

@implementation USHCategoryTableViewController

typedef enum {
    TableSectionCategories,
    TableSections
} TableSection;

@synthesize map = _map;
@synthesize report = _report;
@synthesize doneButton = _doneButton;

#pragma mark - IBActions

- (IBAction)done:(id)sender event:(UIEvent*)event { 
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.doneButton.title = NSLocalizedString(@"Done", nil);
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
    UIColor *color = [NSString isNilOrEmpty:category.color] ? [UIColor blackColor] : [UIColor colorFromHexString:category.color];
    BOOL checked = [self.report containsCategory:category];
    return [USHTableCellFactory checkBoxTableCellForTable:tableView 
                                                indexPath:indexPath 
                                                 delegate:self
                                                     text:category.title 
                                                  details:category.desc 
                                                  checked:checked
                                                    color:color];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    USHCheckBoxTableCell *cell = (USHCheckBoxTableCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.checked) {
        DLog(@"Checked:%@", cell.textLabel.text);
    }
    else {
        DLog(@"Un-Checked:%@", cell.textLabel.text);
    }
}

#pragma mark - USHCheckBoxTableCell

- (void) checkBoxChanged:(USHCheckBoxTableCell *)cell index:(NSIndexPath *)indexPath checked:(BOOL)checked {
    USHCategory *category = [[self.map categoriesSortedByPosition] objectAtIndex:indexPath.row];
    if (checked) {
        DLog(@"%d,%d Checked:%@", indexPath.section, indexPath.row, cell.textLabel.text);
        [self.report addCategoriesObject:category];
    }
    else {
        DLog(@"%d,%d Un-Checked:%@", indexPath.section, indexPath.row, cell.textLabel.text);
        [self.report removeCategoriesObject:category];
    }
}

@end
