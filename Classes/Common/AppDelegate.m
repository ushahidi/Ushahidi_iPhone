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

#import "AppDelegate.h"
#import "NavigationController.h"
#import "DeploymentTableViewController.h"
#import "IncidentTabViewController.h"
#import "CheckinTabViewController.h"
#import "IncidentDetailsViewController.h"
#import "CategorySelectViewController.h"
#import "UserSelectViewController.h"
#import "SettingsViewController.h"
#import "SplashViewController.h"
#import "Deployment.h"
#import "Settings.h"
#import "Device.h"
#import "NSString+Extension.h"
#import "Ushahidi.h"
#import "Device.h"
#import "BaseViewController.h"

@interface AppDelegate()

@end

@implementation AppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize deploymentTableViewController;
@synthesize incidentTabViewController; 
@synthesize incidentDetailsViewController; 
@synthesize checkinTabViewController;
@synthesize splitViewController;
@synthesize categorySelectViewController;
@synthesize userSelectViewController;
@synthesize settingsViewController;
@synthesize splashViewController;

- (void)pushDetailsViewController:(BaseViewController *)viewController animated:(BOOL)animated {
    DLog(@"");
    if ([Device isIPad]) {
        if ([viewController conformsToProtocol:@protocol(UISplitViewControllerDelegate)]) {
            DLog(@"UISplitViewControllerDelegate %@", viewController.nibName);
            self.splitViewController.delegate = (UIViewController<UISplitViewControllerDelegate>*)viewController;
        }
        NavigationController *detailNavigationController = [self.splitViewController.viewControllers objectAtIndex:1];
        [detailNavigationController pushViewController:viewController animated:animated];
    }
    else {
        [self.navigationController pushViewController:viewController animated:animated]; 
    }
}

- (void)setDetailsViewController:(BaseViewController *)viewController animated:(BOOL)animated {
    DLog(@"");
    if ([Device isIPad]) {
        if ([viewController conformsToProtocol:@protocol(UISplitViewControllerDelegate)]) {
            DLog(@"UISplitViewControllerDelegate %@", viewController.nibName);
            self.splitViewController.delegate = (UIViewController<UISplitViewControllerDelegate>*)viewController;
        }
        NavigationController *masterNavigationController = [self.splitViewController.viewControllers objectAtIndex:0];
        NavigationController *detailNavigationController = [self.splitViewController.viewControllers objectAtIndex:1];
        if (detailNavigationController.viewControllers.count > 0) {
            if ([detailNavigationController.viewControllers containsObject:viewController] &&
                detailNavigationController.topViewController != viewController) {
                [viewController viewWillBePushed];
                [detailNavigationController popToViewController:viewController animated:animated];
                [viewController viewWasPushed];
            }
            else {
                detailNavigationController = [[[NavigationController alloc] initWithRootViewController:viewController] autorelease];
                detailNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
                detailNavigationController.navigationBar.tintColor = [[Settings sharedSettings] navBarTintColor];
                [viewController viewWillBePushed];
                self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
                [viewController viewWasPushed];
            }
        }
        else {
            [detailNavigationController pushViewController:viewController animated:animated];
            [viewController viewWillBePushed];
            self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
            [viewController viewWasPushed];
        }        
    }
    else {
        [self.navigationController pushViewController:viewController animated:animated];
    }
}

- (void) showSettings:(id)sender {
	DLog(@"");
	self.settingsViewController.modalPresentationStyle = UIModalPresentationPageSheet;
	self.settingsViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    if ([Device isIPad]) {
        [self.splitViewController presentModalViewController:self.settingsViewController animated:YES];
    }
    else {
        [self.navigationController presentModalViewController:self.settingsViewController animated:YES];
    }
}

- (UIBarButtonItem*) getSettingsButton {
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [settingsButton addTarget:self action:@selector(showSettings:) forControlEvents:UIControlEventTouchUpInside];
    return [[[UIBarButtonItem alloc] initWithCustomView:settingsButton] autorelease];
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.applicationSupportsShakeToEdit = NO;
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    NSString *mapURL = [[Settings sharedSettings] mapURL];
	DLog(@"MapURL: %@", mapURL);
	
    NSString *mapName = [[Settings sharedSettings] mapName];
	DLog(@"MapName: %@", mapName);
	
    NSString *lastDeployment = [[Settings sharedSettings] lastDeployment];
	DLog(@"LastDeployment: %@", lastDeployment);
    
    NavigationController *masterNavigationController = [[[NavigationController alloc] init] autorelease];
    masterNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    masterNavigationController.navigationBar.tintColor = [[Settings sharedSettings] navBarTintColor];
    
    NavigationController *detailNavigationController = [[[NavigationController alloc] init] autorelease];
    detailNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    detailNavigationController.navigationBar.tintColor = [[Settings sharedSettings] navBarTintColor];
    
    if ([Device isIPad]) {
        self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
        self.navigationController = detailNavigationController;
    } 
    else {
        self.navigationController = masterNavigationController;
    }
    if ([NSString isNilOrEmpty:mapURL] == NO && [NSString isNilOrEmpty:mapName] == NO) {
		Deployment *deployment = [[[Ushahidi sharedUshahidi] getDeploymentWithUrl:mapURL] autorelease];
		if (deployment == nil) {
            self.splashViewController.shouldDismissOnAppear = NO;
            [masterNavigationController pushViewController:self.categorySelectViewController animated:NO];
            if ([Device isIPad]) {
                [self setDetailsViewController:self.incidentTabViewController animated:NO];
            }
            deployment = [[Deployment alloc] initWithName:mapName url:mapURL];
			[[Ushahidi sharedUshahidi] addDeployment:deployment];
			[[Ushahidi sharedUshahidi] loadDeployment:deployment];
			[[Ushahidi sharedUshahidi] getVersionOfDeployment:deployment forDelegate:self];
        }
		else {
            self.splashViewController.shouldDismissOnAppear = YES;
			[[Ushahidi sharedUshahidi] loadDeployment:deployment];	
			if (deployment.supportsCheckins) {
                self.checkinTabViewController.deployment = deployment;
                if ([Device isIPad]) {
                    [masterNavigationController pushViewController:self.userSelectViewController animated:NO];
                    self.checkinTabViewController.navigationItem.rightBarButtonItem = [self getSettingsButton];
                }
                else {
                    self.checkinTabViewController.navigationItem.leftBarButtonItem = [self getSettingsButton];
                }
                [self setDetailsViewController:self.checkinTabViewController animated:NO];
            }
			else {
				self.incidentTabViewController.deployment = deployment;
                if ([Device isIPad]) {
                    [masterNavigationController pushViewController:self.categorySelectViewController animated:NO];
                    self.incidentTabViewController.navigationItem.rightBarButtonItem = [self getSettingsButton];
                }
                else {
                    self.incidentTabViewController.navigationItem.leftBarButtonItem = [self getSettingsButton];
                }
                [self setDetailsViewController:self.incidentTabViewController animated:NO];
            }
		}
	}
	else if ([NSString isNilOrEmpty:lastDeployment] == NO) {
        self.splashViewController.shouldDismissOnAppear = YES;
		Deployment *deployment = [[Ushahidi sharedUshahidi] getDeploymentWithUrl:lastDeployment];
		if (deployment != nil) {
            [[Ushahidi sharedUshahidi] loadDeployment:deployment];
			if (deployment.supportsCheckins) {
                [masterNavigationController pushViewController:self.deploymentTableViewController animated:NO];
				self.checkinTabViewController.deployment = deployment;
                [self pushDetailsViewController:self.checkinTabViewController animated:NO];
			}
			else {
                [masterNavigationController pushViewController:self.deploymentTableViewController animated:NO];
				self.incidentTabViewController.deployment = deployment;
				NSString *lastIncident = [[Settings sharedSettings] lastIncident];
				if ([NSString isNilOrEmpty:lastIncident] == NO) {
					Incident *incident = [[Ushahidi sharedUshahidi] getIncidentWithIdentifer:lastIncident];
					if (incident != nil) {
                        [self pushDetailsViewController:self.incidentTabViewController animated:NO];
						self.incidentDetailsViewController.incident = incident;
						self.incidentDetailsViewController.incidents = [[Ushahidi sharedUshahidi] getIncidents];
						[self pushDetailsViewController:self.incidentDetailsViewController animated:NO];
    				}
					else {
                        [self pushDetailsViewController:self.incidentTabViewController animated:NO];
					}
				}
				else {
                    [self pushDetailsViewController:self.incidentTabViewController animated:NO];
				}
			}
		}
		else {
            [masterNavigationController pushViewController:self.deploymentTableViewController animated:NO];
            if ([Device isIPad]) {
                [self setDetailsViewController:self.incidentTabViewController animated:NO];
            }
        }
	}
	else  {
        self.splashViewController.shouldDismissOnAppear = YES;
        [masterNavigationController pushViewController:self.deploymentTableViewController animated:NO];
        if ([Device isIPad]) {
            [self setDetailsViewController:self.incidentTabViewController animated:NO];
        }   
    }
    self.splashViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    self.splashViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    if ([Device isIPad]) {
        [self.window addSubview:self.splitViewController.view];
        [self.splitViewController presentModalViewController:self.splashViewController animated:NO];
    } 
    else {
        [self.window addSubview:self.navigationController.view];
        [self.navigationController presentModalViewController:self.splashViewController animated:NO];
    }
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    DLog(@"");
	[[Settings sharedSettings] save];
	[[Ushahidi sharedUshahidi] archive];
}

#pragma mark -
#pragma mark Application's Documents directory

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	DLog(@"");
}

- (void)dealloc {
	DLog(@"");
    [deploymentTableViewController release];
    [incidentTabViewController release];
    [incidentDetailsViewController release];
    [checkinTabViewController release];
    [categorySelectViewController release];
    [userSelectViewController release];
    [splashViewController release];
    [navigationController release];
    [window release];
    [super dealloc];
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi version:(Deployment *)deployment {
	DLog(@"url:%@ version:%@ checkins:%d", deployment.url, deployment.version, deployment.supportsCheckins);
    if (deployment.supportsCheckins) {
        if ([Device isIPad]) {
            NavigationController *masterNavigationController = [self.splitViewController.viewControllers objectAtIndex:0];
            [masterNavigationController setViewController:self.userSelectViewController animated:NO];
            self.checkinTabViewController.navigationItem.rightBarButtonItem = [self getSettingsButton];
            self.splitViewController.delegate = self.checkinTabViewController;
        }
        else {
            self.checkinTabViewController.navigationItem.leftBarButtonItem = [self getSettingsButton];
        }
        self.checkinTabViewController.deployment = deployment;
        [self setDetailsViewController:self.checkinTabViewController animated:YES];
    }
    else {
        if ([Device isIPad]) {
            NavigationController *masterNavigationController = [self.splitViewController.viewControllers objectAtIndex:0];
            [masterNavigationController setViewController:self.categorySelectViewController animated:NO];
            self.incidentTabViewController.navigationItem.rightBarButtonItem = [self getSettingsButton];
            self.splitViewController.delegate = self.incidentTabViewController;
        }
        else {
            self.incidentTabViewController.navigationItem.leftBarButtonItem = [self getSettingsButton];
        }
        self.incidentTabViewController.deployment = deployment;
        [self setDetailsViewController:self.incidentTabViewController animated:YES];
    }
    [self.splashViewController dismissSplashViewController];
}

@end