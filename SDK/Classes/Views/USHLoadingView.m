/*****************************************************************************
 ** Copyright (c) 2012 Ushahidi Inc
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

#import "USHLoadingView.h"
#import "NSBundle+USH.h"

@interface USHLoadingView ()

@property (nonatomic, retain) UIViewController *controller;

- (void) removeFromSuperviewAnimated;
- (void) removeFromSuperviewAfterDelay:(NSNumber*)delay;

@end

@implementation USHLoadingView

@synthesize controller = _controller;
@synthesize activityIndicator = _activityIndicator;
@synthesize activityIndicatorLabel = _activityIndicatorLabel;
@synthesize activityIndicatorBackground = _activityIndicatorBackground;

+ (USHLoadingView*) viewWithController:(UIViewController *)controller {
    NSBundle *bundle = [NSBundle bundleWithName:@"Ushahidi.bundle"];
    NSArray *objects = [bundle loadNibNamed:@"USHLoadingView" owner:controller options:nil];
    USHLoadingView *loadingView = (USHLoadingView*)[objects lastObject];
    loadingView.activityIndicatorBackground.layer.cornerRadius = 20.0f;
    loadingView.controller = controller;
    loadingView.center = controller.view.center;
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | 
                                    UIViewAutoresizingFlexibleRightMargin |
                                    UIViewAutoresizingFlexibleTopMargin |
                                    UIViewAutoresizingFlexibleBottomMargin;
    return loadingView;
}

- (void)dealloc {
	[_controller release];
	[_activityIndicator release];
	[_activityIndicatorLabel release];
    [_activityIndicatorBackground release];
	[super dealloc];	
}

- (void) showWithMessage:(NSString *)message hide:(NSTimeInterval)hide {
    [self showWithMessage:message afterDelay:0.0 animated:YES];
    [self hideAfterDelay:hide];
}

- (void) show {
	[self showWithMessage:NSLocalizedString(@"Loading...", nil) afterDelay:0.0 animated:YES];
}

- (void) showAfterDelay:(NSTimeInterval)delay {
	[self showWithMessage:NSLocalizedString(@"Loading...", nil) afterDelay:delay animated:YES];
}

- (void) showWithMessage:(NSString *)message {
	[self showWithMessage:message afterDelay:0.0 animated:YES];
}

- (void) showWithMessage:(NSString *)message afterDelay:(NSTimeInterval)delay {
	[self showWithMessage:message afterDelay:delay animated:YES];
}

- (void) showWithMessage:(NSString *)message animated:(BOOL)animated {
	[self showWithMessage:message afterDelay:0.0 animated:animated];
}

- (void) showWithMessage:(NSString *)message afterDelay:(NSTimeInterval)delay animated:(BOOL)animated {
	if ([NSThread isMainThread]) {
        if (self.superview == nil) {
            [self.controller.view performSelector:@selector(addSubview:) withObject:self afterDelay:delay];
			self.alpha = 1.0;
			self.center = self.controller.view.center;
            self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
            UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		}
		self.activityIndicator.hidden = !animated;
        self.activityIndicatorLabel.text = message;
	}
	else {
        if (self.superview == nil) {
			[self.controller.view performSelectorOnMainThread:@selector(addSubview:) withObject:self waitUntilDone:NO];
			[self performSelectorOnMainThread:@selector(centerView) withObject:nil waitUntilDone:NO];
            [self.activityIndicatorLabel performSelectorOnMainThread:@selector(setText:) withObject:message waitUntilDone:NO];
		}
		[self.activityIndicatorLabel performSelectorOnMainThread:@selector(setText:) withObject:message waitUntilDone:NO];
	}
}

- (void)centerView {
    self.center = self.controller.view.center;
}

- (void) hide {
	[self hideAfterDelay:0.0];
}

- (void) hideAfterDelay:(NSTimeInterval)delay {
    if ([NSThread isMainThread]) {
        [self performSelector:@selector(removeFromSuperviewAnimated) withObject:nil afterDelay:delay];
	}
	else {
        [self performSelectorOnMainThread:@selector(removeFromSuperviewAfterDelay:) withObject:[NSNumber numberWithFloat:delay] waitUntilDone:NO];
    }
}

- (void) hideIfMessage:(NSString *)message {
    if ([self.activityIndicatorLabel.text isEqualToString:message]) {
        [self hideAfterDelay:0.0];
    }
}

- (void) removeFromSuperviewAfterDelay:(NSNumber*)delay {
    [self performSelector:@selector(removeFromSuperviewAnimated) withObject:nil afterDelay:[delay floatValue]];
}

- (void) removeFromSuperviewAnimated {
    [UIView beginAnimations:@"removeFromSuperview" context:nil];
	[UIView setAnimationDuration:0.3];
	self.alpha = 0.0;
	[UIView commitAnimations];
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];	
}

@end
