//
//  SearchTableCell.m
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-09.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import "SearchTableCell.h"

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
