//
//  AddIncidentViewController.h
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-09.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"
#import "TextFieldTableCell.h"
#import "TextViewTableCell.h"
#import "CheckBoxTableCell.h"
#import "ImagePickerController.h"

@class MapViewController;

@interface AddIncidentViewController : TableViewController<TextFieldTableCellDelegate, 
															TextViewTableCellDelegate, 
															CheckBoxTableCellDelegate>  {
	MapViewController *mapViewController;
	ImagePickerController *imagePickerController;
	UIBarButtonItem *cancelButton;
	UIBarButtonItem *doneButton;
}

@property(nonatomic, retain) IBOutlet MapViewController *mapViewController;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property(nonatomic, retain) ImagePickerController *imagePickerController;

- (IBAction) cancel:(id)sender;
- (IBAction) done:(id)sender;

@end
