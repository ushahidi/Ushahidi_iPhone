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
#import "BaseSortTableViewController.h"
#import "Ushahidi.h"
#import "ItemPicker.h"

@class CheckinTabViewController;
@class CheckinAddViewController;
@class CheckinDetailsViewController;
@class SettingsViewController;
@class Deployment;
@class User;

@interface CheckinTableViewController : BaseSortTableViewController<UshahidiDelegate, 
																	ItemPickerDelegate> {
@public
	CheckinTabViewController *checkinTabViewController;
	CheckinAddViewController *checkinAddViewController;
	CheckinDetailsViewController *checkinDetailsViewController;
	Deployment *deployment;
																		
@private
	NSMutableArray *users;
	User *user;
}

@property(nonatomic,retain) IBOutlet CheckinTabViewController *checkinTabViewController;
@property(nonatomic,retain) IBOutlet CheckinAddViewController *checkinAddViewController;
@property(nonatomic,retain) IBOutlet CheckinDetailsViewController *checkinDetailsViewController;
@property(nonatomic,retain) Deployment *deployment;

- (IBAction) addCheckin:(id)sender;
- (IBAction) refresh:(id)sender;
- (IBAction) filterChanged:(id)sender event:(UIEvent*)event;
- (void) populate:(BOOL)refresh;

@end
