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

#import "BaseTableViewController.h"
#import "BaseViewController.h"
#import "TableCellFactory.h"
#import "UIView+Extension.h"
#import "TableHeaderView.h"
#import "UIColor+Extension.h"
#import "Settings.h"
#import "Device.h"

@interface BaseTableViewController ()

@property(nonatomic,assign) BOOL shouldBeginEditing;
@property(nonatomic,retain) NSMutableDictionary *headers;
@property(nonatomic,retain) NSMutableDictionary *footers;

- (void) scrollToIndexPath:(NSIndexPath *)indexPath;

@end

@implementation BaseTableViewController

@synthesize tableView, allRows, filteredRows, pendingRows, oddRowColor, evenRowColor, shouldBeginEditing, headers, footers, filter, filters;

- (void) hideSearchBar {
	if (self.tableView.tableHeaderView != nil) {
		[self.tableView.tableHeaderView release];
		self.tableView.tableHeaderView = nil;
	}
}

- (void) showSearchBar {
	[self showSearchBarWithPlaceholder:nil];
}

- (void) showSearchBarWithPlaceholder:(NSString *)placeholder {
	UISearchBar *searchBar = [[UISearchBar alloc] init];
	searchBar.delegate = self;
	searchBar.keyboardType = UIKeyboardTypeDefault;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.barStyle = UIBarStyleBlack;
	searchBar.placeholder = placeholder;
    searchBar.tintColor = [[Settings sharedSettings] searchBarTintColor];
    
	[searchBar sizeToFit];
	[self.tableView setTableHeaderView:searchBar];
	[searchBar release];
}

- (NSString *) getSearchText {
	UISearchBar *searchBar = (UISearchBar*)self.tableView.tableHeaderView;
	if (searchBar != nil) {
		return searchBar.text;
	}
	return nil;
}

- (void) setTableFooter:(NSString *)text {
	if (text != nil) {
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,  self.tableView.contentSize.width, 26)];
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor grayColor];
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont systemFontOfSize:15];
		label.text = text;
		[self.tableView setTableFooterView:label];
		[label release];
	}
	else {
		[self.tableView setTableFooterView:nil];
	}
}

- (void) replaceRows:(NSArray *)rows {
	[self.allRows removeAllObjects];
	[self.allRows addObjectsFromArray:rows];
	[self.filteredRows removeAllObjects];
	[self.filteredRows addObjectsFromArray:rows];
}

- (void) filterRows {
	[self filterRows:YES];
}

- (void) filterRows:(BOOL)reloadTable {
	//Do nothing in parent class
}

- (id) rowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.allRows count] > indexPath.row) {
		return [self.allRows objectAtIndex:indexPath.row];
	}
	return nil;
}

- (id) rowAtIndex:(NSInteger)index {
	if ([self.allRows count] > index) {
		return [self.allRows objectAtIndex:index];
	}
	return nil;
}

- (id) filteredRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.filteredRows count] > indexPath.row) {
		return [self.filteredRows objectAtIndex:indexPath.row];
	}
	return nil;
}

-(void) setHeader:(NSString *)header atSection:(NSInteger)section {
   [self.headers setObject:header forKey:[NSString stringWithFormat:@"%d", section]];
}


- (void) setFooter:(NSString *)text atSection:(NSInteger)section color:(UIColor*)color {
	NSString *key = [NSString stringWithFormat:@"%d", section];
	if (text != nil) {
		UILabel *label = [self.footers objectForKey:key];
		if (label != nil) {
			label.text = text;
		}
		else {
			UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,  self.tableView.contentSize.width, 26)];
			newLabel.backgroundColor = [UIColor clearColor];
			newLabel.textColor = color;
			newLabel.textAlignment = UITextAlignmentCenter;
			newLabel.font = [UIFont systemFontOfSize:15];
			newLabel.text = text;
			[self.footers setObject:newLabel forKey:key];
			[newLabel release];
		}
	}
	else {
		[self.footers removeObjectForKey:key];
	}    
}

- (void) setFooter:(NSString *)text atSection:(NSInteger)section {
    [self setFooter:text atSection:section color:[UIColor grayColor]];
}

- (void) clearHeaders {
	[self.headers removeAllObjects];
}

- (void) populate:(NSArray*)items filter:(NSObject*)theFilter {
    DLog(@"");
    self.filter = theFilter;
    [self.allRows removeAllObjects];
    [self.allRows addObjectsFromArray:items];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.allRows = [NSMutableArray arrayWithCapacity:0];
	self.filteredRows = [NSMutableArray arrayWithCapacity:0];
	self.headers = [NSMutableDictionary dictionaryWithCapacity:0];
	self.footers = [NSMutableDictionary dictionaryWithCapacity:0];
	self.shouldBeginEditing = YES;
	if ([Device isIPad]) {
		[self.tableView setBackgroundView:nil];
		[self.tableView setBackgroundView:[[[UIView alloc] init] autorelease]];
		[self.tableView setBackgroundColor:[[Settings sharedSettings] tableGroupedBackColor]];	
	}
	if (self.tableView.style == UITableViewStyleGrouped) {
		self.tableView.backgroundColor = [[Settings sharedSettings] tableGroupedBackColor];
		self.oddRowColor = [UIColor whiteColor];
		self.evenRowColor = [UIColor whiteColor];
	}
	else {
		self.tableView.backgroundColor = [[Settings sharedSettings] tablePlainBackColor];
		self.oddRowColor = [[Settings sharedSettings] tableOddRowColor];
		self.evenRowColor = [[Settings sharedSettings] tableEvenRowColor];
	}
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.allRows = nil;
	self.filteredRows = nil;
    self.pendingRows = nil;
    self.filters = nil;
	self.headers = nil;
	self.footers = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.tableView flashScrollIndicators];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.view endEditing:YES];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)dealloc {
	[allRows release];
	[filteredRows release];
    [pendingRows release];
	[tableView release];
	[oddRowColor release];
	[evenRowColor release];
	[headers release];
	[footers release];
    [filters release];
    [filter release];
	[super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 0;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return [self.filteredRows count];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [TableCellFactory getDefaultTableCellForTable:theTableView indexPath:indexPath];
}

- (void)tableView:(UITableView *)theTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row % 2) {
		if (self.evenRowColor != nil) {
			cell.backgroundColor = self.evenRowColor;
		}
	}
	else {
		if (self.oddRowColor != nil) {
			cell.backgroundColor = self.oddRowColor;
		}
	}
}

- (UIView *)tableView:(UITableView *)theTableView viewForHeaderInSection:(NSInteger)section {
	if ([self.headers count] > section) {
		NSString *header = [self.headers objectForKey:[NSString stringWithFormat:@"%d", section]];
		if (self.tableView.style == UITableViewStyleGrouped) {
			return [TableHeaderView headerForTable:theTableView 
                                              text:header 
                                         textColor:[UIColor blackColor] 
                                   backgroundColor:[UIColor clearColor]];
		}
		else {
			return [TableHeaderView headerForTable:theTableView 
                                              text:header 
                                         textColor:[[Settings sharedSettings] tableHeaderTextColor] 
                                   backgroundColor:[[Settings sharedSettings] tableHeaderBackColor]];
		}
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForHeaderInSection:(NSInteger)section {
	if ([self.headers count] > section) {
		return [TableHeaderView getViewHeight];
	}
	return 0;
}

- (UIView *)tableView:(UITableView *)theTableView viewForFooterInSection:(NSInteger)section {
	return [self.footers objectForKey:[NSString stringWithFormat:@"%d", section]];
}

- (CGFloat)tableView:(UITableView *)theTableView heightForFooterInSection:(NSInteger)section {
	UILabel *label = [self.footers objectForKey:[NSString stringWithFormat:@"%d", section]];
	return label != nil ? label.frame.size.height : 0.0;
}

- (void) scrollToIndexPath:(NSIndexPath *)indexPath {
	DLog(@"scrollToIndexPath: [%d, %d]", indexPath.section, indexPath.row);
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];	
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
}   

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:YES animated:YES];
	self.editing = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:NO animated:YES];
	self.editing = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	if(![searchBar isFirstResponder]) {
		self.shouldBeginEditing = NO;
	}
	[self filterRows:YES];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)bar {
    BOOL boolToReturn = self.shouldBeginEditing;
    self.shouldBeginEditing = YES;
    return boolToReturn;
}

@end
