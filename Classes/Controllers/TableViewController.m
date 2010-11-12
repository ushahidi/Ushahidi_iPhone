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

#import "TableViewController.h"
#import "TableCellFactory.h"
#import "UIView+Extension.h"
#import "TableHeaderView.h"
#import "UIColor+Extension.h"
#import "Device.h"

@interface TableViewController ()

@property(nonatomic,assign) CGFloat toolbarHeight;
@property(nonatomic,assign) BOOL shouldBeginEditing;
@property(nonatomic,retain) NSMutableArray *headers;
@property(nonatomic,retain) NSMutableDictionary *footers;

- (void) scrollToIndexPath:(NSIndexPath *)indexPath;
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) keyboardWillHide:(NSNotification *)notification;
- (void) resizeTableToFrame:(CGRect)rect duration:(NSTimeInterval)duration;

@end

@implementation TableViewController

@synthesize tableView, allRows, filteredRows, oddRowColor, evenRowColor, toolbarHeight, shouldBeginEditing, headers, footers;

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

-(void) addHeader:(NSString *)header {
    [self.headers addObject:header];
}

-(void) addHeaders:(NSString *)string, ... {
    va_list args;
    va_start(args, string);
	for (NSString *arg = string; arg != nil; arg = va_arg(args, NSString*)) {
		if (arg != nil && [arg length] > 0) {
			[self.headers addObject:arg];
		}
	}
	va_end(args);
}

- (void) setFooter:(NSString *)text atSection:(NSInteger)section {
	NSString *key = [NSString stringWithFormat:@"%d", section];
	UILabel *label = [self.footers objectForKey:key];
	if (label != nil) {
		label.text = text;
	}
	else {
		UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,  self.tableView.contentSize.width, 28)];
		newLabel.backgroundColor = [UIColor clearColor];
		newLabel.textColor = [UIColor grayColor];
		newLabel.textAlignment = UITextAlignmentCenter;
		newLabel.font = [UIFont systemFontOfSize:15];
		newLabel.text = text;
		[self.footers setObject:newLabel forKey:key];
		[newLabel release];
	}
}

- (void) clearHeaders {
	[self.headers removeAllObjects];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	DLog(@"%@", self.nibName);
	self.allRows = [[NSMutableArray alloc] initWithCapacity:0];
	self.filteredRows = [[NSMutableArray alloc] initWithCapacity:0];
	self.headers = [[NSMutableArray alloc] initWithCapacity:0];
	self.footers = [[NSMutableDictionary alloc] initWithCapacity:0];
	self.shouldBeginEditing = YES;
	if ([Device isIPad]) {
		[self.tableView setBackgroundView:nil];
		[self.tableView setBackgroundView:[[[UIView alloc] init] autorelease]];
		[self.tableView setBackgroundColor:[UIColor ushahidiLiteTan]];	
	}
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	DLog(@"%@", self.nibName);
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.tableView flashScrollIndicators];
	DLog(@"%@", self.nibName);
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	DLog(@"%@", self.nibName);
	[self.view endEditing:YES];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	DLog(@"%@", self.nibName);
}

- (void)dealloc {
	DLog(@"%@", self.nibName);
	[allRows release];
	[filteredRows release];
	[tableView release];
	[oddRowColor release];
	[evenRowColor release];
	[headers release];
	[footers release];
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
		if (self.oddRowColor != nil) {
			cell.backgroundColor = self.oddRowColor;
		}
	}
	else {
		if (self.evenRowColor != nil) {
			cell.backgroundColor = self.evenRowColor;
		}
	}
}

- (UIView *)tableView:(UITableView *)theTableView viewForHeaderInSection:(NSInteger)section {
	if ([self.headers count] > section) {
		NSString *header = [self.headers objectAtIndex:section];
		if (self.tableView.style == UITableViewStyleGrouped) {
			return [TableHeaderView headerForTable:theTableView text:header textColor:[UIColor ushahidiRed] backgroundColor:[UIColor clearColor]];
		}
		else {
			return [TableHeaderView headerForTable:theTableView text:header textColor:[UIColor ushahidiRed] backgroundColor:[UIColor ushahidiLiteBrown]];
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

#pragma mark -
#pragma mark Keyboard

-(void) keyboardWillShow:(NSNotification *)notification {
	DLog(@"notification:%@", notification);
	NSTimeInterval duration = 0.3;
	[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
	
	CGRect keyboardFrame = CGRectMake(0, 0, 0, 0);
	[[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
	
	CGRect tableFrame = self.tableView.frame;
	if ([UIDevice currentDevice].orientation == UIInterfaceOrientationPortrait ||
		[UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown) {
		tableFrame.size.height -= keyboardFrame.size.height;	
	}
	else {
		tableFrame.size.height -= keyboardFrame.size.width;
	}
	
	self.toolbarHeight = self.view.frame.size.height - (self.tableView.frame.origin.y + self.tableView.frame.size.height);
	tableFrame.size.height += self.toolbarHeight;
	
	[self resizeTableToFrame:tableFrame duration:duration];
}

-(void) keyboardWillHide:(NSNotification *)notification {
	DLog(@"notification:%@", notification);
	NSTimeInterval duration = 0.3;
	[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
	
	CGRect keyboardFrame = CGRectMake(0, 0, 0, 0);
	[[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
	
	CGRect tableFrame = self.tableView.frame;
	if ([UIDevice currentDevice].orientation == UIInterfaceOrientationPortrait ||
		[UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown) {
		tableFrame.size.height += keyboardFrame.size.height;	
	}
	else {
		tableFrame.size.height += keyboardFrame.size.width;
	}
	tableFrame.size.height -= self.toolbarHeight;
	
	[self resizeTableToFrame:tableFrame duration:duration];
}

- (void) resizeTableToFrame:(CGRect)frame duration:(NSTimeInterval)duration {
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:NO];
    [UIView setAnimationDuration:duration];
	self.tableView.frame = frame;
	[UIView commitAnimations];
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
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:NO animated:YES];
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
