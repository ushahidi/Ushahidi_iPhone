//
//  AddInstanceViewController.h
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-09.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"
#import "TextFieldTableCell.h"

@interface AddInstanceViewController : TableViewController<TextFieldTableCellDelegate> {
	UIBarButtonItem *cancelButton;
	UIBarButtonItem *doneButton;
}

@property(nonatomic,retain) IBOutlet UIBarButtonItem *cancelButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *doneButton;

- (IBAction) cancel:(id)sender;
- (IBAction) done:(id)sender;

@end
