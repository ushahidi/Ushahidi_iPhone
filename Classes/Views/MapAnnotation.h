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
#import <MapKit/MKAnnotation.h>
#import <MapKit/MKPinAnnotationView.h>

@interface MapAnnotation : NSObject <MKAnnotation> {
	
@public
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
	MKPinAnnotationColor pinColor;
	NSObject *object;
}

@property (nonatomic, readwrite, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) MKPinAnnotationColor pinColor;
@property (nonatomic, retain) NSObject *object;
		   
- (id) initWithTitle:(NSString *)title 
			subtitle:(NSString *)subtitle 
		  coordinate:(CLLocationCoordinate2D)coordinate 
		   pinColor:(MKPinAnnotationColor)pinColor;

@end
