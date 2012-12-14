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

#import "USHAppDelegateMain.h"
#import "USHMapTableViewController.h"
#import "USHReportTabBarController.h"
#import "USHSettingsViewController.h"
#import "USHReportAddViewController.h"
#import "USHFilterViewController.h"
#import <Ushahidi/USHDevice.h>
#import <Ushahidi/USHViewController.h>
#import <Ushahidi/USHTableViewController.h>
#import <Ushahidi/USHTabBarController.h>
#import <Ushahidi/USHShareController.h>
#import <Ushahidi/USHWindow.h>
#import <Ushahidi/Ushahidi.h>
#import <Ushahidi/NSString+USH.h>
#import <Ushahidi/UIAlertView+USH.h>
#import <Ushahidi/UIBarButtonItem+USH.h>
#import "USHSettings.h"

@interface USHAppDelegateMain ()

@property (strong, nonatomic) NSString *textTermsOfService;
@property (strong, nonatomic) NSString *textPrivacyPolicy;

- (void) viewDidLoad:(NSNotification *)notification;
- (void) showUserAgreement;

- (USHMap*) loadCustomMap;
- (NSArray*) loadCustomMaps;

- (UINavigationController*) navigationControllerWithRootViewController:(UIViewController*)controller;
- (UISplitViewController*) splitViewControllerWithDelegate:(id<UISplitViewControllerDelegate>)delegate master:(UIViewController*)masterViewController details:(UIViewController*)detailsViewController;
@end

@implementation USHAppDelegateMain

@synthesize filterViewController = _filterViewController;
@synthesize mapTableViewController = _mapTableViewController;
@synthesize reportTabBarController = _reportTabBarController;
@synthesize settingsViewController = _settingsViewController;
@synthesize reportAddViewController = _reportAddViewController;
@synthesize textTermsOfService = _textTermsOfService;
@synthesize textPrivacyPolicy = _textPrivacyPolicy;

#pragma mark - Helpers

- (void) updateIconBadgeNumber {
    NSInteger badgeNumber = 0;
    if ([[USHSettings sharedInstance] showBadgeNumber]) {
        for (USHMap *map in [[Ushahidi sharedInstance] maps]) {
            for (USHReport *report in map.reports) {
                if (report.viewed == nil) {
                    badgeNumber += 1;
                }
            }
        }
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
}

- (void) showUserAgreement {
    if ([NSString isNilOrEmpty:[[USHSettings sharedInstance] termsOfServiceURL]] == NO ||
        [NSString isNilOrEmpty:[[USHSettings sharedInstance] privacyPolicyURL]] == NO) {
        if ([[USHSettings sharedInstance] termsOfService] == NO) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"User Agreement", nil)
                                                                 message:NSLocalizedString(@"By using this app, you agree to the following terms and policy:", nil)
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"I Agree", nil)
                                                       otherButtonTitles:nil] autorelease];
            if ([NSString isNilOrEmpty:[[USHSettings sharedInstance] termsOfServiceURL]] == NO) {
                self.textTermsOfService = NSLocalizedString(@"Terms Of Service", nil);
                [alertView addButtonWithTitle:self.textTermsOfService];
            }
            if ([NSString isNilOrEmpty:[[USHSettings sharedInstance] privacyPolicyURL]] == NO) {
                self.textPrivacyPolicy = NSLocalizedString(@"Privacy Policy", nil);
                [alertView addButtonWithTitle:self.textPrivacyPolicy];
            }
            [alertView show];
        }
    }
}

#pragma mark - UIApplication

- (void)dealloc {
    [_mapTableViewController release];
    [_reportTabBarController release];
    [_reportAddViewController release];
    [_settingsViewController release];
    [_textTermsOfService release];
    [_textPrivacyPolicy release];
    [_filterViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //#################### STYLING ####################
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidLoad:) name:USHViewDidLoad object:nil];
    //#################### USHAHIDI ####################
    [[Ushahidi sharedInstance] setYoutubeUsername:[[USHSettings sharedInstance] youtubeUsername]];
    [[Ushahidi sharedInstance] setYoutubePassword:[[USHSettings sharedInstance] youtubePassword]];
    [[Ushahidi sharedInstance] setYoutubeDeveloperKey:[[USHSettings sharedInstance] youtubeDeveloperKey]];
    //#################### WINDOW ####################
    if ([USHDevice isIPad]) {
        if ([[USHSettings sharedInstance] hasMapURL]) {
            if ([[USHSettings sharedInstance] showReportList]) {
                USHMap *map = [self loadCustomMap];
                self.filterViewController.map = map;
                self.reportTabBarController.map = map;
                self.splitViewController = [self splitViewControllerWithDelegate:self.reportTabBarController
                                                                          master:self.filterViewController
                                                                         details:self.reportTabBarController];
                self.window.rootViewController = self.splitViewController;
            }
            else {
                USHMap *map = [self loadCustomMap];
                self.reportAddViewController.map = map;
                self.reportAddViewController.report = [[Ushahidi sharedInstance] addReportForMap:map];
                self.window.rootViewController = [self navigationControllerWithRootViewController:self.reportAddViewController];
            }
        }
        else if ([[USHSettings sharedInstance] hasMapURLS]) {
            [self loadCustomMaps];
            self.splitViewController = [self splitViewControllerWithDelegate:self.reportTabBarController
                                                                      master:self.mapTableViewController
                                                                     details:self.reportTabBarController];
            self.window.rootViewController = self.splitViewController;
        }
        else {
            self.splitViewController = [self splitViewControllerWithDelegate:self.reportTabBarController
                                                                      master:self.mapTableViewController
                                                                     details:self.reportTabBarController];
            self.window.rootViewController = self.splitViewController;
        }
    } 
    else {
        if ([[USHSettings sharedInstance] hasMapURL]) {
            if ([[USHSettings sharedInstance] showReportList]) {
                self.reportTabBarController.map = [self loadCustomMap];
                self.window.rootViewController = [self navigationControllerWithRootViewController:self.reportTabBarController];
            }
            else {
                USHMap *map = [self loadCustomMap];
                self.reportAddViewController.map = map;
                self.reportAddViewController.report = [[Ushahidi sharedInstance] addReportForMap:map];
                self.window.rootViewController = [self navigationControllerWithRootViewController:self.reportAddViewController];
            }
        }
        else if ([[USHSettings sharedInstance] hasMapURLS]) {
            [self loadCustomMaps];
            self.window.rootViewController = [self navigationControllerWithRootViewController:self.mapTableViewController];
        }
        else {
            self.window.rootViewController = [self navigationControllerWithRootViewController:self.mapTableViewController];
        }
    }
    [self.window setFrame:[[UIScreen mainScreen] bounds]];
    [self statusBarHidden:[[USHSettings sharedInstance] hideStatusBar] animated:NO];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [super applicationWillResignActive:application];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:USHViewDidLoad object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [super applicationDidBecomeActive:application];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:USHViewDidLoad object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidLoad:) name:USHViewDidLoad object:nil];
    [self showUserAgreement];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [super applicationWillTerminate:application];
    [self updateIconBadgeNumber];
    for (USHMap *map in [[Ushahidi sharedInstance] maps]) {
        map.syncing = [NSNumber numberWithBool:NO];
    }
    [[Ushahidi sharedInstance] saveChanges];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [super applicationDidEnterBackground:application];
    [self updateIconBadgeNumber];
    for (USHMap *map in [[Ushahidi sharedInstance] maps]) {
        map.syncing = [NSNumber numberWithBool:NO];
    }
    [[Ushahidi sharedInstance] saveChanges];
}

#pragma mark - NSNotification

- (void) viewDidLoad:(NSNotification *)notification {
    if ([notification.object isKindOfClass:UINavigationController.class]) {
        DLog(@"UINavigationController %@", notification.object);
        UINavigationController *navigationController = (UINavigationController*)notification.object;
        navigationController.navigationBar.tintColor = [[USHSettings sharedInstance] navBarColor];
    }
    if ([notification.object isKindOfClass:USHViewController.class]) {
        DLog(@"USHViewController %@", notification.object);
        USHViewController *viewController = (USHViewController*)notification.object;
        viewController.navBarColor = [[USHSettings sharedInstance] navBarColor];
        viewController.toolBarColor = [[USHSettings sharedInstance] toolBarColor];
        viewController.buttonDoneColor = [[USHSettings sharedInstance] buttonDoneColor];
    }
    if ([notification.object isKindOfClass:USHTableViewController.class]) {
        DLog(@"USHTableViewController %@", notification.object);
        USHTableViewController *tableViewController = (USHTableViewController*)notification.object;
        tableViewController.tableRowColor = [[USHSettings sharedInstance] tableRowColor];
        tableViewController.tableRowSelectColor = [[USHSettings sharedInstance] tableSelectColor];
        tableViewController.tableHeaderTextColor = [[USHSettings sharedInstance] tableHeaderColor];
        tableViewController.tablePlainBackColor = [[USHSettings sharedInstance] tableBackColor];
        tableViewController.tableGroupedBackColor = [[USHSettings sharedInstance] tableBackColor];
        tableViewController.searchBarColor = [[USHSettings sharedInstance] searchBarColor];
        tableViewController.refreshControlColor = [[USHSettings sharedInstance] refreshControlColor];
    }
    if ([notification.object isKindOfClass:USHTabBarController.class]) {
        DLog(@"USHTabBarController %@", notification.object);
        USHTabBarController *tabBarController = (USHTabBarController*)notification.object;
        tabBarController.navBarColor = [[USHSettings sharedInstance] navBarColor];
        tabBarController.tabBarColor = [[USHSettings sharedInstance] tabBarColor];
    }
    if ([notification.object isKindOfClass:USHShareController.class]) {
        DLog(@"USHShareController %@", notification.object);
        USHShareController *shareController = (USHShareController*)notification.object;
        shareController.navBarColor = [[USHSettings sharedInstance] navBarColor];
    }
}

#pragma mark - NSNotification

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex == buttonIndex) {
        [[USHSettings sharedInstance] setTermsOfService:YES];
    }
    else {
        NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
        if ([buttonTitle isEqualToString:self.textTermsOfService]) {
            NSURL *termsOfServiceURL = [NSURL URLWithString:[[USHSettings sharedInstance] termsOfServiceURL]];
            [[UIApplication sharedApplication] openURL:termsOfServiceURL];
        }
        else if ([buttonTitle isEqualToString:self.textPrivacyPolicy]) {
            NSURL *privacyPolicyURL = [NSURL URLWithString:[[USHSettings sharedInstance] privacyPolicyURL]];
            [[UIApplication sharedApplication] openURL:privacyPolicyURL];
        }
    }
}

#pragma mark - Custom Maps

- (USHMap*) loadCustomMap {
    if ([[USHSettings sharedInstance] hasMapURL]) {
        NSString *url = [[USHSettings sharedInstance] mapURL];
        if ([[Ushahidi sharedInstance] hasMapWithUrl:url]) {
            return [[Ushahidi sharedInstance] mapWithUrl:url];
        }
        else {
            NSString *name = [[USHSettings sharedInstance] mapName];
            return [[Ushahidi sharedInstance] addMapWithUrl:url title:name];
        }
    }
    return nil;
}

- (NSArray*) loadCustomMaps {
    if ([[[Ushahidi sharedInstance] maps] count] == 0) {
        NSDictionary *maps = [[USHSettings sharedInstance] mapURLs];
        for (NSString *name in maps.allKeys) {
            NSString *url = [maps objectForKey:name];
            if ([[Ushahidi sharedInstance] hasMapWithUrl:url]) {
                DLog(@"Exists %@ %@", name, url);
            }
            else {
                DLog(@"Added %@ %@", name, url);
                [[Ushahidi sharedInstance] addMapWithUrl:url title:name];
            }
        }
        [[Ushahidi sharedInstance] saveChanges];
        return [[Ushahidi sharedInstance] maps];
    }
    return [NSArray array];
}

#pragma mark - Helpers

- (UINavigationController*) navigationControllerWithRootViewController:(UIViewController*)controller {
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
    navigationController.navigationBar.tintColor = [[USHSettings sharedInstance] navBarColor];
    return navigationController;
}

- (UISplitViewController*) splitViewControllerWithDelegate:(id<UISplitViewControllerDelegate>)delegate master:(UIViewController*)masterViewController details:(UIViewController*)detailsViewController {
    UISplitViewController *splitViewController = [[[UISplitViewController alloc] init] autorelease];
    UINavigationController *navigationController = [self navigationControllerWithRootViewController:detailsViewController];
    splitViewController.viewControllers = [NSArray arrayWithObjects:masterViewController, navigationController, nil];
    splitViewController.delegate = delegate;
    return splitViewController;
}

@end
