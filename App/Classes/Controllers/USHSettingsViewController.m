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

#import "USHSettingsViewController.h"
#import "USHTableCellFactory.h"
#import "USHTextTableCell.h"
#import "USHInputTableCell.h"
#import "USHIconTableCell.h"
#import "USHImageTableCell.h"
#import "USHSliderTableCell.h"
#import "USHSettings.h"
#import <Ushahidi/USHDevice.h>
#import <Ushahidi/UITableView+USH.h>
#import <Ushahidi/NSString+USH.h>
#import <Ushahidi/USHAppDelegate.h>

@interface USHSettingsViewController ()

@property (strong, nonatomic) USHShareController *shareController;

@end

@implementation USHSettingsViewController

typedef enum {
	TableSectionContact,
    TableSectionDisplay,
	TableSectionPhoto,
    TableSectionMap,
    TableSectionSMS,
	TableSectionAbout,
    TableSections
} TableSection;

typedef enum {
	TableSectionContactRowFirst,
	TableSectionContactRowLast,
	TableSectionContactRowEmail,
    TableSectionContactRows
} TableSectionContactRow;

typedef enum {
    TableSectionDisplayRowStatusBar,
    TableSectionDisplayRowBadgeCount,
    TableSectionDisplayRows
} TableSectionDisplayRow;

typedef enum {
    TableSectionMapRowDownloadMaps,
    TableSectionMapRows
} TableSectionMapRow;

typedef enum {
    TableSectionSMSRowOpenGeoSMS,
    TableSectionSMSRows
} TableSectionSMSRow;

typedef enum {
    TableSectionPhotoRowDownloadImages,
	TableSectionPhotoRowResizeImages,
	TableSectionPhotoRowImageSize,
    TableSectionPhotoRows
} TableSectionPhotoRow;

typedef enum {
	TableSectionAboutRowVersion,
	TableSectionAboutRowShare,
	TableSectionAboutRowEmail,
	TableSectionAboutRowWebsite,
	TableSectionAboutRowLogo,
    TableSectionAboutRows
} TableSectionAboutRow;

@synthesize shareController = _shareController;
@synthesize doneButton = _doneButton;

#pragma mark - IBActions

- (IBAction)done:(id)sender event:(UIEvent*)event {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIViewController

- (void)dealloc {
    [_shareController release];
    [_doneButton release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shareController = [[USHShareController alloc] initWithController:self];
    self.doneButton.title = NSLocalizedString(@"Done", nil);
    self.navigationItem.title = NSLocalizedString(@"Settings", nil);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - UITableViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TableSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == TableSectionContact) {
        return TableSectionContactRows;
    }
    if (section == TableSectionDisplay) {
        if ([[USHSettings sharedInstance] showReportList]) {
            return TableSectionDisplayRows;
        }
        return 0;
    }
    if (section == TableSectionPhoto) {
        if ([[USHSettings sharedInstance] showReportList]) {
            return TableSectionPhotoRows;
        }
        return 0;
    }
    if (section == TableSectionMap) {
        if ([[USHSettings sharedInstance] showReportList]) {
            return TableSectionMapRows;
        }
        return 0;
    }
    if (section == TableSectionSMS) {
        return TableSectionSMSRows;
    }
    if (section == TableSectionAbout) {
        return TableSectionAboutRows;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableSectionContact) {
        if (indexPath.row == TableSectionContactRowFirst) {
            return [USHTableCellFactory inputTableCellForTable:tableView indexPath:indexPath delegate:self
                                                   placeholder:NSLocalizedString(@"Enter first name", nil)
                                                          text:[[USHSettings sharedInstance] contactFirstName]
                                                          icon:@"firstname.png"
                                                capitalization:UITextAutocapitalizationTypeWords
                                                    correction:UITextAutocorrectionTypeNo
                                                      spelling:UITextSpellCheckingTypeNo
                                                      keyboard:UIKeyboardTypeNamePhonePad
                                                          done:UIReturnKeyDefault];
        }
        if (indexPath.row == TableSectionContactRowLast) {
            return [USHTableCellFactory inputTableCellForTable:tableView indexPath:indexPath delegate:self
                                                   placeholder:NSLocalizedString(@"Enter last name", nil)
                                                          text:[[USHSettings sharedInstance] contactLastName]
                                                          icon:@"lastname.png"
                                                capitalization:UITextAutocapitalizationTypeWords
                                                    correction:UITextAutocorrectionTypeNo
                                                      spelling:UITextSpellCheckingTypeNo
                                                      keyboard:UIKeyboardTypeNamePhonePad
                                                          done:UIReturnKeyDefault];
        }
        if (indexPath.row == TableSectionContactRowEmail) {
            return [USHTableCellFactory inputTableCellForTable:tableView indexPath:indexPath delegate:self
                                                   placeholder:NSLocalizedString(@"Enter email address", nil)
                                                          text:[[USHSettings sharedInstance] contactEmailAddress]
                                                          icon:@"email.png"
                                                capitalization:UITextAutocapitalizationTypeNone
                                                    correction:UITextAutocorrectionTypeNo
                                                      spelling:UITextSpellCheckingTypeNo
                                                      keyboard:UIKeyboardTypeEmailAddress
                                                          done:UIReturnKeyDefault];
        }
    }
    else if (indexPath.section == TableSectionPhoto) {
        if (indexPath.row == TableSectionPhotoRowDownloadImages) {
            return [USHTableCellFactory switchTableCellForTable:tableView indexPath:indexPath delegate:self
                                                           text:NSLocalizedString(@"Download Photos", nil)
                                                           icon:@"download.png"
                                                             on:[[USHSettings sharedInstance] downloadPhotos]];
        }
        else if (indexPath.row == TableSectionPhotoRowResizeImages) {
            return [USHTableCellFactory switchTableCellForTable:tableView indexPath:indexPath delegate:self
                                                           text:NSLocalizedString(@"Resize New Photos", nil)
                                                           icon:@"resize.png"
                                                             on:[[USHSettings sharedInstance] resizePhotos]];
        }
        else if (indexPath.row == TableSectionPhotoRowImageSize) {
            return [USHTableCellFactory sliderTableCellForTable:tableView indexPath:indexPath delegate:self
                                                           text:NSLocalizedString(@"Resize Photo Width", nil)
                                                           icon:@"width.png"
                                                          value:[[USHSettings sharedInstance] imageWidth]
                                                            min:200
                                                            max:1024
                                                        enabled:[[USHSettings sharedInstance] resizePhotos]];
        }
    }
    else if (indexPath.section == TableSectionDisplay) {
        if (indexPath.row == TableSectionDisplayRowStatusBar) {
            return [USHTableCellFactory switchTableCellForTable:tableView indexPath:indexPath delegate:self
                                                           text:NSLocalizedString(@"Hide Status Bar", nil)
                                                           icon:@"statusbar.png"
                                                             on:[[USHSettings sharedInstance] hideStatusBar]];
        }
        else if (indexPath.row == TableSectionDisplayRowBadgeCount) {
            return [USHTableCellFactory switchTableCellForTable:tableView indexPath:indexPath delegate:self
                                                           text:NSLocalizedString(@"Icon Badge Number", nil)
                                                           icon:@"badge.png"
                                                             on:[[USHSettings sharedInstance] showBadgeNumber]];
        }
    }
    else if (indexPath.section == TableSectionSMS) {
        if (indexPath.row == TableSectionSMSRowOpenGeoSMS) {
            return [USHTableCellFactory switchTableCellForTable:tableView indexPath:indexPath delegate:self
                                                           text:NSLocalizedString(@"Enable OpenGeoSMS", nil)
                                                           icon:@"sms.png"
                                                             on:[[USHSettings sharedInstance] openGeoSMS]];
        }
    }
    else if (indexPath.section == TableSectionMap) {
        if (indexPath.row == TableSectionMapRowDownloadMaps) {
            return [USHTableCellFactory switchTableCellForTable:tableView indexPath:indexPath delegate:self
                                                           text:NSLocalizedString(@"Download Map Images", nil)
                                                           icon:@"map.png"
                                                             on:[[USHSettings sharedInstance] downloadMaps]];
        }
    }
    else if (indexPath.section == TableSectionAbout) {
        if (indexPath.row == TableSectionAboutRowVersion) {
            NSString *version = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Version", nil), [[USHSettings sharedInstance] appVersion], nil];
            return [USHTableCellFactory iconTableCellForTable:tableView indexPath:indexPath text:version icon:@"version.png" accessory:NO];
        }
        if (indexPath.row == TableSectionAboutRowShare) {
            return [USHTableCellFactory iconTableCellForTable:tableView indexPath:indexPath text:NSLocalizedString(@"Share Application", nil) icon:@"share.png" accessory:YES];
        }
        if (indexPath.row == TableSectionAboutRowEmail) {
            return [USHTableCellFactory iconTableCellForTable:tableView indexPath:indexPath text:[[USHSettings sharedInstance] supportEmail] icon:@"email.png" accessory:YES];
        }
        if (indexPath.row == TableSectionAboutRowWebsite) {
            return [USHTableCellFactory iconTableCellForTable:tableView indexPath:indexPath text:[[USHSettings sharedInstance] supportURL] icon:@"web.png" accessory:YES];
        }
        if (indexPath.row == TableSectionAboutRowLogo) {
            NSString *logo = [USHDevice isIPad] ? @"Logo-iPad.png" : @"Logo-iPhone.png";
            return [USHTableCellFactory imageTableCellForTable:tableView indexPath:indexPath imageName:logo];
        }
    }
    
    static NSString *CellIdentifier = @"Cell"; 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == TableSectionAbout) {
        if (indexPath.row == TableSectionAboutRowShare) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [self.shareController showShareForCell:cell];
        }
        else if (indexPath.row == TableSectionAboutRowEmail) {
            NSString *subject = [NSString stringWithFormat:@"%@ %@", [[USHSettings sharedInstance] appName], [[USHSettings sharedInstance] appVersion]];
            NSMutableString *html = [NSMutableString string];
            [html appendFormat:@"<b>%@</b>: %@ %@", NSLocalizedString(@"Version", nil), [[USHSettings sharedInstance] appName], [[USHSettings sharedInstance] appVersion]];
            [html appendString:@"<br/>"];
            [html appendFormat:@"<b>%@</b>: %@ %@", NSLocalizedString(@"Model", nil), [USHDevice deviceModel], [USHDevice deviceVersion]];
            [self.shareController sendEmail:html subject:subject attachment:nil fileName:nil recipient:[[USHSettings sharedInstance] supportEmail]];
        }
        else if (indexPath.row == TableSectionAboutRowWebsite) {
            [self.shareController openURL:[[USHSettings sharedInstance] supportURL]];
        }
        else if (indexPath.row == TableSectionAboutRowLogo) {
            [self.shareController openURL:[[USHSettings sharedInstance] supportURL]];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableSectionAbout && indexPath.row == TableSectionAboutRowLogo) {
        NSString *logo = [USHDevice isIPad] ? @"Logo-iPad.png" : @"Logo-iPhone.png";
        UIImage *image = [UIImage imageNamed:logo];
        return tableView.contentSize.width * image.size.height / image.size.width;
    }
    return 44;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == TableSectionContact) {
        return NSLocalizedString(@"Contact", nil);
    }
    if (section == TableSectionPhoto &&
        [[USHSettings sharedInstance] showReportList]) {
        return NSLocalizedString(@"Photos", nil);
    }
    if (section == TableSectionSMS) {
        return NSLocalizedString(@"SMS", nil);
    }
    if (section == TableSectionAbout) {
        return NSLocalizedString(@"About", nil);
    }
    if (section == TableSectionDisplay &&
        [[USHSettings sharedInstance] showReportList]) {
        return NSLocalizedString(@"Display", nil);
    }
    if (section == TableSectionMap &&
        [[USHSettings sharedInstance] showReportList]) {
        return NSLocalizedString(@"Maps", nil);
    }
    return nil;
}

#pragma mark - USHInputTableCellDelegate

- (void) inputFocussed:(USHInputTableCell *)cell indexPath:(NSIndexPath *)indexPath {
    DLog(@"%d,%d", indexPath.section, indexPath.row);
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void) inputChanged:(USHInputTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
    if (indexPath.section == TableSectionContact){
        if (indexPath.row == TableSectionContactRowFirst) {
            [[USHSettings sharedInstance] setContactFirstName:text];
        }
        else if (indexPath.row == TableSectionContactRowLast) {
            [[USHSettings sharedInstance] setContactLastName:text];
        }
        else if (indexPath.row == TableSectionContactRowEmail) {
            [[USHSettings sharedInstance] setContactEmailAddress:text];
        }
    }
}

- (void) inputReturned:(USHInputTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
    if (indexPath.section == TableSectionContact){
        if (indexPath.row == TableSectionContactRowFirst) {
            [[USHSettings sharedInstance] setContactFirstName:text];
        }
        else if (indexPath.row == TableSectionContactRowLast) {
            [[USHSettings sharedInstance] setContactLastName:text];
        }
        else if (indexPath.row == TableSectionContactRowEmail) {
            [[USHSettings sharedInstance] setContactEmailAddress:text];
        }
    }
}

#pragma mark - USHSwitchTableCellDelegate

- (void) switchTableViewCell:(USHSwitchTableCell *)cell index:(NSIndexPath *)indexPath on:(BOOL)on {
    if (indexPath.section == TableSectionPhoto) {
        if (indexPath.row == TableSectionPhotoRowDownloadImages) {
            [[USHSettings sharedInstance] setDownloadPhotos:on];
        }
        else if (indexPath.row == TableSectionPhotoRowResizeImages) {
            [[USHSettings sharedInstance] setResizePhotos:on];
            NSIndexPath *sliderIndexPath = [NSIndexPath indexPathForRow:TableSectionPhoto inSection:TableSectionPhotoRowImageSize];
            USHSliderTableCell *sliderCell = (USHSliderTableCell*)[self.tableView cellForRowAtIndexPath:sliderIndexPath];
            if (sliderCell != nil) {
                sliderCell.enabled = on;
            }
            else {
                [self.tableView reloadData];
            }
        }
    }
    else if (indexPath.section == TableSectionDisplay) {
        if (indexPath.row == TableSectionDisplayRowStatusBar) {
            USHAppDelegate *appDelegate = (USHAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate statusBarHidden:on animated:YES];
            [[USHSettings sharedInstance] setHideStatusBar:on];
        }
        else if (indexPath.row == TableSectionDisplayRowBadgeCount) {
            [[USHSettings sharedInstance] setShowBadgeNumber:on];
        }
    }
    else if (indexPath.section == TableSectionSMS) {
        if (indexPath.row == TableSectionSMSRowOpenGeoSMS) {
            [[USHSettings sharedInstance] setOpenGeoSMS:on];
        }
    }
    else if (indexPath.section == TableSectionMap) {
        if (indexPath.row == TableSectionMapRowDownloadMaps) {
            [[USHSettings sharedInstance] setDownloadMaps:on];
        }
    }
}

#pragma mark - USHSliderTableCellDelegate

- (void) sliderTableViewCell:(USHSliderTableCell *)cell index:(NSIndexPath *)indexPath value:(NSInteger)value {
    if (indexPath.section == TableSectionPhoto) {
        if (indexPath.row == TableSectionPhotoRowImageSize) {
            [[USHSettings sharedInstance] setImageWidth:value];
        }
    }
}

#pragma mark - USHShareController

- (void) shareOpenURL:(USHShareController*)share {
    [share openURL:[[USHSettings sharedInstance] appStoreURL]];
}

- (void) shareSendSMS:(USHShareController*)share {
    [share sendSMS:[NSString stringWithFormat:@"%@ %@ %@", [[USHSettings sharedInstance] appName], [[USHSettings sharedInstance] appVersion], [[USHSettings sharedInstance] appStoreURL]]];
}

- (void) shareSendEmail:(USHShareController*)share {
    [share sendEmail:[[USHSettings sharedInstance] appStoreURL]
             subject:[NSString stringWithFormat:@"%@ %@", [[USHSettings sharedInstance] appName], [[USHSettings sharedInstance] appVersion]]
          attachment:nil
            fileName:nil
           recipient:nil];
}

- (void) shareSendTweet:(USHShareController*)share {
    [share sendTweet:[NSString stringWithFormat:@"%@ %@", [[USHSettings sharedInstance] appName], [[USHSettings sharedInstance] appVersion]]
                 url:[[USHSettings sharedInstance] appStoreURL]];
}

- (void) sharePostFacebook:(USHShareController*)share {
    [share postFacebook:[NSString stringWithFormat:@"%@ %@", [[USHSettings sharedInstance] appName], [[USHSettings sharedInstance] appVersion]]
                    url:[[USHSettings sharedInstance] appStoreURL]];
}

@end
