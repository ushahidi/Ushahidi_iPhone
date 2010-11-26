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
#import "InputView.h"
#import "AlertView.h"

@class WebViewController;
@class LoadingViewController;
@class InputView;
@class AlertView;

@interface BaseViewController : UIViewController<InputViewDelegate, UIAlertViewDelegate> {

@public 
	IBOutlet WebViewController *webViewController;
	
@protected
	LoadingViewController *loadingView;
	InputView *inputView;
	AlertView *alertView;
	BOOL willBePushed;
	BOOL wasPushed;
}

@property(nonatomic, retain) WebViewController *webViewController;
@property(nonatomic, retain) LoadingViewController *loadingView;
@property(nonatomic, retain) InputView *inputView;
@property(nonatomic, retain) AlertView *alertView;
@property(nonatomic, assign) BOOL willBePushed;
@property(nonatomic, assign) BOOL wasPushed;

- (void)viewWillBePushed;
- (void)viewWasPushed;

@end
