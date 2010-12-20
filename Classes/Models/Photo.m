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

#import "Photo.h"
#import "UIImage+Resize.h"
#import "NSObject+Extension.h"
#import "NSDictionary+Extension.h"
#import "NSString+Extension.h"

@interface Photo ()

@end

@implementation Photo

NSInteger const kMaxThumbnaiWidth = 80;
NSInteger const kMaxThumbnaiHeight = 80;

@synthesize image, thumbnail, indexPath, downloading, imageURL, thumbnailURL;

+ (id)photoWithImage:(UIImage *)theImage {
	return [[[Photo alloc] initWithImage:theImage] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super initWithDictionary:dictionary]) {
		self.imageURL = [dictionary stringForKey:@"link_url"];
		self.thumbnailURL = [dictionary stringForKey:@"thumb_url"];
	}
	return self;
}

- (id)initWithImage:(UIImage *)theImage {
	if (self = [super init]) {
		self.image = theImage;
		@try {
			DLog(@"Creating Thumbnail...");
			CGSize thumbnailSize = self.image.size.width > self.image.size.height
				? CGSizeMake(kMaxThumbnaiWidth, kMaxThumbnaiWidth * self.image.size.height / self.image.size.width)
				: CGSizeMake(kMaxThumbnaiHeight * self.image.size.width / self.image.size.height, kMaxThumbnaiHeight);
			self.thumbnail = [self.image resizedImage:thumbnailSize interpolationQuality:kCGInterpolationMedium];
		}
		@catch (NSException *e) {
			DLog(@"NSException: %@", e);
		}
	}
	return self;
}

+ (NSInteger) maxThumbnailHeight {
	return kMaxThumbnaiHeight;
}

+ (NSInteger) maxThumbnailWidth {
	return kMaxThumbnaiWidth;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[super encodeWithCoder:encoder];
	if (self.image != nil) {
		[encoder encodeObject:UIImagePNGRepresentation(self.image) forKey:@"image"];
	} 
	else {
		[encoder encodeObject:nil forKey:@"image"];
	}
	if (self.thumbnail != nil) {
		[encoder encodeObject:UIImagePNGRepresentation(self.thumbnail) forKey:@"thumbnail"];
	} 
	else {
		[encoder encodeObject:nil forKey:@"thumbnail"];
	}
	[encoder encodeObject:self.imageURL forKey:@"imageURL"];
	[encoder encodeObject:self.thumbnailURL forKey:@"thumbnailURL"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		NSData *imageData = [decoder decodeObjectForKey:@"image"];
		if (imageData != nil) {
			self.image = [UIImage imageWithData:imageData];
		}
		NSData *thumbnailData = [decoder decodeObjectForKey:@"thumbnail"];
		if (thumbnailData != nil) {
			self.thumbnail = [UIImage imageWithData:thumbnailData];
		}
		self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
		self.thumbnailURL = [decoder decodeObjectForKey:@"thumbnailURL"];
	}
	return self;
}

- (void)dealloc {
	[image release];
	[thumbnail release];
	[indexPath release];
	[imageURL release];
	[thumbnailURL release];
    [super dealloc];
}

- (NSData *) getJpegData {
	return self.image != nil ? UIImageJPEGRepresentation(self.image, 1.0) : nil;
}

- (NSData *) getPngData {
	return self.image != nil ? UIImagePNGRepresentation(self.image) : nil;
}

@end
