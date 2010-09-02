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

#import "DateTableCell.h"
#import "NSDate+Extension.h"

@interface DateTableCell ()

@end

@implementation DateTableCell

@synthesize delegate, indexPath, date;

- (id)initWithDelegate:(id<DateTableCellDelegate>)theDelegate reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		self.delegate = theDelegate;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    return self;
}

- (void) setDate:(NSDate *)theDate timeFormat:(BOOL)timeFormat{
	[date release];
	if (theDate != nil) {
		[theDate retain];
		date = theDate;
		self.textLabel.text = timeFormat ? [theDate timeToString] : [theDate dateToString];
		self.textLabel.textColor = [UIColor blackColor];
		self.textLabel.textAlignment = UITextAlignmentLeft;
	}
}

- (void) setPlaceholder:(NSString *)placeholder {
	self.textLabel.text = placeholder;
	self.textLabel.textColor = [UIColor lightGrayColor];
	self.textLabel.textAlignment = UITextAlignmentCenter;
}

- (void) setFont:(UIFont *)font {
	self.textLabel.font = [UIFont fontWithName:[font fontName] size:18];
	self.detailTextLabel.font = [UIFont fontWithName:[font fontName] size:14];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
	DLog(@"setSelected: %d", selected);
	if (selected) {
		SEL selector = @selector(dateTableCellClicked:date:indexPath:);
		if (self.delegate != NULL && [self.delegate respondsToSelector:selector]) {
			[self.delegate dateTableCellClicked:self date:self.date indexPath:self.indexPath];
		}	
	}
}

- (void)dealloc {
	delegate = nil;
    [super dealloc];
}

@end
