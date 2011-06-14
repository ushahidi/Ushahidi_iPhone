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
#import "BaseDetailsViewController.h"
#import "TextTableCell.h"
#import "MapTableCell.h"
#import "Ushahidi.h"
#import "Photo.h"
#import "SMS.h"
#import "Email.h"
#import "Bitly.h"

@interface CheckinDetailsViewController : BaseDetailsViewController<UshahidiDelegate, 
																	SMSDelegate,
																	EmailDelegate,
																	BitlyDelegate,
																	MapTableCellDelegate> {
	Checkin *checkin;
	NSArray *checkins;
}

@property(nonatomic,retain) Checkin *checkin;
@property(nonatomic,retain) NSArray *checkins;

- (IBAction) nextPrevious:(id)sender;
- (IBAction) sendEmail:(id)sender;
- (IBAction) sendSMS:(id)sender;
- (IBAction) sendTweet:(id)sender;

@end
