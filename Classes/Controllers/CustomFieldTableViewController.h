//
//  CustomFieldTableViewController.h
//  Ushahidi_iOS
//
//  Created by Bhadrik Patel on 9/18/12.
//  Copyright (c) 2012 Ushahidi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "Ushahidi.h"
#import "CheckBoxTableCell.h"
#import "IncidentCustomField.h"
#import "BaseAddViewController.h"

@class Incident;

@interface CustomFieldTableViewController : BaseTableViewController<UshahidiDelegate,CheckBoxTableCellDelegate>{
    
@public
    UIBarButtonItem *cancelButton;
	UIBarButtonItem *doneButton;
    Incident *incident; 
    IncidentCustomField *customField;
}

@property(nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property(nonatomic, retain) Incident *incident;
@property(nonatomic, retain) IncidentCustomField *customField;

- (IBAction) cancel:(id)sender;
- (IBAction) done:(id)sender;

@end






