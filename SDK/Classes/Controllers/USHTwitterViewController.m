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

#import "USHTwitterViewController.h"
#import "USHDevice.h"
#import "USHLoadingView.h"
#import "UIBarButtonItem+USH.h"

@interface USHTwitterViewController ()

@property (strong, nonatomic) NSString *javascript;

- (void)cancel:(id)sender event:(UIEvent*)event;

@end

@implementation USHTwitterViewController

@synthesize webView = _webView;
@synthesize url = _url;
@synthesize name = _name;
@synthesize summary = _summary;
@synthesize javascript = _javascript;
@synthesize image = _image;

#pragma mark - Handlers

- (void)cancel:(id)sender event:(UIEvent*)event {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIViewController

- (void)dealloc {
    [_webView release];
    [_name release];
    [_url release];
    [_javascript release];
    [_image release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Twitter", nil);
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem borderedItemWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                         tintColor:self.navBarColor
                                                                            target:self
                                                                            action:@selector(cancel:event:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *path = [NSString stringWithFormat:@"https://twitter.com/intent/tweet?url=%@&text=%@", 
                      self.url, [self.name stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    DLog(@"URL:%@ Path:%@", self.url, path);
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request]; 
    if ([USHDevice isIPad]) {
        CGRect frame = self.view.superview.frame;
        frame.size.width = 500;
        frame.size.height = 400;
        self.view.superview.frame = frame;   
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([USHDevice isIPad] && self.modalPresentationStyle == UIModalPresentationFormSheet) {
        self.view.superview.center = self.view.superview.superview.center;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void) dismissModalViewController {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIWebViewController

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = [[request URL] absoluteString];
    if (navigationType == UIWebViewNavigationTypeFormResubmitted) {
        DLog(@"FormResubmitted %@", url);    
    }
    else if (navigationType == UIWebViewNavigationTypeFormSubmitted) {
        DLog(@"FormSubmitted %@", url);    
    }
    else if (navigationType == UIWebViewNavigationTypeBackForward) {
        DLog(@"BackForward %@", url);    
    }
    else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        DLog(@"LinkClicked %@", url);    
    }
    else if (navigationType == UIWebViewNavigationTypeOther) {
        DLog(@"Other %@", url);    
    }
    else if (navigationType == UIWebViewNavigationTypeReload) {
        DLog(@"Reload %@", url);    
    }
    else {
        DLog(@"%d %@", navigationType, url);
    }
    if ([url isEqualToString:@"https://mobile.twitter.com/"]) {
        [self dismissModalViewControllerAnimated:YES];
        return NO;
    }
    if ([url isEqualToString:@"https://mobile.twitter.com/signup"]) {
        if ([USHDevice isIPad]) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            CGRect frame = self.view.superview.frame;
            frame.size.width = 700;
            frame.size.height = 615;
            self.view.superview.frame = frame;
            self.view.superview.center = self.view.superview.superview.center;
            [UIView commitAnimations];
        }
    }
    if ([url hasPrefix:@"https://twitter.com/intent/tweet?url="]) {
        if ([USHDevice isIPad]) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            CGRect frame = self.view.superview.frame;
            frame.size.width = 500;
            frame.size.height = 350;
            self.view.superview.frame = frame;
            [UIView commitAnimations];
        }
    }   
    if ([url isEqualToString:@"https://twitter.com/intent/tweet/update"]) {
        [self showLoadingWithMessage:@"Sending..."];
    }
    if ([url hasPrefix:@"https://twitter.com/intent/tweet/complete"]) {
        [self showLoadingWithMessage:@"Sent!"];
        [self performSelector:@selector(dismissModalViewController) withObject:nil afterDelay:1.5];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    DLog(@"%@", [[webView request] URL]);
    NSString *url = [[[webView request] URL] absoluteString];
    if ([url isEqualToString:@"https://twitter.com/intent/tweet/update"]) {
        [self showLoadingWithMessage:@"Sending..."];
    }
    else {
        [self showLoading];   
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    DLog(@"%@", [[webView request] URL]);
    NSString *url = [[[webView request] URL] absoluteString];
    if ([url hasPrefix:@"https://twitter.com/intent/tweet?url="]) {
        [self hideLoading];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    DLog(@"Error:%@", [error description]);
}

@end
