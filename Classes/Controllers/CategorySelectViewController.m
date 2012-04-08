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

#import "CategorySelectViewController.h"
#import "LoadingViewController.h"
#import "BaseTabViewController.h"
#import "Category.h"
#import "TableCellFactory.h"
#import "SubtitleTableCell.h"
#import "Device.h"
#import "UIColor+Extension.h"

@interface CategorySelectViewController ()

@property(nonatomic, retain) Category *selected;

@end

@implementation CategorySelectViewController

@synthesize baseTabViewController;
@synthesize selected;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Categories", nil);
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.allRows removeAllObjects];
    [self.allRows addObject:[[[Category alloc] initWithTitle:NSLocalizedString(@"All Categories", nil) 
                                                 description:NSLocalizedString(@"View All Categories", nil)
                                                       color:[UIColor blackColor]] autorelease]];
	[self.allRows addObjectsFromArray:[[Ushahidi sharedUshahidi] getCategoriesForDelegate:self]];
	[self.filteredRows removeAllObjects];
    [self.filteredRows addObjectsFromArray:self.allRows];
	if (self.selected == nil && self.filteredRows.count > 0) {
        self.selected = [self.filteredRows objectAtIndex:0];
    }
    [self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc {
	[baseTabViewController release];
    [selected release];
	[super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return self.filteredRows.count;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SubtitleTableCell *cell = [TableCellFactory getSubtitleTableCellWithForTable:theTableView indexPath:indexPath];
	Category *category = (Category *)[self filteredRowAtIndexPath:indexPath];
    if ([category.title isEqualToString:self.selected.title]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [theTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    if (category != nil) {
        [cell setText:category.title];	
		[cell setDescription:category.description];
		[cell setTextColor:category.color];
	}
	else {
		[cell setText:nil];
		[cell setDescription:nil];
	}
	return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"section:%d row:%d", indexPath.section, indexPath.row);
	self.selected = (Category *)[self filteredRowAtIndexPath:indexPath];
    if (self.selected.identifier != nil) {
        [self.baseTabViewController populateWithFilter:self.selected];
    }
    else {
        [self.baseTabViewController populateWithFilter:nil];
    }
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self setDetailsViewController:self.baseTabViewController animated:YES];
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi categories:(NSArray *)categories error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if(hasChanges) {
		DLog(@"categories: %d", [categories count]);
		[self.allRows removeAllObjects];
		[self.allRows addObjectsFromArray:categories];
		[self.filteredRows removeAllObjects];
		[self.filteredRows addObjectsFromArray:categories];
		[self.tableView reloadData];
		[self.tableView flashScrollIndicators];
		DLog(@"Re-Adding Rows");
	}
	else {
		DLog(@"No Changes");
	}
}

@end
