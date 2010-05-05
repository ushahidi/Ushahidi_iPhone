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

@class API;
@class MKMapView;
@interface UshahidiProjAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	API *instanceAPI;
	NSString *urlString,*fname,*lname,*emailStr;
	NSString *dt,*cat,*lat,*lng;
	MKMapView *mapView;
	NSArray *incidentArray;
	NSArray *mapArray;
	NSMutableArray *imgArray;
	NSString *mapType;
	NSString *reports;
	float tempLat,tempLng;
	NSArray *arrCategory;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic,retain) NSString *urlString,*fname,*lname,*emailStr;
@property (nonatomic,retain) NSString *dt,*cat,*lat,*lng;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) NSArray *incidentArray;
@property (nonatomic, retain) NSArray *mapArray;
@property (nonatomic, retain) NSMutableArray *imgArray;
@property (nonatomic, retain) NSString *mapType;
@property (nonatomic, retain) NSString *reports;
@property (nonatomic, readwrite) float tempLat,tempLng;
@property (nonatomic, retain) NSArray *arrCategory;
// Definitions of Methods of Implementation
- (NSArray *)getCategories;
- (NSArray *)getAllIncidents;
-(NSArray *)getMapCentre;
-(BOOL)postData:(NSMutableDictionary *)dict;
-(BOOL)postDataWithImage:(NSMutableDictionary *)dict;

- (NSArray *)getCategoriesByid:(int)catid;

-(void) showUser;


@end

