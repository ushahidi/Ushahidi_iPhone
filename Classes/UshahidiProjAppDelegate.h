//
//  UshahidiProjAppDelegate.h
//  UshahidiProj
//
//  Created by iSoft Solutions on 23/02/10.
//  Copyright iSoft Solutions 2010. All rights reserved.
//

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

