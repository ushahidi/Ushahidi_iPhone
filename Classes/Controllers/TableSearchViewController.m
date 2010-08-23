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

#import "TableSearchViewController.h"

@interface TableSearchViewController ()

@end

@implementation TableSearchViewController

@synthesize searchBar, searchButton;

- (void) toggleSearchBar:(UISearchBar *)theSearchBar animated:(BOOL)animated {
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];	
	}
	CGRect searchBarFrame = theSearchBar.frame;
	CGRect tableViewFrame = self.tableView.frame;
	if (searchBarFrame.origin.y < 0) {
		DLog(@"Show");
		searchBarFrame.origin.y += searchBarFrame.size.height;
		tableViewFrame.origin.y = searchBarFrame.size.height;
		tableViewFrame.size.height -= searchBarFrame.size.height;
		[theSearchBar becomeFirstResponder];
	}
	else {
		DLog(@"Hide");
		searchBarFrame.origin.y -= searchBarFrame.size.height;
		tableViewFrame.origin.y = 0;
		tableViewFrame.size.height += searchBarFrame.size.height;
		[theSearchBar setText:@""];
		[theSearchBar resignFirstResponder];
	}
	theSearchBar.frame = searchBarFrame;
	self.tableView.frame = tableViewFrame;
	if (animated) {
		[UIView commitAnimations];
	}
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
	[searchBar release];
	[searchButton release];
    [super dealloc];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	theSearchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)theSearchBar {
	theSearchBar.showsCancelButton = NO;
}   

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar {
	[theSearchBar setText:@""];
	[self.filteredRows removeAllObjects];
	[self.filteredRows addObjectsFromArray:self.allRows];
	[self.tableView reloadData];	
	[self.tableView flashScrollIndicators];
	[theSearchBar resignFirstResponder];
	[self toggleSearchBar:theSearchBar animated:YES];
}  

@end
