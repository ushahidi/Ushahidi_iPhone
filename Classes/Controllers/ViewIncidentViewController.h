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

@class WebViewController;
@class MapViewController;
@class ImageViewController;
@class NewsViewController;
@class Incident;
@class Email;
@class SMS;
@class MoviePlayer;

@interface ViewIncidentViewController : TableViewController<UshahidiDelegate, 
															UIWebViewDelegate,
															SMSDelegate,
															MapTableCellDelegate> {
	
@public
	MapViewController *mapViewController;
	ImageViewController *imageViewController;
	NewsViewController *newsViewController;
	UISegmentedControl *nextPrevious;
	Incident *incident;
	NSArray *incidents;
	BOOL pending; 
	UIBarButtonItem *emailLinkButton;
	UIBarButtonItem *emailDetailsButton;
																
@private
	Email *email;
	SMS *sms;
	MoviePlayer *moviePlayer;
																
}

@property(nonatomic,retain) IBOutlet MapViewController *mapViewController;
@property(nonatomic,retain) IBOutlet ImageViewController *imageViewController;
@property(nonatomic,retain) IBOutlet NewsViewController *newsViewController;
@property(nonatomic,retain) IBOutlet UISegmentedControl *nextPrevious;
@property(nonatomic,retain) Incident *incident;
@property(nonatomic,retain) NSArray *incidents;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *emailLinkButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *emailDetailsButton;
@property(nonatomic,assign) BOOL pending;

- (IBAction) nextPrevious:(id)sender;
- (IBAction) emailLink:(id)sender;
- (IBAction) emailDetails:(id)sender;
- (IBAction) smsLink:(id)sender;

@end
