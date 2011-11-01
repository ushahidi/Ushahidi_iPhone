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
#import "MapAnnotation.h"
#import "Settings.h"
#import "TableHeaderView.h"
#import "Internet.h"
#import "Checkin.h"
#import "User.h"
#import "Photo.h"
#import "ItemPicker.h"

@interface CheckinTableViewController()

@property(nonatomic,retain) NSMutableArray *users;
@property(nonatomic,retain) User *user;

- (void) pushViewController:(UIViewController *)viewController;

@end

@implementation CheckinTableViewController

@synthesize checkinTabViewController, checkinAddViewController, checkinDetailsViewController;
@synthesize users, user, deployment;

#pragma mark -
#pragma mark Handlers

- (IBAction) addCheckin:(id)sender {
	DLog(@"");
	[self.checkinTabViewController presentModalViewController:self.checkinAddViewController animated:YES];
}

- (IBAction) refresh:(id)sender {
	self.refreshButton.enabled = NO;
	[self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];
	[[Ushahidi sharedUshahidi] getCheckinsForDelegate:self];
	[[Ushahidi sharedUshahidi] getVersionOfDeployment:self.deployment forDelegate:self];
}

- (IBAction) filterChanged:(id)sender event:(UIEvent*)event {
	DLog(@"");
	NSMutableArray *items = [NSMutableArray arrayWithObject:NSLocalizedString(@" --- ALL USERS --- ", nil)];
	for (User *theUser in self.users) {
		if ([NSString isNilOrEmpty:[theUser name]] == NO) {
			[items addObject:[theUser name]];
		}
	}
	if (event != nil) {
		UIView *toolbar = [[event.allTouches anyObject] view];
		CGRect rect = CGRectMake(toolbar.frame.origin.x, self.view.frame.size.height - toolbar.frame.size.height, toolbar.frame.size.width, toolbar.frame.size.height);
		[self.itemPicker showWithItems:items 
						  withSelected:[self.user name] 
							   forRect:rect 
								   tag:0];
	}
	else {
		[self.itemPicker showWithItems:items 
						  withSelected:[self.user name] 
							   forRect:CGRectMake(100, self.view.frame.size.height, 0, 0) 
								   tag:0];	
	}
}

- (void) populate:(BOOL)refresh {
	DLog(@"refresh:%d", refresh);
	if (refresh) {
		[self.allRows removeAllObjects];
		[self.allRows addObjectsFromArray:[[Ushahidi sharedUshahidi] getCheckinsForDelegate:self]];
	}
	else if (self.user != nil) {
		[self.allRows removeAllObjects];
		[self.allRows addObjectsFromArray:[[Ushahidi sharedUshahidi] getCheckins]];
	}
	else {
		[self.allRows removeAllObjects];
		[self.allRows addObjectsFromArray:[[Ushahidi sharedUshahidi] getCheckins]];
	}
	[self.users removeAllObjects];
	if ([[Ushahidi sharedUshahidi] hasUsers]) {
		[self.users addObjectsFromArray:[[Ushahidi sharedUshahidi] getUsers]];
	}
	[self filterRows:YES];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.users = [[NSMutableArray alloc] initWithCapacity:0];
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
	[users release];
	[user release];
	[deployment release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return [self.filteredRows count]; 
}

- (CGFloat)tableView:(UITableView *)theTableView heightForHeaderInSection:(NSInteger)section {
	return [TableHeaderView getViewHeight];;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [CheckinTableCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	CheckinTableCell *cell = [TableCellFactory getCheckinTableCellForTable:theTableView indexPath:indexPath];
	Checkin *checkin = [self.filteredRows objectAtIndex:indexPath.row];
	if (checkin != nil) {
		[cell setName:checkin.name];
		if ([NSString isNilOrEmpty:checkin.message]) {
			[cell setMessage:checkin.coordinates];
		}
		else {
			[cell setMessage:checkin.message];
		}
		[cell setDate:checkin.dateString];
		UIImage *image = [checkin getFirstPhotoThumbnail];
		if (image != nil) {
			[cell setImage:image];
		}
		else if (checkin.hasPhotos) {
			Photo *photo = [checkin firstPhoto];
			photo.indexPath = indexPath;
			[[Ushahidi sharedUshahidi] downloadPhoto:photo forCheckin:checkin forDelegate:self];
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
		[cell setName:nil];
		[cell setMessage:nil];
		[cell setDate:nil];
		[cell setImage:nil];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	self.checkinDetailsViewController.checkin = [self.filteredRows objectAtIndex:indexPath.row];
	self.checkinDetailsViewController.checkins = self.filteredRows;
	if (self.editing) {
		[self.view endEditing:YES];
		[self performSelector:@selector(pushViewController:) withObject:self.checkinDetailsViewController afterDelay:0.1];
	}
	else {
		[self pushViewController:self.checkinDetailsViewController];
	}
}

- (void) pushViewController:(UIViewController *)viewController {
	[self.checkinTabViewController.navigationController pushViewController:self.checkinDetailsViewController animated:YES];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void) filterRows:(BOOL)reload {
	[self.filteredRows removeAllObjects];
	NSString *searchText = [self getSearchText];
	NSArray *checkins;
	if (self.tableSort.selectedSegmentIndex == TableSortDate) {
		checkins = [self.allRows sortedArrayUsingSelector:@selector(compareByDate:)];
	}
	else {
		checkins = [self.allRows sortedArrayUsingSelector:@selector(compareByName:)];
	}
	for (Checkin *checkin in checkins) {
        if (self.user != nil) {
            if ([self.user.name isEqualToString:checkin.name] && 
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

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi checkins:(NSArray *)theCheckins error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if (error != nil) {
		DLog(@"error: %d %@", [error code], [error localizedDescription]);
	}
	else if (hasChanges) {
		DLog(@"Re-Adding Checkins: %d", [theCheckins count]);
		[self.allRows removeAllObjects];
		[self.allRows addObjectsFromArray:theCheckins];
		[self populate:YES];
	}
	else {
		DLog(@"No Changes Checkins");
	}
	[self.loadingView hide];
	self.refreshButton.enabled = YES;
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi users:(NSArray *)theUsers error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if (error != nil) {
		DLog(@"error: %d %@", [error code], [error localizedDescription]);
	}
	else if (hasChanges) {
		DLog(@"Re-Adding Users: %d", [theUsers count]);
		[self.users removeAllObjects];
		[self.users addObjectsFromArray:theUsers];
	}
	else {
		DLog(@"No Changes Users");
	}
	self.filterButton.enabled = YES;
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi map:(UIImage *)map checkin:(Checkin *)checkin {
	DLog(@"downloadedFromUshahidi:map:object:");
	NSInteger row = [self.filteredRows indexOfObject:checkin];
	if (row != NSNotFound) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
		CheckinTableCell *cell = (CheckinTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
		if (cell != nil && [checkin getFirstPhotoThumbnail] == nil) {
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
		CheckinTableCell *cell = (CheckinTableCell *)[self.tableView cellForRowAtIndexPath:photo.indexPath];
		if (cell != nil) {
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
	else {
		[self.tableView reloadData];
	}
}

- (void) mainQueueFinished {
	DLog(@"");
	[self.loadingView hideAfterDelay:1.0];
}

#pragma mark -
#pragma mark ItemPickerDelegate

- (void) itemPickerReturned:(ItemPicker *)theItemPicker item:(NSString *)item {
	DLog(@"itemPickerReturned: %@", item);
	self.user = nil;
	for (User *theUser in self.users) {
		if ([theUser.name isEqualToString:item]) {
			self.user = theUser;
			DLog(@"User: %@", theUser.name);
			break;
		}
	}
	if (self.user != nil) {
		[self setHeader:self.user.name atSection:0];
	}
	else {
		[self setHeader:NSLocalizedString(@"All Users", nil) atSection:0];
	}
	[self filterRows:YES];
	if ([self.filteredRows count] == 0) {
		[self.loadingView showWithMessage:NSLocalizedString(@"No Checkins", nil)];
		[self.loadingView hideAfterDelay:1.0];					 
	}	
}

@end
