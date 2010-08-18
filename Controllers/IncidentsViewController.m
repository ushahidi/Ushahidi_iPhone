    //
//  IncidentsViewController.m
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-09.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import "IncidentsViewController.h"
#import "AddIncidentViewController.h"
#import "ViewIncidentViewController.h"
#import "SubtitleTableCell.h"
#import "TableCellFactory.h"

typedef enum {
	TableSectionSearch,
	TableSectionIncidents
} TableSection;

typedef enum {
	ViewTypeReports,
	ViewTypeMap
} ViewType;

@interface IncidentsViewController (Internal)

@end

@implementation IncidentsViewController

@synthesize addIncidentViewController, viewIncidentViewController, mapView;

#pragma mark -
#pragma mark Handlers

- (IBAction) action:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
															 delegate:self 
													cancelButtonTitle: @"Cancel" 
											   destructiveButtonTitle:nil
													otherButtonTitles:nil];
	[actionSheet setActionSheetStyle:UIBarStyleBlackTranslucent];
	[actionSheet showInView:[self view]];
	[actionSheet release];
}

- (IBAction) add:(id)sender {
	DLog(@"add");
	[self presentModalViewController:self.addIncidentViewController animated:YES];
}

- (IBAction) refresh:(id)sender {
	DLog(@"refresh");
}

- (IBAction) toggleReportsAndMap:(id)sender {
	DLog(@"toggleReportsAndMap");
	UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
	if (segmentControl.selectedSegmentIndex == ViewTypeReports) {
		self.tableView.hidden = NO;
		self.mapView.hidden = YES;
	}
	else if (segmentControl.selectedSegmentIndex == ViewTypeMap) {
		self.tableView.hidden = YES;
		self.mapView.hidden = NO;
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
	return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
	[addIncidentViewController release];
	[viewIncidentViewController release];
	[mapView release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (section == TableSectionSearch) {
		return 1;
	}
	if (section == TableSectionIncidents) {
		return 20;
	}
	return 0;}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionSearch) {
		SearchTableCell *cell = [TableCellFactory getSearchTableCellWithDelegate:self table:theTableView];
		[cell setPlaceholder:@"Search incidents..."];
		return cell;
	}
	else if (indexPath.section == TableSectionIncidents) {
		SubtitleTableCell *cell = [TableCellFactory getSubtitleTableCellWithDefaultImage:[UIImage imageNamed:@"no_image.png"] table:theTableView];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		[cell setText:[NSString stringWithFormat:@"Demo Report %d", indexPath.row]];
		[cell setDescription:@"Mumbai Pune Bypass Rd, Haiti - May 26 2010"];
		return cell;
	}
	return nil;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	[self.navigationController pushViewController:self.viewIncidentViewController animated:YES];
}

- (void)tableView:(UITableView *)theTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.backgroundColor = (indexPath.row % 2) ? [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1] : [UIColor clearColor];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *titleAtIndex = [actionSheet buttonTitleAtIndex:buttonIndex];
	DLog(@"titleAtIndex: %@", titleAtIndex);
}

#pragma mark -
#pragma mark UISearchCellDelegate

- (void) searchCellChanged:(SearchTableCell *)cell searchText:(NSString *)text {
	DLog(@"searchCellChanged: %@", text);
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapViewWillStartLoadingMap:(MKMapView *)theMapView {
	DLog(@"");
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)theMapView {
	DLog(@"");
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)theMapView withError:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
}

@end
