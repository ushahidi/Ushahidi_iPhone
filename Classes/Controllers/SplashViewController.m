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

#import "SplashViewController.h"
#import "DeploymentTableViewController.h"
#import "IncidentTabViewController.h"
#import "CheckinTabViewController.h"
#import "IncidentDetailsViewController.h"
#import "Deployment.h"
#import "Settings.h"
#import "NSString+Extension.h"

@interface SplashViewController ()

- (void) pushNextViewController;

@end

@implementation SplashViewController

@synthesize deploymentTableViewController, incidentTabViewController, incidentDetailsViewController, checkinTabViewController;

#pragma mark -
#pragma mark private

- (void) pushNextViewController {
	NSString *mapURL = [[Settings sharedSettings] mapURL];
	DLog(@"MapURL: %@", mapURL);
	NSString *mapName = [[Settings sharedSettings] mapName];
	DLog(@"MapName: %@", mapName);
	NSString *lastDeployment = [[Settings sharedSettings] lastDeployment];
	DLog(@"LastDeployment: %@", lastDeployment);
	if ([NSString isNilOrEmpty:mapURL] == NO && [NSString isNilOrEmpty:mapName] == NO) {
		Deployment *deployment = [[Ushahidi sharedUshahidi] getDeploymentWithUrl:mapURL];
		if (deployment == nil) {
			deployment = [[Deployment alloc] initWithName:mapName url:mapURL];
			[[Ushahidi sharedUshahidi] addDeployment:deployment];
			[[Ushahidi sharedUshahidi] loadDeployment:deployment];
			[[Ushahidi sharedUshahidi] getVersionOfDeployment:deployment forDelegate:self];
		}
		else {
			[[Ushahidi sharedUshahidi] loadDeployment:deployment];	
			if (deployment.supportsCheckins) {
				self.checkinTabViewController.deployment = deployment;
				[self.navigationController pushViewController:self.checkinTabViewController animated:YES];	
			}
			else {
				self.incidentTabViewController.deployment = deployment;
				[self.navigationController pushViewController:self.incidentTabViewController animated:YES];
			}
		}
	}
	else if ([NSString isNilOrEmpty:lastDeployment] == NO) {
		Deployment *deployment = [[Ushahidi sharedUshahidi] getDeploymentWithUrl:lastDeployment];
		if (deployment != nil) {
			[self.navigationController pushViewController:self.deploymentTableViewController animated:NO];
			[[Ushahidi sharedUshahidi] loadDeployment:deployment];
			if (deployment.supportsCheckins) {
				self.checkinTabViewController.deployment = deployment;
				[self.navigationController pushViewController:self.checkinTabViewController animated:YES];	
			}
			else {
				self.incidentTabViewController.deployment = deployment;
				NSString *lastIncident = [[Settings sharedSettings] lastIncident];
				if ([NSString isNilOrEmpty:lastIncident] == NO) {
					Incident *incident = [[Ushahidi sharedUshahidi] getIncidentWithIdentifer:lastIncident];
					if (incident != nil) {
						[self.navigationController pushViewController:self.incidentTabViewController animated:NO];
						self.incidentDetailsViewController.incident = incident;
						self.incidentDetailsViewController.incidents = [[Ushahidi sharedUshahidi] getIncidents];
						[self.navigationController pushViewController:self.incidentDetailsViewController animated:YES];
					}
					else {
						[self.navigationController pushViewController:self.incidentTabViewController animated:YES];
					}
				}
				else {
					[self.navigationController pushViewController:self.incidentTabViewController animated:YES];			
				}
			}
		}
		else {
			[self.navigationController pushViewController:self.deploymentTableViewController animated:YES];
		}
	}
	else {
		[self.navigationController pushViewController:self.deploymentTableViewController animated:YES];
	}	
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self.deploymentTableViewController setBackButtonTitle:NSLocalizedString(@"Maps", nil)];
	[self.incidentTabViewController setBackButtonTitle:NSLocalizedString(@"Reports", nil)];
	[self.incidentDetailsViewController setBackButtonTitle:NSLocalizedString(@"Report", nil)];
	[self.checkinTabViewController setBackButtonTitle:NSLocalizedString(@"Checkins", nil)];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self performSelector:@selector(pushNextViewController) withObject:nil afterDelay:0.0];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	if (self.navigationController.modalViewController == nil) {
		[self.navigationController setNavigationBarHidden:NO animated:animated];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[deploymentTableViewController release];
	[incidentTabViewController release];
	[incidentDetailsViewController release];
	[checkinTabViewController release];
    [super dealloc];
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi version:(Deployment *)deployment {
	DLog(@"url: %@ version: %@ checkins: %d", deployment.url, deployment.version, deployment.supportsCheckins);
	if (deployment.supportsCheckins) {
		self.checkinTabViewController.deployment = deployment;
		[self.navigationController pushViewController:self.checkinTabViewController animated:YES];	
	}
	else {
		self.incidentTabViewController.deployment = deployment;
		[self.navigationController pushViewController:self.incidentTabViewController animated:YES];
	}
}

@end
