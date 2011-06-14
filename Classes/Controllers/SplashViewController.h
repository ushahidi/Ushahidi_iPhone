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

@class DeploymentTableViewController;
@class IncidentTabViewController;
@class IncidentDetailsViewController;
@class CheckinTabViewController;

@interface SplashViewController : UIViewController {
	
@public
	IBOutlet DeploymentTableViewController *deploymentTableViewController;
	IBOutlet IncidentTabViewController *incidentTabViewController;
	IBOutlet IncidentDetailsViewController *incidentDetailsViewController;
	IBOutlet CheckinTabViewController *checkinTabViewController;
}

@property(nonatomic, retain) DeploymentTableViewController *deploymentTableViewController;
@property(nonatomic, retain) IncidentTabViewController *incidentTabViewController;
@property(nonatomic, retain) IncidentDetailsViewController *incidentDetailsViewController;
@property(nonatomic, retain) CheckinTabViewController *checkinTabViewController;

@end
