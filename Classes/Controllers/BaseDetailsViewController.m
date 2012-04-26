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

#import "BaseDetailsViewController.h"
#import "WebViewController.h"
#import "MapViewController.h"
#import "ImageViewController.h"
#import "NewsViewController.h"
#import "TableCellFactory.h"
#import "SubtitleTableCell.h"
#import "ImageTableCell.h"
#import "LoadingViewController.h"
#import "TwitterViewController.h"
#import "AlertView.h"
#import "InputView.h"
#import "Photo.h"
#import "Location.h"
#import "UIColor+Extension.h"
#import "TableHeaderView.h"
#import "Email.h"
#import "Deployment.h"
#import "News.h"
#import "Video.h"
#import "NSString+Extension.h"
#import "MoviePlayer.h"
#import "SMS.h"
#import "Settings.h"
#import "Ushahidi.h"
#import "Device.h"

@interface BaseDetailsViewController()

@end

@implementation BaseDetailsViewController

@synthesize imageViewController, mapViewController, twitterViewController, newsViewController;
@synthesize smsButton, emailButton, tweetButton, nextPrevious;
@synthesize email, sms, moviePlayer;

#pragma mark -
#pragma mark UIViewController

- (void) viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [[Settings sharedSettings] tablePlainBackColor];
	self.oddRowColor = [[Settings sharedSettings] tableOddRowColor];
	self.evenRowColor = [[Settings sharedSettings] tableOddRowColor];
	
	self.email = [[Email alloc] initWithController:self];
	self.sms = [[SMS alloc] initWithController:self];
	self.moviePlayer = [[MoviePlayer alloc] initWithController:self];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.email = nil;
	self.sms = nil;
	self.moviePlayer = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)dealloc {
	[imageViewController release];
	[mapViewController release];
	[twitterViewController release];
	[newsViewController release];
	[nextPrevious release];
	[smsButton release];
	[emailButton release];
	[tweetButton release];
	[email release];
	[sms release];
	[super dealloc];
}

#pragma mark -
#pragma mark SMSDelegate

- (void) smsSent:(SMS *)theSms {
	DLog(@"");
	[self.loadingView showWithMessage:NSLocalizedString(@"Sent", nil) afterDelay:1.0];
	[self.loadingView hideAfterDelay:2.5];
}

- (void) smsCancelled:(SMS *)theSms {
	DLog(@"");
	[self.loadingView hide];
}

- (void) smsFailed:(SMS *)theSms {
	DLog(@"");
	[self.loadingView hide];
	[self.alertView showOkWithTitle:NSLocalizedString(@"SMS Failed", nil) 
						 andMessage:NSLocalizedString(@"Unable To Send SMS", nil)];
}

#pragma mark -
#pragma mark EmailDelegate

- (void) emailSent:(Email *)email {
	DLog(@"");
	[self.loadingView showWithMessage:NSLocalizedString(@"Sent", nil)];
	[self.loadingView hideAfterDelay:2.5];
}

- (void) emailCancelled:(Email *)email {
	DLog(@"");
}

- (void) emailFailed:(Email *)email {
	DLog(@"");
	[self.alertView showOkWithTitle:NSLocalizedString(@"Email Failed", nil) 
						 andMessage:NSLocalizedString(@"Unable To Send Email", nil)];
}

@end
