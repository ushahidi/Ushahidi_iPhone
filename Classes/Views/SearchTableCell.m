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

#import "SearchTableCell.h"

@interface SearchTableCell ()

@property (nonatomic, assign) id<SearchTableCellDelegate> delegate;

@end


@implementation SearchTableCell

@synthesize delegate, indexPath, searchBar;

- (id)initWithDelegate:(id<SearchTableCellDelegate>)theDelegate reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		self.delegate = theDelegate;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.searchBar = [[UISearchBar alloc] initWithFrame:self.contentView.frame];
		self.searchBar.delegate = self;
		self.searchBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		self.searchBar.keyboardType = UIKeyboardTypeDefault;
		self.searchBar.barStyle = UIBarStyleBlack;
		[self.contentView addSubview:self.searchBar];
	}
    return self;
}

- (void) setKeyboardType:(UIKeyboardType)keyboardType {
	self.searchBar.keyboardType = keyboardType;
}

- (void) setBarStyle:(UIBarStyle)barStyle {
	self.searchBar.barStyle = barStyle;
}

- (void) setPlaceholder:(NSString *)placeholder {
	self.searchBar.placeholder = placeholder;
}

- (void)dealloc {
	delegate = nil;
	[indexPath release];
	[super dealloc];
}

- (void) notifyDelegate {
	SEL selector = @selector(searchCellChanged:searchText:);
	if (self.delegate != NULL && [self.delegate respondsToSelector:selector]) {
		[self.delegate searchCellChanged:self searchText:self.searchBar.text];
	}
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	theSearchBar.showsCancelButton = YES;
}   

- (void)searchBarTextDidEndEditing:(UISearchBar *)theSearchBar {
	theSearchBar.showsCancelButton = NO;
}   

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
	[self notifyDelegate];
}   

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	theSearchBar.showsCancelButton = NO;
	[theSearchBar resignFirstResponder];
	[self notifyDelegate];
}   

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar {
	theSearchBar.showsCancelButton = NO;
	[theSearchBar resignFirstResponder];
	[self notifyDelegate];
} 

@end
