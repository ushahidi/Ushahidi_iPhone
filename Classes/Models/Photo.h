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
#import "Media.h"


@interface Photo : Media {

@public
	UIImage *image;	
	UIImage *thumbnail;
	NSIndexPath *indexPath;
	BOOL downloading;
}

@property(nonatomic,retain) UIImage *image;
@property(nonatomic,retain) UIImage *thumbnail;
@property(nonatomic,retain) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL downloading;

+ (id)photoWithImage:(UIImage *)image;
- (id)initWithImage:(UIImage *)image;
- (NSData *) getJpegData;
- (NSData *) getPngData;
+ (NSInteger) maxThumbnailHeight;
+ (NSInteger) maxThumbnailWidth;

@end
