    //
//  ViewIncidentViewController.m
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-09.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import "ViewIncidentViewController.h"
#import "WebViewController.h"
#import "MapViewController.h"
#import "ImageViewController.h"
#import "TableCellFactory.h"
#import "SubtitleTableCell.h"
#import "ImageTableCell.h"

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
	NavBarNext,
	NavBarPrevious
} NavBar;

@interface ViewIncidentViewController (Internal)

- (NSString *) getIncidentDescription;

@end

@implementation ViewIncidentViewController

@synthesize webViewController, mapViewController, imageViewController, nextPrevious;

- (NSString *) getIncidentDescription {
	return [NSString stringWithFormat:@"%@%@%@%@%@", 
			@"I am writing to inform you that the following homeless family members need help urgently in the Carrefour-Feuilles neighbourhood.\n\n",
			@"Their homes got destroyed by the killer earthquake of January 12, 2010, and they haven't received any assistance yet!\n\n", 
			@"I haven't been able to reach them yet, in order to provide them with your phone numbers.\n\n", 
			@"They all gather together, day and night, in the neighbourhood of Barrière-Jour, Avenue N prolongée, two blocks over the Hotel Le Prince.\n\n", 
			@"The situation there is awful. Some of them have babies that are very vulnerable with them."];
}

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
	if (self.nextPrevious.selectedSegmentIndex == NavBarNext) {
		DLog(@"Next");
	}
	else if (self.nextPrevious.selectedSegmentIndex == NavBarPrevious) {
		DLog(@"Previous");
	}
}

#pragma mark -
#pragma mark UIViewController

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
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
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
	[webViewController release];
	[mapViewController release];
	[imageViewController release];
	[nextPrevious release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 7;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (section == TableSectionNews) {
		return 3;
	}
	if (section == TableSectionLocation) {
		return 2;
	}
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionDescription) {
		TextTableCell *cell = [TableCellFactory getTextTableCellWithDelegate:self table:theTableView];
		[cell setText:[self getIncidentDescription]];
		return cell;
	}
	else if (indexPath.section == TableSectionNews) {
		SubtitleTableCell *cell = [TableCellFactory getSubtitleTableCellWithDefaultImage:[UIImage imageNamed:@"no_image.png"] table:theTableView];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		if (indexPath.row == 0) {
			[cell setText:@"Safer sex drives HIV rates down"];
			[cell setDescription:@"http://www.nation.co.ke/News/world/Safer%20sex%20drives%20HIV%20rates%20down/-/1068/957250/-/h2mji1z/-/index.html"];
		}
		else if (indexPath.row == 1) {
			[cell setText:@"Bangkok tourists warned not to feed elephants"];
			[cell setDescription:@"http://www.nation.co.ke/News/world/Tourists%20warned%20not%20to%20feed%20elephants/-/1068/957258/-/x6yek8z/-/index.html"];
		}
		else if (indexPath.row == 2) {
			[cell setText:@"BP fits new cap to seal oil well"];
			[cell setDescription:@"http://www.nation.co.ke/News/world/BP%20fits%20new%20cap%20to%20seal%20oil%20well/-/1068/957248/-/11d2xowz/-/index.html"];
		}
		return cell;
	}
	else if (indexPath.section == TableSectionLocation && indexPath.row == 1) {
		MapTableCell *cell = [TableCellFactory getMapTableCellWithDelegate:self table:theTableView];
		[cell setScrollable:NO];
		[cell setZoomable:NO];
		return cell;
	}
	else if (indexPath.section == TableSectionPhotos) {
		ImageTableCell *cell = [TableCellFactory getImageTableCellWithImage:[UIImage imageNamed:@"demo_incident_image.jpg"] table:theTableView];
		return cell;
	}
	else {
		UITableViewCell *cell = [TableCellFactory getDefaultTableCellForTable:theTableView];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		if (indexPath.section == TableSectionTitle) {
			cell.textLabel.text = @"Food/Water/Supplies Needed";
		}
		else if (indexPath.section == TableSectionCategory) {
			cell.textLabel.text = @"Family, Food, Help";
		}
		else if (indexPath.section == TableSectionLocation) {
			cell.textLabel.text = @"Barrière-Jour, Avenue N prolongée, Carrefour-Feuilles";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
		}
		else if (indexPath.section == TableSectionDateTime) {
			cell.textLabel.text = @"February 3rd 2010, 7:34pm";
		}
		return cell;	
	}
}

- (NSString *)tableView:(UITableView *)theTableView titleForHeaderInSection:(NSInteger)section {
	if (section == TableSectionTitle) {
		return @"Title";
	}
	if (section == TableSectionCategory) {
		return @"Category";
	}
	if (section == TableSectionLocation) {
		return @"Location";
	}
	if (section == TableSectionDateTime) {
		return @"Date";
	}
	if (section == TableSectionDescription) {
		return @"Description";
	}
	if (section == TableSectionPhotos) {
		return @"Photos";
	}
	if (section == TableSectionNews) {
		return @"News";
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionDescription) {
		//TODO find better way to calculate cell content width for UITableViewStyleGrouped 
		CGFloat width = theTableView.contentSize.width - 20;
		CGSize tableCellSize = [TextTableCell getCellSizeForText:[self getIncidentDescription] forWidth:width];
		return tableCellSize.height;
	}
	else if (indexPath.section == TableSectionLocation && indexPath.row == 1) {
		return 120;
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
	if (indexPath.section == TableSectionNews) {
		self.webViewController.website = cell.detailTextLabel.text;
		[self.navigationController pushViewController:self.webViewController animated:YES];
	}
	else if (indexPath.section == TableSectionLocation && indexPath.row == 0) {
		self.mapViewController.address = cell.textLabel.text;
		[self.navigationController pushViewController:self.mapViewController animated:YES];
	}
	else if (indexPath.section == TableSectionPhotos) {
		self.imageViewController.image = [((ImageTableCell *)cell) getImage];
		[self.navigationController pushViewController:self.imageViewController animated:YES];
	}
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *titleAtIndex = [actionSheet buttonTitleAtIndex:buttonIndex];
	DLog(@"titleAtIndex: %@", titleAtIndex);
}

@end
