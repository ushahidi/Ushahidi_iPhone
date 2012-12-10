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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "USHViewController.h"

@interface USHTableViewController : USHViewController<UITableViewDelegate, 
                                                      UITableViewDataSource,
                                                      UISearchBarDelegate,
                                                      UISearchBarDelegate,
                                                      UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIColor *tableRowColor;
@property (strong, nonatomic) UIColor *tableRowEvenColor;
@property (strong, nonatomic) UIColor *tableRowOddColor;
@property (strong, nonatomic) UIColor *tableRowSelectColor;
@property (strong, nonatomic) UIColor *tableHeaderBackColor;
@property (strong, nonatomic) UIColor *tableHeaderTextColor;
@property (strong, nonatomic) UIColor *tablePlainBackColor;
@property (strong, nonatomic) UIColor *tableGroupedBackColor;
@property (strong, nonatomic) UIColor *searchBarColor;
@property (strong, nonatomic) UIColor *refreshControlColor;

- (void) scrollToIndexPath:(NSIndexPath *)indexPath;
- (void) setTableFooter:(NSString *)text;

- (void) adjustToolBarHeight;

- (void) showRefreshControl;
- (void) hideRefreshControl;
- (void) startRefreshControl;
- (void) endRefreshControl;

- (void) hideSearchBar;
- (void) showSearchBar;
- (void) showSearchBarWithPlaceholder:(NSString *)placeholder;
- (NSString *) searchText;

- (void) searchTextDidChange:(NSString*)searchText;

@end
