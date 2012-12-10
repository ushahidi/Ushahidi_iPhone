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

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "BaseMapViewController.h"
#import "Ushahidi.h"
#import "Photo.h"

@class CheckinTabViewController;
@class CheckinAddViewController;
@class CheckinDetailsViewController;
@class Deployment;

@interface CheckinMapViewController : BaseMapViewController<UshahidiDelegate, 
															MKMapViewDelegate> {
@public
	CheckinTabViewController *checkinTabViewController;
	CheckinAddViewController *checkinAddViewController;
	CheckinDetailsViewController *checkinDetailsViewController;
	Deployment *deployment;
}

@property(nonatomic,retain) IBOutlet CheckinTabViewController *checkinTabViewController;
@property(nonatomic,retain) IBOutlet CheckinAddViewController *checkinAddViewController;
@property(nonatomic,retain) IBOutlet CheckinDetailsViewController *checkinDetailsViewController;
@property(nonatomic,retain) Deployment *deployment;

- (void) populate:(NSArray*)items filter:(NSObject*)filter;

@end
