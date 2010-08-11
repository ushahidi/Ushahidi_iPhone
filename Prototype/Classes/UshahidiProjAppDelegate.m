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

#import "UshahidiProjAppDelegate.h"
#import "RootViewController.h"
#import "API.h"
#import <MapKit/MapKit.h>

@implementation UshahidiProjAppDelegate

@synthesize window;
@synthesize navigationController,urlString,fname,lname,emailStr,mapView;
@synthesize dt,cat,lat,lng;
@synthesize incidentArray,imgArray,reports,mapType,mapArray,tempLat,tempLng,arrCategory;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
	fname = @"";
	lname = @"";
	emailStr = @"";
	reports = @"100";
	mapType = @"Google Stardard";
	urlString = @"demo.ushahidi.com";
	[mapType retain];
	[urlString retain];
	
	NSUserDefaults *st = [NSUserDefaults standardUserDefaults];
	if([st objectForKey:@"maptype"])
	{
		mapType = [st objectForKey:@"maptype"];
		reports = [st objectForKey:@"reports"];
		emailStr = [st objectForKey:@"email"];
		urlString = [st objectForKey:@"urlString"];
		fname = [st objectForKey:@"fname"];
		lname = [st objectForKey:@"lname"];
	}

	// Override point for customization after app launch    
	instanceAPI = [[API alloc] init];
	mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	mapView.showsUserLocation = YES;
	incidentArray = [[NSMutableArray alloc] init];
	mapArray = [[NSMutableArray alloc] init];
	imgArray = [[NSMutableArray alloc] init];
	arrCategory = [[NSMutableArray alloc] init];
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}

-(void) showUser
{
	NSArray *existingpoints = mapView.annotations;
	if([existingpoints count] > 0)
		[mapView removeAnnotations:existingpoints];
	
	if ([mapView showsUserLocation] == NO) {
        [mapView setShowsUserLocation:YES];
		
    }
	return;
}
- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}

-(NSArray *)getMapCentre
{
	return [instanceAPI mapLocation];
}
- (NSArray *)getCategories {
	return [instanceAPI categoryNames];
}

- (NSArray *)getAllIncidents {
	return [instanceAPI allIncidents];
}

-(BOOL)postData:(NSMutableDictionary *)dict
{
	return [instanceAPI postIncidentWithDictionary:dict];
}
-(BOOL)postDataWithImage:(NSMutableDictionary *)dict
{
	return [instanceAPI postIncidentWithDictionaryWithPhoto:dict];
}

- (NSArray *)getCategoriesByid:(int)catid {
	return [instanceAPI incidentsByCategoryId:catid];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

