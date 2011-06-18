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

#import "IncidentDetailsViewController.h"
#import "WebViewController.h"
#import "MapViewController.h"
#import "ImageViewController.h"
#import "NewsViewController.h"
#import "TableCellFactory.h"
#import "SubtitleTableCell.h"
#import "ImageTableCell.h"
#import "LoadingViewController.h"
#import "TwitterViewController.h"
#import "AlertView.h"
#import "InputView.h"
#import "Incident.h"
#import "Photo.h"
#import "Location.h"
#import "UIColor+Extension.h"
#import "TableHeaderView.h"
#import "Email.h"
#import "Deployment.h"
#import "News.h"
#import "Video.h"
#import "NSString+Extension.h"
#import "MoviePlayer.h"
#import "SMS.h"
#import "Bitly.h"
#import "Settings.h"
#import "Ushahidi.h"
#import "Device.h"

@interface IncidentDetailsViewController ()

@end

@implementation IncidentDetailsViewController

#define kBitlyLogin		@"BitlyLogin"
#define kBitlyApiKey	@"BitlyApiKey"

@synthesize incident, incidents;

#pragma mark -
#pragma mark Enums

typedef enum {
	TableSectionErrors,
	TableSectionTitle,
	TableSectionVerified,
	TableSectionDescription,
	TableSectionCategory,
	TableSectionDateTime,
	TableSectionLocation,
	TableSectionPhotos,
	TableSectionNews,
	TableSectionVideo
} TableSection;

#pragma mark -
#pragma mark Handlers

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
	[[Settings sharedSettings] setLastIncident:self.incident.identifier];
	NSInteger newIndex = [self.incidents indexOfObject:self.incident];
	self.title = [NSString stringWithFormat:@"%d / %d", newIndex + 1, [self.incidents count]];
	[self.nextPrevious setEnabled:(newIndex > 0) forSegmentAtIndex:NavBarPrevious];
	[self.nextPrevious setEnabled:(newIndex + 1 < [self.incidents count]) forSegmentAtIndex:NavBarNext];
	[self.tableView reloadData];
	[self.tableView flashScrollIndicators];
	[self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (IBAction) sendTweet:(id)sender {
	DLog(@"");
	NSMutableString *message = [NSMutableString string];
	if ([self.incident hasURL]) {
		NSURL *link = [[Ushahidi sharedUshahidi] getUrlForIncident:self.incident];
		[message appendFormat:@"%@, %@ %@", [[Ushahidi sharedUshahidi] deploymentName], self.incident.title, [link absoluteString]];
	}
	else {
		[message appendFormat:@"%@, %@", [[Ushahidi sharedUshahidi] deploymentName], self.incident.title];
	}
	self.twitterViewController.tweet = message;
	[self presentModalViewController:self.twitterViewController animated:YES];
}

- (IBAction) sendSMS:(id)sender {
	DLog(@"");
	NSMutableString *message = [NSMutableString string];
	if ([self.incident hasURL]) {
		NSURL *link = [[Ushahidi sharedUshahidi] getUrlForIncident:self.incident];
		[message appendFormat:@"%@, %@ %@", [[Ushahidi sharedUshahidi] deploymentName], self.incident.title, [link absoluteString]];
	}
	else {
		[message appendFormat:@"%@, %@", [[Ushahidi sharedUshahidi] deploymentName], self.incident.title];
	}
	[self.sms sendToRecipients:nil 
				   withMessage:message];
}

- (IBAction) sendEmail:(id)sender {
	DLog(@"");
	NSMutableString *message = [NSMutableString string];
	if ([self.incident hasURL]) {
		NSURL *link = [[Ushahidi sharedUshahidi] getUrlForIncident:self.incident];
		[message appendFormat:@"<b>%@</b>: <a href=\"%@\">%@</a><br/>", NSLocalizedString(@"Title", nil), [link absoluteString], self.incident.title];
	}
	else {
		[message appendFormat:@"<b>%@</b>: %@<br/>", NSLocalizedString(@"Title", nil), self.incident.title];
	}
	[message appendFormat:@"<b>%@</b>: %@<br/>", NSLocalizedString(@"Date", nil), self.incident.dateTimeString];
	if ([NSString isNilOrEmpty:self.incident.latitude] == NO && [NSString isNilOrEmpty:self.incident.longitude] == NO) {
		DLog(@"http://maps.google.com/maps?q=%@,%@(%@)", self.incident.latitude, self.incident.longitude, self.incident.location);
		NSString *locationURL = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@(%@)", self.incident.latitude, self.incident.longitude, self.incident.location];
		[message appendFormat:@"<b>%@</b>: <a href=\"%@\">%@</a><br/>", NSLocalizedString(@"Location", nil), locationURL, self.incident.location];
	}
	else {
		[message appendFormat:@"<b>%@</b>: %@<br/>", NSLocalizedString(@"Location", nil), self.incident.location];
	}
	[message appendFormat:@"<b>%@</b>: %@<br/>", NSLocalizedString(@"Category", nil), self.incident.categoryNames];
	[message appendFormat:@"<b>%@</b>: %@<br/>", NSLocalizedString(@"Description", nil), self.incident.description];
	if (self.incident.news != nil && [self.incident.news count] > 0) {
		[message appendFormat:@"<b>%@</b>:<ul>", NSLocalizedString(@"News", nil)];
		for (News *news in self.incident.news) {
			[message appendFormat:@"<li><a href=\"%@\">%@</a></li>", news.url, news.url];
		}
		[message appendFormat:@"</ul>"];
	}
	NSMutableArray *photos = [NSMutableArray array];
	if (self.incident.map != nil) {
		[photos addObject:self.incident.map];
	}
	if ([self.incident.photos count] > 0) {
		[photos addObjectsFromArray:self.incident.photoImages];
	}
	[self.email sendToRecipients:nil 
					 withMessage:message 
					 withSubject:self.incident.title 
					  withPhotos:photos];
}

#pragma mark -
#pragma mark UIViewController

- (void) viewDidLoad {
	[super viewDidLoad];
	[self setHeader:NSLocalizedString(@"Errors", nil) atSection:TableSectionErrors];
	[self setHeader:NSLocalizedString(@"Title", nil) atSection:TableSectionTitle];
	[self setHeader:NSLocalizedString(@"Verified", nil) atSection:TableSectionVerified];
	[self setHeader:NSLocalizedString(@"Description", nil) atSection:TableSectionDescription];
	[self setHeader:NSLocalizedString(@"Category", nil) atSection:TableSectionCategory];
	[self setHeader:NSLocalizedString(@"Date", nil) atSection:TableSectionDateTime];
	[self setHeader:NSLocalizedString(@"Location", nil) atSection:TableSectionLocation];
	[self setHeader:NSLocalizedString(@"Photos", nil) atSection:TableSectionPhotos];
	[self setHeader:NSLocalizedString(@"News", nil) atSection:TableSectionNews];
	[self setHeader:NSLocalizedString(@"Video", nil) atSection:TableSectionVideo];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	NSInteger index = [self.incidents indexOfObject:self.incident];
	self.title = [NSString stringWithFormat:@"%d / %d", index + 1, [self.incidents count]];
	[self.nextPrevious setEnabled:index > 0 forSegmentAtIndex:NavBarPrevious];
	[self.nextPrevious setEnabled:index + 1 < [self.incidents count] forSegmentAtIndex:NavBarNext];
	if (self.willBePushed) {
		[self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
	}
	[self.tableView reloadData];	
	[[Settings sharedSettings] setLastIncident:self.incident.identifier];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.alertView showInfoOnceOnly:NSLocalizedString(@"Click the Up and Down arrows to move through reports, the SMS button to send the report URL, the Tweet button to share on Twitter or the Email button to send the report details.", nil)];
}

- (void)dealloc {
	[incident release];
	[incidents release];
	[super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 10;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForHeaderInSection:(NSInteger)section {
	if (section == TableSectionErrors) {
		return [NSString isNilOrEmpty:self.incident.errors] ? 0 : [TableHeaderView getViewHeight];
	}
	return [TableHeaderView getViewHeight];
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (section == TableSectionErrors) {
		return [NSString isNilOrEmpty:self.incident.errors] ? 0 : 1;
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
	if (indexPath.section == TableSectionLocation && indexPath.row == 1) {
		if (self.incident.map != nil) {
			ImageTableCell *cell = [TableCellFactory getImageTableCellWithImage:nil table:theTableView indexPath:indexPath];
			[cell setImage:self.incident.map];
			return cell;
		}
		else {
			MapTableCell *cell = [TableCellFactory getMapTableCellForDelegate:self table:theTableView indexPath:indexPath];
			[cell setScrollable:NO];
			[cell setZoomable:NO];
			[cell setCanShowCallout:YES];
			NSString *subtitle = [NSString stringWithFormat:@"%@, %@", self.incident.latitude, self.incident.longitude];
			if ([subtitle isEqualToString:cell.location] == NO) {
				[cell removeAllPins];
				[cell addPinWithTitle:self.incident.location 
							 subtitle:subtitle
							 latitude:self.incident.latitude 
							longitude:self.incident.longitude];
				[cell resizeRegionToFitAllPins:NO];		
				cell.location = subtitle;
			}
			return cell;
		}
	}
	else if (indexPath.section == TableSectionPhotos && [self.incident.photos count] > 0) {
		ImageTableCell *cell = [TableCellFactory getImageTableCellWithImage:nil table:theTableView indexPath:indexPath];
		Photo *photo = [self.incident.photos objectAtIndex:indexPath.row];
		if (photo != nil) {
			if (photo.image != nil) {
				[cell setImage:photo.image];
			}
			else {
				[cell setImage:nil];
				photo.indexPath = indexPath;
				[[Ushahidi sharedUshahidi] downloadPhoto:photo forIncident:self.incident forDelegate:self];
			}
		}
		else {
			[cell setImage:nil];
		}
		return cell;
	}
	else if (indexPath.section == TableSectionNews && [self.incident.news count] > 0) {
		SubtitleTableCell *cell = [TableCellFactory getSubtitleTableCellWithForTable:theTableView indexPath:indexPath];
		News *news = [self.incident.news objectAtIndex:indexPath.row];
		if (news != nil) {
			if ([NSString isNilOrEmpty:news.title] == NO) {
				[cell setText:news.title];	
			}
			else {
				[cell setText:news.url];
			}
			[cell setDescription:news.url];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
		}
		else {
			[cell setText:@""];	
			[cell setDescription:@""];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		return cell;
	}
	else if (indexPath.section == TableSectionVideo && [self.incident.videos count] > 0) {
		SubtitleTableCell *cell = [TableCellFactory getSubtitleTableCellWithForTable:theTableView indexPath:indexPath];
		Video *video = [self.incident.videos objectAtIndex:indexPath.row];
		if (video != nil) {
			if ([NSString isNilOrEmpty:video.title] == NO) {
				[cell setText:video.title];	
			}
			else {
				[cell setText:video.url];
			}
			[cell setDescription:video.url];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
		}
		else {
			[cell setText:@""];	
			[cell setDescription:@""];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		return cell;
	}
	else {
		TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView indexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		if (indexPath.section == TableSectionTitle) {
			cell.textLabel.text = self.incident.title;
		}
		if (indexPath.section == TableSectionDescription) {
			cell.textLabel.text = self.incident.description;
		}
		else if (indexPath.section == TableSectionCategory) {
			cell.textLabel.text = [self.incident categoryNamesWithDefaultText:NSLocalizedString(@"No Category Specified", nil)];
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
			cell.textLabel.text = NSLocalizedString(@"No Photos", nil);
		}
		else if (indexPath.section == TableSectionNews) {
			cell.textLabel.text = NSLocalizedString(@"No News", nil);
		}
		else if (indexPath.section == TableSectionVideo) {
			cell.textLabel.text = NSLocalizedString(@"No Video", nil);
		}
		else if (indexPath.section == TableSectionVerified) {
			cell.textLabel.text = self.incident.verified ? NSLocalizedString(@"Yes", nil) : NSLocalizedString(@"No", nil);
		}
		return cell;	
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionLocation) {
		if (indexPath.row == 0) {
			return [TextTableCell getCellSizeForText:self.incident.location forWidth:theTableView.contentSize.width].height;
		}
		if (self.incident.map != nil) {
			return self.incident.map.size.height;
		}
		return [Device isIPad] ? 225 : 150;
	}
	else if (indexPath.section == TableSectionPhotos) {
		if ([self.incident.photos count] > 0) {
			Photo *photo = [self.incident.photos objectAtIndex:indexPath.row];
			if (photo != nil && photo.image != nil) {
				return self.tableView.frame.size.width * photo.image.size.height / photo.image.size.width;
			}
			return 200;
		}
		return [TextTableCell getCellSizeForText:NSLocalizedString(@"No Photos", nil) forWidth:theTableView.contentSize.width].height;
	}
	else if (indexPath.section == TableSectionNews) {
		if ([self.incident.news count] > 0) {
			return [SubtitleTableCell getCellHeight];
		}
		return [TextTableCell getCellSizeForText:NSLocalizedString(@"No News", nil) forWidth:theTableView.contentSize.width].height;
	}
	else if (indexPath.section == TableSectionVideo) {
		if ([self.incident.videos count] > 0) {
			return [SubtitleTableCell getCellHeight];
		}
		return [TextTableCell getCellSizeForText:NSLocalizedString(@"No Video", nil) forWidth:theTableView.contentSize.width].height;
	}
	else if (indexPath.section == TableSectionTitle) {
		return [TextTableCell getCellSizeForText:self.incident.title forWidth:theTableView.contentSize.width].height;
	}
	else if (indexPath.section == TableSectionVerified) {
		NSString *verifiedText = self.incident.verified ? NSLocalizedString(@"Yes", nil) : NSLocalizedString(@"No", nil);
		return [TextTableCell getCellSizeForText:verifiedText forWidth:theTableView.contentSize.width].height;
	}
	else if (indexPath.section == TableSectionDescription) {
		return [TextTableCell getCellSizeForText:self.incident.description forWidth:theTableView.contentSize.width].height;
	}
	else if (indexPath.section == TableSectionCategory) {
		return [TextTableCell getCellSizeForText:[self.incident categoryNamesWithDefaultText:NSLocalizedString(@"No Category Specified", nil)] forWidth:theTableView.contentSize.width].height;
	}
	else if (indexPath.section == TableSectionDateTime) {
		return [TextTableCell getCellSizeForText:[self.incident dateTimeString] forWidth:theTableView.contentSize.width].height;
	}
	else if (indexPath.section == TableSectionErrors) {
		return [NSString isNilOrEmpty:self.incident.errors] 
			? 0 : [TextTableCell getCellSizeForText:self.incident.errors forWidth:theTableView.contentSize.width].height;
	}
	return 45;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DLog(@"didSelectRowAtIndexPath:[%d, %d]", indexPath.section, indexPath.row);
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	UITableViewCell *cell = [theTableView cellForRowAtIndexPath:indexPath];
	if (indexPath.section == TableSectionNews) {
		if ([self.incident.news count] > 0) {
			self.newsViewController.website = [((SubtitleTableCell *)cell) getDescription];
			[self.navigationController pushViewController:self.newsViewController animated:YES];
		}
	}
	else if (indexPath.section == TableSectionLocation) {
		if (indexPath.row == 1 && self.incident.map != nil) {
			self.imageViewController.title = self.incident.location;
			self.imageViewController.image = self.incident.map;
			self.imageViewController.images = nil;
			self.imageViewController.pending = [self.incident hasURL] == NO;
			[self.navigationController pushViewController:self.imageViewController animated:YES];
		}
		else {
			self.mapViewController.locationName = self.incident.location;
			self.mapViewController.locationLatitude = self.incident.latitude;
			self.mapViewController.locationLongitude = self.incident.longitude;
			[self.navigationController pushViewController:self.mapViewController animated:YES];	
		}
	}
	else if (indexPath.section == TableSectionPhotos) {
		if ([self.incident.photos count] > 0 && [((ImageTableCell *)cell) hasImage]) {
			self.imageViewController.title = NSLocalizedString(@"Image", nil);
			self.imageViewController.image = [((ImageTableCell *)cell) getImage];
			self.imageViewController.images = self.incident.photoImages;
			[self.navigationController pushViewController:self.imageViewController animated:YES];
		}
	}
	else if (indexPath.section == TableSectionVideo) {
		if ([self.incident.videos count] > 0) {
			Video *video = [self.incident.videos objectAtIndex:indexPath.row];
			self.newsViewController.website = video.url;
			[self.navigationController pushViewController:self.newsViewController animated:YES];
		}
	}
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi photo:(Photo *)photo incident:(Incident *)theIncident {
	DLog(@"downloadedFromUshahidi: %@", [photo url]);
	if (photo != nil) {
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
