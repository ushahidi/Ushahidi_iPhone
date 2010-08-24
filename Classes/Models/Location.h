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

@interface Location : NSObject {

@public 
	NSString *name;
	NSString *countryID;
	CGFloat latitude;
	CGFloat longitude;
}

@property(nonatomic,retain) NSString *name;
@property(nonatomic,retain) NSString *countryID;
@property(nonatomic,assign) CGFloat latitude;
@property(nonatomic,assign) CGFloat longitude;

@end
