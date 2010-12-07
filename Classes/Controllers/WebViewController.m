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
#import "Device.h"

@interface WebViewController ()

@property(nonatomic,retain) NSString *homePage;
@property(nonatomic,retain) NSString *googleSearch;

- (void) showLoading:(BOOL)show;

@end

@implementation WebViewController

@synthesize webView, refreshButton, backForwardButton, website, searchBar, activityIndicator, homePage, googleSearch;

typedef enum {
	NavigationBack,
	NavigationForward
} Navigation;

typedef enum {  
    BrowserErrorHostNotFound = -1003,
    BrowserErrorOperationNotCompleted = -999,
    BrowserErrorNoInternetConnection = -1009
} BrowserErrorCode;

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

- (void) showLoading:(BOOL)show {
	if(show) {
		self.refreshButton.image = [UIImage imageNamed:@"empty.png"];
		[self.activityIndicator startAnimating];
	}
	else {
		self.refreshButton.image = [UIImage imageNamed:@"refresh.png"];
		[self.activityIndicator stopAnimating];
	}
}

#pragma mark -
#pragma mark UIViewController

- (void) viewDidLoad {
	if ([Device isIPad]) {
		self.homePage = @"http://www.google.com";
		self.googleSearch = @"http://www.google.com/search?q=%@";
	}
	else {
		self.homePage = @"http://www.google.com/?source=mog";
		self.googleSearch = @"http://www.google.com/m/search?q=%@";
	}
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.website != nil) {
		self.title = self.website;
		[self.webView loadHTMLString:@"<html><head></head><body></body></html>" baseURL:nil];
		[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.website]]];
	}
	else if (self.webView.request == nil){
		self.title = @"Google";
		[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.homePage]]];
	}
	[self.backForwardButton setEnabled:self.webView.canGoBack forSegmentAtIndex:NavigationBack];
	[self.backForwardButton setEnabled:self.webView.canGoForward forSegmentAtIndex:NavigationForward];
}

- (void)dealloc {
	[webView release];
	[refreshButton release];
	[backForwardButton release];
	[searchBar release];
	[website release];
	[activityIndicator release];
	[super dealloc];
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)theWebView {
	DLog(@"%@", [[[theWebView request] URL] absoluteString]);
	[self.backForwardButton setEnabled:self.webView.canGoBack forSegmentAtIndex:NavigationBack];
	[self.backForwardButton setEnabled:self.webView.canGoForward forSegmentAtIndex:NavigationForward];
	[self showLoading:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
	DLog(@"%@", [[[theWebView request] URL] absoluteString]);
	self.title = [[[theWebView request] URL] absoluteString];
	self.searchBar.text = [[[theWebView request] URL] absoluteString];
	[self.backForwardButton setEnabled:self.webView.canGoBack forSegmentAtIndex:NavigationBack];
	[self.backForwardButton setEnabled:self.webView.canGoForward forSegmentAtIndex:NavigationForward];
	[self showLoading:NO];
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
	[self showLoading:NO];
}

#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	[theSearchBar setShowsCancelButton:YES animated:YES];
}   

- (void)searchBarTextDidEndEditing:(UISearchBar *)theSearchBar {
	[theSearchBar setShowsCancelButton:NO animated:YES];
}   

- (void)searchBarCancelButtonClicked:(UISearchBar *) theSearchBar {
	[theSearchBar setShowsCancelButton:NO animated:YES];
	[theSearchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	[theSearchBar setShowsCancelButton:NO animated:YES];
	[theSearchBar resignFirstResponder];
	NSString *searchTextLowercase = [[theSearchBar text] lowercaseString];
	NSURL *url = [searchTextLowercase hasPrefix:@"http://"] || [searchTextLowercase hasPrefix:@"https://"]
		? [NSURL URLWithString:[theSearchBar text]]
		: [NSURL URLWithString:[NSString stringWithFormat:googleSearch, [[theSearchBar text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}   

@end
