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

#import "USHCheckinTableViewController.h"
#import <Ushahidi/USHMap.h>
#import <Ushahidi/USHUSer.h>
#import <Ushahidi/USHCheckin.h>
#import <Ushahidi/NSString+USH.h>
#import "USHTableCellFactory.h"
#import "USHCheckinTableCell.h"
#import "USHTextTableCell.h"
#import "USHCheckinDetailsViewController.h"
#include "USHAnalytics.h"

@interface USHCheckinTableViewController ()

@property (strong, nonatomic) USHMap *_map;
@property (strong, nonatomic) USHUser *_user;

@end

@implementation USHCheckinTableViewController

@synthesize _map = __map;
@synthesize _user = __user;
@synthesize checkinDetailsViewController = _checkinDetailsViewController;

typedef enum {
    //TableSectionPending,
    TableSectionCheckins,
    TableSections
} TableSection;

#pragma mark - USHMap

- (USHMap*)map {
    return self._map;
}

- (void) setMap:(USHMap *)map {
    self._map = map;
    [self.tableView reloadData];
}

#pragma mark - USHUser

- (USHUser*)user {
    return self._user;
}

- (void) setUser:(USHUser *)user {
    self._user = user;
    [self.tableView reloadData];
}

#pragma mark - UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self showSearchBarWithPlaceholder:NSLocalizedString(@"Search checkins...", nil)];
    DLog(@"Checkins:%d", self.map.checkins.count);
    
    [USHAnalytics sendScreenView:USHAnalyticsCheckinTableVCName];
}

#pragma mark - UITableViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TableSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == TableSectionCheckins) {
        NSArray *checkins = [self.map checkinsForUser:self.user text:self.searchText];
        return checkins.count > 0 ? checkins.count : 1;
    }
//    else if (section == TableSectionPending) {
//        return 0;
//    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *checkins = [self.map checkinsForUser:self.user text:self.searchText];
    if (checkins.count > 0) {
        USHCheckin *checkin = [checkins objectAtIndex:indexPath.row];
        USHCheckinTableCell *cell = [USHTableCellFactory checkinTableCellForTable:tableView indexPath:indexPath hasPhotos:checkin.image != nil];
        cell.message = checkin.message;
        cell.date = [checkin dateFormatted:@"h:mm a, MMMM d, yyyy"];
        if (checkin.image != nil) {
            cell.image = [UIImage imageWithData:checkin.image];
        }
        else {
            cell.image = nil;
        }
        if ([NSString isNilOrEmpty:checkin.user.name] == NO) {
            cell.name = checkin.user.name;
        }
        else {
            cell.name = NSLocalizedString(@"Anonymous", nil);
        }
        return cell;
    }
    return [USHTableCellFactory textTableCellForTable:tableView indexPath:indexPath text:NSLocalizedString(@"No checkins", nil)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableSectionCheckins) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSArray *checkins = [self.map checkinsForUser:self.user text:self.searchText];
        if (checkins.count > 0) {
            self.checkinDetailsViewController.map = self.map;
            self.checkinDetailsViewController.checkin = [checkins objectAtIndex:indexPath.row];
            self.checkinDetailsViewController.checkins = checkins;
            [self.navigationController pushViewController:self.checkinDetailsViewController animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *checkins = [self.map checkinsForUser:self.user text:self.searchText];
    if (checkins.count > 0) {
        USHCheckin *checkin = [checkins objectAtIndex:indexPath.row];
        return [USHCheckinTableCell heightForTable:tableView text:checkin.message image:checkin.image != nil];
    }
    return [USHTextTableCell heightForTable:tableView text:NSLocalizedString(@"No checkins", nil)]; 
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == TableSectionCheckins) {
        return self.user != nil ? self.user.name : NSLocalizedString(@"All Checkins", nil);
    }
//    else if (section == TableSectionPending && self.map.reportsPending.count > 0) {
//        return NSLocalizedString(@"Pending Upload", nil);
//    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return indexPath.section == TableSectionPending;
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"%d:%d", indexPath.section, indexPath.row);
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        USHReport *report = [self.map.reportsPending objectAtIndex:indexPath.row];
//        if (report != nil) {
//            [[Ushahidi sharedInstance] removeReport:report];
//            [[Ushahidi sharedInstance] save];
//            //            [tableView beginUpdates];
//            //            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            //            [tableView endUpdates];
//            [tableView reloadData];
//        }
    }
}

#pragma mark - SearchBar

- (void) searchTextDidChange:(NSString *)searchText {
    [self.tableView reloadData];
}

@end
