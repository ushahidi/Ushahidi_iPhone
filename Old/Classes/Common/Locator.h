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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <MapKit/MKReverseGeocoder.h>
#import "ASIHTTPRequest.h"

@protocol LocatorDelegate;

@interface Locator : NSObject<CLLocationManagerDelegate, MKReverseGeocoderDelegate> {

@public
	NSString *latitude;
	NSString *longitude;
	NSString *address;
	
@private
	CLLocationManager *locationManager;
	MKReverseGeocoder *reverseGeocoder;
	id<LocatorDelegate> delegate;
}

@property(nonatomic, retain) NSString *latitude;
@property(nonatomic, retain) NSString *longitude;
@property(nonatomic, retain) NSString *address;

+ (Locator *) sharedLocator;
- (void) detectLocationForDelegate:(id<LocatorDelegate>)delegate;
- (void) lookupAddressForDelegate:(id<LocatorDelegate>)delegate;
- (BOOL) hasLocation;
- (BOOL) hasAddress;

@end

@protocol LocatorDelegate <NSObject>

@optional

- (void) locatorFinished:(Locator *)locator latitude:(NSString *)latitude longitude:(NSString *)longitude;
- (void) locatorFailed:(Locator *)locator error:(NSError *)error;

- (void) lookupFinished:(Locator *)locator address:(NSString *)address;
- (void) lookupFailed:(Locator *)locator error:(NSError *)error;

@end