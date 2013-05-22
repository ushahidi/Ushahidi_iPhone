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

#import "USHReportTableViewController.h"
#import "USHReportDetailsViewController.h"
#import "USHFilterViewController.h"
#import "USHTableCellFactory.h"
#import "USHReportTableCell.h"
#import "USHTextTableCell.h"
#import <Ushahidi/USHMap.h>
#import <Ushahidi/USHReport.h>
#import <Ushahidi/USHCategory.h>
#import <Ushahidi/USHPhoto.h>
#import <Ushahidi/Ushahidi.h>
#import <Ushahidi/USHHeaderView.h>
#import <Ushahidi/UITableView+USH.h>
#import <Ushahidi/UIAlertView+USH.h>
#import "USHSettings.h"

@interface USHReportTableViewController ()

@property (strong, nonatomic) USHMap *_map;
@property (strong, nonatomic) USHCategory *_category;

- (NSString *) noReportsText;
- (void) initialSyncIfNeeded;
- (NSArray*) listOfReports;

@end

@implementation USHReportTableViewController

typedef enum {
    TableSectionPending,
    TableSectionReports,
    TableSections
} TableSection;

@synthesize _map = __map;
@synthesize _category = __category;
@synthesize detailsController = _detailsController;
@synthesize filterViewController = _filterViewController;

typedef enum {
    AlertViewDefault,
    AlertViewSyncNow
} AlertViewType;

#pragma mark - Helpers

-(void) startRefreshControl {
    if ([[Ushahidi sharedInstance] synchronizeWithDelegate:self
                                                       map:self.map
                                                    photos:[[USHSettings sharedInstance] downloadPhotos]
                                                      maps:[[USHSettings sharedInstance] downloadMaps]
                                                     limit:[[USHSettings sharedInstance] downloadLimit]]) {
        DLog(@"Syncing...");
    }
    else {
        [self endRefreshControl];
    }
}

- (void) initialSyncIfNeeded {
    if ([[Ushahidi sharedInstance] synchronizeDate] == nil) {
        [self showLoadingWithMessage:NSLocalizedString(@"Loading...", nil)];
        [self startRefreshControl];
    }
}

#pragma mark - USHMap

- (USHMap*)map {
    return self._map;
}

- (void) setMap:(USHMap *)map {
    self._map = map;
    [self.tableView reloadData];
}

#pragma mark - USHCategory

- (USHCategory*)category {
    return self._category;
}

- (void) setCategory:(USHCategory *)category {
    self._category = category;
    [self.tableView reloadData];
    [self.tableView flashScrollIndicators];
}

#pragma mark - UIViewController

- (void)dealloc {
    [__map release];
    [__category release];
    [_detailsController release];
    [_filterViewController release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showSearchBarWithPlaceholder:NSLocalizedString(@"Search reports...", nil)];
    [self showRefreshControl];
    [self initialSyncIfNeeded];
}

#pragma mark - UITableViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TableSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == TableSectionReports) {
        NSArray *reports = [self listOfReports];
        return reports.count > 0 ? reports.count : 1;
    }
    else if (section == TableSectionPending) {
        return self.map.reportsPending.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableSectionPending) {
        USHReport *report = [self.map.reportsPending objectAtIndex:indexPath.row];
        USHReportTableCell *cell = [USHTableCellFactory reportTableCellForTable:tableView indexPath:indexPath hasPhotos:report.photos.count > 0];
        cell.titleLabel.text = report.title;
        cell.descriptionLabel.text = report.desc;
        cell.pending = YES;
        cell.date = [report dateFormatted:@"h:mm a, MMM d, yyyy"];
        cell.location = report.location;
        cell.category = [report categoryTitles:@", "];
        if (report.photos.count > 0) {
            USHPhoto *photo = [[report.photos allObjects] objectAtIndex:0];
            if (photo.thumb != nil) {
                cell.image = [UIImage imageWithData:photo.thumb];
            }
            else if (photo.image != nil) {
                cell.image = [UIImage imageWithData:photo.image];
            }
            else {
                cell.image = nil;
            }
        }
        else {
            cell.image = nil;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    else if (indexPath.section == TableSectionReports) {
        NSArray *reports = [self listOfReports];
        if (reports.count > 0) {
            USHReport *report = [reports objectAtIndex:indexPath.row];
            BOOL hasPhotos = report.photos.count > 0 || report.snapshot != nil;
            USHReportTableCell *cell = [USHTableCellFactory reportTableCellForTable:tableView indexPath:indexPath hasPhotos:hasPhotos];
            cell.titleLabel.text = report.title;
            cell.descriptionLabel.text = report.desc;
            cell.verified = report.verified != nil ? [report.verified boolValue] : NO;
            cell.date = [report dateFormatted:@"h:mm a, MMM d, yyyy"];
            cell.location = report.location;
            cell.category = [report categoryTitles:@", "];
            cell.modified = report.viewed == nil;
            cell.starred = report.starred.boolValue;
            if (report.photos.count > 0) {
                USHPhoto *photo = [[report.photos allObjects] objectAtIndex:0];
                if (photo.thumb != nil) {
                    cell.image = [UIImage imageWithData:photo.thumb];
                }
                else if (photo.image != nil) {
                    cell.image = [UIImage imageWithData:photo.image];
                }
                else {
                    cell.image = nil;
                }
            }
            else if (report.snapshot != nil) {
                cell.image = [UIImage imageWithData:report.snapshot];
            }
            else {
                cell.image = nil;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        else {
            return [USHTableCellFactory textTableCellForTable:tableView indexPath:indexPath text:self.noReportsText];
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableSectionReports) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSArray *reports = [self listOfReports];
        if (reports.count > 0) {
            self.detailsController.map = self.map;
            self.detailsController.report = [reports objectAtIndex:indexPath.row];
            self.detailsController.reports = reports;
            [self.navigationController pushViewController:self.detailsController animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableSectionReports) {
        NSArray *reports = [self listOfReports];
        if (reports.count > 0) {
            return [USHReportTableCell cellHeight];
        }
        return [USHTextTableCell heightForTable:tableView text:self.noReportsText];
    }
    else if (indexPath.section == TableSectionPending && self.map.reportsPending.count > 0) {
        return [USHReportTableCell cellHeight];
    }
    return 0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == TableSectionReports) {
        return self.category != nil ? self.category.title : NSLocalizedString(@"All Categories", nil);   
    }
    else if (section == TableSectionPending && self.map.reportsPending.count > 0) {
        return NSLocalizedString(@"Pending Upload", nil);   
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == TableSectionPending;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"%d:%d", indexPath.section, indexPath.row);
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        USHReport *report = [self.map.reportsPending objectAtIndex:indexPath.row];
        if (report != nil) {
            [[Ushahidi sharedInstance] removeReport:report];
            [tableView reloadData];
        }
    }
}

#pragma mark - SearchBar

- (NSString *) noReportsText {
    NSMutableString *noReports = [NSMutableString stringWithString:NSLocalizedString(@"No reports", nil)];
    if (self.category != nil) {
        [noReports appendFormat:@" %@ '%@'", NSLocalizedString(@"for", nil), self.category.title];
    }
    if (self.searchText != nil) {
        [noReports appendFormat:@" %@ '%@'", NSLocalizedString(@"with", nil), self.searchText];
    }
    return noReports;
}

- (void) searchTextDidChange:(NSString *)searchText {
    [self.tableView reloadData];
}

#pragma mark - UshahidiDelegate

- (void) ushahidi:(Ushahidi*)ushahidi synchronizing:(USHMap*)map {
    DLog(@"");
}

- (void) ushahidi:(Ushahidi*)ushahidi synchronized:(USHMap*)map error:(NSError*)error {
    DLog(@"");
    [self hideLoading];
    [self endRefreshControl];
    if (error) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Synchronize Error", nil)
                           message:error.localizedDescription
                          delegate:self
                            cancel:NSLocalizedString(@"OK", nil)
                           buttons:nil];
    }
    else {
        [self.tableView reloadData];
        [self.filterViewController reloadFilters];
    }
}

- (NSArray*) listOfReports {
    if ([[USHSettings sharedInstance] sortReportsByDate]) {
        return [self.map reportsWithCategory:self.category text:self.searchText sort:USHSortByDate ascending:NO];
    }
    return [self.map reportsWithCategory:self.category text:self.searchText sort:USHSortByTitle ascending:YES];
}

@end
