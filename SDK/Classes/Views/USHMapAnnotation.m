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

#import "USHMapAnnotation.h"

@implementation USHMapAnnotation

@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize pinColor = _pinColor;
@synthesize object = _object;

- (id) initWithTitle:(NSString *)title
			subtitle:(NSString *)subtitle
		  coordinate:(CLLocationCoordinate2D)coordinate
			pinColor:(MKPinAnnotationColor)pinColor {
	if (self = [super init]) {
		self.title = title;
		self.subtitle = subtitle;
		self.coordinate = coordinate;
		self.pinColor = pinColor;
	}
    return self;
}

- (void)dealloc {
	[_title release];
	[_subtitle release];
	[_object release];
	[super dealloc];
}

@end
