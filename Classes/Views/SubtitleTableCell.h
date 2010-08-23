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

@interface SubtitleTableCell : UITableViewCell {
	
@public
	NSIndexPath *indexPath;
	UIImage *defaultImage;
}

@property (nonatomic, retain) NSIndexPath *indexPath; 
@property (nonatomic, retain) UIImage *defaultImage;

- (id)initWithDefaultImage:(UIImage *)defaultImage reuseIdentifier:(NSString *)reuseIdentifier;
- (void) setText:(NSString *)text;
- (void) setDescription:(NSString *)description;
- (void) setImage:(UIImage *)image;

@end
