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
#import "Ushahidi.h"

@interface BaseTableViewController : BaseViewController<UITableViewDelegate, 
														UITableViewDataSource, 
														UINavigationControllerDelegate, 
														UISearchBarDelegate,
                                                        UshahidiDelegate> {
	
@public
    UITableView *tableView;
	NSMutableArray *allRows;
	NSMutableArray *filteredRows;
    NSMutableArray *pendingRows;   
    NSMutableArray *filters;
    NSObject *filter;

    UIColor *oddRowColor;
    UIColor *evenRowColor; 
                                                            
@private
	BOOL shouldBeginEditing;
	NSMutableDictionary *headers;
	NSMutableDictionary *footers;
}

@property(nonatomic,retain) IBOutlet UITableView *tableView;
@property(nonatomic,retain) NSMutableArray *allRows;
@property(nonatomic,retain) NSMutableArray *filteredRows;
@property(nonatomic,retain) NSMutableArray *pendingRows;
@property(nonatomic,retain) NSMutableArray *filters;
@property(nonatomic,retain) NSObject *filter;

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
- (void) clearHeaders;
- (void) setHeader:(NSString *)header atSection:(NSInteger)section;
- (void) setFooter:(NSString *)text atSection:(NSInteger)section;
- (void) setFooter:(NSString *)text atSection:(NSInteger)section color:(UIColor*)color;
- (void) setTableFooter:(NSString *)text;
- (void) populate:(NSArray*)items filter:(NSObject*)filter;

@end
