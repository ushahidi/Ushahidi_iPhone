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
#import "BaseAddViewController.h"
#import "TextFieldTableCell.h"
#import "TextViewTableCell.h"
#import "ButtonTableCell.h"
#import "ImagePickerController.h"
#import "Ushahidi.h"
#import "DatePicker.h"
#import "Locator.h"
#import "VideoPickerController.h"

@class CategoryTableViewController;
@class LocationSelectViewController;
@class Incident;

@interface IncidentAddViewController : BaseAddViewController<TextFieldTableCellDelegate, 
																TextViewTableCellDelegate, 
																DatePickerDelegate,
																ImagePickerDelegate,
                                                                VideoPickerDelegate,
																UIActionSheetDelegate, 
																LocatorDelegate,
																ButtonTableCellDelegate,
																UshahidiDelegate>  {
																
@public
	CategoryTableViewController *categoryTableViewController;
	LocationSelectViewController *locationSelectViewController;
	ImagePickerController *imagePickerController;
    VideoPickerController *videoPickerController;
														
@private
	DatePicker *datePicker;
	NSString *news;
    Incident *incident;
}

@property(nonatomic, retain) IBOutlet CategoryTableViewController *categoryTableViewController;
@property(nonatomic, retain) IBOutlet LocationSelectViewController *locationSelectViewController;
@property(nonatomic, retain) ImagePickerController *imagePickerController;
@property(nonatomic, retain) VideoPickerController *videoPickerController;

@end
