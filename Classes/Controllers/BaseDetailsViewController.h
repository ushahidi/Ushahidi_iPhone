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
#import "SMS.h"
#import "Email.h"
#import "Bitly.h"

@class WebViewController;
@class MapViewController;
@class ImageViewController;
@class TwitterViewController;
@class NewsViewController;
@class Email;
@class SMS;
@class Bitly;
@class MoviePlayer;

typedef enum {
	NavBarPrevious,
	NavBarNext
} NavBar;

@interface BaseDetailsViewController : BaseTableViewController<SMSDelegate,
															   EmailDelegate,
															   BitlyDelegate> {

@public
	MapViewController *mapViewController;
	ImageViewController *imageViewController;
	TwitterViewController *twitterViewController;
	NewsViewController *newsViewController;
																	
	UISegmentedControl *nextPrevious;
	UIBarButtonItem *smsButton;
	UIBarButtonItem *emailButton;
	UIBarButtonItem *tweetButton;
	
	Email *email;
	SMS *sms;
	Bitly *bitly;
	MoviePlayer *moviePlayer;
}

@property(nonatomic,retain) IBOutlet ImageViewController *imageViewController;
@property(nonatomic,retain) IBOutlet MapViewController *mapViewController;
@property(nonatomic,retain) IBOutlet TwitterViewController *twitterViewController;
@property(nonatomic,retain) IBOutlet NewsViewController *newsViewController;

@property(nonatomic,retain) IBOutlet UISegmentedControl *nextPrevious;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *smsButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *emailButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *tweetButton;

@property(nonatomic,retain) Email *email;
@property(nonatomic,retain) SMS *sms;
@property(nonatomic,retain) Bitly *bitly;
@property(nonatomic,retain) MoviePlayer *moviePlayer;

@end
