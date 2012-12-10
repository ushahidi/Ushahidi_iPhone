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

#import <Ushahidi/USHViewController.h>
#import <Ushahidi/USHInternet.h>
#import <Ushahidi/USHShareController.h>

@class USHRefreshButtonItem;

@interface USHWebViewController : USHViewController<UIWebViewDelegate,
                                                    USHInternetDelegate,
                                                    USHShareControllerDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet USHRefreshButtonItem *refreshButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *zoomButton;
@property (strong, nonatomic) NSString *url;

- (IBAction) refresh:(id)sender event:(UIEvent*)event;
- (IBAction) zoom:(id)sender event:(UIEvent*)event;
- (IBAction) action:(id)sender event:(UIEvent*)event;

- (void) adjustToolBarHeight;

@end
