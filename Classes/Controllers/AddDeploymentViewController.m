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

#import "AddDeploymentViewController.h"
#import "TableCellFactory.h"
#import "LoadingViewController.h"
#import "AlertView.h"
#import "InputView.h"
#import "Ushahidi.h"
#import "UIColor+Extension.h"
#import "NSString+Extension.h"
#import "Deployment.h"
#import "DeploymentTableCell.h"
#import "NSString+Extension.h"
#import "Settings.h"

#define kKilometerPrefix @" km"

typedef enum {
	TableSortDate,
	TableSortName
} TableSort;

@interface AddDeploymentViewController ()

@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *url;
@property(nonatomic, retain) MapDialog *mapDialog;
@property(nonatomic, retain) NSString *mapDistance;
@property(nonatomic, retain) ItemPicker *itemPicker;

- (void) dismissModalView;

@end

@implementation AddDeploymentViewController

@synthesize cancelButton, refreshButton, tableSort, name, url, mapDialog, mapDistance, itemPicker;

#pragma mark -
#pragma mark Private

- (void) dismissModalView {
	[self.loadingView hide];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Handlers

- (IBAction) add:(id)sender {
	DLog(@"");
	self.name = nil;
	self.url = nil;
	[self.mapDialog showWithTitle:NSLocalizedString(@"Enter Map Details", nil) 
							 name:nil 
							  url:nil];
}

- (IBAction) refresh:(id)sender event:(UIEvent *)event {
	DLog(@"");
	NSArray *items = [NSArray arrayWithObjects:@"50 km", @"100 km", @"250 km", @"500 km", @"750 km", @"1000 km", @"1500 km", nil];
	NSString *selected = [NSString isNilOrEmpty:self.mapDistance] ? nil : [NSString stringWithFormat:@"%@%@", self.mapDistance, kKilometerPrefix];
	if (event != nil) {
		UIView *toolbar = [[event.allTouches anyObject] view];
		CGRect rect = CGRectMake(toolbar.frame.origin.x, self.view.frame.size.height - toolbar.frame.size.height, toolbar.frame.size.width, toolbar.frame.size.height);
		[self.itemPicker showWithItems:items withSelected:selected forRect:rect];
	}
	else {
		[self.itemPicker showWithItems:items withSelected:selected forRect:CGRectMake(100, self.view.frame.size.height, 0, 0)];	
	}
}

- (IBAction) cancel:(id)sender {
	DLog(@"cancel");
	if (self.editing) {
		[self.view endEditing:YES];
		[self performSelector:@selector(dismissModalView) withObject:nil afterDelay:0.3];	
	}
	else {
		[self dismissModalView];
	}
}

- (IBAction) tableSortChanged:(id)sender {
	DLog(@"");
	UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
	if (segmentControl.selectedSegmentIndex == TableSortDate) {
		DLog(@"TableSortDate");
	}
	else if (segmentControl.selectedSegmentIndex == TableSortName) {
		DLog(@"TableSortTitle");
	}
	[self filterRows:YES];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.backgroundColor = [UIColor ushahidiLiteTan];
	self.oddRowColor = [UIColor ushahidiDarkTan];
	self.evenRowColor = [UIColor ushahidiLiteBrown];
	[self showSearchBarWithPlaceholder:NSLocalizedString(@"Search maps...", nil)];
	self.mapDialog = [[MapDialog alloc] initForDelegate:self];
	self.mapDistance = [[Settings sharedSettings] mapDistance];
	self.itemPicker = [[ItemPicker alloc] initWithDelegate:self forController:self];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	NSArray *mapsUnsorted = [[Ushahidi sharedUshahidi] getMaps];
	NSArray *mapsSorted = self.tableSort.selectedSegmentIndex == TableSortDate 
		? [mapsUnsorted sortedArrayUsingSelector:@selector(compareByDiscovered:)]
		: [mapsUnsorted sortedArrayUsingSelector:@selector(compareByName:)];
	if ([mapsSorted count] > 0) {
		[self.allRows removeAllObjects];
		[self.allRows addObjectsFromArray:mapsSorted];
		[self.filteredRows removeAllObjects];
		NSString *searchText = [self getSearchText];
		for (Deployment *map in mapsSorted) {
			if ([map matchesString:searchText]) {
				[self.filteredRows addObject:map];
			}
		}
	}
	else {
		self.refreshButton.enabled = NO;
		if ([NSString isNilOrEmpty:[Locator sharedLocator].latitude] && [NSString isNilOrEmpty:[Locator sharedLocator].longitude]) {
			[[Locator sharedLocator] detectLocationForDelegate:self];
			[self.loadingView showWithMessage:NSLocalizedString(@"Locating...", nil)];
		}
		else {
			[self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];
			[[Ushahidi sharedUshahidi] getMapsForDelegate:self 
												 latitude:[Locator sharedLocator].latitude
												longitude:[Locator sharedLocator].longitude
												 distance:self.mapDistance];
		}
	}
	[self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.alertView showInfoOnceOnly:NSLocalizedString(@"Select an existing map from the list, or click the Plus button to manually add your own map.", nil)];
}

- (void)dealloc {
	[cancelButton release];
	[refreshButton release];
	[tableSort release];
	[name release];
	[url release];
	[mapDialog release];
	[itemPicker release];
	[mapDistance release];
	[itemPicker release];
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

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DeploymentTableCell *cell = [TableCellFactory getDeploymentTableCellForTable:theTableView indexPath:indexPath];
	Deployment *map = [self filteredRowAtIndexPath:indexPath];
	if (map != nil) {
		[cell setTitle:map.name];
		[cell setUrl:map.url];
		if ([NSString isNilOrEmpty:map.description]) {
			[cell setDescription:map.name];
		}
		else {
			[cell setDescription:map.description];
		}
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	else {
		[cell setTitle:nil];
		[cell setUrl:nil];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.view endEditing:YES];
	[self.loadingView showWithMessage:NSLocalizedString(@"Added", nil)];
	Deployment *map = [self filteredRowAtIndexPath:indexPath];
	[[Ushahidi sharedUshahidi] addDeployment:map];
	[self performSelector:@selector(dismissModalView) withObject:nil afterDelay:1.5];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [DeploymentTableCell getCellHeight];
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi maps:(NSArray *)maps error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if (error != nil) {
		DLog(@"error: %@", [error localizedDescription]);
		[self.loadingView hide];
		[self.alertView showOkWithTitle:NSLocalizedString(@"Error", nil) 
							 andMessage:[error localizedDescription]];
	}
	else if (hasChanges) {
		DLog(@"Has Changes: %d", [maps count]);
		NSArray *sortedMaps = self.tableSort.selectedSegmentIndex == TableSortDate
			? [maps sortedArrayUsingSelector:@selector(compareByDiscovered:)]
			: [maps sortedArrayUsingSelector:@selector(compareByName:)];
		[self.allRows removeAllObjects];
		[self.allRows addObjectsFromArray:sortedMaps];
		NSString *searchText = [self getSearchText];
		[self.filteredRows removeAllObjects];
		for (Deployment *map in sortedMaps) {
			if ([map matchesString:searchText]) {
				[self.filteredRows addObject:map];
			}
		}
		[self.tableView reloadData];	
		[self.tableView flashScrollIndicators];
		[self.loadingView hide];
	}
	else {
		DLog(@"No Changes");
		[self.loadingView hide];
	}
	self.refreshButton.enabled = YES;
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void) filterRows:(BOOL)reloadTable {
	NSString *searchText = [self getSearchText];
	NSArray *maps;
	if (self.tableSort.selectedSegmentIndex == TableSortDate) {
		maps = [self.allRows sortedArrayUsingSelector:@selector(compareByDiscovered:)];
	}
	else {
		maps = [self.allRows sortedArrayUsingSelector:@selector(compareByName:)];
	}
	[self.filteredRows removeAllObjects];
	for (Deployment *map in maps) {
		if ([map matchesString:searchText]) {
			[self.filteredRows addObject:map];
		}
	}
	if (reloadTable) {
		[self.tableView reloadData];	
		[self.tableView flashScrollIndicators];
	}
}

#pragma mark -
#pragma mark MapDialogDelegate

- (void) mapDialogReturned:(MapDialog *)theMapDialog name:(NSString *)theName url:(NSString *)theUrl {
	DLog(@"name:%@ url:%@", theName, theUrl);
	self.name = theName;
	self.url = theUrl;
	if (self.name != nil && [self.name length] > 0 && 
		self.url != nil && [self.url isValidURL]) {
		[self.loadingView showWithMessage:NSLocalizedString(@"Added", nil)];
		[[Ushahidi sharedUshahidi] addDeploymentByName:theName andUrl:theUrl];	
		[self performSelector:@selector(dismissModalView) withObject:nil afterDelay:1.5];
	}
	else {
		[self.alertView showOkWithTitle:NSLocalizedString(@"Invalid Map Details", nil) 
							 andMessage:NSLocalizedString(@"Please enter a valid name and url.", nil)];
	}
}

- (void) mapDialogCancelled:(MapDialog *)theMapDialog {
	DLog(@"");
	self.name = nil;
	self.url = nil;
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([alert.title isEqualToString:NSLocalizedString(@"Invalid Map Details", nil)]) {
		[self.mapDialog showWithTitle:NSLocalizedString(@"Enter Map Details", nil) 
								 name:self.name 
								  url:self.url];	
	}
}
	
#pragma mark -
#pragma mark LocatorDelegate
					
- (void) locator:(Locator *)locator latitude:(NSString *)latitude longitude:(NSString *)longitude {
	DLog(@"latitude: %@ longitude:%@", latitude, longitude);
	[self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];
	[[Ushahidi sharedUshahidi] getMapsForDelegate:self 
										 latitude:latitude
										longitude:longitude
										 distance:self.mapDistance];
}

#pragma mark -
#pragma mark ItemPickerDelegate

- (void) itemPickerReturned:(ItemPicker *)theItemPicker item:(NSString *)item {
	self.mapDistance = [item stringByReplacingOccurrencesOfString:kKilometerPrefix withString:@""];
	self.refreshButton.enabled = NO;
	if ([NSString isNilOrEmpty:[Locator sharedLocator].latitude] && [NSString isNilOrEmpty:[Locator sharedLocator].longitude]) {
		[[Locator sharedLocator] detectLocationForDelegate:self];
		[self.loadingView showWithMessage:NSLocalizedString(@"Locating...", nil)];
	}
	else {
		[self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];
		[[Ushahidi sharedUshahidi] getMapsForDelegate:self 
											 latitude:[Locator sharedLocator].latitude
											longitude:[Locator sharedLocator].longitude
											 distance:self.mapDistance];
	}
}

@end
