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

#import "USHTableViewController.h"
#import "USHHeaderView.h"
#import "NSString+USH.h"
#import "UITableView+USH.h"
#import "UIBezierPath+USH.h"
#import "CKRefreshControl.h"
#import "USHDevice.h"

static const CGFloat kCornerRadius = 10;

@interface USHTableViewController ()

@property(nonatomic,assign) BOOL shouldBeginEditing;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) CKRefreshControl *refreshControlCK;

- (UIView*) footerLabelWithText:(NSString*)text;

@end

@implementation USHTableViewController

@synthesize tableView = _tableView;
@synthesize shouldBeginEditing;
@synthesize tableRowColor = _tableRowColor;
@synthesize tableRowEvenColor = _tableRowEvenColor;
@synthesize tableRowOddColor = _tableRowOddColor;
@synthesize tableHeaderBackColor = _tableHeaderBackColor;
@synthesize tableHeaderTextColor = _tableHeaderTextColor;
@synthesize tablePlainBackColor = _tablePlainBackColor;
@synthesize tableGroupedBackColor = _tableGroupedBackColor;
@synthesize tableRowSelectColor = _tableRowSelectColor;
@synthesize searchBarColor = _searchBarColor;
@synthesize refreshControlColor = _refreshControlColor;
@synthesize refreshControl = _refreshControl;
@synthesize refreshControlCK = _refreshControlCK;

#pragma mark - ToolBar

- (void) adjustToolBarHeight {
    if ([USHDevice isIPad] && self.toolBar != nil && self.tableView != nil) {
        NSInteger tabBarHeight = 49;
        CGRect toolBarFrame = self.toolBar.frame;
        toolBarFrame.size.height = tabBarHeight;
        toolBarFrame.origin.y = self.view.frame.size.height - tabBarHeight;
        self.toolBar.frame = toolBarFrame;
        CGRect tableViewFrame = self.tableView.frame;
        tableViewFrame.size.height = self.view.frame.size.height - self.tableView.frame.origin.y - tabBarHeight;
        self.tableView.frame = tableViewFrame;
    }
}

#pragma mark - UIRefreshControl

- (void) showRefreshControl  {
    if (NSClassFromString(@"UIRefreshControl") != nil) {
        self.refreshControl = [[[UIRefreshControl alloc] init] autorelease];
        self.refreshControl.tintColor = self.refreshControlColor;
        [self.refreshControl addTarget:self action:@selector(startRefreshControl) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:self.refreshControl];
    }
    else {
        self.refreshControlCK = [[[CKRefreshControl alloc] init] autorelease];
        self.refreshControlCK.tintColor = self.refreshControlColor;
        [self.refreshControlCK addTarget:self action:@selector(startRefreshControl) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:self.refreshControlCK];
    }
}

- (void) hideRefreshControl {
    if (self.refreshControl) {
        [self.refreshControl removeFromSuperview];   
    }
    else if (self.refreshControlCK) {
        [self.refreshControlCK removeFromSuperview];
    }
}

- (void) startRefreshControl {
    //child will implement
}

- (void) endRefreshControl {
    if (self.refreshControl) {
        [self.refreshControl endRefreshing];
    }
    else if (self.refreshControlCK) {
        [self.refreshControlCK endRefreshing];
    }
}

#pragma mark - UISearchBar

- (void) searchTextDidChange:(NSString*)searchText {
    //child should override this method
}

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
    searchBar.tintColor = self.searchBarColor;
    for(UIView *subView in searchBar.subviews) {
        if ([subView isKindOfClass:[UITextField class]]) {
            UITextField *searchField = (UITextField *)subView;
            searchField.font = [UIFont systemFontOfSize:16];
            break;
        }
    }
    
	[searchBar sizeToFit];
	[self.tableView setTableHeaderView:searchBar];
	[searchBar release];
}

- (NSString *) searchText {
	UISearchBar *searchBar = (UISearchBar*)self.tableView.tableHeaderView;
	if (searchBar != nil && [searchBar isKindOfClass:UISearchBar.class]) {
		return searchBar.text;
	}
	return nil;
}

- (UIView*) footerLabelWithText:(NSString*)text {
    NSInteger padding = self.tableView.style == UITableViewStylePlain ? 10 : 12;
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(padding, 0.0, self.tableView.contentWidth - padding - padding, 24.0f)] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor grayColor];
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15];
    label.minimumFontSize = 12;
    label.numberOfLines = 1;
    label.text = text;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIView *view = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.contentWidth, 24.0f)] autorelease];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    view.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    
    return view;
}

- (void) setTableFooter:(NSString *)text {
	if (text != nil) {
		self.tableView.tableFooterView = [self footerLabelWithText:text];
    }
	else {
        self.tableView.tableFooterView = nil;
	}
}

#pragma mark - UIScrollView

- (void) scrollToIndexPath:(NSIndexPath *)indexPath {
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];	
}

#pragma mark - UIViewController

- (void)dealloc {
    [_tableView release];
    [_tableRowColor release];
    [_tableRowEvenColor release];
    [_tableRowOddColor release];
    [_tableHeaderBackColor release];
    [_tableHeaderTextColor release];
    [_tablePlainBackColor release];
    [_tableGroupedBackColor release];
    [_tableRowSelectColor release];
    [_searchBarColor release];
    [_refreshControl release];
    [_refreshControlCK release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.clipsToBounds = YES;
    self.tableView.autoresizesSubviews = YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.tableView.style == UITableViewStylePlain) {
        self.tableView.backgroundColor = self.tablePlainBackColor;
    }
    else {
        [self.tableView setBackgroundView:nil];
		[self.tableView setBackgroundView:[[[UIView alloc] init] autorelease]];
        self.tableView.backgroundColor = self.tableGroupedBackColor;
    }
    NSIndexPath *selected = self.tableView.indexPathForSelectedRow;
    [self.tableView reloadData];
    if (selected != nil) {
        [self.tableView selectRowAtIndexPath:selected animated:NO scrollPosition:UITableViewScrollPositionTop];   
    }
    if (self.tableView.tableHeaderView != nil) {
        UISearchBar *searchBar = (UISearchBar *)self.tableView.tableHeaderView;
        if ([searchBar respondsToSelector:@selector(barTintColor)]) {
            searchBar.tintColor = [UIColor whiteColor];
            searchBar.barTintColor = self.searchBarColor;
        }
        else {
            searchBar.tintColor = self.searchBarColor;
        }
    }
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - UITableViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.style == UITableViewStylePlain) {
        if (indexPath.row % 2) {
            if (self.tableRowEvenColor != nil) {
                cell.backgroundColor = self.tableRowEvenColor;
            }
            else if (self.tableRowColor != nil) {
                cell.backgroundColor = self.tableRowColor;
            }
        }
        else {
            if (self.tableRowOddColor != nil) {
                cell.backgroundColor = self.tableRowOddColor;
            }
            else if (self.tableRowColor != nil) {
                cell.backgroundColor = self.tableRowColor;
            }
        }
        if (cell.selectedBackgroundView != nil) {
            cell.selectedBackgroundView.layer.cornerRadius = 0;
        }
    }
    else {
        if (self.tableRowColor != nil) {
            cell.backgroundColor = self.tableRowColor;
        }
        else {
            cell.backgroundColor = [UIColor whiteColor];
        }
        if (cell.selectedBackgroundView != nil && [USHDevice isIOS6]) {
            NSInteger rows = [tableView numberOfRowsInSection:indexPath.section];
            if (rows == 1) {
                cell.selectedBackgroundView.layer.cornerRadius = kCornerRadius;
            }
            else if (indexPath.row == 0) {
                cell.selectedBackgroundView.layer.cornerRadius = 0;
                cell.selectedBackgroundView.layer.mask = [UIBezierPath roundedLayerWithRect:cell.selectedBackgroundView.bounds
                                                                                    corners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                                                     radius:kCornerRadius];
            }
            else if (indexPath.row == rows - 1) {
                cell.selectedBackgroundView.layer.cornerRadius = 0;
                cell.selectedBackgroundView.layer.mask = [UIBezierPath roundedLayerWithRect:cell.selectedBackgroundView.bounds
                                                                                    corners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                                                                     radius:kCornerRadius];
            }
            else {
                cell.selectedBackgroundView.layer.cornerRadius = 0;
            }
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    if ([NSString isNilOrEmpty:title] == NO) {
        if (tableView.style == UITableViewStylePlain) {
            if (self.tableHeaderTextColor != nil && self.tableHeaderBackColor != nil) {
                return [USHHeaderView headerForTable:tableView 
                                                text:title 
                                           textColor:self.tableHeaderTextColor 
                                     backgroundColor:self.tableHeaderBackColor];   
            }
            return [USHHeaderView headerForTable:tableView 
                                            text:title 
                                       textColor:[UIColor blackColor] 
                                 backgroundColor:[UIColor clearColor]];   
        }
        else {
            if (self.tableHeaderTextColor != nil) {
                return [USHHeaderView headerForTable:tableView
                                                text:title
                                           textColor:self.tableHeaderTextColor
                                     backgroundColor:[UIColor clearColor]];
            }
            return [USHHeaderView headerForTable:tableView
                                            text:title 
                                       textColor:[UIColor blackColor] 
                                 backgroundColor:[UIColor clearColor]];
        }
    }
    return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    if ([NSString isNilOrEmpty:title] == NO) {
        return [USHHeaderView headerHeightForStyle:tableView.style];
    }
    if ([self tableView:tableView numberOfRowsInSection:section] > 0) {
         return 16.0f;
    }
    return 0.1;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView titleForFooterInSection:section];
    if ([NSString isNilOrEmpty:title] == NO) {
        return 24.0f;
    }
    return 0.1f;
}

-(UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView titleForFooterInSection:section];
    if ([NSString isNilOrEmpty:title] == NO) {
        return [self footerLabelWithText:title];
    }
    return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}

#pragma mark - UISearchBarDelegate

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
    [self.tableView flashScrollIndicators];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	if (![searchBar isFirstResponder]) {
		self.shouldBeginEditing = NO;
	}
    [self searchTextDidChange:searchText];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)bar {
    BOOL boolToReturn = self.shouldBeginEditing;
    self.shouldBeginEditing = YES;
    return boolToReturn;
}

@end
