//
//  ImageTableCell.m
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-11.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import "ImageTableCell.h"

@implementation ImageTableCell

@synthesize indexPath, cellImageView;

- (id)initWithImage:(UIImage *)theImage reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.accessoryType = UITableViewCellAccessoryNone;
		self.cellImageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.contentView.frame, 10, 10)];
		self.cellImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		self.cellImageView.contentMode = UIViewContentModeScaleAspectFit;
		self.cellImageView.image = theImage;
		[self.contentView addSubview:self.cellImageView];
	}
    return self;
}

- (void) setImage:(UIImage *)theImage {
	self.cellImageView.image = theImage;
}

- (UIImage *) getImage {
	return self.cellImageView.image;
}

- (void)dealloc {
	[indexPath release];
	[cellImageView release];
    [super dealloc];
}

@end
