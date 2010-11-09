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

- (id)initForDelegate:(id<SearchTableCellDelegate>)delegate reuseIdentifier:(NSString *)reuseIdentifier;
- (void) setKeyboardType:(UIKeyboardType)keyboardType;
- (void) setBarStyle:(UIBarStyle)barStyle;
- (void) setPlaceholder:(NSString *)placeholder;

@end

@protocol SearchTableCellDelegate <NSObject>

@optional

- (void) searchCellChanged:(SearchTableCell *)cell searchText:(NSString *)text;

@end