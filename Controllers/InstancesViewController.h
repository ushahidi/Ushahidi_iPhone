//
//  InstancesViewController.h
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-09.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"
#import "SearchTableCell.h"

@class IncidentsViewController;
@class AddInstanceViewController;

@interface InstancesViewController : TableViewController<SearchTableCellDelegate> {
	IncidentsViewController *incidentsViewController;
	AddInstanceViewController *addInstanceViewController;
}

@property(nonatomic,retain) IBOutlet IncidentsViewController *incidentsViewController;
@property(nonatomic,retain) IBOutlet AddInstanceViewController *addInstanceViewController;

- (IBAction) add:(id)sender;
- (IBAction) refresh:(id)sender;

@end
