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

@interface Photo ()

- (void) downloadImageInBackground:(NSString *)urlString;

@end

@implementation Photo

NSInteger const kMaxWidth = 64;
NSInteger const kMaxHeight = 64;

@synthesize url, image, thumbnail;

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.url forKey:@"url"];
	[encoder encodeObject:self.image forKey:@"image"];
	[encoder encodeObject:self.thumbnail forKey:@"thumbnail"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.url = [decoder decodeObjectForKey:@"url"];
		self.image = [decoder decodeObjectForKey:@"image"];
		self.thumbnail = [decoder decodeObjectForKey:@"thumbnail"];
	}
	return self;
}

- (void)dealloc {
	[url release];
	[image release];
	[thumbnail release];
    [super dealloc];
}

- (void) downloadImage {
	if (self.url != nil) {
		[self performSelectorInBackground:@selector(downloadImageInBackground:) withObject:self.url];
	}
}

- (void) downloadImageInBackground:(NSString *)urlString {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	@try {
		NSURL *imageURL = [NSURL URLWithString:urlString];
		NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
		self.image = [[UIImage alloc] initWithData:imageData];
		CGSize size;
		if (self.image.size.width > self.image.size.height) {
			size = CGSizeMake(kMaxWidth, kMaxWidth * self.image.size.height / self.image.size.width);
		}
		else {
			size = CGSizeMake(kMaxHeight * self.image.size.width / self.image.size.height, kMaxHeight);
		}
		self.thumbnail = [self.image resizedImage:size interpolationQuality:kCGInterpolationMedium];
	}
	@finally {
		[pool release];
	}
}

@end
