//
//  WebViewController.m
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-09.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import "WebViewController.h"

#define kCancel	@"Cancel"
#define kOpenInSafari @"Open in Safari"

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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
