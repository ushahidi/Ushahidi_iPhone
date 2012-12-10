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

@interface NSData (Extension)

/*!	@function	+dataWithBase64EncodedString:
 @discussion	This method returns an autoreleased NSData object. The NSData object is initialized with the
 contents of the Base 64 encoded string. This is a convenience method.
 @param	inBase64String	An NSString object that contains only Base 64 encoded data.
 @result	The NSData object. */
+ (NSData *) dataWithBase64EncodedString:(NSString *) string;

/*!	@function	-initWithBase64EncodedString:
 @discussion	The NSData object is initialized with the contents of the Base 64 encoded string.
 This method returns self as a convenience.
 @param	inBase64String	An NSString object that contains only Base 64 encoded data.
 @result	This method returns self. */
- (id) initWithBase64EncodedString:(NSString *) string;

/*!	@function	-base64EncodingWithLineLength:
 @discussion	This method returns a Base 64 encoded string representation of the data object.
 @param	inLineLength A value of zero means no line breaks.  This is crunched to a multiple of 4 (the next
 one greater than inLineLength).
 @result	The base 64 encoded data. */
- (NSString *) base64EncodingWithLineLength:(unsigned int) lineLength;

@end
