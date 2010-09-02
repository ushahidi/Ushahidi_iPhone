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
#import "TableViewController.h"
#import "TextFieldTableCell.h"
#import "TextViewTableCell.h"
#import "CheckBoxTableCell.h"
#import "DateTableCell.h"
#import "MapTableCell.h"
#import "ImagePickerController.h"
#import "Ushahidi.h"
#import "DatePicker.h"

@class MapViewController;
@class Incident;

@interface AddIncidentViewController : TableViewController<UshahidiDelegate, 
															TextFieldTableCellDelegate, 
															TextViewTableCellDelegate, 
															CheckBoxTableCellDelegate,
															DateTableCellDelegate,
															MapTableCellDelegate,
															DatePickerDelegate>  {
																
@public
	MapViewController *mapViewController;
	ImagePickerController *imagePickerController;
	UIBarButtonItem *cancelButton;
	UIBarButtonItem *doneButton;
																
@private
	NSMutableArray *categories;
	NSMutableArray *countries;
	NSMutableArray *locations;
	DatePicker *datePicker;
	Incident *incident;
}

@property(nonatomic, retain) IBOutlet MapViewController *mapViewController;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property(nonatomic, retain) IBOutlet ImagePickerController *imagePickerController;

- (IBAction) cancel:(id)sender;
- (IBAction) done:(id)sender;

@end
