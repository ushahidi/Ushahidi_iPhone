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
#import "TextViewTableCell.h"
#import "TextFieldTableCell.h"
#import "Bitly.h"
#import "MGTwitterEngineDelegate.h"

@class MGTwitterEngine;

@interface TwitterViewController : BaseTableViewController<TextViewTableCellDelegate, 
															TextFieldTableCellDelegate,
															MGTwitterEngineDelegate,
															BitlyDelegate> {
@public
	UIBarButtonItem *cancelButton;
	UIBarButtonItem *doneButton;
	UIBarButtonItem *logoutButton;
	NSString *tweet;

@private
	MGTwitterEngine *twitter;
	Bitly *bitly;
	NSString *username;
	NSString *password;
}

@property (nonatomic, retain) IBOutlet	UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet	UIBarButtonItem *doneButton;
@property (nonatomic, retain) IBOutlet	UIBarButtonItem *logoutButton;
@property (nonatomic, retain)			NSString *tweet;

- (IBAction) cancel:(id)sender;
- (IBAction) done:(id)sender;
- (IBAction) shorten:(id)sender;
- (IBAction) logout:(id)sender; 

@end
