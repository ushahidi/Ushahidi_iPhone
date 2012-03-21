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

#import "IncidentTabViewController.h"
#import "BaseTabViewController.h"
#import "IncidentAddViewController.h"
#import "IncidentDetailsViewController.h"
#import "IncidentTableViewController.h"
#import "IncidentMapViewController.h"
#import "SettingsViewController.h"
#import "NSString+Extension.h"
#import "UIView+Extension.h"
#import "Deployment.h"
#import "Device.h"
#import "Settings.h"
#import "IncidentTableCell.h"
#import "TableCellFactory.h"
#import "UIColor+Extension.h"
#import "LoadingViewController.h"
#import "NSDate+Extension.h"
#import "AlertView.h"
#import "InputView.h"
#import "Incident.h"
#import "Deployment.h"
#import "Category.h"
#import "NSString+Extension.h"
#import "Settings.h"
#import "TableHeaderView.h"
#import "Internet.h"
#import "ItemPicker.h"
#import "AppDelegate.h"
#import "UIEvent+Extension.h"

@interface IncidentTabViewController ()

@end

@implementation IncidentTabViewController

#pragma mark -
#pragma mark Handlers

- (IBAction) refresh:(id)sender event:(UIEvent*)event {
	DLog(@"");
	self.refreshButton.enabled = NO;
    self.filterButton.enabled = NO;
    self.addButton.enabled = NO;
	[self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];
	[[Ushahidi sharedUshahidi] uploadIncidentsForDelegate:self];
	[[Ushahidi sharedUshahidi] getIncidentsForDelegate:self];
    if ([Device isIPhone] && [[Settings sharedSettings] isWhiteLabel]) {
        [[Ushahidi sharedUshahidi] getCategoriesForDelegate:self];
	}
	[[Ushahidi sharedUshahidi] getVersionForDelegate:self];
}

- (IBAction) filter:(id)sender event:(UIEvent*)event {
	DLog(@"");
	NSMutableArray *titles = [NSMutableArray arrayWithObject:NSLocalizedString(@" --- ALL CATEGORIES --- ", nil)];
	for (Category *theCategory in self.filters) {
		if ([NSString isNilOrEmpty:[theCategory title]] == NO) {
			[titles addObject:theCategory.title];
		}
	}
    Category *category = (Category*)self.filter;
    [self.itemPicker showWithItems:titles 
                      withSelected:[category title] 
                           forRect:[event getRectForView:self.view] 
                               tag:0];
}

- (IBAction) display:(id)sender event:(UIEvent*)event {
    [super display:sender event:event];
    if (self.displayMode.selectedSegmentIndex == ViewModeTable) {
        
    }
    else if (self.displayMode.selectedSegmentIndex == ViewModeMap){
        
    }
}

#pragma mark -
#pragma mark UIViewController

- (void) awakeFromNib{
    [super awakeFromNib];
}

- (void)viewDidLoad {
	[super viewDidLoad];
    self.backButtonTitle = NSLocalizedString(@"Reports", nil);
} 

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
    self.title = self.deployment.name;
    
    [self.allItems removeAllObjects];
    [self.filters removeAllObjects];
    
    if (self.willBePushed) {
        [self.loadingView show];
        self.filterButton.enabled = [self.filters count] > 0;
        [self.allItems addObjectsFromArray:[[Ushahidi sharedUshahidi] getIncidentsForDelegate:self]];
        [self.filters addObjectsFromArray:[[Ushahidi sharedUshahidi] getCategoriesForDelegate:self]];
    }
    else {
        self.filterButton.enabled = [self.filters count] > 0;
        [self.allItems addObjectsFromArray:[[Ushahidi sharedUshahidi] getIncidents]];
        [self.filters addObjectsFromArray:[[Ushahidi sharedUshahidi] getCategories]];
    }
	
	[self.pendingItems removeAllObjects];
	[self.pendingItems addObjectsFromArray:[[Ushahidi sharedUshahidi] getIncidentsPending]];
   
    [self populateWithFilter:self.filter];
	
    self.filterButton.enabled = self.filters.count > 0;
    DLog(@"Categories:%d", [self.filters count]);    
    if (animated) {
        [[Settings sharedSettings] setLastIncident:nil];
    }
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if ([self.pendingItems count] > 0) {
		[self.alertView showInfoOnceOnly:NSLocalizedString(@"Click the Refresh button to upload pending reports.", nil)];
	}
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark ItemPickerDelegate

- (void) itemPickerReturned:(ItemPicker *)theItemPicker item:(NSString *)item {
	DLog(@"itemPickerReturned: %@", item);
	self.filter = nil;
	for (Category *theCategory in self.filters) {
		if ([theCategory.title isEqualToString:item]) {
			self.filter = theCategory;
			DLog(@"Category: %@", theCategory.title);
			break;
		}
	}
    [self populateWithFilter:self.filter];
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadingFromUshahidi:(Ushahidi *)ushahidi categories:(NSArray *)theCategories {
	DLog(@"Downloading Categories...");
	[self.loadingView showWithMessage:NSLocalizedString(@"Categories...", nil)];
}

- (void) downloadingFromUshahidi:(Ushahidi *)ushahidi locations:(NSArray *)locations {
	DLog(@"Downloading Locations...");
	[self.loadingView showWithMessage:NSLocalizedString(@"Locations...", nil)];
}

- (void) downloadingFromUshahidi:(Ushahidi *)ushahidi incidents:(NSArray *)incidents pending:(NSArray *)pending {
	DLog(@"Downloading Incidents...");
	[self.loadingView showWithMessage:NSLocalizedString(@"Incidents...", nil)];
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi incidents:(NSArray *)incidents pending:(NSArray *)pending error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if (error != nil) {
		DLog(@"error: %d %@", [error code], [error localizedDescription]);
		if ([error code] == UnableToCreateRequest) {
			[self.loadingView hide];
			[self.alertView showOkWithTitle:NSLocalizedString(@"Request Error", nil) 
								 andMessage:[error localizedDescription]];
		}
		else if ([error code] == NoInternetConnection) {
			if ([self.loadingView isShowing]) {
				[self.loadingView hide];
				[self.alertView showOkWithTitle:NSLocalizedString(@"No Internet", nil) 
									 andMessage:[error localizedDescription]];
			}
		}
		else if ([self.loadingView isShowing]){
			[self.loadingView hide];
			[self.alertView showOkWithTitle:NSLocalizedString(@"Server Error", nil) 
								 andMessage:[error localizedDescription]];
		}
	}
	else if (hasChanges) {
		DLog(@"Incidents: %d", [incidents count]);
		[self.pendingItems removeAllObjects];
		[self.pendingItems addObjectsFromArray:pending];
		
        [self populate:incidents filter:self.filter];
        DLog(@"Re-Adding Incidents");
	}
	else {
		DLog(@"No Changes Incidents");
	}
	self.addButton.enabled = YES;
    self.refreshButton.enabled = YES;
    self.filterButton.enabled = self.filters.count > 0;
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi categories:(NSArray *)categories error:(NSError *)error hasChanges:(BOOL)hasChanges {
    if (error != nil) {
		DLog(@"error: %d %@", [error code], [error localizedDescription]);
	}
	else if (hasChanges) {
        DLog(@"Re-Adding Categories");
		[self.filters removeAllObjects];
		[self.filters addObjectsFromArray:categories];
	}
    else {
		DLog(@"No Changes Categories");
	}
	self.filterButton.enabled = [self.filters count] > 0;
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi locations:(NSArray *)theLocations error:(NSError *)error hasChanges:(BOOL)hasChanges {
    DLog(@"");
}

- (void) uploadingToUshahidi:(Ushahidi *)ushahidi incident:(Incident *)incident {
    [self.baseTableViewController uploadingToUshahidi:ushahidi incident:incident];
}

- (void) uploadedToUshahidi:(Ushahidi *)ushahidi incident:(Incident *)incident error:(NSError *)error {
    if (error != nil) {
		DLog(@"error: %d %@", [error code], [error localizedDescription]);
		if ([error code] > NoInternetConnection) {
			[self.loadingView hide];
			[self.alertView showOkWithTitle:NSLocalizedString(@"Upload Error", nil) 
								 andMessage:[error localizedDescription]];
		}
	}
    [self.baseTableViewController.pendingRows removeAllObjects];
    [self.baseTableViewController.pendingRows addObjectsFromArray:[[Ushahidi sharedUshahidi] getIncidentsPending]];
    [self.baseTableViewController uploadedToUshahidi:ushahidi incident:incident error:error];
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi map:(UIImage *)map incident:(Incident *)incident {
	DLog(@"downloadedFromUshahidi:incident:map:");
    [self.baseTableViewController downloadedFromUshahidi:ushahidi map:map incident:incident];
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi photo:(Photo *)photo incident:(Incident *)incident {
	DLog(@"incident:%@ photo:%@ indexPath:%@", [incident title], [photo url], [photo indexPath]);
    [self.baseTableViewController downloadedFromUshahidi:ushahidi photo:photo incident:incident];
}

@end
