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

#import "NewsViewController.h"
#import "NSString+Extension.h"
#import "Internet.h"
#import "Device.h"

@interface NewsViewController ()

@property(nonatomic,retain) NSString *current;

@end

@implementation NewsViewController

@synthesize webView, backForwardButton, website, current;

typedef enum {
	NavigationBack,
	NavigationForward
} Navigation;

#pragma mark -
#pragma mark Handlers

- (IBAction) backForward:(id)sender {
	if (self.backForwardButton.selectedSegmentIndex == NavigationBack) {
		if (self.webView.canGoBack) {
			[self.webView goBack];
		}
	}
	else if (self.backForwardButton.selectedSegmentIndex == NavigationForward) {
		if (self.webView.canGoForward) {
			[self.webView goForward];
		}
	}
	[self.backForwardButton setEnabled:self.webView.canGoBack forSegmentAtIndex:NavigationBack];
	[self.backForwardButton setEnabled:self.webView.canGoForward forSegmentAtIndex:NavigationForward];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.current != nil && self.website != nil && 
		[[self.current stringByTrimmingSuffix:@"/"] isEqualToString:[self.website stringByTrimmingSuffix:@"/"]]) {
		//DO nothing, the correct webpage is already loaded
	}
    else if ([self.website isYouTubeLink]) {
        self.title = self.website;
        [self.webView setBackgroundColor:[UIColor blackColor]];
        NSString *htmlString = [self.website youTubeEmbedCode:YES size:self.webView.frame.size];
        [self.webView loadHTMLString:htmlString baseURL:nil];
    }
	else {
		self.title = self.website;
		[self.webView loadHTMLString:@"<html><head></head><body></body></html>" baseURL:nil];
		if (self.website != nil) {
			[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.website]]];	
		}
	}
	[self.backForwardButton setEnabled:self.webView.canGoBack forSegmentAtIndex:NavigationBack];
	[self.backForwardButton setEnabled:self.webView.canGoForward forSegmentAtIndex:NavigationForward];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.webView stopLoading];
}

- (void)dealloc {
	[webView release];
	[backForwardButton release];
	[website release];
	[current release];
    [super dealloc];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    DLog(@"");
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)theWebView {
	DLog(@"%@", [[[theWebView request] URL] absoluteString]);
	[self.backForwardButton setEnabled:self.webView.canGoBack forSegmentAtIndex:NavigationBack];
	[self.backForwardButton setEnabled:self.webView.canGoForward forSegmentAtIndex:NavigationForward];
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
	DLog(@"%@", [[[theWebView request] URL] absoluteString]);
    if ([@"about:blank" isEqualToString:[[[theWebView request] URL] absoluteString]] == NO) {
        self.title = [[[theWebView request] URL] absoluteString];
	}
	self.current = [[[theWebView request] URL] absoluteString];
	[self.backForwardButton setEnabled:self.webView.canGoBack forSegmentAtIndex:NavigationBack];
	[self.backForwardButton setEnabled:self.webView.canGoForward forSegmentAtIndex:NavigationForward];
}

- (void)webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)error {
	DLog(@"error: %d %@", [error code], [error localizedDescription]);
	if ([error code] == BrowserErrorNoInternetConnection) {
		[self.alertView showOkWithTitle:NSLocalizedString(@"No Internet", nil) andMessage:[error localizedDescription]];
	}
	else if ([error code] == BrowserErrorHostNotFound) {
		[self.alertView showOkWithTitle:NSLocalizedString(@"Host Not Found", nil) andMessage:[error localizedDescription]];
	}
	[self.backForwardButton setEnabled:self.webView.canGoBack forSegmentAtIndex:NavigationBack];
	[self.backForwardButton setEnabled:self.webView.canGoForward forSegmentAtIndex:NavigationForward];
}

@end
