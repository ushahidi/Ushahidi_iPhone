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

#import "USHMapAddViewController.h"
#import <Ushahidi/UIAlertView+USH.h>
#import <UShahidi/NSString+USH.h>
#import <UShahidi/USHDevice.h>
#import "USHTableCellFactory.h"
#import "USHMapTableCell.h"
#import "USHTextTableCell.h"
#import "USHSettings.h"

#define kKilometerSuffix @" km"

@interface USHMapAddViewController ()

@property (strong, nonatomic) USHItemPicker *itemPicker;
@property (strong, nonatomic) NSString *radius;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) NSMutableArray *maps;

@end

@implementation USHMapAddViewController

@synthesize itemPicker = _itemPicker;
@synthesize radius = _radius;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize radiusButton = _radiusButton;
@synthesize cancelButton = _cancelButton;

typedef enum {
    SortTypeByName,
    SortTypeByDate
} SortType;

#pragma mark - IBActions

- (IBAction) cancel:(id)sender event:(UIEvent*)event {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) radius:(id)sender event:(UIEvent*)event {
    NSArray *items = [NSArray arrayWithObjects:@"50 km", @"100 km", @"250 km", @"500 km", @"750 km", @"1000 km", @"1500 km", nil];
    NSString *selected = [NSString isNilOrEmpty:self.radius] ? nil : [NSString stringWithFormat:@"%@%@", self.radius, kKilometerSuffix];
    [self.itemPicker showWithItems:items selected:selected event:event tag:0];
}

- (IBAction) sort:(id)sender event:(UIEvent*)event {
    if (self.sortControl.selectedSegmentIndex == SortTypeByName) {
        DLog(@"SortTypeByName");
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [self.maps sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
        [descriptor release];
    }
    else if (self.sortControl.selectedSegmentIndex == SortTypeByDate) {
        DLog(@"SortTypeByDate");
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"discovered" ascending:YES];
        [self.maps sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
        [descriptor release];
    }
    [self.tableView reloadData];
    [self.tableView flashScrollIndicators];
}

#pragma mark - UIViewController

- (void)dealloc {
    [_itemPicker release];
    [_radius release];
    [_latitude release];
    [_longitude release];
    [_radiusButton release];
    [_cancelButton release];
    [_maps release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.itemPicker = [[USHItemPicker alloc] initWithController:self];
    self.radius = @"500";
    self.radiusButton.title = [NSString stringWithFormat:@"%@%@", self.radius, kKilometerSuffix];
    self.cancelButton.title = NSLocalizedString(@"Cancel", nil);
    self.navigationItem.title = NSLocalizedString(@"Add Map", nil);
    self.maps = [NSMutableArray array];
}

- (void) viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];
    self.radiusButton.enabled = NO;
    [self showLoadingWithMessage:NSLocalizedString(@"Locating...", nil)];
    [[USHLocator sharedInstance] locateForDelegate:self];
}

#pragma mark - UITableViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.maps > 0 ? self.maps.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.maps.count == 0) {
        return [USHTableCellFactory textTableCellForTable:tableView indexPath:indexPath text:NSLocalizedString(@"No maps", nil)];
    }
    else {
        USHMapTableCell *cell = [USHTableCellFactory mapTableCellForTable:tableView indexPath:indexPath];
        if (self.maps != nil && self.maps.count > indexPath.row) {
            USHMap *map = [self.maps objectAtIndex:indexPath.row];
            cell.titleLabel.text = map.name;
            cell.urlLabel.text = map.url;
        }
        else {
            cell.titleLabel.text = nil;
            cell.urlLabel.text = nil;
        }
        cell.loading = NO;
        cell.reports = 0;
        cell.checkins = 0;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"%d:%d", indexPath.section, indexPath.row);
    USHMap *map = [self.maps objectAtIndex:indexPath.row];
    DLog(@"%@ %@", map.name, map.url);
    
    USHViewController<UshahidiDelegate> *delegate;
    if ([self.hostingViewController conformsToProtocol:@protocol(UshahidiDelegate)]) {
        DLog(@"conformsToProtocol UshahidiDelegate");
        delegate = (USHViewController<UshahidiDelegate>*)self.hostingViewController;
    }
    else {
        delegate = self;
    }
    [[Ushahidi sharedInstance] addMap:map];
    [[Ushahidi sharedInstance] saveChanges];
    [[Ushahidi sharedInstance] synchronizeWithDelegate:delegate
                                                   map:map
                                                photos:[[USHSettings sharedInstance] downloadPhotos]
                                                  maps:[[USHSettings sharedInstance] downloadMaps]];
    [self showMessage:NSLocalizedString(@"Added", nil) hide:1.5];
    [self performSelector:@selector(dismissModalViewController) withObject:nil afterDelay:1.5];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.maps.count == 0) {
        return [USHTextTableCell heightForTable:tableView text:NSLocalizedString(@"No maps", nil)];
    }
    return [USHMapTableCell cellHeight];
}

#pragma mark - USHLocatorDelegate

- (void) locateFinished:(USHLocator *)locator latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude {
    DLog(@"%@,%@", latitude, longitude);
    self.latitude = latitude;
    self.longitude = longitude;
    self.radiusButton.enabled = YES;
    [self showLoadingWithMessage:[NSString stringWithFormat:@"%@%@...", self.radius, kKilometerSuffix]];
    [[Ushahidi sharedInstance] findMapsWithDelegate:self radius:self.radius latitude:self.latitude longitude:self.longitude];
}

- (void) locateFailed:(USHLocator *)locator error:(NSError *)error {
    DLog(@"Error:%@", error.localizedDescription);
    [self hideLoading];
    self.radiusButton.enabled = NO;
    [self showLoadingWithMessage:NSLocalizedString(@"Searching...", nil)];
    [[Ushahidi sharedInstance] findMapsWithDelegate:self radius:nil latitude:nil longitude:nil];
}

#pragma mark - USHItemPickerDelegate

- (void) itemPickerReturned:(USHItemPicker *)itemPicker item:(NSString *)item index:(NSInteger)index {
    DLog(@"%@", item);
    self.radius = [item stringByReplacingOccurrencesOfString:kKilometerSuffix withString:@""];
    self.radiusButton.title = [NSString stringWithFormat:@"%@%@", self.radius, kKilometerSuffix];
    self.radiusButton.enabled = NO;
    [self showLoadingWithMessage:[NSString stringWithFormat:@"%@%@...", self.radius, kKilometerSuffix]];
    [[Ushahidi sharedInstance] findMapsWithDelegate:self radius:self.radius latitude:self.latitude longitude:self.longitude];
}

#pragma mark - UshahidiDelegate

- (void) ushahidi:(Ushahidi*)ushahidi maps:(NSArray*)maps {
    DLog(@"Maps:%d", maps.count);
    [self hideLoading];
    self.radiusButton.enabled = YES;
    [self.maps removeAllObjects];
    NSSortDescriptor *descriptor;
    if (self.sortControl.selectedSegmentIndex == SortTypeByName) {
        DLog(@"SortTypeByName");
        descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    }
    else if (self.sortControl.selectedSegmentIndex == SortTypeByDate) {
        DLog(@"SortTypeByDate");
        descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    }
    [self.maps addObjectsFromArray:[maps sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]]];
    [self.tableView reloadData];
    [self.tableView flashScrollIndicators];
}

@end
