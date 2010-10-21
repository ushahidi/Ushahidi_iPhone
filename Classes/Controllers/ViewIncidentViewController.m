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

#import "ViewIncidentViewController.h"
#import "WebViewController.h"
#import "MapViewController.h"
#import "ImageViewController.h"
#import "TableCellFactory.h"
#import "SubtitleTableCell.h"
#import "ImageTableCell.h"
#import "LoadingViewController.h"
#import "AlertView.h"
#import "InputView.h"
#import "Incident.h"
#import "Photo.h"
#import "Location.h"
#import "UIColor+Extension.h"
#import "TableHeaderView.h"

typedef enum {
	TableSectionTitle,
	TableSectionCategory,
	TableSectionLocation,
	TableSectionDateTime,
	TableSectionDescription,
	TableSectionPhotos,
	TableSectionNews
} TableSection;

typedef enum {
	NavBarPrevious,
	NavBarNext
} NavBar;

@interface ViewIncidentViewController ()

@end

@implementation ViewIncidentViewController

@synthesize webViewController, mapViewController, imageViewController, nextPrevious, incident, incidents;

#pragma mark -
#pragma mark Handlers

- (IBAction) action:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
															 delegate:self 
													cancelButtonTitle: @"Cancel" 
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Share this Incident", @"Rate this Incident", @"Comment on Incident", nil];
	[actionSheet setActionSheetStyle:UIBarStyleBlackTranslucent];
	[actionSheet showInView:[self view]];
	[actionSheet release];
}

- (IBAction) nextPrevious:(id)sender {
	NSInteger index = [self.incidents indexOfObject:self.incident];
	if (self.nextPrevious.selectedSegmentIndex == NavBarNext) {
		DLog(@"Next");
		self.incident = [self.incidents objectAtIndex:index + 1];
	}
	else if (self.nextPrevious.selectedSegmentIndex == NavBarPrevious) {
		DLog(@"Previous");
		self.incident = [self.incidents objectAtIndex:index - 1];
	}
	self.title = self.incident.title;
	NSInteger newIndex = [self.incidents indexOfObject:self.incident];
	[self.nextPrevious setEnabled:(newIndex > 0) forSegmentAtIndex:NavBarPrevious];
	[self.nextPrevious setEnabled:(newIndex + 1 < [self.incidents count]) forSegmentAtIndex:NavBarNext];
	[self.tableView reloadData];
	[self.tableView flashScrollIndicators];
}

#pragma mark -
#pragma mark UIViewController

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.title = self.incident.title;
	NSInteger index = [self.incidents indexOfObject:self.incident];
	[self.nextPrevious setEnabled:index > 0 forSegmentAtIndex:NavBarPrevious];
	[self.nextPrevious setEnabled:index + 1 < [self.incidents count] forSegmentAtIndex:NavBarNext];
	[self.tableView reloadData];
}

- (void)dealloc {
	[webViewController release];
	[mapViewController release];
	[imageViewController release];
	[nextPrevious release];
	[incident release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 7;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (section == TableSectionNews) {
		return [self.incident.news count];
	}
	if (section == TableSectionPhotos) {
		return [self.incident.photos count];
	}
	if (section == TableSectionLocation) {
		return 2;
	}
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionDescription) {
		TextTableCell *cell = [TableCellFactory getTextTableCellWithDelegate:self table:theTableView];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[cell setText:self.incident.description];
		return cell;
	}
	else if (indexPath.section == TableSectionNews) {
		SubtitleTableCell *cell = [TableCellFactory getSubtitleTableCellWithDefaultImage:[UIImage imageNamed:@"no_image.png"] table:theTableView];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		return cell;
	}
	else if (indexPath.section == TableSectionLocation && indexPath.row == 1) {
		MapTableCell *cell = [TableCellFactory getMapTableCellWithDelegate:self table:theTableView];
		[cell setScrollable:NO];
		[cell setZoomable:NO];
		[cell removeAllPins];
		[cell addPinWithTitle:self.incident.locationName 
					 subtitle:[NSString stringWithFormat:@"%f,%f", incident.locationLatitude, incident.locationLongitude]
					 latitude:self.incident.locationLatitude 
					longitude:self.incident.locationLongitude];
		[cell resizeRegionToFitAllPins:NO];
		return cell;
	}
	else if (indexPath.section == TableSectionPhotos) {
		ImageTableCell *cell = [TableCellFactory getImageTableCellWithImage:nil table:theTableView];
		cell.indexPath = indexPath;
		Photo *photo = [self.incident.photos objectAtIndex:indexPath.row];
		if (photo != nil) {
			if (photo.image != nil) {
				[cell setImage:photo.image];
			}
			else {
				[cell setImage:nil];
				[photo downloadWithDelegate:self];
			}
		}
		else {
			[cell setImage:nil];
		}
		return cell;
	}
	else {
		UITableViewCell *cell = [TableCellFactory getDefaultTableCellForTable:theTableView];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		if (indexPath.section == TableSectionTitle) {
			cell.textLabel.text = self.incident.title;
		}
		else if (indexPath.section == TableSectionCategory) {
			//TODO load categoriess
			cell.textLabel.text = @"";
		}
		else if (indexPath.section == TableSectionLocation) {
			cell.textLabel.text = self.incident.locationName;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;	
		}
		else if (indexPath.section == TableSectionDateTime) {
			cell.textLabel.text = [self.incident getDateString];
		}
//		else if (indexPath.section == TableSectionPhotos && indexPath.row == 0) {
//			cell.textLabel.text = @"Add Photo";
//			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//			cell.selectionStyle = UITableViewCellSelectionStyleGray;
//		}
//		else if (indexPath.section == TableSectionNews && indexPath.row == 0) {
//			cell.textLabel.text = @"Add News Article";
//			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//			cell.selectionStyle = UITableViewCellSelectionStyleGray;
//		}
		return cell;	
	}
	return nil;
}

- (UIView *)tableView:(UITableView *)theTableView viewForHeaderInSection:(NSInteger)section {
	if (section == TableSectionTitle) {
		return [TableHeaderView headerForTable:theTableView text:@"Title" textColor:[UIColor ushahidiDarkGray] backgroundColor:[UIColor ushahidiDarkTan]];
	}
	if (section == TableSectionCategory) {
		return [TableHeaderView headerForTable:theTableView text:@"Category" textColor:[UIColor ushahidiDarkGray] backgroundColor:[UIColor ushahidiDarkTan]];
	}
	if (section == TableSectionLocation) {
		return [TableHeaderView headerForTable:theTableView text:@"Location" textColor:[UIColor ushahidiDarkGray] backgroundColor:[UIColor ushahidiDarkTan]];
	}
	if (section == TableSectionDateTime) {
		return [TableHeaderView headerForTable:theTableView text:@"Date" textColor:[UIColor ushahidiDarkGray] backgroundColor:[UIColor ushahidiDarkTan]];
	}
	if (section == TableSectionDescription) {
		return [TableHeaderView headerForTable:theTableView text:@"Description" textColor:[UIColor ushahidiDarkGray] backgroundColor:[UIColor ushahidiDarkTan]];
	}
	if (section == TableSectionPhotos) {
		return [TableHeaderView headerForTable:theTableView text:@"Photos" textColor:[UIColor ushahidiDarkGray] backgroundColor:[UIColor ushahidiDarkTan]];
	}
	if (section == TableSectionNews) {
		return [TableHeaderView headerForTable:theTableView text:@"News" textColor:[UIColor ushahidiDarkGray] backgroundColor:[UIColor ushahidiDarkTan]];
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionDescription) {
		CGFloat width = theTableView.contentSize.width - 20;
		CGSize tableCellSize = [TextTableCell getCellSizeForText:self.incident.description forWidth:width];
		return tableCellSize.height + 10;
	}
	else if (indexPath.section == TableSectionLocation && indexPath.row == 1) {
		return 140;
	}
	else if (indexPath.section == TableSectionPhotos) {
		return 200;
	}
	else if (indexPath.section == TableSectionNews) {
		return 55;
	}
	return 45;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DLog(@"didSelectRowAtIndexPath:[%d, %d]", indexPath.section, indexPath.row);
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	UITableViewCell *cell = [theTableView cellForRowAtIndexPath:indexPath];
	if (indexPath.section == TableSectionNews && indexPath.row > 0) {
		self.webViewController.website = cell.detailTextLabel.text;
		[self.navigationController pushViewController:self.webViewController animated:YES];
	}
	else if (indexPath.section == TableSectionLocation && indexPath.row == 0) {
		self.mapViewController.locationName = self.incident.locationName;
		self.mapViewController.locationLatitude = self.incident.locationLatitude;
		self.mapViewController.locationLongitude = self.incident.locationLongitude;
		[self.navigationController pushViewController:self.mapViewController animated:YES];
	}
	else if (indexPath.section == TableSectionPhotos) {
		self.imageViewController.image = [((ImageTableCell *)cell) getImage];
		[self.navigationController pushViewController:self.imageViewController animated:YES];
	}
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *titleAtIndex = [actionSheet buttonTitleAtIndex:buttonIndex];
	DLog(@"titleAtIndex: %@", titleAtIndex);
}

#pragma mark -
#pragma mark PhotoDelegate

- (void)photoDownloaded:(Photo *)photo indexPath:(NSIndexPath *)indexPath {
	DLog(@"section:%d row:%d", indexPath.section, indexPath.row);
	ImageTableCell *cell = (ImageTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	if (cell != nil) {
		[cell setImage:photo.image];
	}
}

@end
