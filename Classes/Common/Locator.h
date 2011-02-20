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

@protocol LocatorDelegate;

@interface Locator : NSObject<CLLocationManagerDelegate> {

@public
	NSString *latitude;
	NSString *longitude;
	
@private
	CLLocationManager *locationManager;
	id<LocatorDelegate> delegate;
}

@property(nonatomic, retain) NSString *latitude;
@property(nonatomic, retain) NSString *longitude;

+ (Locator *) sharedLocator;
- (void)detectLocationForDelegate:(id<LocatorDelegate>)delegate;
- (BOOL) hasLocation;

@end

@protocol LocatorDelegate <NSObject>

@optional

- (void) locatorFinished:(Locator *)locator latitude:(NSString *)latitude longitude:(NSString *)longitude;
- (void) locatorFailed:(Locator *)locator error:(NSError *)error;

@end