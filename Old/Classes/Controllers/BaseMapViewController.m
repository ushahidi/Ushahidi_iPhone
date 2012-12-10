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

#import "BaseMapViewController.h"
#import "Settings.h"

@interface BaseMapViewController()

@property(nonatomic,assign) BOOL flipped;
- (void) pageCurl:(BOOL)up fillMode:(NSString*)fillMode type:(NSString*)type duration:(CGFloat)duration;

@end

@implementation BaseMapViewController

@synthesize mapView, flipView, mapType, infoButton, filterLabel, filter, allPins, filteredPins, pendingPins, filters, flipped;

#pragma mark -
#pragma mark Handlers

- (void) populate:(NSArray*)items filter:(NSObject*)theFilter {
    DLog(@"");
    self.filter = theFilter;
    [self.allPins removeAllObjects];
    [self.allPins addObjectsFromArray:items];
}

- (IBAction) mapTypeChanged:(id)sender event:(UIEvent*)event {
    DLog(@"");
	self.mapView.mapType = self.mapType.selectedSegmentIndex;
    self.flipped = NO;
    [self pageCurl:NO fillMode:kCAFillModeBackwards type:@"pageUnCurl" duration:0.5];
}

- (void)mapTypeCancelled:(id)sender event:(UIEvent*)event {
    DLog(@"");
    self.flipped = NO;
    [self pageCurl:NO fillMode:kCAFillModeBackwards type:@"pageUnCurl" duration:0.5];
}

- (IBAction) showInfo:(id)sender event:(UIEvent*)event {
    DLog(@"");
    self.mapType.selectedSegmentIndex = self.mapView.mapType;
    self.flipped = YES;
    [self pageCurl:YES fillMode:kCAFillModeForwards type:@"pageCurl" duration:0.5];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.allPins = [NSMutableArray arrayWithCapacity:0];
	self.filteredPins = [NSMutableArray arrayWithCapacity:0];
    self.filters = [NSMutableArray arrayWithCapacity:0];
    self.flipView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern.png"]];
    [self.mapType setTitle:NSLocalizedString(@"Standard", nil) forSegmentAtIndex:MKMapTypeStandard];
    [self.mapType setTitle:NSLocalizedString(@"Satellite", nil) forSegmentAtIndex:MKMapTypeSatellite];
    [self.mapType setTitle:NSLocalizedString(@"Hybrid", nil) forSegmentAtIndex:MKMapTypeHybrid];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    if (self.flipped) {
        self.flipped = NO;
        [self pageCurl:NO fillMode:kCAFillModeBackwards type:@"pageUnCurl" duration:0];
    }
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)dealloc {
    [allPins release];
    [filteredPins release];
    [pendingPins release];
	[mapView release];
    [flipView release];
	[mapType release];
	[infoButton release];
	[filterLabel release];
    [filters release];
	[filter release];
	[super dealloc];
}

#pragma mark -
#pragma mark Helpers

- (void) pageCurl:(BOOL)up fillMode:(NSString*)fillMode type:(NSString*)type duration:(CGFloat)duration {
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self]; 
    [animation setDuration:duration];
    [animation setTimingFunction:UIViewAnimationCurveEaseInOut];
    animation.type = type;
    animation.fillMode = fillMode;
    if (up) {
        animation.endProgress = 0.50;
    }
    else {
        animation.startProgress = 0.55;
    }
    [animation setRemovedOnCompletion:NO];
    [[self view] exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    [[[self view] layer] addAnimation:animation forKey:@"pageCurlAnimation"];
}

@end
