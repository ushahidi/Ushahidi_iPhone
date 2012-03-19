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

#import "IncidentTableViewController.h"
#import "IncidentTabViewController.h"
#import "IncidentAddViewController.h"
#import "IncidentDetailsViewController.h"
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
#import "Ushahidi.h"
#import "Video.h"

@interface IncidentTableViewController ()

- (void) updateSyncedLabel;

@end

@implementation IncidentTableViewController

@synthesize incidentTabViewController;
@synthesize incidentAddViewController; 
@synthesize incidentDetailsViewController;
@synthesize deployment;

#pragma mark -
#pragma mark Enums

typedef enum {
	TableSectionPending,
	TableSectionIncidents
} TableSection;

#pragma mark -
#pragma mark Handlers

- (void) updateSyncedLabel {
	if (self.deployment.synced) {
		[self setTableFooter:[NSString stringWithFormat:@"%@ %@", 
							  NSLocalizedString(@"Last Sync", nil), 
							  [self.deployment.synced dateToString:@"h:mm a, MMMM d, yyyy"]]];	
	}
	else {
		[self setTableFooter:nil];
	}
}

- (void) populate:(NSArray*)items filter:(NSObject*)theFilter {
    DLog(@"");
    self.filter = theFilter;
    
    [self.allRows removeAllObjects];
    [self.allRows addObjectsFromArray:items];
    
    [self.filteredRows removeAllObjects];
	NSString *searchText = [self getSearchText];
	for (Incident *incident in self.allRows) {
		if (self.filter != nil) {
            Category *category = (Category*)self.filter;
			if ([incident hasCategory:category] && [incident matchesString:searchText]) {
				[self.filteredRows addObject:incident];
			}
		}
		else if ([incident matchesString:searchText]) {
			[self.filteredRows addObject:incident];
		}
	}
	if (self.filter != nil) {
        Category *category = (Category*)self.filter;
        [self setHeader:category.title atSection:TableSectionIncidents];
    }
    else {
        [self setHeader:NSLocalizedString(@"All Categories", nil) atSection:TableSectionIncidents];
    }
    [self setTableFooter:nil];
    [self.tableView reloadData];	
    [self.tableView flashScrollIndicators];	
    [self updateSyncedLabel];	
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonTitle:NSLocalizedString(@"Reports", nil)];
	[self showSearchBarWithPlaceholder:NSLocalizedString(@"Search reports...", nil)];
	[self setHeader:NSLocalizedString(@"Pending Upload", nil) atSection:TableSectionPending];
	[self setHeader:NSLocalizedString(@"All Categories", nil) atSection:TableSectionIncidents];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)dealloc {
	[incidentTabViewController release];
    [incidentAddViewController release];
	[incidentDetailsViewController release];
	[deployment release];
	[super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (section == TableSectionPending) {
		return [self.pendingRows count];
	}
	if (section == TableSectionIncidents) {
		return [self.filteredRows count];
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForHeaderInSection:(NSInteger)section {
	if (section == TableSectionPending && [self.pendingRows count] > 0) {
		return [TableHeaderView getViewHeight];
	}
	else if (section == TableSectionIncidents) {
		return [TableHeaderView getViewHeight];
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [IncidentTableCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	IncidentTableCell *cell = [TableCellFactory getIncidentTableCellForTable:theTableView indexPath:indexPath];
	Incident *incident = indexPath.section == TableSectionIncidents
		? [self filteredRowAtIndexPath:indexPath] : [self.pendingRows objectAtIndex:indexPath.row];
	if (incident != nil) {
		[cell setTitle:incident.title];
        [cell setDescription:incident.description];
		[cell setLocation:incident.location];
		[cell setCategory:incident.categoryNames];
		[cell setDate:incident.dateString];
		[cell setVerified:incident.verified];
        UIImage *image = [incident getFirstPhotoThumbnail];
		if (image != nil) {
			[cell setImage:image];
		}
		else if (incident.hasPhotos) {
			Photo *photo = [incident.photos objectAtIndex:0];
			photo.indexPath = indexPath;
			[[Ushahidi sharedUshahidi] downloadPhoto:photo forIncident:incident forDelegate:self];
		}
		else if (incident.map != nil) {
			[cell setImage:incident.map];
		}
		else {
			[cell setImage:nil];
		}
        if ([incident.videos count] > 0) {
            Video *video = [incident.videos objectAtIndex:0];
            if (video != nil && [[video url] isYouTubeLink]) {
                CGSize videoSize = [cell webViewSize];
                DLog(@"YOUTUBE: %@", video.url);
                NSString *html = [video.url youTubeEmbedCode:NO size:videoSize];
                DLog(@"EMBED: %@", html);
                [cell setHTML:html];
            }
		}
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		[cell setUploading:indexPath.section == TableSectionPending && incident.uploading];
	}
	else {
		[cell setTitle:nil];
		[cell setLocation:nil];
		[cell setCategory:nil];
		[cell setDate:nil];
		[cell setImage:nil];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == TableSectionIncidents) {
		self.incidentDetailsViewController.incident = [self filteredRowAtIndexPath:indexPath];
		self.incidentDetailsViewController.incidents = self.filteredRows;
		self.incidentTabViewController.navigationItem.backBarButtonItem.title = NSLocalizedString(@"Reports", nil);
		if (self.editing) {
			[self.view endEditing:YES];
			[self performSelector:@selector(pushDetailsViewController:) withObject:self.incidentDetailsViewController afterDelay:0.1];
		}
		else {
            [self pushDetailsViewController:self.incidentDetailsViewController animated:YES];
        }
	}
	else {
		self.incidentAddViewController.incident = [self.pendingRows objectAtIndex:indexPath.row];
		if (self.editing) {
			[self.view endEditing:YES];
			[self performSelector:@selector(presentModalViewController:) withObject:self.incidentAddViewController afterDelay:0.1];
		}
		else {
            [self presentModalViewController:self.incidentAddViewController animated:YES];
        }
	}	
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void) filterRows:(BOOL)reload {
    [self.filteredRows removeAllObjects];
	NSString *searchText = [self getSearchText];
	for (Incident *incident in self.allRows) {
		if (self.filter != nil) {
            Category *category = (Category*)self.filter;
			if ([incident hasCategory:category] && [incident matchesString:searchText]) {
				[self.filteredRows addObject:incident];
			}
		}
		else if ([incident matchesString:searchText]) {
			[self.filteredRows addObject:incident];
		}
	}
	if (reload) {
		[self setTableFooter:nil];
		[self.tableView reloadData];	
		[self.tableView flashScrollIndicators];	
		[self updateSyncedLabel];	
	}
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) uploadingToUshahidi:(Ushahidi *)ushahidi incident:(Incident *)incident {
	if (incident != nil){
		NSInteger row = [self.pendingRows indexOfObject:incident];
		DLog(@"Incident: %d %@", row, incident.title);
		if (row > -1) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:TableSectionPending];
            IncidentTableCell *cell = (IncidentTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
			if (cell != nil) {
				[cell setUploading:YES];
			}
		}
		else {
			[self.tableView reloadData];
		}
	}
	else {
		DLog(@"Incident is NULL");
		[self.tableView reloadData];
	}
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
	if (incident != nil) {
		NSInteger row = [self.pendingRows indexOfObject:incident];
		DLog(@"Incident: %d %@", row, incident.title);
		if (row > -1) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:TableSectionPending];
			IncidentTableCell *cell = (IncidentTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
			if (cell != nil) {
				[cell setUploading:NO];
			}
		}
		[self.loadingView showWithMessage:NSLocalizedString(@"Uploaded", nil)];
		[self.loadingView hideAfterDelay:1.0];
	}
	else {
		DLog(@"Incident is NULL");
	}
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi map:(UIImage *)map incident:(Incident *)incident {
	DLog(@"downloadedFromUshahidi:incident:map:");
	NSInteger row = [self.filteredRows indexOfObject:incident];
	if (row != NSNotFound) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:TableSectionIncidents];
		IncidentTableCell *cell = (IncidentTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
		if (cell != nil && [incident getFirstPhotoThumbnail] == nil) {
			[cell setImage:map];
		}
	}
	else {
		[self.tableView reloadData];
	}
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi photo:(Photo *)photo incident:(Incident *)incident {
	DLog(@"incident:%@ photo:%@ indexPath:%@", [incident title], [photo url], [photo indexPath]);
	if (photo != nil && photo.indexPath != nil) {        
		IncidentTableCell *cell = (IncidentTableCell *)[self.tableView cellForRowAtIndexPath:photo.indexPath];
		if (cell != nil) {
			if (photo.thumbnail != nil) {
				[cell setImage:photo.thumbnail];
			}
			else if (photo.image != nil)  {
				[cell setImage:photo.image];
			}
			else {
				[self.tableView reloadData];
			}
		}
		else {
			[self.tableView reloadData];
		}
	}
	else {
		[self.tableView reloadData];
	}
}

@end
