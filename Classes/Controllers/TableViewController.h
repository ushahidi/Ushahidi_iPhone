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
#import "BaseViewController.h"

@interface TableViewController : BaseViewController<UITableViewDelegate, 
													UITableViewDataSource, 
													UINavigationControllerDelegate, 
													UISearchBarDelegate> {
	
@public
	IBOutlet UITableView *tableView;
	
@protected
	NSMutableArray *allRows;
	NSMutableArray *filteredRows;
	UIColor *oddRowColor;
	UIColor *evenRowColor;
	CGFloat toolbarHeight;
	
@private
	BOOL shouldBeginEditing;
}

@property(nonatomic,retain) UITableView *tableView;
@property(nonatomic,retain) NSMutableArray *allRows;
@property(nonatomic,retain) NSMutableArray *filteredRows;
@property(nonatomic,retain) UIColor *oddRowColor;
@property(nonatomic,retain) UIColor *evenRowColor;

- (void) hideSearchBar;
- (void) showSearchBar;
- (void) showSearchBarWithPlaceholder:(NSString *)placeholder;
- (NSString *) getSearchText;

- (id) rowAtIndexPath:(NSIndexPath *)indexPath;
- (id) rowAtIndex:(NSInteger)index;
- (id) filteredRowAtIndexPath:(NSIndexPath *)indexPath;
- (void) filterRows;
- (void) filterRows:(BOOL)reloadTable;
- (void) replaceRows:(NSArray *)rows;

@end
