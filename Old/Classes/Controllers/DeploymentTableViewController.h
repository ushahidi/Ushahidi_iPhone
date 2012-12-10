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
#import "BaseTableViewController.h"
#import "Ushahidi.h"
#import "MapDialog.h"

@class IncidentTabViewController;
@class CheckinTabViewController;
@class DeploymentAddViewController;
@class SettingsViewController;

@interface DeploymentTableViewController : BaseTableViewController<UshahidiDelegate, UIActionSheetDelegate, MapDialogDelegate> {
	
@public
	IBOutlet IncidentTabViewController *incidentTabViewController;
	IBOutlet CheckinTabViewController *checkinTabViewController;
	IBOutlet DeploymentAddViewController *deploymentAddViewController;
	IBOutlet SettingsViewController *settingsViewController;
    IBOutlet UIBarButtonItem *settingsButton;
	IBOutlet UIBarButtonItem *addButton;
	
@private 
    MapDialog *mapDialog;
    NSString *mapName;
    NSString *mapUrl;
}

@property(nonatomic, retain) IncidentTabViewController *incidentTabViewController;
@property(nonatomic, retain) DeploymentAddViewController *deploymentAddViewController;
@property(nonatomic, retain) SettingsViewController *settingsViewController;
@property(nonatomic, retain) CheckinTabViewController *checkinTabViewController;
@property(nonatomic, retain) UIBarButtonItem *settingsButton;
@property(nonatomic, retain) UIBarButtonItem *addButton;

- (IBAction) add:(id)sender event:(UIEvent*)event;
- (IBAction) settings:(id)sender event:(UIEvent*)event;

@end
