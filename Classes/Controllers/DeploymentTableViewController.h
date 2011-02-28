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
#import "Ushahidi.h"

@class IncidentTabViewController;
@class DeploymentAddViewController;
@class SettingsViewController;

@interface DeploymentTableViewController : TableViewController<UshahidiDelegate> {
	
@public
	IBOutlet IncidentTabViewController *incidentTabViewController;
	IBOutlet DeploymentAddViewController *deploymentAddViewController;
	IBOutlet SettingsViewController *settingsViewController;
	IBOutlet UIBarButtonItem *addButton;
	IBOutlet UIBarButtonItem *editButton;
	IBOutlet UIBarButtonItem *refreshButton;
	IBOutlet UISegmentedControl *tableSort;
	
@private 
	UIButton *settingsButton;
}

@property(nonatomic, retain) IncidentTabViewController *incidentTabViewController;
@property(nonatomic, retain) DeploymentAddViewController *deploymentAddViewController;
@property(nonatomic, retain) SettingsViewController *settingsViewController;
@property(nonatomic, retain) UIBarButtonItem *addButton;
@property(nonatomic, retain) UIBarButtonItem *editButton;
@property(nonatomic, retain) UIBarButtonItem *refreshButton;
@property(nonatomic, retain) UISegmentedControl *tableSort;

- (IBAction) add:(id)sender;
- (IBAction) edit:(id)sender;
- (IBAction) refresh:(id)sender;
- (IBAction) tableSortChanged:(id)sender;

@end
