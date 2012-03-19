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

#import "CheckinTableViewController.h"
#import "CheckinTabViewController.h"
#import "CheckinAddViewController.h"
#import "CheckinDetailsViewController.h"
#import "MapViewController.h"
#import "CheckinTableCell.h"
#import "TableCellFactory.h"
#import "UIColor+Extension.h"
#import "NSString+Extension.h"
#import "LoadingViewController.h"
#import "NSDate+Extension.h"
#import "AlertView.h"
#import "InputView.h"
#import "Incident.h"
#import "Deployment.h"
#import "MKMapView+Extension.h"
#import "MKPinAnnotationView+Extension.h"
#import "NSString+Extension.h"
#import "SubtitleTableCell.h"
#import "MapAnnotation.h"
#import "Settings.h"
#import "TableHeaderView.h"
#import "Internet.h"
#import "Checkin.h"
#import "User.h"
#import "Photo.h"
#import "Device.h"

@interface CheckinTableViewController()

- (void) updateSyncedLabel;

@end

@implementation CheckinTableViewController

@synthesize checkinTabViewController, checkinAddViewController, checkinDetailsViewController;
@synthesize deployment;

const CGFloat DETAIL_LABEL_HEIGHT = 18;
const CGFloat TEXT_LABEL_HEIGHT= 22;
const CGFloat CELL_PADDING = 25;
const CGFloat DEFAULT_CELL_HEIGHT = 60;
const CGFloat DEFAULT_IMAGE_WIDTH = 80;
const CGFloat MAXIMUM_CELL_HEIGHT = 2009;
const CGFloat GROUPED_TABLE_DIFFERENCE = 38;

#pragma mark -
#pragma mark Handlers

- (void) updateSyncedLabel {
	if (self.deployment.synced) {
		[self setTableFooter:[NSString stringWithFormat:@"%@ %@", 
							  NSLocalizedString(@"Last Sync", nil), 
							  [self.deployment.synced dateToString:@"h:mm a, MMMM d, yyyy"]]];	
	}
	else {
		[self setTableFooter:nil];
	}
}

- (void) populate:(NSArray*)items filter:(NSObject*)theFilter {
    DLog(@"");
    self.filter = theFilter;
    
    [self.allRows removeAllObjects];
    [self.allRows addObjectsFromArray:items];
    
    [self filterRows:YES];
	if (self.filter != nil) {
        User *user = (User*)self.filter;
        [self setHeader:user.name atSection:0];
    }
    else {
        [self setHeader:NSLocalizedString(@"All Users", nil) atSection:0];
    }
    [self updateSyncedLabel];
    [self.tableView reloadData];	
    [self.tableView flashScrollIndicators];	
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self showSearchBarWithPlaceholder:NSLocalizedString(@"Search checkins...", nil)];
	[self setHeader:NSLocalizedString(@"All Users", nil) atSection:0];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kMainQueueFinished object:nil];
}

- (void)dealloc {
	[checkinTabViewController release];
	[checkinAddViewController release];
	[checkinDetailsViewController release];
	[deployment release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return [self.filteredRows count];
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Checkin *checkin = [self.filteredRows objectAtIndex:indexPath.section];
    return [CheckinTableCell getCellHeightForMessage:checkin.message];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Checkin *checkin = [self.filteredRows objectAtIndex:indexPath.section];
    CheckinTableCell *cell = [TableCellFactory getCheckinTableCellForTable:theTableView indexPath:indexPath];
    if (checkin != nil) {
        if ([NSString isNilOrEmpty:checkin.message]) {
            [cell setMessage:checkin.coordinates];
        }
        else {
            [cell setMessage:checkin.message];
        }
        [cell setName:checkin.name];
        if ([Device isIPad]) {
            [cell setDate:checkin.longDateTimeString];
        }
        else {
            [cell setDate:checkin.shortDateTimeString];
        }
        if (checkin.hasPhotos) {
            Photo *photo = [checkin firstPhoto];
            if (photo != nil) {
                if (photo.thumbnail != nil) {
                    [cell setImage:photo.thumbnail];
                }
                else if (photo.image != nil) {
                    [cell setImage:photo.image];
                }
                
                else {
                    [cell setImage:nil];
                    photo.indexPath = indexPath;
                    [[Ushahidi sharedUshahidi] downloadPhoto:photo forCheckin:checkin forDelegate:self];
                }
            }
        }
        else if (checkin.hasMap) {
            [cell setImage:checkin.map];
        }
        else {
            [cell setImage:nil];
        } 
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    else {
        [cell setMessage:nil];
        [cell setName:nil];
        [cell setDate:nil];
        [cell setMessage:nil];
        [cell setImage:nil];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	self.checkinDetailsViewController.checkin = [self.filteredRows objectAtIndex:indexPath.section];
	self.checkinDetailsViewController.checkins = self.filteredRows;
	if (self.editing) {
		[self.view endEditing:YES];
		[self performSelector:@selector(pushDetailsViewController:) withObject:self.checkinDetailsViewController afterDelay:0.1];
	}
	else {
		[self pushDetailsViewController:self.checkinDetailsViewController animated:YES];
	}
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void) filterRows:(BOOL)reload {
    DLog(@"Reload:%d", reload);
	[self.filteredRows removeAllObjects];
	NSString *searchText = [self getSearchText];
	NSArray *checkins = [self.allRows sortedArrayUsingSelector:@selector(compareByDate:)];
	for (Checkin *checkin in checkins) {
        if (self.filter != nil) {
            User *user = (User*)self.filter;
            if ([user.name isEqualToString:checkin.name] && 
                [checkin.message anyWordHasPrefix:searchText]) {
                [self.filteredRows addObject:checkin];
            }
        }
        else if ([checkin.message anyWordHasPrefix:searchText] ||
            [checkin.name anyWordHasPrefix:searchText]) {
            [self.filteredRows addObject:checkin];
        }
	}
	if (reload) {
		[self.tableView reloadData];	
		[self.tableView flashScrollIndicators];	
	}
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadingFromUshahidi:(Ushahidi *)ushahidi checkins:(NSArray *)checkins {
	[self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi checkins:(NSArray *)checkins error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if (error != nil) {
		DLog(@"error: %d %@", [error code], [error localizedDescription]);
	}
	else if (hasChanges) {
		DLog(@"Re-Adding Checkins: %d", [checkins count]);
		[self.allRows removeAllObjects];
		[self.allRows addObjectsFromArray:checkins];
	}
	else {
		DLog(@"No Changes Checkins");
	}
    [self filterRows:YES];
	[self.loadingView hide];
	self.refreshButton.enabled = YES;
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi users:(NSArray *)users error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if (error != nil) {
		DLog(@"error: %d %@", [error code], [error localizedDescription]);
	}
	else if (hasChanges) {
		DLog(@"Re-Adding Users: %d", [users count]);
        [self.filters removeAllObjects];
        [self.filters addObjectsFromArray:users];
	}
	else {
		DLog(@"No Changes Users");
	}
	self.filterButton.enabled = self.filters.count > 0;
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi map:(UIImage *)map checkin:(Checkin *)checkin {
	DLog(@"downloadedFromUshahidi:map:object:");
	NSInteger section = [self.filteredRows indexOfObject:checkin];
	if (section != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        CheckinTableCell *cell = (CheckinTableCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        if (cell.image == nil) {
            [cell setImage:map];
        }
	}
	else {
		[self.tableView reloadData];
	}
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi photo:(Photo *)photo checkin:(Checkin *)checkin {
	DLog(@"url:%@ indexPath:%@", [photo url], [photo indexPath]);
	if (photo != nil && photo.indexPath != nil) {
        CheckinTableCell *cell = (CheckinTableCell*)[self.tableView cellForRowAtIndexPath:photo.indexPath];
		if (photo.thumbnail != nil) {
            [cell setImage:photo.thumbnail];
        }
        else if (photo.image != nil)  {
            [cell setImage:photo.image];
        }
        else {
            [self.tableView reloadData];
        }        
	}
	else {
		[self.tableView reloadData];
	}
}

@end
