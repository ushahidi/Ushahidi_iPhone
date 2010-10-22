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

@property (nonatomic, assign) id<PhotoDelegate> delegate;
@property (nonatomic, assign) BOOL downloading;

- (void) downloadImageInBackground:(NSString *)urlString;
- (void) notifyDelegate;

@end

@implementation Photo

NSInteger const kMaxWidth = 80;
NSInteger const kMaxHeight = 80;

@synthesize delegate, image, thumbnail, indexPath, downloading;

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super initWithDictionary:dictionary]) {
		
	}
	return self;
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
	}
	return self;
}

- (void)dealloc {
	delegate = nil;
	[image release];
	[thumbnail release];
	[indexPath release];
    [super dealloc];
}

- (void) downloadWithDelegate:(id<PhotoDelegate>)theDelegate {
	self.delegate = theDelegate;
	if (self.url != nil && self.downloading == NO) {
		self.downloading = YES;
		[self performSelectorInBackground:@selector(downloadImageInBackground:) withObject:self.url];
	}
}

- (void) downloadImageInBackground:(NSString *)urlString {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	@try {
		DLog(@"Downloading Photo: %@", urlString);
		//TODO get full photo url
		NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://demo.ushahidi.com/media/uploads/%@", urlString]];
		NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
		if (imageData != nil) {
			self.image = [[UIImage alloc] initWithData:imageData];
			CGSize thumbnailSize = CGSizeMake(kMaxWidth, kMaxHeight);
			if (self.image.size.width > self.image.size.height) {
				thumbnailSize = CGSizeMake(kMaxWidth, kMaxWidth * self.image.size.height / self.image.size.width);
			}
			else {
				thumbnailSize = CGSizeMake(kMaxHeight * self.image.size.width / self.image.size.height, kMaxHeight);
			}
			self.thumbnail = [self.image resizedImage:thumbnailSize interpolationQuality:kCGInterpolationMedium];
			[self performSelectorOnMainThread:@selector(notifyDelegate) withObject:nil waitUntilDone:YES];
		}
	}
	@finally {
		self.downloading = NO;
		[pool release];
	}
}

- (void) notifyDelegate {
	SEL selector = @selector(photoDownloaded:indexPath:);
	if (self.delegate != nil && [self.delegate respondsToSelector:selector]) {
		[self.delegate photoDownloaded:self indexPath:self.indexPath];
	}
}

- (NSData *) getData {
	return self.image != nil ? UIImagePNGRepresentation(self.image) : nil;
}

@end
