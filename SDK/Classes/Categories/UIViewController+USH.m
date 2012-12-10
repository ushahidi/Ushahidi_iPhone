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

#import "UIViewController+USH.h"

@implementation UIViewController (USH)

- (BOOL) isTopController {
    NSArray *viewControllers = [[self navigationController] viewControllers];
    UIViewController *rootViewController = [viewControllers objectAtIndex:0];    
    return rootViewController == self;
}

- (BOOL) isTopView:(UIView *)view {
    return [[self.view subviews] lastObject] == view;
}

- (BOOL)isModalViewController {
    BOOL isModal = ((self.parentViewController && self.parentViewController.modalViewController == self) || 
                    ( self.navigationController && self.navigationController.parentViewController && self.navigationController.parentViewController.modalViewController == self.navigationController) ||
                    [[[self tabBarController] parentViewController] isKindOfClass:[UITabBarController class]]);
    if (!isModal && [self respondsToSelector:@selector(presentingViewController)]) {
        isModal = ((self.presentingViewController && self.presentingViewController.modalViewController == self) || 
                   (self.navigationController && self.navigationController.presentingViewController && self.navigationController.presentingViewController.modalViewController == self.navigationController) ||
                   [[[self tabBarController] presentingViewController] isKindOfClass:[UITabBarController class]]);
    }
    return isModal;        
}

- (CGRect) touchOfEvent:(UIEvent*)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view];
    CGRect rect;
    rect.origin.x = location.x;
    rect.origin.y = location.y;
    rect.size.width = 5;
    rect.size.height = 5;
    return rect;
}

- (void) animatePageCurlUp:(CGFloat)duration {
    [self animatePageCurl:YES fillMode:kCAFillModeForwards type:@"pageCurl" duration:duration];
}

- (void) animatePageCurlDown:(CGFloat)duration {
    [self animatePageCurl:NO fillMode:kCAFillModeBackwards type:@"pageUnCurl" duration:duration];
}

- (void) animatePageCurl:(BOOL)up fillMode:(NSString*)fillMode type:(NSString*)type duration:(CGFloat)duration {
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self]; 
    [animation setDuration:duration];
    [animation setTimingFunction:UIViewAnimationCurveEaseInOut];
    animation.type = type;
    animation.fillMode = fillMode;
    if (up) {
        animation.endProgress = 0.50;
    }
    else {
        animation.startProgress = 0.55;
    }
    [animation setRemovedOnCompletion:NO];
    [[self view] exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    [[[self view] layer] addAnimation:animation forKey:@"pageCurlAnimation"];
}

- (UIBarButtonItem *) barButtonWithItems:(UIBarButtonItem*)item, ... {
    va_list args;
    va_start(args, item);
    UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 44.01f)] autorelease]; 
    toolbar.clearsContextBeforeDrawing = NO;
    toolbar.clipsToBounds = NO;
    toolbar.tintColor = [UIColor colorWithWhite:0.305f alpha:0.0f];
    toolbar.barStyle = -1; 
    NSMutableArray *buttons = [NSMutableArray array];
    for (UIBarButtonItem *button = item; button != nil; button = va_arg(args, UIBarButtonItem*)) {
        [buttons addObject:button];
    }
    va_end(args);
    [toolbar setItems:buttons animated:NO];
    
    double width = toolbar.items.count > 1 ? 10.0 * (toolbar.items.count - 1) : 0.0;
    for (int i = 0; i < [toolbar.subviews count]; i++){
        UIView *view = (UIView *)[toolbar.subviews objectAtIndex:i];
        width += view.bounds.size.width;
    }
    DLog(@"Nib:%@ Items:%d Width:%f ", self.class, [toolbar.subviews count], width);
    CGSize size = toolbar.frame.size;
    size.width = width;
    toolbar.frame = CGRectMake(0, 0, size.width, size.height);
    
    return [[[UIBarButtonItem alloc] initWithCustomView:toolbar] autorelease];
}

- (CGRect) touchForEvent:(UIEvent*)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view];
    CGRect rect;
    rect.origin.x = location.x;
    rect.origin.y = location.y;
    rect.size.width = 5;
    rect.size.height = 5;
    return rect;
}

@end
