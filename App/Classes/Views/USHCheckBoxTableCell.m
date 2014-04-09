/*****************************************************************************
 ** Copyright (c) 2012 Ushahidi Inc
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

#import "USHCheckBoxTableCell.h"
#import <Ushahidi/NSObject+USH.h>

@interface USHCheckBoxTableCell ()

@end

@implementation USHCheckBoxTableCell

typedef enum {
	CheckedFalse,
	CheckedTrue
} Checked;

@synthesize checkBox = _checkBox;
@synthesize textLabel;
@synthesize detailsTextLabel;
@synthesize delegate = _delegate;

- (IBAction)checked:(id)sender event:(UIEvent*)event {
    DLog(@"");
    if (self.checked) {
		[self setChecked:NO];
	}
	else {
		[self setChecked:YES];
	}
    [self.delegate performSelectorOnMainThread:@selector(checkBoxChanged:index:checked:) 
                                 waitUntilDone:YES 
                                   withObjects:self, self.indexPath, self.checked, nil];
}

- (BOOL) checked {
	return (self.tag == CheckedTrue);
}

- (void) setChecked:(BOOL)isChecked {
	if (isChecked) {
		self.tag = CheckedTrue;
		[self.checkBox setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
	}
	else {
		self.tag = CheckedFalse;
		[self.checkBox setImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
	}
}


@end
