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
#import "LoadingViewController.h"
#import "AlertView.h"
#import "InputView.h"

@interface WebViewController ()

@end

@implementation WebViewController

@synthesize webView, refreshButton, backForwardButton, website;

NSString * const kGoogleSearch = @"http://www.google.com/search?q=%@"; 

typedef enum {
	NavigationBack,
	NavigationForward
} Navigation;

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
	[self.backForwardButton setEnabled:self.webView.canGoBack forSegmentAtIndex:NavigationBack];
	[self.backForwardButton setEnabled:self.webView.canGoForward forSegmentAtIndex:NavigationForward];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)dealloc {
	[webView release];
	[refreshButton release];
	[backForwardButton release];
	[super dealloc];
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)theWebView {
	DLog(@"");
	[self.backForwardButton setEnabled:self.webView.canGoBack forSegmentAtIndex:NavigationBack];
	[self.backForwardButton setEnabled:self.webView.canGoForward forSegmentAtIndex:NavigationForward];
	self.refreshButton.enabled = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
	DLog(@"");
	self.title = [[[theWebView request] URL] absoluteString];
	[self.backForwardButton setEnabled:self.webView.canGoBack forSegmentAtIndex:NavigationBack];
	[self.backForwardButton setEnabled:self.webView.canGoForward forSegmentAtIndex:NavigationForward];
	self.refreshButton.enabled = YES;
	self.website = [[[theWebView request] URL] absoluteString];
}

- (void)webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
	[self.backForwardButton setEnabled:self.webView.canGoBack forSegmentAtIndex:NavigationBack];
	[self.backForwardButton setEnabled:self.webView.canGoForward forSegmentAtIndex:NavigationForward];
	self.refreshButton.enabled = YES;
}

#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:YES animated:YES];
}   

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:NO animated:YES];
}   

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
	[searchBar setShowsCancelButton:NO animated:YES];
	[searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:NO animated:YES];
	[searchBar resignFirstResponder];
	NSString *searchTextLowercase = [[searchBar text] lowercaseString];
	NSURL *url = [searchTextLowercase hasPrefix:@"http://"] || [searchTextLowercase hasPrefix:@"https://"]
		? [NSURL URLWithString:[searchBar text]]
		: [NSURL URLWithString:[NSString stringWithFormat:kGoogleSearch, [[searchBar text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}   

@end
