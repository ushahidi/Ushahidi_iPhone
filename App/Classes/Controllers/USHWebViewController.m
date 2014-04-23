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

#import "USHWebViewController.h"
#import <Ushahidi/UIViewController+USH.h>
#import <Ushahidi/USHRefreshButtonItem.h>
#import <Ushahidi/UIBarButtonItem+USH.h>
#import <Ushahidi/USHInternet.h>
#import <Ushahidi/USHDevice.h>
#import "USHAnalytics.h"

@interface USHWebViewController ()

@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) UIBarButtonItem *forwardButton;
@property (strong, nonatomic) USHShareController *shareController;

@end

@implementation USHWebViewController

@synthesize url = _url;
@synthesize webView = _webView;
@synthesize backButton = _backButton;
@synthesize forwardButton = _forwardButton;
@synthesize refreshButton = _refreshButton;
@synthesize zoomButton = _zoomButton;
@synthesize shareController = _shareController;

typedef enum {
    NavigateBack,
    NavigateForward
} Navigate;

#pragma mark - IBActions

- (IBAction) refresh:(id)sender event:(UIEvent*)event {
    [self.webView reload];
}

- (IBAction) zoom:(id)sender event:(UIEvent*)event {
    if (self.webView.scalesPageToFit) {
        self.webView.scalesPageToFit = NO;
        self.zoomButton.image = [UIImage imageNamed:@"zoomout.png"];
    }
    else {
        self.webView.scalesPageToFit = YES;
        self.zoomButton.image = [UIImage imageNamed:@"zoomin.png"];
    }
    [self.webView reload];
}

- (IBAction) action:(id)sender event:(UIEvent*)event {
    [self.shareController showShareForEvent:event];
}

- (void) loadAddress:(NSString *)address {
    if (address != nil && address.length > 0) {
        NSString *website = [address hasPrefix:@"http://"] || [address hasPrefix:@"https://"]
        ? address : [NSString stringWithFormat:@"http://www.google.com/search?q=%@", [address stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        NSURL *url = [NSURL URLWithString:website];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    } 
}

#pragma mark - UIToolBar

- (void) adjustToolBarHeight {
    if ([USHDevice isIPad] && self.toolBar != nil && self.webView != nil) {
        NSInteger tabBarHeight = 49;
        CGRect toolBarFrame = self.toolBar.frame;
        toolBarFrame.size.height = tabBarHeight;
        toolBarFrame.origin.y = self.view.frame.size.height - tabBarHeight;
        self.toolBar.frame = toolBarFrame;
        CGRect webViewFrame = self.webView.frame;
        webViewFrame.size.height = self.view.frame.size.height - self.webView.frame.origin.y - tabBarHeight;
        self.webView.frame = webViewFrame;
    }
}

#pragma mark - UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.backButton = [UIBarButtonItem borderedItemWithImage:[UIImage imageNamed:@"back.png"]
                                                   tintColor:self.navBarColor
                                                      target:self.webView
                                                      action:@selector(goBack)];
    self.forwardButton = [UIBarButtonItem borderedItemWithImage:[UIImage imageNamed:@"forward.png"]
                                                      tintColor:self.navBarColor
                                                         target:self.webView
                                                         action:@selector(goForward)];
    self.navigationItem.rightBarButtonItem = [self barButtonWithItems:self.backButton, self.forwardButton, nil];
    self.shareController = [[USHShareController alloc] initWithController:self];
    self.refreshButton.indicator = UIActivityIndicatorViewStyleWhite;
    
    [self adjustToolBarHeight];
    
    [USHAnalytics sendScreenView:USHAnalyticsWebVCName];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.shareController = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadAddress:self.url];
    if (self.webView.scalesPageToFit) {
        self.zoomButton.image = [UIImage imageNamed:@"zoomin.png"];
    }
    else {
        self.zoomButton.image = [UIImage imageNamed:@"zoomout.png"];
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    DLog(@"");
    self.refreshButton.refreshing = YES;
    if ([[USHInternet sharedInstance] hasWiFi] || [[USHInternet sharedInstance] hasNetwork]) {
        self.navigationItem.title = NSLocalizedString(@"Loading...", nil);
        self.refreshButton.refreshing = YES;
    }
    else {
        self.navigationItem.title = NSLocalizedString(@"No Internet", nil);
        [self showLoadingWithMessage:NSLocalizedString(@"No Internet", nil)];
        [self hideLoadingAfterDelay:2.0];
    }
    self.backButton.enabled = webView.canGoBack;
    self.forwardButton.enabled = webView.canGoForward;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    DLog(@"%@", [webView stringByEvaluatingJavaScriptFromString:@"document.title"]);
    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.refreshButton.refreshing = NO;
    self.backButton.enabled = webView.canGoBack;
    self.forwardButton.enabled = webView.canGoForward;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    DLog(@"%@", [error localizedDescription]);
    self.navigationItem.title = [error localizedDescription];
    self.refreshButton.refreshing = NO;
    self.backButton.enabled = webView.canGoBack;
    self.forwardButton.enabled = webView.canGoForward;
}

#pragma mark - USHShareController

- (void) shareOpenURL:(USHShareController*)share {
    [self.shareController openURL:self.webView.request.URL.absoluteString];
}

- (void) shareCopyText:(USHShareController*)share {
    NSString *text = [NSString stringWithFormat:@"%@ %@", self.navigationItem.title, self.webView.request.URL.absoluteString];
    [self.shareController copyText:text];
}

- (void) shareSendSMS:(USHShareController*)share {
    NSString *sms = [NSString stringWithFormat:@"%@ %@", self.navigationItem.title, self.webView.request.URL.absoluteString];
    [self.shareController sendSMS:sms];
}

- (void) shareSendEmail:(USHShareController*)share {
    NSString *url = self.webView.request.URL.absoluteString;
    NSString *email = [NSString stringWithFormat:@"%@<br/><a href='%@'>%@</a>", self.navigationItem.title, url, url, nil];
    [self.shareController sendEmail:email subject:self.navigationItem.title attachment:nil fileName:nil recipient:nil];
}

- (void) shareSendTweet:(USHShareController*)share {
    NSString *url = self.webView.request.URL.absoluteString;    
    [self.shareController sendTweet:self.navigationItem.title url:url];
}

- (void) shareShowQRCode:(USHShareController*)share {
    DLog(@"");
    NSString *url = self.webView.request.URL.absoluteString;
    [self.shareController showQRCode:url title:self.navigationItem.title];
}

- (void) sharePostFacebook:(USHShareController*)share {
    [self.shareController postFacebook:self.title url:self.url image:nil];
}

@end
