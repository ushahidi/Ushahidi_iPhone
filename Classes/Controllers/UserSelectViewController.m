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

#import "UserSelectViewController.h"
#import "BaseTabViewController.h"
#import "LoadingViewController.h"
#import "Device.h"
#import "TableCellFactory.h"
#import "SubtitleTableCell.h"
#import "User.h"
#import "NSString+Extension.h"

@interface UserSelectViewController ()

@property(nonatomic, retain) User *selected;

@end

@implementation UserSelectViewController

@synthesize baseTabViewController;
@synthesize selected;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.allRows removeAllObjects];
	[self.allRows addObject:[[[User alloc] initWithIdentifier:nil name:NSLocalizedString(@"All Users", nil)] autorelease]];
    for (User *user in [[Ushahidi sharedUshahidi] getUsers]) {
        if ([NSString isNilOrEmpty:user.name] == NO) {
            [self.allRows addObject:user];    
        }
    }
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
	UITableViewCell *cell = [TableCellFactory getDefaultTableCellForTable:theTableView indexPath:indexPath];
	User *user = (User *)[self filteredRowAtIndexPath:indexPath];
    if ([user.name isEqualToString:self.selected.name]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [theTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    if (user != nil) {
        cell.textLabel.text = user.name; 
	}
	else {
		cell.textLabel.text = nil;
	}
	return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"section:%d row:%d", indexPath.section, indexPath.row);
    self.selected = (User *)[self filteredRowAtIndexPath:indexPath];
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

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi users:(NSArray *)users error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if (error != nil) {
		DLog(@"error: %d %@", [error code], [error localizedDescription]);
	}
	else if (hasChanges) {
		DLog(@"Re-Adding Users: %d", [users count]);
		[self.allRows removeAllObjects];
        [self.filteredRows removeAllObjects];
        [self.allRows addObjectsFromArray:users];
        [self.filteredRows addObjectsFromArray:self.allRows];
        [self.tableView reloadData];
	}
	else {
		DLog(@"No Changes Users");
	}
}

@end
