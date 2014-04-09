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

#import <Ushahidi/USHTableCell.h>

@protocol USHSwitchTableCellDelegate;

@interface USHSwitchTableCell : USHTableCell {
@public
    UILabel *textLabel;
    UIImageView *imageView;
}

@property (nonatomic, strong) IBOutlet UILabel *textLabel;
@property (nonatomic, strong) IBOutlet UISwitch *switchControl;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet NSObject<USHSwitchTableCellDelegate>*delegate;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) BOOL on;

- (IBAction) changed:(id)sender;

@end

@protocol USHSwitchTableCellDelegate <NSObject>

@optional

- (void) switchTableViewCell:(USHSwitchTableCell *)cell index:(NSIndexPath *)indexPath on:(BOOL)on;

@end