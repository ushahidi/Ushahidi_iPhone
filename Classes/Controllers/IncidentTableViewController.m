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

#import "IncidentTableViewController.h"
#import "IncidentTabViewController.h"
#import "IncidentAddViewController.h"
#import "IncidentDetailsViewController.h"
#import "IncidentTableCell.h"
#import "TableCellFactory.h"
#import "UIColor+Extension.h"
#import "LoadingViewController.h"
#import "NSDate+Extension.h"
#import "AlertView.h"
#import "InputView.h"
#import "Incident.h"
#import "Deployment.h"
#import "Category.h"
#import "NSString+Extension.h"
#import "Settings.h"
#import "TableHeaderView.h"
#import "Internet.h"
#import "ItemPicker.h"

@interface IncidentTableViewController ()

@property(nonatomic,retain) NSMutableArray *pending;
@property(nonatomic,retain) ItemPicker *itemPicker;
@property(nonatomic,retain) NSMutableArray *categories;
@property(nonatomic,retain) Category *category;

- (void) updateSyncedLabel;


- (void) pushViewController:(UIViewController *)viewController;
- (void) presentModalViewController:(UIViewController *)viewController;

- (void) mainQueueFinished;
- (void) mapQueueFinished;
- (void) photoQueueFinished;
- (void) uploadQueueFinished;

@end

@implementation IncidentTableViewController

@synthesize incidentTabViewController, incidentAddViewController, incidentDetailsViewController;
@synthesize tableSort, refreshButton, filterButton, itemPicker;
@synthesize pending, categories, category, deployment;

#pragma mark -
#pragma mark Enums

typedef enum {
	TableSectionPending,
	TableSectionIncidents
} TableSection;

typedef enum {
	TableSortDate,
	TableSortTitle,
	TableSortVerified
} TableSort;

#pragma mark -
#pragma mark Handlers

- (IBAction) addReport:(id)sender {
	DLog(@"");
	self.incidentAddViewController.incident = nil;
	[self.incidentTabViewController presentModalViewController:self.incidentAddViewController animated:YES];
}

- (IBAction) refresh:(id)sender {
	DLog(@"");
	self.refreshButton.enabled = NO;
	[self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];
	[[Ushahidi sharedUshahidi] getIncidentsForDelegate:self];
	[[Ushahidi sharedUshahidi] uploadIncidentsForDelegate:self];
	[[Ushahidi sharedUshahidi] getCategoriesForDelegate:self];
}

- (IBAction) sortChanged:(id)sender {
	UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
	if (segmentControl.selectedSegmentIndex == TableSortDate) {
		DLog(@"TableSortDate");
	}
	else if (segmentControl.selectedSegmentIndex == TableSortTitle) {
		DLog(@"TableSortTitle");
	}
	else if (segmentControl.selectedSegmentIndex == TableSortVerified) {
		DLog(@"TableSortVerified");
	}
	[self filterRows:YES];
}

- (IBAction) filterChanged:(id)sender event:(UIEvent*)event {
	DLog(@"");
	NSMutableArray *items = [NSMutableArray arrayWithObject:NSLocalizedString(@" --- ALL CATEGORIES --- ", nil)];
	for (Category *theCategory in self.categories) {
		if ([NSString isNilOrEmpty:[theCategory title]] == NO) {
			[items addObject:theCategory.title];
		}
	}
	if (event != nil) {
		UIView *toolbar = [[event.allTouches anyObject] view];
		CGRect rect = CGRectMake(toolbar.frame.origin.x, self.view.frame.size.height - toolbar.frame.size.height, toolbar.frame.size.width, toolbar.frame.size.height);
		[self.itemPicker showWithItems:items 
						  withSelected:[self.category title] 
							   forRect:rect 
								   tag:0];
	}
	else {
		[self.itemPicker showWithItems:items 
						  withSelected:[self.category title] 
							   forRect:CGRectMake(100, self.view.frame.size.height, 0, 0) 
								   tag:0];	
	}
}

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

- (void) populate:(BOOL)refresh {
	DLog(@"refresh:%d", refresh);
	[self.allRows removeAllObjects];
	if (refresh) {
		[self.allRows addObjectsFromArray:[[Ushahidi sharedUshahidi] getIncidentsForDelegate:self]];
		[self.categories removeAllObjects];
		if ([[Ushahidi sharedUshahidi] hasCategories]) {
			[self.categories addObjectsFromArray:[[Ushahidi sharedUshahidi] getCategories]];
		}
		else {
			[self.categories addObjectsFromArray:[[Ushahidi sharedUshahidi] getCategoriesForDelegate:self]];
		}
		self.category = nil;
		if ([[Ushahidi sharedUshahidi] hasLocations] == NO) {
			[[Ushahidi sharedUshahidi] getLocationsForDelegate:self];
		}
		if ([self.categories count] == 0) {
			[self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];	
		}
		[self setHeader:NSLocalizedString(@"All Categories", nil) atSection:TableSectionIncidents];
	}
	else {
		[self.allRows addObjectsFromArray:[[Ushahidi sharedUshahidi] getIncidents]];
	}
	[self.pending removeAllObjects];
	[self.pending addObjectsFromArray:[[Ushahidi sharedUshahidi] getIncidentsPending]];
	[self filterRows:YES];
	self.filterButton.enabled = [self.categories count] > 0;
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.pending = [[NSMutableArray alloc] initWithCapacity:0];
	self.categories = [[NSMutableArray alloc] initWithCapacity:0];
	self.itemPicker = [[ItemPicker alloc] initWithDelegate:self forController:self];
	self.tableView.backgroundColor = [UIColor ushahidiLiteTan];
	self.oddRowColor = [UIColor ushahidiLiteTan];
	self.evenRowColor = [UIColor ushahidiDarkTan];
	[self showSearchBarWithPlaceholder:NSLocalizedString(@"Search reports...", nil)];
	[self setHeader:NSLocalizedString(@"Pending Upload", nil) atSection:TableSectionPending];
	[self setHeader:NSLocalizedString(@"All Categories", nil) atSection:TableSectionIncidents];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.itemPicker = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.allRows removeAllObjects];
	[self.allRows addObjectsFromArray:[[Ushahidi sharedUshahidi] getIncidents]];
	
	[self.pending removeAllObjects];
	[self.pending addObjectsFromArray:[[Ushahidi sharedUshahidi] getIncidentsPending]];
	
	[self filterRows:YES];
	
	self.filterButton.enabled = [self.categories count] > 0;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainQueueFinished) name:kMainQueueFinished object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapQueueFinished) name:kMapQueueFinished object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoQueueFinished) name:kPhotoQueueFinished object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadQueueFinished) name:kUploadQueueFinished object:nil];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if ([self.pending count] > 0 ) {
		[self.alertView showInfoOnceOnly:NSLocalizedString(@"Click the Refresh button to upload pending reports.", nil)];
	}
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kMainQueueFinished object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kMapQueueFinished object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPhotoQueueFinished object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kUploadQueueFinished object:nil];
}

- (void)dealloc {
	[incidentTabViewController release];
	[incidentAddViewController release];
	[incidentDetailsViewController release];
	[deployment release];
	[tableSort release];
	[pending release];
	[itemPicker release];
	[categories release];
	[category release];
	[super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (section == TableSectionPending) {
		return [self.pending count];
	}
	if (section == TableSectionIncidents) {
		return [self.filteredRows count];
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForHeaderInSection:(NSInteger)section {
	if (section == TableSectionPending && [self.pending count] > 0) {
		return [TableHeaderView getViewHeight];
	}
	else if (section == TableSectionIncidents) {
		return [TableHeaderView getViewHeight];
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [IncidentTableCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	IncidentTableCell *cell = [TableCellFactory getIncidentTableCellForTable:theTableView indexPath:indexPath];
	Incident *incident = indexPath.section == TableSectionIncidents
		? [self filteredRowAtIndexPath:indexPath] : [self.pending objectAtIndex:indexPath.row];
	if (incident != nil) {
		[cell setTitle:incident.title];
		[cell setLocation:incident.location];
		[cell setCategory:incident.categoryNames];
		[cell setDate:incident.dateString];
		[cell setVerified:incident.verified];
		UIImage *image = [incident getFirstPhotoThumbnail];
		if (image != nil) {
			[cell setImage:image];
		}
		else if (incident.hasPhotos) {
			Photo *photo = [incident.photos objectAtIndex:0];
			[[Ushahidi sharedUshahidi] downloadPhoto:photo incident:incident forDelegate:self];
		}
		else if (incident.map != nil) {
			[cell setImage:incident.map];
		}
		else {
			[cell setImage:nil];
		}
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		[cell setUploading:indexPath.section == TableSectionPending && incident.uploading];
	}
	else {
		[cell setTitle:nil];
		[cell setLocation:nil];
		[cell setCategory:nil];
		[cell setDate:nil];
		[cell setImage:nil];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == TableSectionIncidents) {
		self.incidentDetailsViewController.incident = [self filteredRowAtIndexPath:indexPath];
		self.incidentDetailsViewController.incidents = self.filteredRows;
		self.incidentTabViewController.navigationItem.backBarButtonItem.title = NSLocalizedString(@"Reports", nil);
		if (self.editing) {
			[self.view endEditing:YES];
			[self performSelector:@selector(pushViewController:) withObject:self.incidentDetailsViewController afterDelay:0.1];
		}
		else {
			[self pushViewController:self.incidentDetailsViewController];
		}
	}
	else {
		self.incidentAddViewController.incident = [self.pending objectAtIndex:indexPath.row];
		if (self.editing) {
			[self.view endEditing:YES];
			[self performSelector:@selector(presentModalViewController:) withObject:self.incidentAddViewController afterDelay:0.1];
		}
		else {
			[self presentModalViewController:self.incidentAddViewController];
		}
	}	
}

- (void) pushViewController:(UIViewController *)viewController {
	[self.incidentTabViewController.navigationController pushViewController:self.incidentDetailsViewController animated:YES];
}

- (void) presentModalViewController:(UIViewController *)viewController {
	[self.incidentTabViewController presentModalViewController:self.incidentAddViewController animated:YES];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void) filterRows:(BOOL)reload {
	[self.filteredRows removeAllObjects];
	NSString *searchText = [self getSearchText];
	NSArray *incidents;
	if (self.tableSort.selectedSegmentIndex == TableSortDate) {
		incidents = [self.allRows sortedArrayUsingSelector:@selector(compareByDate:)];
	}
	else if (self.tableSort.selectedSegmentIndex == TableSortVerified) {
		incidents = [self.allRows sortedArrayUsingSelector:@selector(compareByVerified:)];
	}
	else {
		incidents = [self.allRows sortedArrayUsingSelector:@selector(compareByTitle:)];
	}
	for (Incident *incident in incidents) {
		if (self.category != nil) {
			if ([incident hasCategory:self.category] && [incident matchesString:searchText]) {
				[self.filteredRows addObject:incident];
			}
		}
		else if ([incident matchesString:searchText]) {
			[self.filteredRows addObject:incident];
		}
	}
	if (reload) {
		[self setTableFooter:nil];
		[self.tableView reloadData];	
		[self.tableView flashScrollIndicators];	
		[self updateSyncedLabel];	
	}
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadingFromUshahidi:(Ushahidi *)ushahidi categories:(NSArray *)theCategories {
	DLog(@"Downloading Categories...");
	[self.loadingView showWithMessage:NSLocalizedString(@"Categories...", nil)];
}

- (void) downloadingFromUshahidi:(Ushahidi *)ushahidi locations:(NSArray *)locations {
	DLog(@"Downloading Locations...");
	[self.loadingView showWithMessage:NSLocalizedString(@"Locations...", nil)];
}

- (void) downloadingFromUshahidi:(Ushahidi *)ushahidi incidents:(NSArray *)incidents pending:(NSArray *)thePending {
	DLog(@"Downloading Incidents...");
	[self.loadingView showWithMessage:NSLocalizedString(@"Incidents...", nil)];
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi incidents:(NSArray *)incidents pending:(NSArray *)thePending error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if (error != nil) {
		DLog(@"error: %d %@", [error code], [error localizedDescription]);
		if ([error code] == UnableToCreateRequest) {
			[self.loadingView hide];
			[self.alertView showOkWithTitle:NSLocalizedString(@"Request Error", nil) 
								 andMessage:[error localizedDescription]];
		}
		else if ([error code] == NoInternetConnection) {
			if ([self.loadingView isShowing]) {
				[self.loadingView hide];
				[self.alertView showOkWithTitle:NSLocalizedString(@"No Internet", nil) 
									 andMessage:[error localizedDescription]];
			}
		}
		else if ([self.loadingView isShowing]){
			[self.loadingView hide];
			[self.alertView showOkWithTitle:NSLocalizedString(@"Server Error", nil) 
								 andMessage:[error localizedDescription]];
		}
	}
	else if (hasChanges) {
		DLog(@"incidents: %d", [incidents count]);
		[self updateSyncedLabel];
		[self.allRows removeAllObjects];
		if (self.tableSort.selectedSegmentIndex == TableSortDate) {
			[self.allRows addObjectsFromArray:[incidents sortedArrayUsingSelector:@selector(compareByDate:)]];
		}
		else if (self.tableSort.selectedSegmentIndex == TableSortVerified) {
			[self.allRows addObjectsFromArray:[incidents sortedArrayUsingSelector:@selector(compareByVerified:)]];
		}
		else {
			[self.allRows addObjectsFromArray:[incidents sortedArrayUsingSelector:@selector(compareByTitle:)]];
		}
		[self.filteredRows removeAllObjects];
		[self.filteredRows addObjectsFromArray:self.allRows];
		[self.pending removeAllObjects];
		[self.pending addObjectsFromArray:thePending];
		
		[self.tableView reloadData];
		[self.tableView flashScrollIndicators];	
		DLog(@"Re-Adding Incidents");
	}
	else {
		DLog(@"No Changes Incidents");
		[self updateSyncedLabel];
		[self.tableView reloadData];
	}
	self.refreshButton.enabled = YES;
}

- (void) uploadingToUshahidi:(Ushahidi *)ushahidi incident:(Incident *)incident {
	if (incident != nil){
		NSInteger row = [self.pending indexOfObject:incident];
		DLog(@"Incident: %d %@", row, incident.title);
		if (row > -1) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:TableSectionPending];
			IncidentTableCell *cell = (IncidentTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
			if (cell != nil) {
				[cell setUploading:YES];
			}
		}
		else {
			[self.tableView reloadData];
		}
	}
	else {
		DLog(@"Incident is NULL");
		[self.tableView reloadData];
	}
}

- (void) uploadedToUshahidi:(Ushahidi *)ushahidi incident:(Incident *)incident error:(NSError *)error {
	if (error != nil) {
		DLog(@"error: %d %@", [error code], [error localizedDescription]);
		if ([error code] > NoInternetConnection) {
			[self.loadingView hide];
			[self.alertView showOkWithTitle:NSLocalizedString(@"Upload Error", nil) 
								 andMessage:[error localizedDescription]];
		}
	}
	if (incident != nil) {
		NSInteger row = [self.pending indexOfObject:incident];
		DLog(@"Incident: %d %@", row, incident.title);
		if (row > -1) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:TableSectionPending];
			IncidentTableCell *cell = (IncidentTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
			if (cell != nil) {
				[cell setUploading:NO];
			}
		}
		[self.loadingView showWithMessage:NSLocalizedString(@"Uploaded", nil)];
		[self.loadingView hideAfterDelay:1.0];
	}
	else {
		DLog(@"Incident is NULL");
	}
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi map:(UIImage *)map incident:(Incident *)incident {
	DLog(@"downloadedFromUshahidi:incident:map:");
	NSInteger row = [self.filteredRows indexOfObject:incident];
	if (row != NSNotFound) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:TableSectionIncidents];
		IncidentTableCell *cell = (IncidentTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
		if (cell != nil && [incident getFirstPhotoThumbnail] == nil) {
			[cell setImage:map];
		}
	}
	else {
		[self.tableView reloadData];
	}
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi photo:(Photo *)photo incident:(Incident *)incident {
	DLog(@"downloadedFromUshahidi:incident:photo:%@ indexPath:%@", [photo url], [photo indexPath]);
	if (photo != nil && photo.indexPath != nil) {
		IncidentTableCell *cell = (IncidentTableCell *)[self.tableView cellForRowAtIndexPath:photo.indexPath];
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

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi categories:(NSArray *)theCategories error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if (error != nil) {
		DLog(@"error: %d %@", [error code], [error localizedDescription]);
	}
	else if (hasChanges) {
		[self.categories removeAllObjects];
		for (Category *theCategory in theCategories) {
			[self.categories addObject:theCategory];
		}
		DLog(@"Re-Adding Categories");
	}
	else {
		DLog(@"No Changes Categories");
	}
	self.filterButton.enabled = [self.categories count] > 0;
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi locations:(NSArray *)theLocations error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if (error != nil) {
		DLog(@"error: %d %@", [error code], [error localizedDescription]);
	}
	else if (hasChanges) {
		DLog(@"Re-Adding Locations");
	}
	else {
		DLog(@"No Changes Locations");
	}
}

- (void) mainQueueFinished {
	DLog(@"");
	[self.loadingView hideAfterDelay:1.0];
}

- (void) mapQueueFinished {
	DLog(@"");
}

- (void) photoQueueFinished {
	DLog(@"");
}

- (void) uploadQueueFinished {
	DLog(@"");
}

#pragma mark -
#pragma mark ItemPickerDelegate

- (void) itemPickerReturned:(ItemPicker *)theItemPicker item:(NSString *)item {
	DLog(@"itemPickerReturned: %@", item);
	self.category = nil;
	for (Category *theCategory in self.categories) {
		if ([theCategory.title isEqualToString:item]) {
			self.category = theCategory;
			DLog(@"Category: %@", theCategory.title);
			break;
		}
	}
	if (self.category != nil) {
		[self setHeader:self.category.title atSection:TableSectionIncidents];
	}
	else {
		[self setHeader:NSLocalizedString(@"All Categories", nil) atSection:TableSectionIncidents];
	}
	[self filterRows:YES];
	if ([self.filteredRows count] == 0) {
		[self.loadingView showWithMessage:NSLocalizedString(@"No Reports", nil)];
		[self.loadingView hideAfterDelay:1.0];					 
	}	
}

@end
