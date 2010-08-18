//
//  SearchTableCell.h
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-09.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchTableCellDelegate;

@interface SearchTableCell : UITableViewCell<UISearchBarDelegate> {

@public
	NSIndexPath	*indexPath;
	UISearchBar *searchBar;
@private
	id<SearchTableCellDelegate>	delegate;
}

@property (nonatomic, retain) NSIndexPath *indexPath; 
@property (nonatomic, retain) UISearchBar *searchBar;

- (id)initWithDelegate:(id<SearchTableCellDelegate>)delegate reuseIdentifier:(NSString *)reuseIdentifier;
- (void) setKeyboardType:(UIKeyboardType)keyboardType;
- (void) setBarStyle:(UIBarStyle)barStyle;
- (void) setPlaceholder:(NSString *)placeholder;

@end

@protocol SearchTableCellDelegate <NSObject>

@optional

- (void) searchCellChanged:(SearchTableCell *)cell searchText:(NSString *)text;

@end