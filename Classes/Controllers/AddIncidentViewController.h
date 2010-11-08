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
#import "ImagePickerController.h"
#import "Ushahidi.h"
#import "DatePicker.h"
#import "ImagePickerController.h"

@class CategoriesViewController;
@class LocationsViewController;
@class IncidentsViewController;
@class Incident;

@interface AddIncidentViewController : TableViewController<TextFieldTableCellDelegate, 
														   TextViewTableCellDelegate, 
														   DatePickerDelegate,
														   ImagePickerDelegate>  {
																
@public
	ImagePickerController *imagePickerController;
	CategoriesViewController *categoriesViewController;
	LocationsViewController *locationsViewController;
	IncidentsViewController *incidentsViewController;
	UIBarButtonItem *cancelButton;
	UIBarButtonItem *doneButton;
																
@private
	DatePicker *datePicker;
	Incident *incident;
}

@property(nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property(nonatomic, retain) IBOutlet ImagePickerController *imagePickerController;
@property(nonatomic, retain) IBOutlet CategoriesViewController *categoriesViewController;
@property(nonatomic, retain) IBOutlet LocationsViewController *locationsViewController;
@property(nonatomic, retain) IBOutlet IncidentsViewController *incidentsViewController;

- (IBAction) cancel:(id)sender;
- (IBAction) done:(id)sender;

@end
