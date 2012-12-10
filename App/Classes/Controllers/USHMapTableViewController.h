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
#import <Ushahidi/USHRefreshButton.h>
#import <Ushahidi/USHMapDialog.h>

@class USHReportTableViewController;
@class USHReportTabBarController;
@class USHMapAddViewController;
@class USHSettingsViewController;

@interface USHMapTableViewController : USHTableViewController<UshahidiDelegate,
                                                              UIAlertViewDelegate,
                                                              UIActionSheetDelegate,
                                                              USHMapDialogDelegate>


@property (strong, nonatomic) IBOutlet USHReportTabBarController *reportTabController;
@property (strong, nonatomic) IBOutlet USHMapAddViewController *mapAddViewController;
@property (strong, nonatomic) IBOutlet USHSettingsViewController *settingsViewController;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *infoButton;
@property (strong, nonatomic) IBOutlet USHRefreshButton *refreshButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;

- (IBAction)refresh:(id)sender event:(UIEvent*)event;
- (IBAction)add:(id)sender event:(UIEvent*)event;
- (IBAction)edit:(id)sender event:(UIEvent*)event;
- (IBAction)info:(id)sender event:(UIEvent*)event;

@end
