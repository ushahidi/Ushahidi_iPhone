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
#import "Settings.h"
#import "Device.h"

@interface TableViewController ()

@property(nonatomic,assign) BOOL shouldBeginEditing;
@property(nonatomic,retain) NSMutableDictionary *headers;
@property(nonatomic,retain) NSMutableDictionary *footers;

- (void) scrollToIndexPath:(NSIndexPath *)indexPath;
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) keyboardDidShow:(NSNotification *)notification;
- (void) keyboardWillHide:(NSNotification *)notification;
- (void) keyboardDidHide:(NSNotification *)notification;
- (void) resizeTableToFrame:(CGRect)rect duration:(NSTimeInterval)duration animation:(NSString *)animation;
- (CGFloat) getFrameHeight:(CGRect)frame;

@end

@implementation TableViewController

@synthesize tableView, allRows, filteredRows, oddRowColor, evenRowColor, shouldBeginEditing, headers, footers, editing;

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

- (void) setFooter:(NSString *)text atSection:(NSInteger)section {
	NSString *key = [NSString stringWithFormat:@"%d", section];
	if (text != nil) {
		UILabel *label = [self.footers objectForKey:key];
		if (label != nil) {
			label.text = text;
		}
		else {
			UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,  self.tableView.contentSize.width, 26)];
			newLabel.backgroundColor = [UIColor clearColor];
			newLabel.textColor = [UIColor grayColor];
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

- (void) clearHeaders {
	[self.headers removeAllObjects];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	DLog(@"%@", self.nibName);
	self.toolBar.tintColor = [[Settings sharedSettings] toolBarTintColor];
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
	self.headers = nil;
	self.footers = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
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
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
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
		NSString *header = [self.headers objectForKey:[NSString stringWithFormat:@"%d", section]];
		if (self.tableView.style == UITableViewStyleGrouped) {
			return [TableHeaderView headerForTable:theTableView text:header textColor:[[Settings sharedSettings] tableHeaderTextColor] backgroundColor:[UIColor clearColor]];
		}
		else {
			return [TableHeaderView headerForTable:theTableView text:header textColor:[[Settings sharedSettings] tableHeaderTextColor] backgroundColor:[[Settings sharedSettings] tableHeaderBackColor]];
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
	//DLog(@"notification:%@", notification);
	NSTimeInterval duration = 0.3;
	[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
	DLog(@"View x:%f y:%f width:%f height:%f", self.tableView.superview.frame.origin.x, self.tableView.superview.frame.origin.y, self.tableView.superview.frame.size.width, self.tableView.superview.frame.size.height);
	
	CGRect keyboardFrame = CGRectMake(0, 0, 0, 0);
	[[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
	DLog(@"Keyboard x:%f y:%f width:%f height:%f", keyboardFrame.origin.x, keyboardFrame.origin.y, keyboardFrame.size.width, keyboardFrame.size.height);
	
	CGRect tableFrame = self.tableView.frame;
	DLog(@"Table x:%f y:%f width:%f height:%f", tableFrame.origin.x, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height);
	
	tableFrame.size.height = [self getFrameHeight:self.tableView.superview.frame] - tableFrame.origin.y - [self getFrameHeight:keyboardFrame];
	
	[self resizeTableToFrame:tableFrame duration:duration animation:@"ShrinkTableHeight"];
}

-(void) keyboardDidShow:(NSNotification *)notification {
	self.editing = YES;
}

-(void) keyboardWillHide:(NSNotification *)notification {
	//DLog(@"notification:%@", notification);
	NSTimeInterval duration = 0.3;
	[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
	DLog(@"View x:%f y:%f width:%f height:%f", self.tableView.superview.frame.origin.x, self.tableView.superview.frame.origin.y, self.tableView.superview.frame.size.width, self.tableView.superview.frame.size.height);
	
	CGRect keyboardFrame = CGRectMake(0, 0, 0, 0);
	[[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
	DLog(@"Keyboard x:%f y:%f width:%f height:%f", keyboardFrame.origin.x, keyboardFrame.origin.y, keyboardFrame.size.width, keyboardFrame.size.height);
	
	CGRect tableFrame = self.tableView.frame;
	DLog(@"Table x:%f y:%f width:%f height:%f", tableFrame.origin.x, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height);
	
	if (self.toolBar) {
		tableFrame.size.height = self.toolBar.frame.origin.y - tableFrame.origin.y;
	}
	else {
		tableFrame.size.height = [self getFrameHeight:self.tableView.superview.frame] - tableFrame.origin.y;
	}
	
	[self resizeTableToFrame:tableFrame duration:duration animation:@"RestoreTableHeight"];
}

-(void) keyboardDidHide:(NSNotification *)notification {
	self.editing = NO;
}

- (CGFloat) getFrameHeight:(CGRect)frame {
	if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait ||
		[UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown) {
		DLog(@"UIDeviceOrientation: UIDeviceOrientationPortrait");
		return frame.size.height;
	}
	else if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft ||
			 [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
		DLog(@"UIDeviceOrientation: UIDeviceOrientationLandscape");
		return frame.size.width;
	}
	else if ([UIDevice currentDevice].orientation == UIDeviceOrientationUnknown) {
		DLog(@"UIDeviceOrientation: UIDeviceOrientationUnknown");
		return frame.size.height;
	}
	else {
		DLog(@"UIDeviceOrientation: %d", [UIDevice currentDevice].orientation);
	}
	return frame.size.height;
}

- (void) resizeTableToFrame:(CGRect)frame duration:(NSTimeInterval)duration animation:(NSString *)animation {
	DLog(@"size: %f, %f", frame.size.width, frame.size.height);
	[UIView beginAnimations:animation context:nil];
    [UIView setAnimationDuration:duration];
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.tableView cache:YES];
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
