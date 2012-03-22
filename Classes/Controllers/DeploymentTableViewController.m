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

#import "DeploymentTableViewController.h"
#import "IncidentTabViewController.h"
#import "CheckinTabViewController.h"
#import "DeploymentAddViewController.h"
#import "SettingsViewController.h"
#import "DeploymentTableCell.h"
#import "TableCellFactory.h"
#import "UIColor+Extension.h"
#import "UIView+Extension.h"
#import "LoadingViewController.h"
#import "AlertView.h"
#import "InputView.h"
#import "Deployment.h"
#import "NSString+Extension.h"
#import "Settings.h"
#import "Device.h"
#import "AppDelegate.h"
#import "MapDialog.h"
#import "UIEvent+Extension.h"

@interface DeploymentTableViewController ()

@property(nonatomic, retain) MapDialog *mapDialog;
@property(nonatomic, retain) NSString *mapName;
@property(nonatomic, retain) NSString *mapUrl;

- (void) mainQueueFinished;

@end

@implementation DeploymentTableViewController

typedef enum {
	MapAddByUrl,
	MapAddByLocation
} MapAdd;

@synthesize incidentTabViewController;
@synthesize checkinTabViewController;
@synthesize deploymentAddViewController;
@synthesize settingsViewController;
@synthesize addButton;
@synthesize settingsButton;
@synthesize mapDialog;
@synthesize mapName;
@synthesize mapUrl;

#pragma mark -
#pragma mark Handlers

- (IBAction) add:(id)sender event:(UIEvent*)event {
	DLog(@"");
    self.mapName = nil;
    self.mapUrl = nil;
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil 
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:NSLocalizedString(@"Add Map By URL", nil), 
                                                                       NSLocalizedString(@"Find Maps Around Me", nil), nil] autorelease];    
    CGRect rect = [event getRectForView:self.view];
    [actionSheet showFromRect:rect inView:self.view animated:YES];
}

- (IBAction) settings:(id)sender event:(UIEvent*)event {
	DLog(@"");
	self.settingsViewController.modalPresentationStyle = UIModalPresentationPageSheet;
	self.settingsViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:self.settingsViewController animated:YES];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = NSLocalizedString(@"Maps", nil);
	self.mapDialog = [[MapDialog alloc] initForDelegate:self];
    
    NSArray *deployments = [[Ushahidi sharedUshahidi] getDeploymentsUsingSorter:@selector(compareByName:)];
    [self.allRows removeAllObjects];
    [self.allRows addObjectsFromArray:deployments];
    [self.filteredRows removeAllObjects];
    [self.filteredRows addObjectsFromArray:deployments];
    if ([Device isIPad]) {
        if ([[Ushahidi sharedUshahidi] hasDeployment]) {
            [self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];
            [[Ushahidi sharedUshahidi] loadDeploymentForDelegate:self];
        }
        else if (self.filteredRows.count > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
            [self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];
            Deployment *deployment = [self.filteredRows objectAtIndex:0];
            [[Ushahidi sharedUshahidi] loadDeployment:deployment forDelegate:self];    
        }
        if (self.filteredRows.count < 4) {
            CGFloat height = 4 * [DeploymentTableCell getCellHeight];
            self.contentSizeForViewInPopover = CGSizeMake(320.0, height);
        }
        else if (self.filteredRows.count < 12) {
            CGFloat height = self.filteredRows.count * [DeploymentTableCell getCellHeight];
            self.contentSizeForViewInPopover = CGSizeMake(320.0, height);
        }
        else {
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 800);
        }
    }
} 

- (void)viewDidUnload {
    [super viewDidUnload];
    self.mapDialog = nil;
	self.settingsButton = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	NSArray *deployments = [[Ushahidi sharedUshahidi] getDeploymentsUsingSorter:@selector(compareByName:)];
    [self.allRows removeAllObjects];
    [self.allRows addObjectsFromArray:deployments];
    [self.filteredRows removeAllObjects];
    [self.filteredRows addObjectsFromArray:deployments];
    [self.tableView reloadData];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainQueueFinished) name:kMainQueueFinished object:nil];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    if (animated) {
        [[Settings sharedSettings] setLastDeployment:nil];
    }
    [self.tableView flashScrollIndicators];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.view endEditing:YES];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kMainQueueFinished object:nil];
}

- (void)dealloc {
	[incidentTabViewController release];
	[checkinTabViewController release];
	[deploymentAddViewController release];
	[settingsViewController release];
    [mapDialog release];
    [settingsButton release];
    [addButton release];
    [mapName release];
    [mapUrl release];
	[super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [DeploymentTableCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DeploymentTableCell *cell = [TableCellFactory getDeploymentTableCellForTable:theTableView indexPath:indexPath];
	Deployment *deployment = [self filteredRowAtIndexPath:indexPath];
	if (deployment != nil) {
		[cell setTitle:deployment.name];
		[cell setUrl:deployment.url];
		if ([NSString isNilOrEmpty:deployment.description]) {
			[cell setDescription:deployment.name];
		}
		else {
			[cell setDescription:deployment.description];
		}
        if ([Device isIPad]) {
            if ([[Ushahidi sharedUshahidi] isDeployment:deployment]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [theTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
        if (cell.gestureRecognizers.count == 0) {
            UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
            longPressRecognizer.minimumPressDuration = 1.25;
            [cell addGestureRecognizer:longPressRecognizer]; 
            [longPressRecognizer release];   
        }
	}
	else {
		[cell setTitle:nil];
		[cell setUrl:nil];
		[cell setDescription:nil];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"section:%d row:%d", indexPath.section, indexPath.row);
    if ([theTableView isEditing]) {
        [theTableView setEditing:NO];
        self.settingsButton.enabled = YES; 
        self.addButton.enabled = YES;
        [self.tableView reloadData];
    }
    else {
        if ([Device isIPad]) {
            [theTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        else {
            [theTableView deselectRowAtIndexPath:indexPath animated:YES];    
        }
        [self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];
        Deployment *deployment = [self.filteredRows objectAtIndex:indexPath.row];
        [[Ushahidi sharedUshahidi] loadDeployment:deployment forDelegate:self];   
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		Deployment *deployment = [self.filteredRows objectAtIndex:indexPath.row];
		@try {
            BOOL isCurrentDeployment = [[Ushahidi sharedUshahidi] isDeployment:deployment];
            if ([[Ushahidi sharedUshahidi] removeDeployment:deployment]) {
				[self.loadingView showWithMessage:NSLocalizedString(@"Removed", nil)];
				[self.loadingView hideAfterDelay:1.0];
				[self.allRows removeObject:deployment];
				[self.filteredRows removeObject:deployment];
                if ([Device isIPad] && isCurrentDeployment) {
                    if (self.filteredRows.count > 0) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
                        [self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];
                        [[Ushahidi sharedUshahidi] loadDeployment:[self.filteredRows objectAtIndex:0] forDelegate:self];
                    }
                }
                [self.tableView setEditing:NO animated:YES];
                [self.tableView reloadData];
                self.addButton.enabled = YES;
                self.settingsButton.enabled = YES;
			}
			else {
				[self.alertView showOkWithTitle:NSLocalizedString(@"Remove Error", nil) 
									 andMessage:NSLocalizedString(@"There was a problem removing the map.", nil)];	
			}
		}
		@catch (NSException *e) {
			[self.alertView showOkWithTitle:NSLocalizedString(@"Remove Error", nil) 
								 andMessage:NSLocalizedString(@"There was a problem removing the map.", nil)];
		}
	}	
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi deployments:(NSArray *)deployments error:(NSError *)error hasChanges:(BOOL)hasChanges {
	DLog(@"");
	[self.loadingView hide];
	if (error != nil) {
		DLog(@"error: %@", [error localizedDescription]);
		[self.alertView showOkWithTitle:NSLocalizedString(@"Error", nil) 
							 andMessage:[error localizedDescription]];
	}
	else if (hasChanges) {
		DLog(@"Has Changes: %d", [deployments count]);
		NSArray *sortedDeployments =[deployments sortedArrayUsingSelector:@selector(compareByName:)];
		[self.allRows removeAllObjects];
		[self.allRows addObjectsFromArray:sortedDeployments];
		NSString *searchText = [self getSearchText];
		[self.filteredRows removeAllObjects];
		for (Deployment *deployment in sortedDeployments) {
			if ([deployment matchesString:searchText]) {
				[self.filteredRows addObject:deployment];
			}
		}
		[self.tableView reloadData];	
		[self.tableView flashScrollIndicators];
	}
	else {
		DLog(@"No Changes");
	}
	[self.loadingView hide];
}

- (void) mainQueueFinished {
	DLog(@"");
	[self.loadingView hideAfterDelay:0.0];
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (void)longPress:(UILongPressGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if ([self.tableView isEditing]) {
            [self.tableView setEditing:NO];
            self.settingsButton.enabled = YES;
            self.addButton.enabled = YES;
        }
        else {
            [self.tableView setEditing:YES];
            self.settingsButton.enabled = NO;
            self.addButton.enabled = NO;
        }
    }
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        self.mapName = nil;
        self.mapUrl = nil;
    }
    else if (buttonIndex == MapAddByUrl) {
        [self.mapDialog showWithTitle:NSLocalizedString(@"Enter Map Details", nil) 
                                 name:self.mapName 
                                  url:self.mapUrl];
    }
    else if (buttonIndex == MapAddByLocation) {
        self.deploymentAddViewController.modalPresentationStyle = UIModalPresentationPageSheet;
        self.deploymentAddViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:self.deploymentAddViewController animated:YES];
    }
}

#pragma mark -
#pragma mark MapDialogDelegate

- (void) mapDialogReturned:(MapDialog *)theMapDialog name:(NSString *)name url:(NSString *)url {
	DLog(@"name:%@ url:%@", name, url);
	if ([NSString isNilOrEmpty:name] == NO && [NSString isNilOrEmpty:url] == NO) {
        self.mapName = nil;
        self.mapUrl = nil;
        [self.loadingView showWithMessage:NSLocalizedString(@"Adding...", nil)];
		Deployment *deployment = [[Deployment alloc] initWithName:name url:url];
		if ([[Ushahidi sharedUshahidi] addDeployment:deployment]) {
			[[Ushahidi sharedUshahidi] getVersionOfDeployment:deployment forDelegate:self];
            [self.allRows addObject:deployment];
            [self.filteredRows addObject:deployment];
            [self.tableView reloadData];
            [self.tableView flashScrollIndicators];
        }
        [deployment release];
    }
	else {
        self.mapName = name;
        self.mapUrl = url;
		[self.alertView showOkWithTitle:NSLocalizedString(@"Invalid Map Details", nil) 
							 andMessage:NSLocalizedString(@"Please enter a valid name and url.", nil)];
	}
}

- (void) mapDialogCancelled:(MapDialog *)theMapDialog {
	DLog(@"");
    self.mapName = nil;
    self.mapUrl = nil;
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([alert.title isEqualToString:NSLocalizedString(@"Invalid Map Details", nil)]) {
		[self.mapDialog showWithTitle:NSLocalizedString(@"Enter Map Details", nil) 
								 name:self.mapName 
								  url:self.mapUrl];	
	}
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) loadedFromUshahidi:(Ushahidi *)ushahidi deployment:(Deployment *)deployment {
	DLog(@"");
    NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
    [self.tableView reloadData];
    if ([Device isIPad]) {
        [self.tableView selectRowAtIndexPath:selected animated:NO scrollPosition:UITableViewScrollPositionNone];    
    }
	if (deployment.supportsCheckins) {
		self.checkinTabViewController.deployment = deployment;
        [self setDetailsViewController:self.checkinTabViewController animated:YES];
    }
	else {
		self.incidentTabViewController.deployment = deployment;
        [self setDetailsViewController:self.incidentTabViewController animated:YES];
	}
    [self.loadingView hide];
}

@end
