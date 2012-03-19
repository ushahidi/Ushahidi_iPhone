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
#import <QuartzCore/QuartzCore.h>
#import "BaseViewController.h"
#import "Ushahidi.h"

@interface BaseMapViewController : BaseViewController<UshahidiDelegate> {

@public
    UIButton *flipView;
    MKMapView *mapView;
	UISegmentedControl *mapType;
	UIButton *infoButton;
    UILabel *filterLabel;
    NSObject *filter;
	NSMutableArray *allPins;
	NSMutableArray *filteredPins;
    NSMutableArray *pendingPins;
    NSMutableArray *filters;
    
@private
    BOOL flipped;
}

@property(nonatomic,retain) IBOutlet MKMapView *mapView;
@property(nonatomic,retain) IBOutlet UIButton *flipView;
@property(nonatomic,retain) IBOutlet UISegmentedControl *mapType;
@property(nonatomic,retain) IBOutlet UIButton *infoButton;
@property(nonatomic,retain) IBOutlet UILabel *filterLabel;
@property(nonatomic,retain) NSObject *filter;
@property(nonatomic,retain) NSMutableArray *allPins;
@property(nonatomic,retain) NSMutableArray *filteredPins;
@property(nonatomic,retain) NSMutableArray *pendingPins;
@property(nonatomic,retain) NSMutableArray *filters;

- (void) populate:(NSArray*)items filter:(NSObject*)filter;
- (IBAction) showInfo:(id)sender event:(UIEvent*)event;
- (IBAction) mapTypeChanged:(id)sender event:(UIEvent*)event;
- (IBAction) mapTypeCancelled:(id)sender event:(UIEvent*)event;

@end
