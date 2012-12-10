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
#import "Ushahidi.h"

@class DeploymentTableViewController;
@class IncidentTabViewController;
@class IncidentDetailsViewController;
@class CheckinTabViewController;
@class CategorySelectViewController;
@class UserSelectViewController;
@class SettingsViewController;
@class BaseViewController;
@class SplashViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, UshahidiDelegate> {
    
@public
    UIWindow *window;
	UINavigationController *navigationController;
    UISplitViewController *splitViewController;

    DeploymentTableViewController *deploymentTableViewController;
    IncidentTabViewController *incidentTabViewController;
    IncidentDetailsViewController *incidentDetailsViewController;
    CheckinTabViewController *checkinTabViewController;
    
    CategorySelectViewController *categorySelectViewController;
    UserSelectViewController *userSelectViewController;
    SettingsViewController  *settingsViewController;
    SplashViewController *splashViewController;
}

@property(nonatomic, retain) IBOutlet UIWindow *window;
@property(nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property(nonatomic, retain) IBOutlet UISplitViewController *splitViewController;

@property(nonatomic, retain) IBOutlet DeploymentTableViewController *deploymentTableViewController;
@property(nonatomic, retain) IBOutlet IncidentTabViewController *incidentTabViewController;
@property(nonatomic, retain) IBOutlet IncidentDetailsViewController *incidentDetailsViewController;
@property(nonatomic, retain) IBOutlet CheckinTabViewController *checkinTabViewController;

@property(nonatomic, retain) IBOutlet CategorySelectViewController *categorySelectViewController;
@property(nonatomic, retain) IBOutlet UserSelectViewController *userSelectViewController;
@property(nonatomic, retain) IBOutlet SettingsViewController  *settingsViewController;
@property(nonatomic, retain) IBOutlet SplashViewController *splashViewController;

- (NSString *)applicationDocumentsDirectory;
- (void)pushDetailsViewController:(BaseViewController *)viewController animated:(BOOL)animated ;
- (void)setDetailsViewController:(BaseViewController *)viewController animated:(BOOL)animated;

@end

