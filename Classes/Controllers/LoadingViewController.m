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

#import "LoadingViewController.h"
#import "Device.h"

@interface LoadingViewController ()

@property (nonatomic, retain) UIViewController *controller;

- (void) removeFromSuperview;

@end


@implementation LoadingViewController

@synthesize controller, activityIndicator, activityIndicatorLabel, activityIndicatorBackground;

- (id) initWithController:(UIViewController *)theController {
	NSString *nibName = [Device isIPad] ? @"LoadingViewController_iPad" : @"LoadingViewController_iPhone";
	if (self = [super initWithNibName:nibName bundle:[NSBundle mainBundle]]) {
		self.controller = theController;
	}
    return self;
}

- (void)dealloc {
	[controller release];
	[activityIndicator release];
	[activityIndicatorLabel release];
	[activityIndicatorBackground release];
	[super dealloc];	
}

- (void) show {
	[self showWithMessage:@"Loading..." afterDelay:0.0];
}

- (void) showAfterDelay:(NSTimeInterval)delay {
	[self showWithMessage:@"Loading..." afterDelay:delay];
}

- (void) showWithMessage:(NSString *)message {
	[self showWithMessage:message afterDelay:0.0];
}

- (void) showWithMessage:(NSString *)message afterDelay:(NSTimeInterval)delay {
	DLog(@"message:%@ delay:%d", message, delay);
	if ([NSThread isMainThread]) {
		if (self.view.superview == nil) {
			[self.controller.view performSelector:@selector(addSubview:) withObject:self.view afterDelay:delay];
			self.view.alpha = 1.0;
			self.view.center = self.controller.view.center;
		}
		self.activityIndicatorLabel.text = message;
	}
	else {
		if (self.view.superview == nil) {
			[self.controller.view performSelectorOnMainThread:@selector(addSubview:) withObject:self.view waitUntilDone:NO];
			[self.view performSelectorOnMainThread:@selector(setCenter:) withObject:self.controller.view waitUntilDone:NO];
			[self.activityIndicatorLabel performSelectorOnMainThread:@selector(setText:) withObject:message waitUntilDone:NO];
		}
		[self.activityIndicatorLabel performSelectorOnMainThread:@selector(setText:) withObject:message waitUntilDone:NO];
	}
}

- (BOOL) isShowing {
	return self.view.superview != nil;
}

- (void) hide {
	[self hideAfterDelay:0.0];
}

- (void) hideAfterDelay:(NSTimeInterval)delay {
	DLog(@"delay:%d", delay);
	if ([NSThread isMainThread]) {
		[self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:delay];
	}
	else {
		[self performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
	}
}

- (void) removeFromSuperview {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	self.view.alpha = 0.0;
	[UIView commitAnimations];
	[self.view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
}

@end
