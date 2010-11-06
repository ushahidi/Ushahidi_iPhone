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
#import "Messages.h"
#import "TableHeaderView.h"

typedef enum {
	TableSectionErrors,
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

@synthesize mapViewController, imageViewController, nextPrevious, incident, incidents;

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
	NSInteger newIndex = [self.incidents indexOfObject:self.incident];
	self.title = [NSString stringWithFormat:@"%d / %d", newIndex + 1, [self.incidents count]];
	[self.nextPrevious setEnabled:(newIndex > 0) forSegmentAtIndex:NavBarPrevious];
	[self.nextPrevious setEnabled:(newIndex + 1 < [self.incidents count]) forSegmentAtIndex:NavBarNext];
	[self.tableView reloadData];
	[self.tableView flashScrollIndicators];
}

#pragma mark -
#pragma mark UIViewController


- (void) viewDidLoad {
	[super viewDidLoad];
	self.tableView.backgroundColor = [UIColor ushahidiLiteTan];
	self.oddRowColor = [UIColor ushahidiLiteTan];
	self.evenRowColor = [UIColor ushahidiLiteTan];
	[self addHeaders:[Messages errors], [Messages title], [Messages category], [Messages location], [Messages date], [Messages description], [Messages photos], [Messages news], nil];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	NSInteger index = [self.incidents indexOfObject:self.incident];
	self.title = [NSString stringWithFormat:@"%d / %d", index + 1, [self.incidents count]];
	[self.nextPrevious setEnabled:index > 0 forSegmentAtIndex:NavBarPrevious];
	[self.nextPrevious setEnabled:index + 1 < [self.incidents count] forSegmentAtIndex:NavBarNext];
	[self.tableView reloadData];
}

- (void)dealloc {
	[mapViewController release];
	[imageViewController release];
	[nextPrevious release];
	[incident release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 8;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForHeaderInSection:(NSInteger)section {
	return section == TableSectionErrors && self.incident.errors == nil 
		? 0 : [TableHeaderView getViewHeight];
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (section == TableSectionErrors) {
		return self.incident.errors != nil ? 1 : 0;
	}
	if (section == TableSectionNews) {
		if ([self.incident.news count] > 0) {
			return [self.incident.news count];
		}
		return 1;
	}
	if (section == TableSectionPhotos) {
		if ([self.incident.photos count] > 0) {
			return [self.incident.photos count];
		}
		return 1;
	}
	if (section == TableSectionLocation) {
		return 2;
	}
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionNews && [self.incident.news count] > 0) {
		SubtitleTableCell *cell = [TableCellFactory getSubtitleTableCellWithDefaultImage:[UIImage imageNamed:@"no_image.png"] table:theTableView];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		return cell;
	}
	else if (indexPath.section == TableSectionLocation && indexPath.row == 1) {
		if (self.incident.map != nil) {
			ImageTableCell *cell = [TableCellFactory getImageTableCellWithImage:nil table:theTableView];
			cell.indexPath = indexPath;
			[cell setImage:self.incident.map];
			return cell;
		}
		else {
			MapTableCell *cell = [TableCellFactory getMapTableCellWithDelegate:self table:theTableView];
			[cell setScrollable:NO];
			[cell setZoomable:NO];
			//TODO prevent map from re-adding pin
			[cell removeAllPins];
			[cell addPinWithTitle:self.incident.location 
						 subtitle:[NSString stringWithFormat:@"%@,%@", self.incident.latitude, self.incident.longitude]
						 latitude:self.incident.latitude 
						longitude:self.incident.longitude];
			[cell resizeRegionToFitAllPins:NO];	
			return cell;
		}
	}
	else if (indexPath.section == TableSectionPhotos && [self.incident.photos count] > 0) {
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
		TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.indexPath = indexPath;
		if (indexPath.section == TableSectionTitle) {
			cell.textLabel.text = self.incident.title;
		}
		if (indexPath.section == TableSectionDescription) {
			cell.textLabel.text = self.incident.description;
		}
		else if (indexPath.section == TableSectionCategory) {
			cell.textLabel.text = [self.incident categoryNamesWithDefaultText:[Messages noCategorySpecified]];
		}
		else if (indexPath.section == TableSectionLocation) {
			cell.textLabel.text = self.incident.location;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;	
		}
		else if (indexPath.section == TableSectionDateTime) {
			cell.textLabel.text = [self.incident dateTimeString];
		}
		else if (indexPath.section == TableSectionErrors) {
			cell.textLabel.text = [self.incident errors];
		}
		else if (indexPath.section == TableSectionPhotos) {
			cell.textLabel.text = [Messages noPhotos];
		}
		else if (indexPath.section == TableSectionNews) {
			cell.textLabel.text = [Messages noNews];
		}
		return cell;	
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionLocation && indexPath.row == 1) {
		if (self.incident.map != nil) {
			return 180;
		}
		return 140;
	}
	else if (indexPath.section == TableSectionPhotos) {
		if ([self.incident.photos count] > 0) {
			return 200;
		}
		return [TextTableCell getCellSizeForText:[Messages noPhotos] forWidth:theTableView.contentSize.width].height;
	}
	else if (indexPath.section == TableSectionNews) {
		if ([self.incident.news count] > 0) {
			return 55;
		}
		return [TextTableCell getCellSizeForText:[Messages noNews] forWidth:theTableView.contentSize.width].height;
	}
	else if (indexPath.section == TableSectionTitle) {
		return [TextTableCell getCellSizeForText:self.incident.title forWidth:theTableView.contentSize.width].height;
	}
	else if (indexPath.section == TableSectionDescription) {
		return [TextTableCell getCellSizeForText:self.incident.description forWidth:theTableView.contentSize.width].height;
	}
	else if (indexPath.section == TableSectionLocation) {
		return [TextTableCell getCellSizeForText:self.incident.location forWidth:theTableView.contentSize.width].height;
	}
	else if (indexPath.section == TableSectionCategory) {
		return [TextTableCell getCellSizeForText:[self.incident categoryNamesWithDefaultText:[Messages noCategorySpecified]] forWidth:theTableView.contentSize.width].height;
	}
	else if (indexPath.section == TableSectionDateTime) {
		return [TextTableCell getCellSizeForText:[self.incident dateTimeString] forWidth:theTableView.contentSize.width].height;
	}
	else if (indexPath.section == TableSectionErrors) {
		return self.incident.errors != nil 
			? [TextTableCell getCellSizeForText:self.incident.errors forWidth:theTableView.contentSize.width].height
			: 0;
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
	else if (indexPath.section == TableSectionLocation) {
		self.mapViewController.locationName = self.incident.location;
		self.mapViewController.locationLatitude = self.incident.latitude;
		self.mapViewController.locationLongitude = self.incident.longitude;
		[self.navigationController pushViewController:self.mapViewController animated:YES];
	}
	else if (indexPath.section == TableSectionPhotos) {
		if ([self.incident.photos count] > 0) {
			self.imageViewController.image = [((ImageTableCell *)cell) getImage];
			[self.navigationController pushViewController:self.imageViewController animated:YES];
		}
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
