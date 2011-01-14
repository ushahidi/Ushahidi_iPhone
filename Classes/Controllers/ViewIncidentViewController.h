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
#import "TextTableCell.h"
#import "MapTableCell.h"
#import "Ushahidi.h"
#import "Photo.h"
#import "SMS.h"
#import "Email.h"
#import "Bitly.h"

@class WebViewController;
@class MapViewController;
@class ImageViewController;
@class NewsViewController;
@class TwitterViewController;
@class Incident;
@class Email;
@class SMS;
@class Bitly;
@class MoviePlayer;

@interface ViewIncidentViewController : TableViewController<UshahidiDelegate, 
															UIWebViewDelegate,
															SMSDelegate,
															EmailDelegate,
															BitlyDelegate,
															MapTableCellDelegate> {
	
@public
	MapViewController *mapViewController;
	ImageViewController *imageViewController;
	NewsViewController *newsViewController;
	TwitterViewController *twitterViewController;
	UISegmentedControl *nextPrevious;
	Incident *incident;
	NSArray *incidents;
	BOOL pending; 
	UIBarButtonItem *smsButton;
	UIBarButtonItem *emailButton;
	UIBarButtonItem *tweetButton;
																
@private
	Email *email;
	SMS *sms;
	Bitly *bitly;
	MoviePlayer *moviePlayer;
																
}

@property(nonatomic,retain) IBOutlet MapViewController *mapViewController;
@property(nonatomic,retain) IBOutlet ImageViewController *imageViewController;
@property(nonatomic,retain) IBOutlet NewsViewController *newsViewController;
@property(nonatomic,retain) IBOutlet TwitterViewController *twitterViewController;
@property(nonatomic,retain) IBOutlet UISegmentedControl *nextPrevious;
@property(nonatomic,retain) Incident *incident;
@property(nonatomic,retain) NSArray *incidents;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *smsButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *emailButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *tweetButton;
@property(nonatomic,assign) BOOL pending;

- (IBAction) nextPrevious:(id)sender;
- (IBAction) sendEmail:(id)sender;
- (IBAction) sendSMS:(id)sender;
- (IBAction) sendTweet:(id)sender;

@end
