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

#import <Ushahidi/USHTabBarController.h>
#import <Ushahidi/USHItemPicker.h>
#import <Ushahidi/Ushahidi.h>

@class USHMap;
@class USHCategory;
@class USHReportTableViewController;
@class USHReportMapViewController;
@class USHCategoryTableViewController;
@class USHReportAddViewController;
@class USHCheckinTableViewController;
@class USHSettingsViewController;

@interface USHReportTabBarController : USHTabBarController<UISplitViewControllerDelegate,
                                                           UIActionSheetDelegate,
                                                           UIAlertViewDelegate,
                                                           USHItemPickerDelegate,
                                                           UshahidiDelegate>


@property (strong, nonatomic) IBOutlet USHReportTableViewController *reportTableController;
@property (strong, nonatomic) IBOutlet USHReportMapViewController *reportMapController;
@property (strong, nonatomic) IBOutlet USHReportAddViewController *reportAddController;
@property (strong, nonatomic) IBOutlet USHCheckinTableViewController *checkinTableController;
@property (strong, nonatomic) IBOutlet USHCategoryTableViewController *categoryTableController;
@property (strong, nonatomic) IBOutlet USHSettingsViewController *settingsViewController;

@property (strong, nonatomic) USHMap *map;
@property (strong, nonatomic) USHCategory *category;

- (IBAction)filter:(id)sender event:(UIEvent*)event;
- (IBAction)info:(id)sender event:(UIEvent*)event;

@end
