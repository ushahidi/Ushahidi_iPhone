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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol USHLocatorDelegate;

@interface USHLocator : NSObject<CLLocationManagerDelegate>

@property(nonatomic, retain) NSNumber *latitude;
@property(nonatomic, retain) NSNumber *longitude;
@property(nonatomic, retain) NSString *address;

+ (instancetype) sharedInstance;

- (void) locateForDelegate:(NSObject<USHLocatorDelegate>*)delegate;
- (void) lookupForDelegate:(NSObject<USHLocatorDelegate>*)delegate;
- (void) geocodeForDelegate:(NSObject<USHLocatorDelegate>*)delegate;

- (void) stopLocate;
- (void) stopLookup;

- (BOOL) hasLocation;
- (BOOL) hasAddress;

@end

@protocol USHLocatorDelegate <NSObject>

@optional

- (void) locateFinished:(USHLocator *)locator latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude;
- (void) locateFailed:(USHLocator *)locator error:(NSError *)error;

- (void) lookupFinished:(USHLocator *)locator address:(NSString *)address;
- (void) lookupFailed:(USHLocator *)locator error:(NSError *)error;

- (void) geocodeFinished:(USHLocator *)locator latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude address:(NSString *)address;
- (void) geocodeFailed:(USHLocator *)locator error:(NSError *)error;

@end