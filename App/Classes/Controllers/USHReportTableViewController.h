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
#import <Ushahidi/Ushahidi.h>
#import <Ushahidi/USHTableViewController.h>

@class USHMap;
@class USHCategory;
@class USHFilterViewController;
@class USHReportDetailsViewController;

@interface USHReportTableViewController : USHTableViewController<UshahidiDelegate,
                                                                 UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet USHReportDetailsViewController *detailsController;
@property (strong, nonatomic) IBOutlet USHFilterViewController *filterViewController;

@property (strong, nonatomic) USHMap *map;
@property (strong, nonatomic) USHCategory *category;

@end
