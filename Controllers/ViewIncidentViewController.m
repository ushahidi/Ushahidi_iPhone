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
#import "TableCellFactory.h"

typedef enum {
	TableSectionTitle,
	TableSectionCategory,
	TableSectionLocation,
	TableSectionDate,
	TableSectionTime,
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

@synthesize webViewController, mapViewController, nextPrevious;

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
													otherButtonTitles:@"Email Incident", @"Tweet Incident", @"Report Incident", nil];
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
	[nextPrevious release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 8;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (section == TableSectionNews) {
		return 3;
	}
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionDescription) {
		TextTableCell *cell = [TableCellFactory getTextTableCellFWithDelegate:self table:theTableView identifier:@"TextTableCell"];
		[cell setText:[self getIncidentDescription]];
		return cell;
	}
	else {
		UITableViewCell *cell = [TableCellFactory getDefaultTableCellForTable:theTableView identifier:@"UITableViewCell"];
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
		else if (indexPath.section == TableSectionDate) {
			cell.textLabel.text = @"Feb 3 2010";
		}
		else if (indexPath.section == TableSectionTime) {
			cell.textLabel.text = @"7:34pm";
		}
		else if (indexPath.section == TableSectionPhotos) {
			cell.textLabel.text = @"No Incident Photos";
		}
		else if (indexPath.section == TableSectionNews) {
			if (indexPath.row == 0) {
				cell.textLabel.text = @"http://www.ushahidi.com";
			}
			else if (indexPath.row == 1) {
				cell.textLabel.text = @"http://swift.ushahidi.com";
			}
			else if (indexPath.row == 2) {
				cell.textLabel.text = @"http://crowdmap.com";
			}
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
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
	if (section == TableSectionDate) {
		return @"Date";
	}
	if (section == TableSectionTime) {
		return @"Time";
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
	return 45;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DLog(@"didSelectRowAtIndexPath:[%d, %d]", indexPath.section, indexPath.row);
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	UITableViewCell *cell = [theTableView cellForRowAtIndexPath:indexPath];
	if (indexPath.section == TableSectionNews) {
		self.webViewController.website = cell.textLabel.text;
		[self.navigationController pushViewController:self.webViewController animated:YES];
	}
	else if (indexPath.section == TableSectionLocation) {
		self.mapViewController.address = cell.textLabel.text;
		[self.navigationController pushViewController:self.mapViewController animated:YES];
	}
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *titleAtIndex = [actionSheet buttonTitleAtIndex:buttonIndex];
	DLog(@"titleAtIndex: %@", titleAtIndex);
}

@end
