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

#import <UIKit/UIKit.h>

#define USHViewDidLoad @"USHViewDidLoad"
#define USHViewDidUnload @"USHViewDidUnload"

#define USHViewWillAppear @"USHViewWillAppear"
#define USHViewDidAppear @"USHViewDidAppear"

#define USHViewWillDisappear @"USHViewWillDisappear"
#define USHViewDidDisappear @"USHViewDidDisappear"

@interface USHViewController : UIViewController<UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;

@property (strong, nonatomic) UIColor *navBarColor;
@property (strong, nonatomic) UIColor *toolBarColor;
@property (strong, nonatomic) UIColor *buttonDoneColor;

@property (strong, nonatomic) UIViewController *hostingViewController;

@property (strong, nonatomic) UIBarButtonItem *leftBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *rightBarButtonItem;

@property (strong, nonatomic) NSString *backBarButtonTitle;

- (void) viewWillBePushed;
- (void) viewWasPushed;

- (void) showMessage:(NSString*)message;
- (void) showMessage:(NSString*)message hide:(NSTimeInterval)delay;

- (void) hideMessage;
- (void) hideMessageAfterDelay:(NSTimeInterval)delay;
- (void) hideMessageIfEquals:(NSString *)message;

- (void) showLoading;
- (void) showLoadingWithMessage:(NSString *)message;
- (void) showLoadingWithMessage:(NSString *)message hide:(NSTimeInterval)delay;

- (void) hideLoading;
- (void) hideLoadingAfterDelay:(NSTimeInterval)delay;

- (void) presentModalViewController:(USHViewController *)viewController;
- (void) presentModalViewController:(USHViewController *)viewController animated:(BOOL)animated;

- (void) dismissModalViewController;
- (void) dismissModalViewControllerAnimated:(BOOL)animated;

- (void) setTitleViewWithImage:(NSString*)imageName orText:(NSString*)title;

@end
