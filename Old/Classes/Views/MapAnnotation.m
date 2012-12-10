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

#import "MapAnnotation.h"

@implementation MapAnnotation

@synthesize coordinate, title, subtitle, pinColor, object;

- (id) initWithTitle:(NSString *)theTitle 
			subtitle:(NSString *)theSubtitle 
		  coordinate:(CLLocationCoordinate2D)theCoordinate 
			pinColor:(MKPinAnnotationColor)thePinColor {
	if (self = [super init]) {
		self.title = theTitle;
		self.subtitle = theSubtitle;
		self.coordinate = theCoordinate;
		self.pinColor = thePinColor;
	}
    return self;
}

- (void)dealloc {
	[title release];
	[subtitle release];
	[object release];
	[super dealloc];
}

@end
