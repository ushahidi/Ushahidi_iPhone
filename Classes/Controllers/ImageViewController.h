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
#import "BaseViewController.h"

@class Email;
@class TwitterViewController;

@interface ImageViewController : BaseViewController {
	
@public
	TwitterViewController *twitterViewController;
	UIImageView *imageView;
	UISegmentedControl *nextPrevious;
	UIImage *image;
	NSArray *images;
	UIBarButtonItem *emailButton;
	UIBarButtonItem *saveButton;
	UIBarButtonItem *tweetButton;
	BOOL pending; 
	
@private
	Email *email;
	
}

@property(nonatomic, retain) IBOutlet TwitterViewController *twitterViewController;
@property(nonatomic, retain) IBOutlet UIImageView *imageView;
@property(nonatomic, retain) IBOutlet UISegmentedControl *nextPrevious;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *emailButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *tweetButton;
@property(nonatomic, retain) UIImage *image;
@property(nonatomic, retain) NSArray *images;
@property(nonatomic, assign) BOOL pending;

- (IBAction) nextPrevious:(id)sender;
- (IBAction) sendEmail:(id)sender;
- (IBAction) savePhoto:(id)sender;
- (IBAction) tweetPhoto:(id)sender;

@end
