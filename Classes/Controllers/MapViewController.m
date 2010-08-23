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

#import "MapViewController.h"

typedef enum {
	MapTypeNormal,
	MapTypeSatellite,
	MapTypeHybrid
} MapType;

@interface MapViewController (Internal)

- (void) showSearchBar:(BOOL)show animated:(BOOL)animated;

@end

@implementation MapViewController

@synthesize mapView, searchBar, mapType, address;

#pragma mark -
#pragma mark Internal

- (void) showSearchBar:(BOOL)show animated:(BOOL)animated {
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.3];
	}
	CGRect searchBarFrame = self.searchBar.frame;
	if (show) {
		if (self.searchBar.frame.origin.y < 0) {
			searchBarFrame.origin.y += self.searchBar.frame.size.height;
		}
		[self.searchBar becomeFirstResponder];
	}
	else {
		if (self.searchBar.frame.origin.y >= 0) {
			searchBarFrame.origin.y -= self.searchBar.frame.size.height;
		}
		[self.searchBar resignFirstResponder];
	}
	self.searchBar.frame = searchBarFrame;
	if (animated) {
		[UIView commitAnimations];
	}
}

#pragma mark -
#pragma mark Handlers

- (IBAction) search:(id)sender {
	DLog(@"");
	[self showSearchBar:YES animated:YES];
}

- (IBAction) findLocation:(id)sender {
	self.mapView.showsUserLocation = YES;
}

- (IBAction) mapTypeChanged:(id)sender {
	self.mapView.mapType = self.mapType.selectedSegmentIndex;
}

#pragma mark -
#pragma mark UIViewController

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.address != nil) {
		self.title = self.address;
	}
	else {
		self.title = @"Map";
	}
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self showSearchBar:NO animated:NO];
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
	[address release];
	[mapView release];
	[mapType release];
	[searchBar release];
	[super dealloc];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapViewWillStartLoadingMap:(MKMapView *)theMapView {
	DLog(@"");
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)theMapView {
	DLog(@"");
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)theMapView withError:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	theSearchBar.showsCancelButton = YES;
}   

- (void)searchBarTextDidEndEditing:(UISearchBar *)theSearchBar {
	theSearchBar.showsCancelButton = NO;
}   

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
	DLog(@"searchText: %@", searchText);
}   

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	[self showSearchBar:NO animated:YES];
}   

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar {
	[self showSearchBar:NO animated:YES];
} 

@end
