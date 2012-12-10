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

#import <Ushahidi/USHAddViewController.h>
#import <Ushahidi/USHDatePicker.h>
#import <Ushahidi/USHLocator.h>
#import <Ushahidi/USHImagePicker.h>
#import <Ushahidi/USHVideoPicker.h>
#import <Ushahidi/USHLoginDialog.h>
#import <Ushahidi/Ushahidi.h>
#import <Ushahidi/USHShareController.h>
#import "USHInputTableCell.h"

@class USHCategoryTableViewController;
@class USHLocationAddViewController;
@class USHSettingsViewController;
@class USHMap;
@class USHReport;

@interface USHReportAddViewController : USHAddViewController<UshahidiDelegate,
                                                             USHDatePickerDelegate,
                                                             UIAlertViewDelegate,
                                                             USHLocatorDelegate,
                                                             USHImagePickerDelegate,
                                                             USHVideoPickerDelegate,
                                                             USHInputTableCellDelegate,
                                                             USHLoginDialogDelegate,
                                                             USHShareControllerDelegate>

@property (strong, nonatomic) IBOutlet USHCategoryTableViewController *categoryTableController;
@property (strong, nonatomic) IBOutlet USHLocationAddViewController *locationAddViewController;
@property (strong, nonatomic) IBOutlet USHSettingsViewController *settingsViewController;

@property (strong, nonatomic) USHMap *map;
@property (strong, nonatomic) USHReport *report;
@property (assign, nonatomic) BOOL openGeoSMS;

- (IBAction)info:(id)sender event:(UIEvent*)event;

@end
