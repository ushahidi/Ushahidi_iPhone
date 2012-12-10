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

#import "CheckinTabViewController.h"
#import "BaseTabViewController.h"
#import "CheckinTableViewController.h"
#import "CheckinMapViewController.h"
#import "SettingsViewController.h"
#import "LoadingViewController.h"
#import "NSString+Extension.h"
#import "UIView+Extension.h"
#import "Deployment.h"
#import "Device.h"
#import "Settings.h"
#import "User.h"
#import "UIEvent+Extension.h"

@interface CheckinTabViewController ()

@property(nonatomic, retain) UserDialog *userDialog;

@end

@implementation CheckinTabViewController

@synthesize checkinTableViewController;
@synthesize checkinMapViewController;
@synthesize userDialog;

#pragma mark -
#pragma mark Handlers

#pragma mark -
#pragma mark Handlers

- (IBAction) refresh:(id)sender event:(UIEvent*)event {
	DLog(@"");
    self.addButton.enabled = NO;
	self.refreshButton.enabled = NO;
    self.filterButton.enabled = NO;
	[self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];
	[[Ushahidi sharedUshahidi] getCheckinsForDelegate:self];
	[[Ushahidi sharedUshahidi] getVersionForDelegate:self];
}

- (IBAction) filter:(id)sender event:(UIEvent*)event {
	DLog(@"");
	NSMutableArray *names = [NSMutableArray arrayWithObject:NSLocalizedString(@"--- ALL USERS ---", nil)];
	for (User *user in self.filters) {
		if ([NSString isNilOrEmpty:[user name]] == NO) {
			[names addObject:user.name];
		}
	}
    User *user = (User*)self.filter;
    [self.itemPicker showWithItems:names 
                      withSelected:user.name 
                           forRect:[event getRectForView:self.view] 
                               tag:0];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    self.backButtonTitle = NSLocalizedString(@"Checkins", nil);
    self.userDialog = [[UserDialog alloc] initForDelegate:self];
} 

- (void)viewDidUnload {
    [super viewDidUnload];
    self.userDialog = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
    self.title = self.deployment.name;
    
    [self.allItems removeAllObjects];
	if (self.willBePushed) {
        [self.allItems addObjectsFromArray:[[Ushahidi sharedUshahidi] getCheckinsForDelegate:self]];
    }
    else {
        self.addButton.enabled = YES;
        self.refreshButton.enabled = YES;
        self.filterButton.enabled = [self.filters count] > 0;
        [self.allItems addObjectsFromArray:[[Ushahidi sharedUshahidi] getCheckins]];
    }
    
    [self.filters removeAllObjects];
    [self.filters addObjectsFromArray:[[Ushahidi sharedUshahidi] getUsers]];
    self.filterButton.enabled = [self.filters count] > 0;
    
    [self populateWithFilter:self.filter];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if ([[Settings sharedSettings] hasFirstName] == NO && 
		[[Settings sharedSettings] hasLastName] == NO &&
		[[Settings sharedSettings] hasEmail] == NO) {
		[self.userDialog showWithTitle:NSLocalizedString(@"Contact Settings", nil) 
								 first:[[Settings sharedSettings] firstName] 
								  last:[[Settings sharedSettings] lastName]  
								 email:[[Settings sharedSettings] email]];
	}
}

- (void)dealloc {
	[checkinTableViewController release];
	[checkinMapViewController release];
    [userDialog release];
    [super dealloc];
}

#pragma mark -
#pragma mark UserDialog

- (void) userDialogReturned:(UserDialog *)dialog first:(NSString *)first last:(NSString *)last email:(NSString *)email {
    DLog(@"first:%@ last:%@ email:%@", first, last, email);
	[[Settings sharedSettings] setFirstName:first];
	[[Settings sharedSettings] setLastName:last];
	[[Settings sharedSettings] setEmail:email];
}

- (void) userDialogCancelled:(UserDialog *)dialog {
    DLog(@"");
}

#pragma mark -
#pragma mark ItemPickerDelegate

- (void) itemPickerReturned:(ItemPicker *)theItemPicker item:(NSString *)item {
	DLog(@"itemPickerReturned: %@", item);
	self.filter = nil;
	for (User *user in self.filters) {
		if ([user.name isEqualToString:item]) {
			self.filter = user;
			DLog(@"User: %@", user.name);
			break;
		}
	}
    [self populateWithFilter:self.filter];
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadingFromUshahidi:(Ushahidi *)ushahidi checkins:(NSArray *)checkins {
	[self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi checkins:(NSArray *)checkins error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if (error != nil) {
		DLog(@"error: %d %@", [error code], [error localizedDescription]);
	}
	else if (hasChanges) {
		DLog(@"Re-Adding Checkins: %d", [checkins count]);
		[self.allItems removeAllObjects];
		[self.allItems addObjectsFromArray:checkins];
    }
	else {
		DLog(@"No Changes Checkins");
	}
    [self populateWithFilter:self.filter];
    self.addButton.enabled = YES;
	self.refreshButton.enabled = YES;
    self.filterButton.enabled = [self.filters count] > 0;
    [self.loadingView hide];
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi users:(NSArray *)users error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if (error != nil) {
		DLog(@"error: %d %@", [error code], [error localizedDescription]);
	}
	else {
		DLog(@"Users: %d", [users count]);
        [self.filters removeAllObjects];
        [self.filters addObjectsFromArray:users];
	}
	self.filterButton.enabled = [self.filters count] > 0;
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi map:(UIImage *)map checkin:(Checkin *)checkin {
	DLog(@"downloadedFromUshahidi:map:object:");
    [self.baseTableViewController downloadedFromUshahidi:ushahidi map:map checkin:checkin];
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi photo:(Photo *)photo checkin:(Checkin *)checkin {
	DLog(@"url:%@ indexPath:%@", [photo url], [photo indexPath]);
    [self.baseTableViewController downloadedFromUshahidi:ushahidi photo:photo checkin:checkin];
}

- (void) mainQueueFinished {
	DLog(@"");
	[self.loadingView hideAfterDelay:1.0];
}

@end
