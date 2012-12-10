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
#import <Ushahidi/USHAppDelegate.h>

@class USHWindow;
@class USHMapTableViewController;
@class USHReportTabBarController;
@class USHSettingsViewController;
@class USHReportAddViewController;
@class USHFilterViewController;

@interface USHAppDelegateMain : USHAppDelegate<UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet USHReportTabBarController *reportTabBarController;
@property (strong, nonatomic) IBOutlet USHMapTableViewController *mapTableViewController;
@property (strong, nonatomic) IBOutlet USHSettingsViewController *settingsViewController;
@property (strong, nonatomic) IBOutlet USHFilterViewController *filterViewController;
@property (strong, nonatomic) IBOutlet USHReportAddViewController *reportAddViewController;

- (void) updateIconBadgeNumber;

@end
