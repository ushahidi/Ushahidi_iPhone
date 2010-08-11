//
//  TextTableCell.m
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-10.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import "TextTableCell.h"

#define kPadding 20

@implementation TextTableCell

@synthesize delegate, indexPath; 

- (id)initWithDelegate:(id<TextTableCellDelegate>)theDelegate reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		self.delegate = theDelegate;
		self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		self.textLabel.numberOfLines = 0; 
		self.textLabel.font = [UIFont boldSystemFontOfSize:18];
	}
    return self;
}

- (NSString *) getText {
	return	self.textLabel.text;
}

- (void) setText:(NSString *)theText {
	if (theText == nil || [theText isEqualToString:@""]) {
		self.textLabel.text = @"";
	}
	else {
		self.textLabel.text = theText;
	}
}

- (CGSize) getCellSize {
	CGRect rect = [self.textLabel textRectForBounds:CGRectMake(0.0, 0.0, self.frame.size.width, FLT_MAX) limitedToNumberOfLines:0];
	return CGSizeMake(rect.size.width, rect.size.height);
}

+ (CGSize)getCellSizeForText:(NSString *)theText forWidth:(CGFloat)width {
	CGSize rect = [theText sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:CGSizeMake(width, 9999) lineBreakMode:UILineBreakModeWordWrap]; 
	return CGSizeMake(rect.width, rect.height + kPadding + kPadding);
}

- (void)dealloc {
	delegate = nil;
	[indexPath release];
    [super dealloc];
}

@end
