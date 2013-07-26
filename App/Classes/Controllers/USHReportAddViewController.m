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

#import "USHReportAddViewController.h"
#import "USHCategoryTableViewController.h"
#import "USHLocationAddViewController.h"
#import "USHSettingsViewController.h"
#import "USHTableCellFactory.h"
#import "USHIconTableCell.h"
#import "USHInputTableCell.h"
#import "USHImageTableCell.h"
#import "USHSettings.h"
#import <Ushahidi/UIAlertView+USH.h>
#import <Ushahidi/Ushahidi.h>
#import <Ushahidi/USHReport.h>
#import <Ushahidi/USHDevice.h>
#import <Ushahidi/USHReport.h>
#import <Ushahidi/USHMap.h>
#import <Ushahidi/Ushahidi.h>
#import <Ushahidi/USHInternet.h>
#import <Ushahidi/USHLocator.h>
#import <Ushahidi/NSString+USH.h>
#import <Ushahidi/UITableView+USH.h>
#import <Ushahidi/UIBarButtonItem+USH.h>

@interface USHReportAddViewController ()

@property (strong, nonatomic) USHDatePicker *datePicker;
@property (strong, nonatomic) USHImagePicker *imagePicker;
@property (strong, nonatomic) USHVideoPicker *videoPicker;
@property (strong, nonatomic) USHInputTableCell *inputCell;
@property (strong, nonatomic) USHLoginDialog *loginDialog;

@property (strong, nonatomic) USHShareController *shareController;
@property (strong, nonatomic) NSString *locateError;
@property (strong, nonatomic) NSString *lookupError;

- (void) showKeyboardForSection:(NSInteger)section;

@end

@implementation USHReportAddViewController

@synthesize datePicker = _datePicker;
@synthesize imagePicker = _imagePicker;
@synthesize videoPicker = _videoPicker;
@synthesize map = _map;
@synthesize report = _report;
@synthesize categoryTableController = _categoryTableController;
@synthesize inputCell = _inputCell;
@synthesize loginDialog = _loginDialog;
@synthesize locationAddViewController = _locationAddViewController;
@synthesize settingsViewController = _settingsViewController;
@synthesize openGeoSMS = _openGeoSMS;
@synthesize locateError = _locateError;
@synthesize lookupError = _lookupError;

typedef enum {
    TableSectionTitle,
    TableSectionDescription,
    TableSectionCategory,
    TableSectionDate,
    TableSectionLocation,
    TableSectionPhotos,
    TableSectionVideos,
    TableSections
} TableSection;

typedef enum {
    TableSectionDateRowDate,
    TableSectionDateRowTime,
    TableSectionDateRows
} TableSectionDateRow;

typedef enum {
    TableSectionLocationRowAddress,
    TableSectionLocationRowCoordinates,
    TableSectionLocationRows
} TableSectionLocationRow;

typedef enum {
    AlertViewTypeDefault,
	AlertViewTypeUnsaved,
    AlertViewTypeUploaded,
    AlertViewTypeNoInternet
} AlertViewType;

#pragma mark - IBActions

- (IBAction)info:(id)sender event:(UIEvent*)event {
    if ([USHDevice isIPhone]) {
        self.settingsViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        self.settingsViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    else if ([[USHSettings sharedInstance] showReportList]) {
        self.settingsViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        self.settingsViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    else {
        self.settingsViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        self.settingsViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    [self presentModalViewController:self.settingsViewController animated:YES];
}

- (IBAction)cancel:(id)sender event:(UIEvent*)event {
    DLog(@"");
    [UIAlertView showWithTitle:NSLocalizedString(@"Unsaved Changes", nil) 
                       message:NSLocalizedString(@"Are you sure you want to cancel?", nil) 
                      delegate:self 
                           tag:AlertViewTypeUnsaved 
                        cancel:NSLocalizedString(@"No", nil) 
                       buttons:NSLocalizedString(@"Yes", nil), nil];
}

- (IBAction)done:(id)sender event:(UIEvent*)event {
    DLog(@"");
    if ([NSString isNilOrEmpty:self.report.title]) {
        [self showMessage:NSLocalizedString(@"Title Required", nil) hide:1.5];
        [self showKeyboardForSection:TableSectionTitle];
    }
    else if ([NSString isNilOrEmpty:self.report.desc]) {
        [self showMessage:NSLocalizedString(@"Description Required", nil) hide:1.5];
        [self showKeyboardForSection:TableSectionDescription];
    }
    else if (self.report.categories.count == 0) {
        [self showMessage:NSLocalizedString(@"Category Required", nil) hide:1.5];
    }
    else if (self.report.date == nil) {
        [self showMessage:NSLocalizedString(@"Date Required", nil) hide:1.5];
    }
    else if ([NSString isNilOrEmpty:self.report.location]) {
        [self showMessage:NSLocalizedString(@"Location Required", nil) hide:1.5];
        [self showKeyboardForSection:TableSectionLocation];
    }
    else {
        self.report.authorFirst = [[USHSettings sharedInstance] contactFirstName];
        self.report.authorLast = [[USHSettings sharedInstance] contactLastName];
        self.report.authorEmail = [[USHSettings sharedInstance] contactEmailAddress];
        if (self.openGeoSMS) {
            NSMutableString *sms = [NSMutableString string];
            [sms appendFormat:@"http://maps.google.com/?q=%@,%@&GeoSMS\n", self.report.latitude, self.report.longitude];
            [sms appendFormat:@"%@", self.report.title];
            [sms appendFormat:@"#%@", [self.report categoryIDs:@","]];
            [sms appendFormat:@"@%@\n", [[self.report dateFormatted:@"MM/dd/yyyy hh:mm a"] lowercaseString]];
            [sms appendFormat:@"%@\n", self.report.location];
            [sms appendFormat:@"%@", self.report.desc];
            [self.shareController sendSMS:sms recipient:self.map.sms];
        }
        else {
            if ([[USHSettings sharedInstance] showReportList]) {
                if ([[USHInternet sharedInstance] hasNetwork] || [[USHInternet sharedInstance] hasWiFi]) {
                    [self.inputCell hideKeyboard];
                    [self showLoadingWithMessage:NSLocalizedString(@"Uploading...", nil)];
                    [[Ushahidi sharedInstance] uploadReport:self.report delegate:self];
                }
                else {
                    self.report.pending = [NSNumber numberWithBool:YES];
                    [[Ushahidi sharedInstance] saveChanges];
                    [self showMessage:NSLocalizedString(@"Report Queued", nil) hide:1.5];
                    [self performSelector:@selector(dismissModalViewController) withObject:nil afterDelay:1.7];
                }
            }
            else {
                if ([[USHInternet sharedInstance] hasNetwork] || [[USHInternet sharedInstance] hasWiFi]) {
                    [UIAlertView showWithTitle:NSLocalizedString(@"Internet Connection Required", nil)
                                       message:NSLocalizedString(@"Please verify your internet connection and try again.", nil)
                                      delegate:self
                                           tag:AlertViewTypeNoInternet
                                        cancel:NSLocalizedString(@"OK", nil)
                                       buttons:nil];
                }
                else {
                    [self.inputCell hideKeyboard];
                    [self showLoadingWithMessage:NSLocalizedString(@"Uploading...", nil)];
                    [[Ushahidi sharedInstance] uploadReport:self.report delegate:self];
                }
            }
        }
    }
}

#pragma mark - Helpers

- (void) showKeyboardForSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    USHInputTableCell *cell = (USHInputTableCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell showKeyboard];
}

- (void) tableView:(UITableView *)tableView didTouchAtPoint:(CGPoint)point {
    if (self.inputCell != nil) {
        [self.inputCell hideKeyboard];
    }
}

#pragma mark - UIViewController

- (void)dealloc {
    [_map release];
    [_report release];
    [_datePicker release];
    [_imagePicker release];
    [_videoPicker release];
    [_inputCell release];
    [_shareController release];
    [_categoryTableController release];
    [_locationAddViewController release];
    [_settingsViewController release];
    [_locateError release];
    [_lookupError release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad]; 
    self.datePicker = [[[USHDatePicker alloc] initForDelegate:self] autorelease];
    self.imagePicker = [[[USHImagePicker alloc] initWithController:self] autorelease];
    self.videoPicker = [[[USHVideoPicker alloc] initWithController:self] autorelease];
    self.loginDialog = [[[USHLoginDialog alloc] initForDelegate:self] autorelease];
    self.shareController = [[[USHShareController alloc] initWithController:self] autorelease];
    self.locateError = nil;
    self.lookupError = nil;
    
    if ([[USHSettings sharedInstance] showReportList]) {
        self.leftBarButtonItem = [UIBarButtonItem borderedItemWithTitle:NSLocalizedString(@"Cancel", nil)
                                                              tintColor:[[USHSettings sharedInstance] navBarColor]
                                                                 target:self
                                                                 action:@selector(cancel:event:)];
        self.navigationItem.title = NSLocalizedString(@"Add Report", nil);
    }
    else {
        self.leftBarButtonItem = [UIBarButtonItem infoItemWithTarget:self action:@selector(info:event:)];
        [self setTitleViewWithImage:@"Logo-Title.png" orText:[[USHSettings sharedInstance] appName]];
        [[Ushahidi sharedInstance] dowloadCategoriesWithDelegate:self map:self.map];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.datePicker = nil;
    self.imagePicker = nil;
    self.videoPicker = nil;
    self.loginDialog = nil;
    self.shareController = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.openGeoSMS) {
        self.doneButton.title = NSLocalizedString(@"Send", nil);
    }
    else {
        self.doneButton.title = NSLocalizedString(@"Upload", nil);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DLog(@"Latitude:%@ Longitude:%@", self.report.latitude, self.report.longitude);
    if (self.report.latitude == nil || self.report.latitude.floatValue == 0 ||
        self.report.longitude == nil || self.report.longitude.floatValue == 0) {
        [[USHLocator sharedInstance] locateForDelegate:self];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[USHLocator sharedInstance] stopLocate];
    [[USHLocator sharedInstance] stopLookup];
}

#pragma mark - UITableViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TableSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == TableSectionDate) {
        return TableSectionDateRows;
    }
    if (section == TableSectionLocation) {
        return TableSectionLocationRows;
    }
    if (section == TableSectionDescription) {
        return 1;
    }
    if (section == TableSectionVideos) {
        if (self.openGeoSMS) {
            return 0;
        }
        if ([[USHSettings sharedInstance] youtubeCredentials] == NO) {
            return 0;
        }
        return 1;
    }
    if (section == TableSectionPhotos) {
        if (self.openGeoSMS) {
            return 0;
        }
        if (self.report.photos.count > 0) {
            return self.report.photos.count + 1;
        }
        return 1;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableSectionTitle) {
        return [USHTableCellFactory inputTableCellForTable:tableView 
                                                indexPath:indexPath 
                                                  delegate:self
                                               placeholder:NSLocalizedString(@"Enter title", nil)
                                                     text:self.report.title 
                                                     icon:@"title.png"];
    }
    else if (indexPath.section == TableSectionDescription) {
        return [USHTableCellFactory inputTableCellForTable:tableView 
                                                indexPath:indexPath 
                                                  delegate:self
                                               placeholder:NSLocalizedString(@"Enter description", nil)
                                                     text:self.report.desc 
                                                     icon:@"description.png"];
    }
    else if (indexPath.section == TableSectionCategory) {
        NSString *categories = self.report.categories.count > 0 ? [self.report categoryTitles:@", "] : NSLocalizedString(@"Select a category", nil);
        return [USHTableCellFactory iconTableCellForTable:tableView 
                                                indexPath:indexPath 
                                                     text:categories 
                                                     icon:@"category.png"
                                                accessory:YES
                                                   greyed:self.report.categories.count == 0];
    }
    else if (indexPath.section == TableSectionDate) {
        if (indexPath.row == TableSectionDateRowDate) {
            return [USHTableCellFactory iconTableCellForTable:tableView 
                                                    indexPath:indexPath 
                                                         text:self.report.dateString 
                                                         icon:@"date.png"
                                                    accessory:YES
                                                       greyed:NO];
        }
        else if (indexPath.row == TableSectionDateRowTime) {
            return [USHTableCellFactory iconTableCellForTable:tableView 
                                                    indexPath:indexPath 
                                                         text:self.report.timeString
                                                         icon:@"time.png"
                                                    accessory:YES
                                                       greyed:NO];
        }
    }
    else if (indexPath.section == TableSectionLocation) {
        if (indexPath.row == TableSectionLocationRowAddress) {
            NSString *placeholder;
            if ([NSString isNilOrEmpty:self.locateError] == NO) {
                placeholder = self.locateError;
            }
            else if ([NSString isNilOrEmpty:self.lookupError] == NO) {
                placeholder = self.lookupError;
            }
            else {
                placeholder = NSLocalizedString(@"Finding address...", nil);
            }
            return [USHTableCellFactory inputTableCellForTable:tableView
                                                     indexPath:indexPath 
                                                      delegate:self
                                                   placeholder:placeholder
                                                          text:self.report.location 
                                                          icon:@"map.png"];
        }
        else if (indexPath.row == TableSectionLocationRowCoordinates) {
            NSString *coordinates;
            BOOL greyed;
            if ([NSString isNilOrEmpty:self.locateError] == NO) {
                coordinates = [NSString stringWithFormat:@"%.1f, %.1f", self.report.latitude.floatValue, self.report.longitude.floatValue];
                greyed = NO;
            }
            else if (self.report.latitude.intValue != 0.0) {
                coordinates = [NSString stringWithFormat:@"%.8f, %.8f", self.report.latitude.floatValue, self.report.longitude.floatValue];
                greyed = NO;
            }
            else {
                coordinates = NSLocalizedString(@"Finding location...", nil);
                greyed = YES;
            }
            return [USHTableCellFactory iconTableCellForTable:tableView
                                                    indexPath:indexPath 
                                                         text:coordinates 
                                                         icon:@"place.png"
                                                    accessory:YES
                                                       greyed:greyed];
        }
    }
    else if (indexPath.section == TableSectionPhotos) {
        if (indexPath.row == 0) {
            return [USHTableCellFactory iconTableCellForTable:tableView
                                                    indexPath:indexPath
                                                         text:@"Add photo"
                                                         icon:@"photo.png"
                                                    accessory:YES
                                                       greyed:YES];
        }
        else if (self.report.photos.count > 0) {
            USHPhoto *photo = [[self.report.photos allObjects] objectAtIndex:indexPath.row - 1];
            return [USHTableCellFactory imageTableCellForTable:tableView
                                                     indexPath:indexPath
                                                         image:photo.image
                                                     removable:YES];
        }
    }
    else if (indexPath.section == TableSectionVideos) {
        if (self.report.videos.count > 0) {
            USHVideo *video = self.report.videos.allObjects.lastObject;
            NSString *text = [NSString isNilOrEmpty:video.url] ? NSLocalizedString(@"User Captured Video", nil) : video.url;
            return [USHTableCellFactory iconTableCellForTable:tableView
                                                    indexPath:indexPath
                                                         text:text
                                                         icon:@"video.png"
                                                    accessory:YES
                                                       greyed:NO];
        }
        return [USHTableCellFactory iconTableCellForTable:tableView 
                                                indexPath:indexPath 
                                                     text:@"Add video" 
                                                     icon:@"video.png"
                                                accessory:YES
                                                   greyed:YES];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == TableSectionDate) {
        CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
        if (indexPath.row == TableSectionDateRowDate) {
            [self.datePicker showWithDate:self.report.date mode:UIDatePickerModeDate indexPath:indexPath forRect:rect];
        }
        else if (indexPath.row == TableSectionDateRowTime) {
            [self.datePicker showWithDate:self.report.date mode:UIDatePickerModeTime indexPath:indexPath forRect:rect];
        } 
    }
    else if (indexPath.section == TableSectionPhotos && indexPath.row == 0) {
        CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
        [self.imagePicker showImagePickerForRect:rect resize:YES width:[[USHSettings sharedInstance] imageWidth]];
    }
    else if (indexPath.section == TableSectionPhotos && indexPath.row > 0) {
        USHPhoto *photo = [[self.report.photos allObjects] objectAtIndex:indexPath.row - 1];
        if ([[Ushahidi sharedInstance] removePhoto:photo]) {
            [self.report removePhotosObject:photo];
        }
        [self.tableView reloadRowsAtSection:TableSectionPhotos];
    }
    else if (indexPath.section == TableSectionCategory) {
        self.categoryTableController.map = self.map;
        self.categoryTableController.report = self.report;
        self.categoryTableController.modalPresentationStyle = UIModalPresentationFormSheet;
        self.categoryTableController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:self.categoryTableController animated:YES];
    }
    else if (indexPath.section == TableSectionLocation) {
        self.locationAddViewController.map = self.map;
        self.locationAddViewController.report = self.report;
        self.locationAddViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        self.locationAddViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:self.locationAddViewController animated:YES];
    }
    else if (indexPath.section == TableSectionVideos) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self.videoPicker showVideoPickerForCell:cell];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableSectionDescription) {
        if ([USHDevice isIPad]) {
            if ([USHDevice isPortraitMode]) {
                return 250;
            }
            return 90;
        }
        return 100;
    }
    if (indexPath.section == TableSectionLocation) {
        if (indexPath.row == TableSectionLocationRowAddress) {
            return [USHInputTableCell heightForTable:tableView text:self.report.location];
        }
        return 44;
    }
    if (indexPath.section == TableSectionPhotos) {
        if (self.openGeoSMS) {
            return 0;
        }
        if (indexPath.row > 0) {
            return 200;
        }
        return 44;
    }
    if (indexPath.section == TableSectionVideos) {
        if (self.openGeoSMS) {
            return 0;
        }
    }
    return 44;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

#pragma mark - USHDatePickerDelegate

- (void) datePickerReturned:(USHDatePicker *)datePicker indexPath:(NSIndexPath *)indexPath date:(NSDate *)date {
    if (indexPath.row == TableSectionDateRowDate) {
        DLog(@"Date:%@", date);
        self.report.date = date;
    }
    else if (indexPath.row == TableSectionDateRowTime) {
        DLog(@"Time:%@", date);
        self.report.date = date;
    }
    [self.tableView reloadRowsAtSection:TableSectionDate];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == AlertViewTypeUnsaved &&
        buttonIndex != alertView.cancelButtonIndex) {
        if ([[Ushahidi sharedInstance] removeReport:self.report]) {
            DLog(@"Removed");
        }
        else {
            DLog(@"Not Removed");
        }
        [[Ushahidi sharedInstance] saveChanges];
        [self dismissModalViewControllerAnimated:YES];
    }
    else if (alertView.tag == AlertViewTypeUploaded) {
        self.report = [[Ushahidi sharedInstance] addReportForMap:self.map];
        [self.tableView reloadData];
        [self.tableView flashScrollIndicators];
    }	
}

#pragma mark - USHLocatorDelegate

- (void) locateFinished:(USHLocator *)locator latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude {
    DLog(@"%@,%@", latitude, longitude);
    self.report.latitude = latitude;
    self.report.longitude = longitude;
    self.locateError = nil;
    [self.tableView reloadRowsAtSection:TableSectionLocation];
    if ([NSString isNilOrEmpty:self.report.location]) {
        [[USHLocator sharedInstance] lookupForDelegate:self];   
    }
}

- (void) locateFailed:(USHLocator *)locator error:(NSError *)error {
    DLog(@"Error:%@", [error description]);
    self.report.latitude = [NSNumber numberWithFloat:0.0];
    self.report.longitude = [NSNumber numberWithFloat:0.0];
    self.locateError = NSLocalizedString(@"Error finding location", nil);
    [self.tableView reloadRowsAtSection:TableSectionLocation];
}

- (void) lookupFinished:(USHLocator *)locator address:(NSString *)address {
    DLog(@"%@", address);
    self.report.location = address;
    self.lookupError = nil;
    [self.tableView reloadRowsAtSection:TableSectionLocation];
}

- (void) lookupFailed:(USHLocator *)locator error:(NSError *)error {
    DLog(@"Error:%@", [error description]);
    self.lookupError = NSLocalizedString(@"Error finding address", nil);
    [self.tableView reloadRowsAtSection:TableSectionLocation];
}

#pragma mark - USHImagePickerDelegate

- (void) imagePickerDidCancel:(USHImagePicker *)imagePicker {
    DLog(@"");
}

- (void) imagePickerDidSelect:(USHImagePicker *)imagePicker {
    DLog(@"");
    [self showLoadingWithMessage:NSLocalizedString(@"Adding...", nil)];
}

- (void) imagePickerDidFinish:(USHImagePicker *)imagePicker image:(UIImage *)image {
    DLog(@"");
    USHPhoto *photo = [[Ushahidi sharedInstance] addPhotoForReport:self.report];
    photo.image = UIImageJPEGRepresentation(image, 1.0);
    [self showLoadingWithMessage:NSLocalizedString(@"Added", nil) hide:0.8];
    [self.tableView reloadRowsAtSection:TableSectionPhotos];
}

#pragma mark - USHInputTableCellDelegate

- (void) inputFocussed:(USHInputTableCell *)cell indexPath:(NSIndexPath *)indexPath {
    DLog(@"%d,%d", indexPath.section, indexPath.row);
    self.inputCell = cell;
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void) inputChanged:(USHInputTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
    self.inputCell = cell;
    if (indexPath.section == TableSectionTitle) {
        self.report.title = text;
    }
    else if (indexPath.section == TableSectionDescription) {
        self.report.desc = text;
    }
    else if (indexPath.section == TableSectionLocation) {
        self.report.location = text;
    }
}

- (void) inputReturned:(USHInputTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
    DLog(@"%d,%d %@", indexPath.section, indexPath.row, text);
    self.inputCell = nil;
}

#pragma mark - UshahidiDelegate

- (void) ushahidi:(Ushahidi*)ushahidi uploaded:(USHMap*)map video:(USHVideo*)video error:(NSError*)error {
    if (error != nil) {
        DLog(@"Map:%@ Video:%@ Error:%@", map.name, video.url, error.localizedDescription);
    }
    else {
        DLog(@"Map:%@ Video:%@", map.name, video.url);
        USHVideo *userVideo = self.report.videos.allObjects.lastObject;
        userVideo.url = video.url;
        [self.tableView reloadData];
    }
}

- (void) ushahidi:(Ushahidi*)ushahidi uploaded:(USHMap*)map report:(USHReport*)report error:(NSError*)error {
    if (error != nil) {
        [self hideLoading];
        DLog(@"Error:%@ Description:%@ Code:%d", error, error.description, error.code);
        if (error.code == NSURLErrorUserAuthenticationRequired) {
            [self.loginDialog showWithTitle:NSLocalizedString(@"Authentication Required", nil) 
                                   username:self.map.username 
                                   password:self.map.password];
        }
        else {
            [UIAlertView showWithTitle:NSLocalizedString(@"Upload Error", nil) 
                               message:[error localizedDescription] 
                              delegate:self 
                                   tag:AlertViewTypeDefault 
                                cancel:NSLocalizedString(@"OK", nil) 
                               buttons:nil];   
        }
    }
    else {
        self.report.pending = [NSNumber numberWithBool:NO];
        [[Ushahidi sharedInstance] saveChanges];
        if ([[USHSettings sharedInstance] showReportList]) {
            [self showLoadingWithMessage:NSLocalizedString(@"Uploaded", nil) hide:2.0];
            [self performSelector:@selector(dismissModalViewController) withObject:nil afterDelay:2.2];
        }
        else {
            [self hideLoading];
            [UIAlertView showWithTitle:NSLocalizedString(@"Uploaded", nil)
                               message:NSLocalizedString(@"Your report has been uploaded and is pending approval.", nil)
                              delegate:self
                                   tag:AlertViewTypeUploaded
                                cancel:NSLocalizedString(@"OK", nil)
                               buttons:nil];
        }
    }
}

- (void) ushahidi:(Ushahidi*)ushahidi downloaded:(USHMap*)map category:(USHCategory*)category {
    DLog(@"Category:%@", category.title);
}

#pragma mark - USHVideoPickerDelegate

- (void) videoPickerDidStart:(USHVideoPicker*)videoPicker {
    DLog(@"");
}

- (void) videoPickerDidCancel:(USHVideoPicker*)videoPicker {
    DLog(@"");
}

- (void) videoPickerDidFail:(USHVideoPicker*)videoPicker error:(NSError*)error {
    DLog(@"Error:%@", error.localizedDescription);
    [UIAlertView showWithTitle:NSLocalizedString(@"Video Error", nil)
                       message:error.localizedDescription
                      delegate:self
                        cancel:NSLocalizedString(@"Ok", nil)
                       buttons:nil];
}

- (void) videoPickerDidFinish:(USHVideoPicker*)videoPicker url:(NSURL *)url {
    DLog(@"%@", url);
    USHVideo *video = nil;
    if (self.report.videos.count > 0) {
        video = self.report.videos.allObjects.lastObject;
    }
    else {
        video = [[Ushahidi sharedInstance] addVideoForReport:self.report];
    }
    video.data = [NSData dataWithContentsOfURL:url];
    [[Ushahidi sharedInstance] saveChanges];
    [self.tableView reloadRowsAtSection:TableSectionVideos];
}

#pragma mark - USHShareControllerDelegate

- (void) sendSMSWasSent:(USHShareController*)share {
    self.report.pending = [NSNumber numberWithBool:NO];
    [[Ushahidi sharedInstance] saveChanges];
    [self performSelector:@selector(dismissModalViewController) withObject:nil afterDelay:0.5];
}

@end
