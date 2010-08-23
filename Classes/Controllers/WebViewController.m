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

#import "WebViewController.h"

#define kCancel	@"Cancel"
#define kOpenInSafari @"Open in Safari"

@interface WebViewController ()

@end

@implementation WebViewController

@synthesize webView, refreshButton, backButton, forwardButton, website;

- (IBAction) action:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
															 delegate:self 
													cancelButtonTitle:kCancel 
											   destructiveButtonTitle:nil
													otherButtonTitles:kOpenInSafari, nil];
	[actionSheet setActionSheetStyle:UIBarStyleBlackTranslucent];
	[actionSheet showInView:[self view]];
	[actionSheet release];
}

#pragma mark -
#pragma mark UIViewController

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.website != nil) {
		self.title = self.website;
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.website]];
		[self.webView loadRequest:request];
	}
	else {
		self.title = @"Web";
		[self.webView loadHTMLString:@"<html><head></head><body></body></html>" baseURL:nil];
	}
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.backButton.enabled = self.webView.canGoBack;
	self.forwardButton.enabled = self.webView.canGoForward;
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
	[webView release];
	[refreshButton release];
	[backButton release];
	[forwardButton release];
	[super dealloc];
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)theWebView {
	DLog(@"");
	self.backButton.enabled = theWebView.canGoBack;
	self.forwardButton.enabled = theWebView.canGoForward;
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
	DLog(@"");
	self.title = [[[theWebView request] URL] absoluteString];
	self.backButton.enabled = theWebView.canGoBack;
	self.forwardButton.enabled = theWebView.canGoForward;
}

- (void)webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
	self.backButton.enabled = theWebView.canGoBack;
	self.forwardButton.enabled = theWebView.canGoForward;
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *titleAtIndex = [actionSheet buttonTitleAtIndex:buttonIndex];
	DLog(@"titleAtIndex: %@", titleAtIndex);
	if ([titleAtIndex isEqualToString:kOpenInSafari]) {
		NSURL *websiteURL = [[self.webView request] URL];
		if ([[UIApplication sharedApplication] canOpenURL:websiteURL]){
			[[UIApplication sharedApplication] openURL:websiteURL];
		}	
		else {
			DLog(@"Unable to open website: %@", [websiteURL absoluteString]);
		}
	}
}

@end
