//
//  SubtitleTableCell.m
//  Ushahidi
//
//  Created by Dale Zak on 10-04-26.
//  Copyright 2010 Dale Zak. All rights reserved.
//

#import "SubtitleTableCell.h"

@interface SubtitleTableCell (Internal)

- (void) setButtonImage:(UIImage *)image;
- (void) clicked:(id)sender;

@end

@implementation SubtitleTableCell

@synthesize indexPath, defaultImage;

- (id)initWithDefaultImage:(UIImage *)theDefaultImage reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
		self.defaultImage = theDefaultImage;
		self.imageView.image = theDefaultImage;
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.selectionStyle = UITableViewCellSelectionStyleGray;
	}
    return self;
}

- (void)dealloc {
	[indexPath release];
	[defaultImage release];
	[super dealloc];
}

- (void) setText:(NSString *)theText {
	if (theText == nil || [theText isEqualToString:@""]) {
		self.textLabel.text = @"";
	}
	else {
		self.textLabel.text = theText;
	}
}

- (void) setDescription:(NSString *)description {
	if (description == nil || [description isEqualToString:@""]) {
		self.detailTextLabel.text = @"";	
	}
	else {
		self.detailTextLabel.text = description;
	}
}

- (void) setImage:(UIImage *)theImage {
	if (theImage != nil) {
		self.imageView.image = theImage;
	}
	else {
		self.imageView.image = self.defaultImage;
	}
}

@end
