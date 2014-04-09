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

#import "USHReportTabBarController.h"
#import "USHReportTableViewController.h"
#import "USHReportMapViewController.h"
#import "USHReportAddViewController.h"
#import "USHCheckinTableViewController.h"
#import "USHCategoryTableViewController.h"
#import "USHSettingsViewController.h"
#import <Ushahidi/USHMap.h>
#import <Ushahidi/USHCategory.h>
#import <Ushahidi/UIBarButtonItem+USH.h>
#import <Ushahidi/USHRefreshButtonItem.h>
#import <Ushahidi/UIViewController+USH.h>
#import <Ushahidi/UIEvent+USH.h>
#import <Ushahidi/UIAlertView+USH.h>
#import <Ushahidi/UIActionSheet+USH.h>
#import <Ushahidi/NSString+USH.h>
#import "USHSettings.h"
#import <Ushahidi/Ushahidi.h>
#import <Ushahidi/USHDevice.h>
#import <Ushahidi/NSBundle+USH.h>

@interface USHReportTabBarController ()

@property (strong, nonatomic) NSString *textSubmitViaUshahidiAPI;
@property (strong, nonatomic) NSString *textSubmitViaOpenGeoSMS;

@property (strong, nonatomic) USHItemPicker *itemPicker;
@property (strong, nonatomic) USHRefreshButtonItem *locateButton;
@property (strong, nonatomic) UIBarButtonItem *filterButton;

- (void)add:(id)sender event:(UIEvent*)event;

@end

@implementation USHReportTabBarController

@synthesize reportTableController = _reportTableController;
@synthesize reportMapController = _reportMapController;
@synthesize categoryTableController = _categoryTableController;
@synthesize settingsViewController = _settingsViewController;
@synthesize itemPicker = _itemPicker;
@synthesize filterButton = _filterButton;
@synthesize locateButton = _locateButton;
@synthesize reportAddController = _reportAddController;
@synthesize checkinTableController = _checkinTableController;
@synthesize textSubmitViaUshahidiAPI = _textSubmitViaUshahidiAPI;
@synthesize textSubmitViaOpenGeoSMS = _textSubmitViaOpenGeoSMS;

#pragma mark - IBActions

- (void)add:(id)sender event:(UIEvent*)event {
    DLog(@"");
    if ([[USHSettings sharedInstance] openGeoSMS] &&
        [NSString isNilOrEmpty:self.map.sms] == NO) {
        [UIActionSheet showWithTitle:nil
                            delegate:self
                               event:event
                              cancel:NSLocalizedString(@"Cancel", nil)
                             buttons:self.textSubmitViaOpenGeoSMS, self.textSubmitViaUshahidiAPI, nil];
    }
    else {
        self.reportAddController.openGeoSMS = NO;
        self.reportAddController.map = self.map;
        self.reportAddController.report = [[Ushahidi sharedInstance] addReportForMap:self.map];
        self.reportAddController.modalPresentationStyle = UIModalPresentationPageSheet;
        self.reportAddController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:self.reportAddController animated:YES];
    }
}

- (IBAction)filter:(id)sender event:(UIEvent*)event {
    DLog(@"");
	NSMutableArray *titles = [NSMutableArray arrayWithObject:NSLocalizedString(@"--- ALL CATEGORIES ---", nil)];
	for (USHCategory *category in self.map.categoriesSortedByPosition) {
		if (category.title != nil) {
			[titles addObject:category.title];
		}
	}
    [self.itemPicker showWithItems:titles 
                          selected:self.category.title
                             event:event
                               tag:0];
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

#pragma mark - USHMap

- (USHMap*)map {
    return self.reportTableController.map;
}

- (void) setMap:(USHMap *)map {
    self.navigationItem.title = map.name;
    self.reportTableController.map = map;
    self.reportMapController.map = map;
    self.categoryTableController.map = map;
    self.checkinTableController.map = map;
}

#pragma mark - USHCategory

- (USHCategory*) category {
    return self.reportTableController.category;
}

- (void) setCategory:(USHCategory *)category {
    self.reportMapController.category = category;
    self.reportTableController.category = category;
}

#pragma mark - UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.textSubmitViaUshahidiAPI = NSLocalizedString(@"Upload via Ushahidi API", nil);
    self.textSubmitViaOpenGeoSMS = NSLocalizedString(@"Send via OpenGeoSMS", nil);
    self.itemPicker = [[USHItemPicker alloc] initWithController:self];
    
    if ([[USHSettings sharedInstance] showReportButton]) {
        [self addMiddleButtonWithImage:[UIImage imageNamed:@"action.png"]
                        highlightImage:[UIImage imageNamed:@"action_click.png"]
                                action:@selector(add:event:)];
    }
    self.locateButton = [[USHRefreshButtonItem alloc] initWithImage:[UIImage imageNamed:@"locate.png"]
                                                           tintColor:[[USHSettings sharedInstance] navBarColor]
                                                              target:self.reportMapController
                                                              action:@selector(locate:event:)];
    self.filterButton = [UIBarButtonItem borderedItemWithImage:[UIImage imageNamed:@"filter.png"]
                                                     tintColor:[[USHSettings sharedInstance] navBarColor] 
                                                        target:self
                                                        action:@selector(filter:event:)];
    if ([USHDevice isIPad] && [USHDevice isLandscapeMode]) {
        NSBundle *bundle = [NSBundle bundleWithName:@"Ushahidi.bundle"];
        NSString *hidePath = [bundle pathForResource:@"hide" ofType:@"png"];
        self.leftBarButtonItem = [UIBarButtonItem borderedItemWithImage:[UIImage imageWithContentsOfFile:hidePath]
                                                              tintColor:[[USHSettings sharedInstance] navBarColor]
                                                                 target:[[UIApplication sharedApplication] delegate]
                                                                 action:@selector(sidebar:event:)];
    }
    if ([USHDevice isIPhone] && [[USHSettings sharedInstance] hasMapURL]) {
        [self setTitleViewWithImage:@"Logo-Title.png" orText:[[USHSettings sharedInstance] appName]];
        self.leftBarButtonItem = [UIBarButtonItem infoItemWithTarget:self action:@selector(info:event:)];
        self.rightBarButtonItem = [self barButtonWithItems:self.filterButton, nil];
    }
    else if ([USHDevice isIPad] && [[USHSettings sharedInstance] hasMapURL]) {
        self.rightBarButtonItem = nil;
    }
    else {
        self.rightBarButtonItem = [self barButtonWithItems:self.filterButton, nil];
    }
    self.reportTableController.title = NSLocalizedString(@"List", nil);
    self.reportMapController.title = NSLocalizedString(@"Map", nil);
    self.backBarButtonTitle = NSLocalizedString(@"Reports", nil);
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.itemPicker = nil;
    self.locateButton = nil;
    self.filterButton = nil;
}

#pragma mark - UISplitViewController

- (void)splitViewController:(UISplitViewController *)splitController 
     willHideViewController:(UIViewController *)viewController 
          withBarButtonItem:(UIBarButtonItem *)barButtonItem 
       forPopoverController:(UIPopoverController *)popoverController {
    DLog(@"%@", viewController.class);
    barButtonItem.style = UIBarButtonItemStyleDone;
    if ([barButtonItem respondsToSelector:@selector(tintColor)]) {
        barButtonItem.tintColor = [[USHSettings sharedInstance] buttonDoneColor];
    }
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)splitController 
     willShowViewController:(UIViewController *)viewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    DLog(@"%@", viewController.class);
    
    NSBundle *bundle = [NSBundle bundleWithName:@"Ushahidi.bundle"];
    NSString *hidePath = [bundle pathForResource:@"hide" ofType:@"png"];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem borderedItemWithImage:[UIImage imageWithContentsOfFile:hidePath]
                                                                         tintColor:[[USHSettings sharedInstance] navBarColor]
                                                                            target:[[UIApplication sharedApplication] delegate] 
                                                                            action:@selector(sidebar:event:)];
}

- (BOOL)splitViewController: (UISplitViewController*)splitController 
   shouldHideViewController:(UIViewController *)viewController 
              inOrientation:(UIInterfaceOrientation)orientation {
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return NO;
    }
    if (orientation == UIInterfaceOrientationLandscapeRight) {
        return NO;
    }
    if (orientation == UIInterfaceOrientationPortrait) {
        return YES;
    }
    if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return YES;
    }
    return NO;
}

#pragma mark - USHItemPickerDelegate

- (void) itemPickerReturned:(USHItemPicker *)itemPicker item:(NSString *)item index:(NSInteger)index {
    DLog(@"%d : %@", index, item); 
    if (index == 0) {
        self.category = nil;
        self.reportMapController.category = nil;
        self.reportTableController.category = nil;
    }
    else {
        for (USHCategory *category in self.map.categories) {
            if ([category.title isEqualToString:item]) {
                self.category = category;
                self.reportMapController.category = category;
                self.reportTableController.category = category;
                break;
            }
        }   
    }
}

- (void) itemPickerCancelled:(USHItemPicker *)itemPicker {
    DLog(@"");
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (viewController == self.reportTableController) {
        DLog(@"USHReportTableViewController");
        if ([[USHSettings sharedInstance] hasMapURL] && [USHDevice isIPad]) {
            self.rightBarButtonItem = nil;
        }
        else {
            self.rightBarButtonItem = [self barButtonWithItems:self.filterButton, nil];
        }
    }
    else if (viewController == self.reportMapController) {
        DLog(@"USHReportMapViewController");
        if ([[USHSettings sharedInstance] hasMapURL] && [USHDevice isIPad]) {
            self.rightBarButtonItem = [self barButtonWithItems:self.locateButton, nil];
        }
        else {
            self.rightBarButtonItem = [self barButtonWithItems:self.locateButton, self.filterButton, nil];
        }
    }
    else if (viewController == self.checkinTableController) {
        DLog(@"USHCheckinTableViewController");
    }
    else {
        DLog(@"%@", viewController.class);
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([buttonTitle isEqualToString:self.textSubmitViaUshahidiAPI]) {
            self.reportAddController.openGeoSMS = NO;
        }
        else if ([buttonTitle isEqualToString:self.textSubmitViaOpenGeoSMS]) {
            self.reportAddController.openGeoSMS = YES;
        }
        self.reportAddController.map = self.map;
        self.reportAddController.report = [[Ushahidi sharedInstance] addReportForMap:self.map];
        self.reportAddController.modalPresentationStyle = UIModalPresentationPageSheet;
        self.reportAddController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:self.reportAddController animated:YES];
    }
}

@end
