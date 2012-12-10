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

- (BOOL) isJpeg:(NSString*)url;

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
		NSString *link_url = [dictionary stringForKey:@"link_url"];
		if ([NSString isNilOrEmpty:link_url] == NO) {
			self.imageURL = link_url;
		}
		NSString *thumb_url = [dictionary stringForKey:@"thumb_url"];
		if ([NSString isNilOrEmpty:thumb_url] == NO) {
			self.thumbnailURL = thumb_url;
		}
		else {
			self.thumbnailURL = [dictionary stringForKey:@"thumb"];
		}
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
    @try {
        if (self.image != nil) {
            DLog(@"Image:%@ Thumbnail:%@", self.imageURL, self.thumbnailURL);
            if ([self isJpeg:self.imageURL] || [self isJpeg:self.thumbnailURL]) {
                [encoder encodeObject:UIImageJPEGRepresentation(self.image, 1.0) forKey:@"image"];
            }
            else {
                [encoder encodeObject:UIImagePNGRepresentation(self.image) forKey:@"image"];    
            }
        } 
        else {
            [encoder encodeObject:nil forKey:@"image"];
        }
        if (self.thumbnail != nil) {
            if ([self isJpeg:self.imageURL] || [self isJpeg:self.thumbnailURL]) {
                [encoder encodeObject:UIImageJPEGRepresentation(self.image, 1.0) forKey:@"thumbnail"];
            }
            else {
                [encoder encodeObject:UIImagePNGRepresentation(self.image) forKey:@"thumbnail"];    
            }
        } 
        else {
            [encoder encodeObject:nil forKey:@"thumbnail"];
        }
        [encoder encodeObject:self.imageURL forKey:@"imageURL"];
        [encoder encodeObject:self.thumbnailURL forKey:@"thumbnailURL"];
    }
    @catch (NSException *exception) {
        DLog(@"NSException %@", exception);
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
		self.thumbnailURL = [decoder decodeObjectForKey:@"thumbnailURL"];
        NSData *imageData = [decoder decodeObjectForKey:@"image"];
		if (imageData != nil) {
			self.image = [UIImage imageWithData:imageData];
		}
		NSData *thumbnailData = [decoder decodeObjectForKey:@"thumbnail"];
		if (thumbnailData != nil) {
			self.thumbnail = [UIImage imageWithData:thumbnailData];
		}
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

- (BOOL) isJpeg:(NSString*)path {
    for (NSString *extension in [NSArray arrayWithObjects:@".jpg", @".jpeg", @".JPG", @".JPEG", nil]) {
        if ([path hasSuffix:extension]) {
            return YES;
        }
    }
    return NO;
}

@end
