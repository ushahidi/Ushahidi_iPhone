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
#import <QuartzCore/QuartzCore.h>

@interface LoadingViewController : UIViewController {

@public
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIImageView *activityIndicatorBackground;
	IBOutlet UILabel *activityIndicatorLabel;
	
@private
	UIViewController *controller;
}

@property (nonatomic, retain) UILabel *activityIndicatorLabel;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UIImageView *activityIndicatorBackground;

- (id) initWithController:(UIViewController *)controller;

- (void) show;
- (void) showAfterDelay:(NSTimeInterval)delay;
- (void) showWithMessage:(NSString *)message;
- (void) showWithMessage:(NSString *)message afterDelay:(NSTimeInterval)delay;
- (void) hide;
- (void) hideAfterDelay:(NSTimeInterval)delay;
- (BOOL) isShowing;
- (NSString *) message;

@end
