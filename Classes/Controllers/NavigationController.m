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

#import "NavigationController.h"

@implementation NavigationController

- (void) setViewController:(UIViewController*)viewController animated:(BOOL)animated {
    self.viewControllers = nil;
    [self pushViewController:viewController animated:animated];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
	SEL viewWillBePushed = @selector(viewWillBePushed);
	if ([viewController respondsToSelector:viewWillBePushed]) {
		[viewController performSelector:viewWillBePushed withObject:nil];
	}
	DLog(@"%@", [viewController nibName]);
	[super pushViewController:viewController animated:animated];
	SEL viewWasPushed = @selector(viewWasPushed);
	if ([viewController respondsToSelector:viewWasPushed]) {
		[viewController performSelector:viewWasPushed withObject:nil];
	}
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
	DLog(@"%@", [self nibName]);
	return [super popViewControllerAnimated:animated];
}

@end
