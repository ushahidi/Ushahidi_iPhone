/*****************************************************************************
 ** Copyright (c) 2012 Ushahidi Inc
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

#import "USHMapTableViewController.h"
#import "USHReportTabBarController.h"
#import "USHMapAddViewController.h"
#import "USHSettingsViewController.h"
#import "USHTableCellFactory.h"
#import "USHMapTableCell.h"
#import "USHTextTableCell.h"
#import <Ushahidi/UIAlertView+USH.h>
#import <Ushahidi/UIActionSheet+USH.h>
#import <Ushahidi/USHDevice.h>
#import <Ushahidi/UITableView+USH.h>
#import <Ushahidi/NSString+USH.h>
#import <UShahidi/USHRefreshButtonItem.h>
#import "USHSettings.h"
#import "USHAnalytics.h"

@interface USHMapTableViewController ()

@property (strong, nonatomic) NSString *mapName;
@property (strong, nonatomic) NSString *mapURL;
@property (strong, nonatomic) NSString *textByUrl;
@property (strong, nonatomic) NSString *textAroundMe;

- (USHMapTableCell*) cellForMap:(USHMap*)map;

- (void) loadFirstMapIfIPad;
- (void) initialSyncIfNeeded;

@end

@implementation USHMapTableViewController

typedef enum {
    TableSectionMaps,
    TableSections
} TableSection;

typedef enum {
    ActionSheetDefault,
    ActionSheetAddMap
} ActionSheetType;

typedef enum {
    AlertViewDefault,
    AlertViewSyncNow
} AlertViewType;

@synthesize mapName = _mapName;
@synthesize mapURL = _mapURL;
@synthesize addButton = _addButton;
@synthesize infoButton = _infoButton;
@synthesize refreshButton = _refreshButton;
@synthesize reportTabController = _reportTabController;
@synthesize textByUrl = _textByUrl;
@synthesize textAroundMe = _textAroundMe;
@synthesize mapAddViewController = _mapAddViewController;
@synthesize editButton = _editButton;
@synthesize settingsViewController = _settingsViewController;

#pragma mark - IBActions

- (IBAction)edit:(id)sender event:(UIEvent*)event {
    if (self.tableView.editing) {
        self.tableView.editing = NO;
        self.editButton.image = [UIImage imageNamed:@"edit.png"];
        self.addButton.enabled = YES;
        self.infoButton.enabled = YES;
        self.refreshButton.enabled = YES;
    }
    else {
        self.tableView.editing = YES;
        self.editButton.image = [UIImage imageNamed:@"done"];
        self.addButton.enabled = NO;
        self.infoButton.enabled = NO;
        self.refreshButton.enabled = NO;
    }
}

- (IBAction)info:(id)sender event:(UIEvent*)event {
    if ([USHDevice isIPad]) {
        self.settingsViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        self.settingsViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    else {
        self.settingsViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        self.settingsViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    [self presentModalViewController:self.settingsViewController animated:YES];
}

- (IBAction)refresh:(id)sender event:(UIEvent*)event {
    DLog(@"");
    [self startRefreshControl];
}

- (IBAction)add:(id)sender event:(UIEvent*)event {
    DLog(@"");
    [UIActionSheet showWithTitle:nil
                        delegate:self
                           event:event
                             tag:ActionSheetAddMap
                          cancel:NSLocalizedString(@"Cancel", nil)
                         buttons:self.textByUrl, self.textAroundMe, nil];    
}

#pragma mark - Handlers

-(void) startRefreshControl {
    if ([[Ushahidi sharedInstance] synchronizeWithDelegate:self
                                                    photos:[[USHSettings sharedInstance] downloadPhotos]
                                                      maps:[[USHSettings sharedInstance] downloadMaps]
                                                     limit:[[USHSettings sharedInstance] downloadLimit]]) {
        DLog(@"Syncing...");
        self.addButton.enabled = NO;
        self.infoButton.enabled = NO;
        self.editButton.enabled = NO;
    }
    else {
        [self endRefreshControl];
    }
}

- (void) loadFirstMapIfIPad {
    if ([USHDevice isIPad] && [Ushahidi sharedInstance].maps.count > 0) {
        self.reportTabController.map = [[Ushahidi sharedInstance] mapAtIndex:0];
        self.reportTabController.category = nil;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void) initialSyncIfNeeded {
    if ([[Ushahidi sharedInstance] synchronizeDate] == nil) {
        [self startRefreshControl];
    }
}

#pragma mark - UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.textByUrl = NSLocalizedString(@"Add Map By URL", nil);
    self.textAroundMe = NSLocalizedString(@"Find Maps Around Me", nil);
    
    [self setTitleViewWithImage:@"Logo-Title.png" orText:[[USHSettings sharedInstance] appName]];
    self.backBarButtonTitle = NSLocalizedString(@"Maps", nil);
    
    [self loadFirstMapIfIPad];
    [self adjustToolBarHeight];
    [self showRefreshControl];
    [self initialSyncIfNeeded];
    
    [USHAnalytics sendScreenView:USHAnalyticsMapTableVCName];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - UITableViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TableSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[Ushahidi sharedInstance] numberOfMaps] > 0 ? [[Ushahidi sharedInstance] numberOfMaps] : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[Ushahidi sharedInstance] numberOfMaps] == 0) {
        return [USHTableCellFactory textTableCellForTable:tableView indexPath:indexPath text:NSLocalizedString(@"No maps", nil)];
    }
    else {
        USHMapTableCell *cell = [USHTableCellFactory mapTableCellForTable:tableView indexPath:indexPath];
        NSArray *maps = [[Ushahidi sharedInstance] maps];
        if (maps != nil && maps.count > indexPath.row) {
            USHMap *map = [maps objectAtIndex:indexPath.row];
            cell.titleLabel.text = map.name;
            if ([NSString isNilOrEmpty:map.error]) {
                cell.urlLabel.text = map.url;
            }
            else {
                cell.urlLabel.text = map.error;
            }
            cell.reports = map.reports.count;
            cell.checkins = map.checkins.count;
            cell.loading = map.syncing != nil ? [map.syncing boolValue] : NO;
            if ([USHDevice isIPad]) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        else {
            cell.titleLabel.text = nil;
            cell.urlLabel.text = nil;
            cell.reportsLabel.text = nil;
            cell.checkinsLabel.text = nil;
            cell.reports = 0;
            cell.checkins = 0;
            cell.loading = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"%d:%d", indexPath.section, indexPath.row);
    if ([[Ushahidi sharedInstance] numberOfMaps] > 0) {
        self.reportTabController.map = [[Ushahidi sharedInstance] mapAtIndex:indexPath.row];
        self.reportTabController.category = nil;
        if ([USHDevice isIPhone]) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            self.reportTabController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:self.reportTabController animated:YES];
        }
        else {
            UINavigationController *navigationController = self.reportTabController.navigationController;
            [navigationController popToViewController:self.reportTabController animated:YES];
        }
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [UIActionSheet showWithTitle:nil
                            delegate:self
                               event:nil
                                 tag:ActionSheetAddMap
                              cancel:NSLocalizedString(@"Cancel", nil)
                             buttons:self.textByUrl, self.textAroundMe, nil];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"%d:%d", indexPath.section, indexPath.row);
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([[Ushahidi sharedInstance] numberOfMaps] > indexPath.row) {
            USHMap *map = [[Ushahidi sharedInstance] mapAtIndex:indexPath.row];
            if ([[Ushahidi sharedInstance] removeMap:map]) {
                [[Ushahidi sharedInstance] saveChanges];
                [tableView reloadData];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[Ushahidi sharedInstance] numberOfMaps] == 0) {
        return [USHTextTableCell heightForTable:tableView text:NSLocalizedString(@"No maps", nil)];
    }
    return [USHMapTableCell cellHeight];
}

- (USHMapTableCell*) cellForMap:(USHMap*)map {
    if ([[Ushahidi sharedInstance] numberOfMaps] > 0) {
        NSInteger index = [[[Ushahidi sharedInstance] maps] indexOfObject:map];
        if (index > -1) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            return (USHMapTableCell*)[self.tableView cellForRowAtIndexPath:indexPath];   
        }   
    }
    return nil;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"Maps", nil);
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if ([[Ushahidi sharedInstance] synchronizeDate] != nil) {
        NSString * syncDate = [[Ushahidi sharedInstance] synchronizeDateWithFormat:@"h:mm a, MMM d, yyyy"];
        return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Last synced", nil), syncDate];
    }
    return nil;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:self.textByUrl]) {
        USHMapDialog *mapDialog = [[USHMapDialog alloc] initForDelegate:self];
        [mapDialog showWithTitle:NSLocalizedString(@"Add Map", nil) 
                            name:self.mapName 
                             url:self.mapURL];        
    }
    else if ([title isEqualToString:self.textAroundMe]) {
        self.mapAddViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        self.mapAddViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:self.mapAddViewController animated:YES];
    }
}

#pragma mark - USHMapDialogDelegate

- (void) mapDialogReturned:(USHMapDialog *)mapDialog name:(NSString *)name url:(NSString *)url {
    DLog(@"%@ %@", name, url);
    self.mapName = name;
    self.mapURL = url;
    USHMap *map = [[Ushahidi sharedInstance] addMapWithUrl:url title:name];
    if (map != nil){
        self.mapName = nil;
        self.mapURL = nil;
        [[Ushahidi sharedInstance] synchronizeWithDelegate:self map:map
                                                    photos:[[USHSettings sharedInstance] downloadPhotos]
                                                      maps:[[USHSettings sharedInstance] downloadMaps]
                                                     limit:[[USHSettings sharedInstance] downloadLimit]];
    }
    else {
        [UIAlertView showWithTitle:NSLocalizedString(@"Add Map Error", nil)
                           message:NSLocalizedString(@"Unable to add map to database", nil)
                          delegate:self cancel:NSLocalizedString(@"OK", nil)
                           buttons:nil];
    }
    [self.tableView reloadData];
    [self.tableView flashScrollIndicators];
}

- (void) mapDialogCancelled:(USHMapDialog *)mapDialog {
    DLog(@"");
    self.mapName = nil;
    self.mapURL = nil;
}

#pragma mark - UshahidiDelegate

- (void) ushahidi:(Ushahidi*)ushahidi synchronizing:(USHMap*)map {
    DLog(@"Map:%@", map.name);
    self.refreshButton.refreshing = YES;
    self.addButton.enabled = NO;
    self.infoButton.enabled = NO;
    self.editButton.enabled = NO;
    USHMapTableCell *cell = [self cellForMap:map];
    if (cell != nil && [cell isKindOfClass:USHMapTableCell.class]) {
        cell.loading = YES;
        cell.urlLabel.text = NSLocalizedString(@"Syncing...", nil);
        [cell.urlLabel setNeedsDisplay];
    }
    else {
        [self.tableView reloadData];
    }
}

- (void) ushahidi:(Ushahidi*)ushahidi synchronized:(USHMap*)map error:(NSError*)error {
    DLog(@"Map:%@ : Error:%@", map.name, error != nil ? [error description] : @"");
    USHMapTableCell *cell = [self cellForMap:map];
    if (cell != nil && [cell isKindOfClass:USHMapTableCell.class]) {
        cell.loading = NO;
        if (error != nil) {
            cell.urlLabel.text = error.localizedDescription;
        }
        else if ([NSString isNilOrEmpty:map.error] == NO) {
            cell.urlLabel.text = map.error;
        }
        else {
            cell.urlLabel.text = map.url;
            cell.reports = map.reports.count;
            cell.checkins = map.checkins.count;
        }
        [cell.urlLabel setNeedsDisplay];
    }
    else {
        [self.tableView reloadData];
    }
}

- (void) ushahidi:(Ushahidi*)ushahidi synchronization:(NSInteger)remaining {
    DLog(@"%d", remaining);
    if (remaining > 0) {
        self.refreshButton.refreshing = YES;
        self.addButton.enabled = NO;
        self.infoButton.enabled = NO;
        self.editButton.enabled = NO;
    }
    else {
        self.refreshButton.refreshing = NO;
        self.addButton.enabled = YES;
        self.infoButton.enabled = YES;
        self.editButton.enabled = YES;
        [self endRefreshControl];
        [self.tableView reloadData];
    }
}

- (void) ushahidi:(Ushahidi*)ushahidi downloaded:(USHMap*)map report:(USHReport*)report {
    DLog(@"Map:%@ Report:%@", map.name, report.title);
    USHMapTableCell *cell = [self cellForMap:map];
    if (cell != nil && [cell isKindOfClass:USHMapTableCell.class]) {
        cell.urlLabel.text = NSLocalizedString(@"Reports...", nil);
        [cell.urlLabel setNeedsDisplay];
    }
}

- (void) ushahidi:(Ushahidi*)ushahidi downloaded:(USHMap*)map checkin:(USHCheckin*)checkin {
    DLog(@"Map:%@ Checkin:%@", map.name, checkin.message);
    USHMapTableCell *cell = [self cellForMap:map];
    if (cell != nil && [cell isKindOfClass:USHMapTableCell.class]) {
        cell.urlLabel.text = NSLocalizedString(@"Checkins...", nil);
        [cell.urlLabel setNeedsDisplay];
    }
}

- (void) ushahidi:(Ushahidi*)ushahidi downloaded:(USHMap*)map category:(USHCategory*)category {
    DLog(@"Map:%@ Category:%@", map.name, category.title);
    USHMapTableCell *cell = [self cellForMap:map];
    if (cell != nil && [cell isKindOfClass:USHMapTableCell.class]) {
        cell.urlLabel.text = NSLocalizedString(@"Categories...", nil);
        [cell.urlLabel setNeedsDisplay];
    }
}

- (void) ushahidi:(Ushahidi*)ushahidi downloaded:(USHMap*)map location:(USHLocation*)location {
    DLog(@"Map:%@ Location:%@", map.name, location.name);
    USHMapTableCell *cell = [self cellForMap:map];
    if (cell != nil && [cell isKindOfClass:USHMapTableCell.class]) {
        cell.urlLabel.text = NSLocalizedString(@"Locations...", nil);
        [cell.urlLabel setNeedsDisplay];
    }
}

- (void) ushahidi:(Ushahidi*)ushahidi downloaded:(USHMap*)map photo:(USHPhoto*)photo {
    DLog(@"Map:%@ Photo:%@", map.name, photo.url);
    USHMapTableCell *cell = [self cellForMap:map];
    if (cell != nil && [cell isKindOfClass:USHMapTableCell.class]) {
        cell.urlLabel.text = NSLocalizedString(@"Photos...", nil);
        [cell.urlLabel setNeedsDisplay];
    }
}

- (void) ushahidi:(Ushahidi*)ushahidi downloaded:(USHMap*)map map:(UIImage *)image {
    DLog(@"Map:%@ Image:UIImage", map.name);
    USHMapTableCell *cell = [self cellForMap:map];
    if (cell != nil && [cell isKindOfClass:USHMapTableCell.class]) {
        cell.urlLabel.text = NSLocalizedString(@"Maps...", nil);
        [cell.urlLabel setNeedsDisplay];
    }
}

- (void) ushahidi:(Ushahidi*)ushahidi uploaded:(USHMap*)map video:(USHVideo*)video error:(NSError*)error {
    DLog(@"Map:%@ Video:%@", map.name, video.url);
    USHMapTableCell *cell = [self cellForMap:map];
    if (cell != nil && [cell isKindOfClass:USHMapTableCell.class]) {
        cell.urlLabel.text = NSLocalizedString(@"Uploaded video...", nil);
        [cell.urlLabel setNeedsDisplay];
    }
}

- (void) ushahidi:(Ushahidi*)ushahidi uploaded:(USHMap*)map report:(USHReport*)report error:(NSError*)error {
    DLog(@"Map:%@ Report:%@", map.name, report.title);
    USHMapTableCell *cell = [self cellForMap:map];
    if (cell != nil && [cell isKindOfClass:USHMapTableCell.class]) {
        cell.urlLabel.text = NSLocalizedString(@"Uploaded report...", nil);
        [cell.urlLabel setNeedsDisplay];
    }
}

@end
