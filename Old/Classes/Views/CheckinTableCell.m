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

#import "CheckinTableCell.h"
#import "IndexedTableCell.h"
#import "Settings.h"
#import "Device.h"

@implementation CheckinTableCell

@synthesize nameLabel, messageLabel, dateLabel, imageView;

- (void)dealloc {
	[nameLabel release];
	[messageLabel release];
	[dateLabel release];
	[imageView release];
	[super dealloc];
}

- (void) setName:(NSString *)theName {
	self.nameLabel.text = theName;
}

- (NSString *)name {
	return self.nameLabel.text;
}

- (void) setMessage:(NSString *)theMessage {
	self.messageLabel.text = theMessage;
}

- (NSString *)message {
	return self.messageLabel.text;
}

- (void) setDate:(NSString *)theDate {
	self.dateLabel.text = theDate;
}

- (NSString *)date {
	return self.dateLabel.text;
}

- (void) setImage:(UIImage *)theImage {
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 5.0;
	if (theImage != nil) {
		self.imageView.image = theImage;
	} 
	else {
		self.imageView.image = [UIImage imageNamed:@"placeholder.png"];
	}
}

- (UIImage *) image {
	return self.imageView.image;
}

- (void) setSelectedColor:(UIColor *)color {
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    selectedBackgroundView.layer.cornerRadius = 10;
	[selectedBackgroundView setBackgroundColor:color];
	[self setSelectedBackgroundView:selectedBackgroundView];
	[selectedBackgroundView release];	
}

- (UIColor *) selectedColor {
	return self.selectedBackgroundView.backgroundColor;
}

+ (CGFloat) getCellHeightForMessage:(NSString*)theMessage {
    // TODO adjust cell height to fit all checkin message text
    return [Device isIPad] ? 100 : 90;
}

@end
