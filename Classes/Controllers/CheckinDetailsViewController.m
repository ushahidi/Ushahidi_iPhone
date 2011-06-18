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

#import "CheckinDetailsViewController.h"
#import "TwitterViewController.h"
#import "ImageViewController.h"
#import "MapViewController.h"
#import "TableCellFactory.h"
#import "UIColor+Extension.h"
#import "MapTableCell.h"
#import "ImageTableCell.h"
#import "TextTableCell.h"
#import "Photo.h"
#import "Checkin.h"
#import "Ushahidi.h"
#import "Incident.h"
#import "Device.h"
#import "Settings.h"
#import "NSString+Extension.h"

@interface CheckinDetailsViewController()

@end

@implementation CheckinDetailsViewController

@synthesize checkin, checkins;

#pragma mark -
#pragma mark Enums

typedef enum {
	TableSectionName,
	TableSectionMessage,
	TableSectionDate,
	TableSectionLocation,
	TableSectionPhotos
} TableSection;

typedef enum {
	TableRowLocationLink,
	TableRowLocationMap
} TableRowLocation;

#pragma mark -
#pragma mark Handlers

- (IBAction) nextPrevious:(id)sender {
	NSInteger index = [self.checkins indexOfObject:self.checkin];
	if (self.nextPrevious.selectedSegmentIndex == NavBarNext) {
		DLog(@"Next");
		self.checkin = [self.checkins objectAtIndex:index + 1];
	}
	else if (self.nextPrevious.selectedSegmentIndex == NavBarPrevious) {
		DLog(@"Previous");
		self.checkin = [self.checkins objectAtIndex:index - 1];
	}
	[[Settings sharedSettings] setLastIncident:self.checkin.identifier];
	NSInteger newIndex = [self.checkins indexOfObject:self.checkin];
	self.title = [NSString stringWithFormat:@"%d / %d", newIndex + 1, [self.checkins count]];
	[self.nextPrevious setEnabled:(newIndex > 0) forSegmentAtIndex:NavBarPrevious];
	[self.nextPrevious setEnabled:(newIndex + 1 < [self.checkins count]) forSegmentAtIndex:NavBarNext];
	[self.tableView reloadData];
	[self.tableView flashScrollIndicators];
	[self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (IBAction) sendTweet:(id)sender {
	DLog(@"");
	NSMutableString *message = [NSMutableString string];
	if ([NSString isNilOrEmpty:self.checkin.message] == NO) {
		[message appendFormat:@"\"%@\"", self.checkin.message];
	}
	if ([NSString isNilOrEmpty:self.checkin.name] == NO) {
		if ([message length] > 0) {
			[message appendFormat:@" - %@", self.checkin.name];
		}
		else {
			[message appendFormat:@"%@", self.checkin.name];
		}
	}
	if ([message length] > 0) {
		[message appendFormat:@" http://maps.google.com/maps?q=%@,%@", self.checkin.latitude, self.checkin.longitude];
	}
	else {
		[message appendFormat:@"http://maps.google.com/maps?q=%@,%@", self.checkin.latitude, self.checkin.longitude];
	}
	if ([self.checkin hasPhotos]) {
		Photo *photo = [self.checkin firstPhoto];
		if ([message length] > 0) {
			[message appendFormat:@" %@", photo.url];
		}
		else {
			[message appendFormat:@"%@", photo.url];
		}
	}
	self.twitterViewController.tweet = message;
	[self presentModalViewController:self.twitterViewController animated:YES];
}

- (IBAction) sendSMS:(id)sender {
	DLog(@"");
	NSMutableString *message = [NSMutableString string];
	if ([NSString isNilOrEmpty:self.checkin.message] == NO) {
		[message appendFormat:@"\"%@\"", self.checkin.message];
	}
	if ([NSString isNilOrEmpty:self.checkin.name] == NO) {
		if ([message length] > 0) {
			[message appendFormat:@" - %@", self.checkin.name];
		}
		else {
			[message appendFormat:@"%@", self.checkin.name];
		}
	}
	if ([message length] > 0) {
		[message appendFormat:@" http://maps.google.com/maps?q=%@,%@", self.checkin.latitude, self.checkin.longitude];
	}
	else {
		[message appendFormat:@"http://maps.google.com/maps?q=%@,%@", self.checkin.latitude, self.checkin.longitude];
	}
	if ([self.checkin hasPhotos]) {
		Photo *photo = [self.checkin firstPhoto];
		if ([message length] > 0) {
			[message appendFormat:@" %@", photo.url];
		}
		else {
			[message appendFormat:@"%@", photo.url];
		}
	}
	[self.sms sendToRecipients:nil 
				   withMessage:message];
}

- (IBAction) sendEmail:(id)sender {
	DLog(@"");
	NSMutableString *subject = [NSMutableString string];
	NSMutableString *message = [NSMutableString string];
	if ([NSString isNilOrEmpty:self.checkin.message] == NO) {
		[subject appendFormat:@"\"%@\"", self.checkin.message];
		[message appendFormat:@"\"%@\"", self.checkin.message];
	}
	if ([NSString isNilOrEmpty:self.checkin.name] == NO) {
		if ([message length] > 0) {
			[subject appendFormat:@" - %@", self.checkin.name];
			[message appendFormat:@" - %@", self.checkin.name];
		}
		else {
			[subject appendFormat:@"%@", self.checkin.name];
			[message appendFormat:@"%@", self.checkin.name];
		}
	}
	if (self.checkin.date != nil) {
		if ([message length] > 0) {
			[message appendFormat:@", %@", self.checkin.dateTimeString];
		}
		else {
			[message appendFormat:@"%@", self.checkin.dateTimeString];
		}
	}
	NSString *mapURL = [NSString stringWithFormat:@"<br/>http://maps.google.com/maps?q=%@,%@", self.checkin.latitude, self.checkin.longitude];
	[message appendFormat:@"<br/><a href=\"%@\" title=\"%@\">%@</>", mapURL, mapURL, mapURL];
	NSMutableArray *photos = [NSMutableArray array];
	if (self.checkin.map != nil) {
		[photos addObject:self.checkin.map];
	}
	else {
		@try {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:TableRowLocationMap inSection:TableSectionLocation]; 
			MapTableCell *mapCell = (MapTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
			MKMapView *mapView = mapCell.mapView;
			UIGraphicsBeginImageContext(mapView.bounds.size);
			[mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
			UIImage *mapImage = UIGraphicsGetImageFromCurrentImageContext();
			if (mapImage != nil) {
				[photos addObject:mapImage];
			}
			UIGraphicsEndImageContext();
		}
		@catch (NSException *e) {
			DLog(@"%@", e);
		}
	}
	if ([self.checkin.photos count] > 0) {
		[photos addObjectsFromArray:self.checkin.photoImages];
	}
	[self.email sendToRecipients:nil 
					 withMessage:message 
					 withSubject:subject 
					  withPhotos:photos];
}

#pragma mark -
#pragma mark UIViewController

- (void) viewDidLoad {
	[super viewDidLoad];
	[self setBackButtonTitle:NSLocalizedString(@"Checkin", nil)];
	[self setHeader:NSLocalizedString(@"Name", nil) atSection:TableSectionName];
	[self setHeader:NSLocalizedString(@"Date", nil) atSection:TableSectionDate];
	[self setHeader:NSLocalizedString(@"Message", nil) atSection:TableSectionMessage];
	[self setHeader:NSLocalizedString(@"Location", nil) atSection:TableSectionLocation];
	[self setHeader:NSLocalizedString(@"Photos", nil) atSection:TableSectionPhotos];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	NSInteger index = [self.checkins indexOfObject:self.checkin];
	self.title = [NSString stringWithFormat:@"%d / %d", index + 1, [self.checkins count]];
	[self.nextPrevious setEnabled:index > 0 forSegmentAtIndex:NavBarPrevious];
	[self.nextPrevious setEnabled:index + 1 < [self.checkins count] forSegmentAtIndex:NavBarNext];
	if (self.willBePushed) {
		[self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
	}
	[self.tableView reloadData];	
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.alertView showInfoOnceOnly:NSLocalizedString(@"Click the Up and Down arrows to move through checkins, click the Location to view a larger map or tap a Photo to view it full screen.", nil)];
}

- (void)dealloc {
	[checkins release];
	[checkin release];
	[super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 5;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (section == TableSectionPhotos && self.checkin.hasPhotos) {
		return [self.checkin.photos count];
	}
	if (section == TableSectionLocation && self.checkin.hasLocation) {
		return 2;
	}
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionName) {
		TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView indexPath:indexPath];
		if (self.checkin.hasName) {
			[cell setText:self.checkin.name];
		}
		else {
			[cell setText:NSLocalizedString(@"Not Specified", nil)];
		}
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
	else if (indexPath.section == TableSectionDate) {
		TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView indexPath:indexPath];
		if (self.checkin.hasDate) {
			[cell setText:self.checkin.dateTimeString];
		}
		else {
			[cell setText:NSLocalizedString(@"Not Specified", nil)];
		}
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
	else if (indexPath.section == TableSectionMessage) {
		TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView indexPath:indexPath];
		if (self.checkin.hasMessage) {
			[cell setText:self.checkin.message];
		}
		else {
			[cell setText:NSLocalizedString(@"Not Specified", nil)];
		}
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
	else if (indexPath.section == TableSectionLocation) {
		if (self.checkin.hasLocation) {
			if (indexPath.row == TableRowLocationLink) {
				TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView indexPath:indexPath];
				[cell setText:[NSString stringWithFormat:@"%@, %@", self.checkin.latitude, self.checkin.longitude]];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = UITableViewCellSelectionStyleGray;
				return cell;
			}
			else if (indexPath.row == TableRowLocationMap) {
				MapTableCell *cell = [TableCellFactory getMapTableCellForDelegate:self table:theTableView indexPath:indexPath];
				[cell setScrollable:YES];
				[cell setZoomable:YES];
				[cell setCanShowCallout:YES];
				NSString *location = [NSString stringWithFormat:@"%@, %@", self.checkin.latitude, self.checkin.longitude];
				if ([location isEqualToString:cell.location] == NO) {
					[cell removeAllPins];
					[cell addPinWithTitle:self.checkin.message 
								 subtitle:self.checkin.dateTimeString
								 latitude:self.checkin.latitude 
								longitude:self.checkin.longitude];
					[cell resizeRegionToFitAllPins:NO];		
					cell.location = location;
				}
				return cell;	
			}
		}
		else {
			TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView indexPath:indexPath];
			[cell setText:NSLocalizedString(@"Not Specified", nil)];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
		}
	}
	else if (indexPath.section == TableSectionPhotos) {
		if (self.checkin.hasPhotos) {
			ImageTableCell *cell = [TableCellFactory getImageTableCellWithImage:nil table:theTableView indexPath:indexPath];
			Photo *photo = [self.checkin.photos objectAtIndex:indexPath.row];
			if (photo != nil) {
				photo.indexPath = indexPath;
				if (photo.image != nil) {
					[cell setImage:photo.image];
				}
				else {
					[cell setImage:nil];
					[[Ushahidi sharedUshahidi] downloadPhoto:photo forCheckin:checkin forDelegate:self];
				}
			}
			else {
				[cell setImage:nil];
			}
			return cell;	
		}
		else {
			TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView indexPath:indexPath];
			[cell setText:NSLocalizedString(@"No Photos", nil)];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
		}
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionPhotos) {
		if (self.checkin.hasPhotos) {
			Photo *photo = [self.checkin.photos objectAtIndex:indexPath.row];
			if (photo != nil && photo.image != nil) {
				return theTableView.frame.size.width * photo.image.size.height / photo.image.size.width;
			}
			return 200;	
		}
	}
	else if (indexPath.section == TableSectionLocation) {
		if (indexPath.row == TableRowLocationMap && self.checkin.hasLocation) {
			return [Device isIPad] ? 300 : 150;
		}
	}
	else if (indexPath.section == TableSectionName) {
		return [TextTableCell getCellSizeForText:self.checkin.user forWidth:theTableView.contentSize.width].height;
	}
	else if (indexPath.section == TableSectionDate) {
		return [TextTableCell getCellSizeForText:self.checkin.dateString forWidth:theTableView.contentSize.width].height;
	}
	else if (indexPath.section == TableSectionMessage) {
		return [TextTableCell getCellSizeForText:self.checkin.message forWidth:theTableView.contentSize.width].height;
	}
	return 45;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DLog(@"didSelectRowAtIndexPath:[%d, %d]", indexPath.section, indexPath.row);
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	UITableViewCell *cell = [theTableView cellForRowAtIndexPath:indexPath];
	if (indexPath.section == TableSectionPhotos) {
		if ([self.checkin.photos count] > 0 && [((ImageTableCell *)cell) hasImage]) {
			self.imageViewController.title = NSLocalizedString(@"Image", nil);
			self.imageViewController.image = [((ImageTableCell *)cell) getImage];
			self.imageViewController.images = self.checkin.photoImages;
			[self.navigationController pushViewController:self.imageViewController animated:YES];
		}
	}
	else if (indexPath.section == TableSectionLocation && indexPath.row == TableRowLocationLink) {
		if (self.checkin.hasMessage && self.checkin.hasName && self.checkin.hasDate) {
			self.mapViewController.locationName = self.checkin.message;
			self.mapViewController.locationDetails = [NSString stringWithFormat:@"%@ - %@", self.checkin.name, self.checkin.dateTimeString];
		}
		else if (self.checkin.hasMessage && self.checkin.hasName) {
			self.mapViewController.locationName = self.checkin.message;
			self.mapViewController.locationDetails = self.checkin.name;
		}
		else if (self.checkin.hasMessage && self.checkin.hasDate) {
			self.mapViewController.locationName = self.checkin.message;
			self.mapViewController.locationDetails = self.checkin.dateTimeString;
		}
		else if (self.checkin.hasName && self.checkin.hasDate) {
			self.mapViewController.locationName = self.checkin.name;
			self.mapViewController.locationDetails = self.checkin.dateTimeString;
		}
		else if (self.checkin.hasMessage) {
			self.mapViewController.locationName = self.checkin.message;
			self.mapViewController.locationDetails = nil;
		}
		else if (self.checkin.hasName) {
			self.mapViewController.locationName = self.checkin.name;
			self.mapViewController.locationDetails = nil;
		}
		else if (self.checkin.hasDate) {
			self.mapViewController.locationName = self.checkin.dateTimeString;
			self.mapViewController.locationDetails = nil;
		}
		else {
			self.mapViewController.locationName = nil;
			self.mapViewController.locationDetails = nil;
		}
		self.mapViewController.locationLatitude = self.checkin.latitude;
		self.mapViewController.locationLongitude = self.checkin.longitude;
		[self.navigationController pushViewController:self.mapViewController animated:YES];	
	}
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi photo:(Photo *)photo checkin:(Checkin *)checkin {
	DLog(@"downloadedFromUshahidi: %@", [photo url]);
	if (photo != nil && photo.indexPath != nil) {
		ImageTableCell *cell = (ImageTableCell *)[self.tableView cellForRowAtIndexPath:photo.indexPath];
		if (cell != nil) {
			[cell setImage:photo.image];
		}
		else {
			[self.tableView reloadData];
		}
	}
}

@end