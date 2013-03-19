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

#import "USHTableCellFactory.h"
#import "USHMapTableCell.h"
#import "USHReportTableCell.h"
#import "USHCheckinTableCell.h"
#import "USHTextTableCell.h"
#import "USHIconTableCell.h"
#import "USHImageTableCell.h"
#import "USHCommentTableCell.h"
#import "USHImageTableCell.h"
#import "USHWebTableCell.h"
#import "USHLocationTableCell.h"
#import "USHCheckBoxTableCell.h"
#import "USHSwitchTableCell.h"
#import "USHInputTableCell.h"
#import "USHSliderTableCell.h"
#import "USHSettings.h"
#import <Ushahidi/USHDevice.h>
#import <Ushahidi/NSString+USH.h>
#import <Ushahidi/UITableView+USH.h>

@interface USHTableCellFactory ()

+ (UITableViewCell *) cellForTable:(UITableView*)tableView withNibName:(NSString *)nibName;

@end

@implementation USHTableCellFactory

+ (UITableViewCell *) cellForTable:(UITableView*)tableView withNibName:(NSString *)nibName {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nibName];
    if (cell == nil) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
        cell = [objects lastObject];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.numberOfLines = 0;
    return cell;
}

+ (USHMapTableCell *) mapTableCellForTable:(UITableView *)tableView 
                                 indexPath:(NSIndexPath *)indexPath {
    NSString *nibName = [USHDevice isIPad] ? @"USHMapTableCell_iPad" : @"USHMapTableCell_iPhone";
    USHMapTableCell *cell = (USHMapTableCell*)[self cellForTable:tableView withNibName:nibName];
    cell.indexPath = indexPath;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.selectedColor = [[USHSettings sharedInstance] tableSelectColor];
    return cell;
}

+ (USHReportTableCell *) reportTableCellForTable:(UITableView *)tableView 
                                       indexPath:(NSIndexPath *)indexPath
                                       hasPhotos:(BOOL)photos {
    NSString *nibName;
    if ([USHDevice isIPad]) {
        nibName = photos ? @"USHReportTableCell_iPad" : @"USHReportNoImageTableCell_iPad";
    }
    else {
        nibName = photos ? @"USHReportTableCell_iPhone" : @"USHReportNoImageTableCell_iPhone";
    }
    USHReportTableCell *cell = (USHReportTableCell*)[self cellForTable:tableView withNibName:nibName];
    cell.indexPath = indexPath;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectedColor = [[USHSettings sharedInstance] tableSelectColor];
    return cell; 
}

+ (USHCheckinTableCell *) checkinTableCellForTable:(UITableView *)tableView 
                                         indexPath:(NSIndexPath *)indexPath
                                         hasPhotos:(BOOL)photos{
    NSString *nibName;
    if ([USHDevice isIPad]) {
        nibName = photos ? @"USHCheckinTableCell_iPad" : @"USHCheckinNoImageTableCell_iPad";
    }
    else {
        nibName = photos ? @"USHCheckinTableCell_iPhone" : @"USHCheckinNoImageTableCell_iPhone";
    }
    USHCheckinTableCell *cell = (USHCheckinTableCell*)[self cellForTable:tableView withNibName:nibName];
    cell.indexPath = indexPath;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectedColor = [[USHSettings sharedInstance] tableSelectColor];
    return cell;
}


+ (USHTextTableCell *) textTableCellForTable:(UITableView *)tableView 
                                   indexPath:(NSIndexPath *)indexPath 
                                        text:(NSString *)text {
    return [USHTableCellFactory textTableCellForTable:tableView indexPath:indexPath text:text accessory:NO selection:NO];
}

+ (USHTextTableCell *) textTableCellForTable:(UITableView *)tableView
                                   indexPath:(NSIndexPath *)indexPath
                                        text:(NSString *)text
                                   accessory:(BOOL)accessory
                                   selection:(BOOL)selection {
    NSString *nibName = @"USHTextTableCell";
    USHTextTableCell *cell = (USHTextTableCell*)[self cellForTable:tableView withNibName:nibName];
    cell.indexPath = indexPath;
    cell.selectedColor = [[USHSettings sharedInstance] tableSelectColor];
    cell.textLabel.text = text;
    if (selection) {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (accessory) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

+ (USHIconTableCell *) iconTableCellForTable:(UITableView *)tableView 
                                   indexPath:(NSIndexPath *)indexPath 
                                        text:(NSString *)text
                                        icon:(NSString*)icon {
    return [USHTableCellFactory iconTableCellForTable:tableView indexPath:indexPath text:text icon:icon accessory:NO greyed:NO];
}

+ (USHIconTableCell *) iconTableCellForTable:(UITableView *)tableView 
                                   indexPath:(NSIndexPath *)indexPath 
                                        text:(NSString *)text
                                        icon:(NSString*)icon 
                                   accessory:(BOOL)accessory {
    return [USHTableCellFactory iconTableCellForTable:tableView indexPath:indexPath text:text icon:icon accessory:accessory greyed:NO];
}

+ (USHIconTableCell *) iconTableCellForTable:(UITableView *)tableView 
                                   indexPath:(NSIndexPath *)indexPath
                                        text:(NSString *)text
                                        icon:(NSString *)icon
                                   accessory:(BOOL)accessory
                                      greyed:(BOOL)greyed {
    NSString *nibName = @"USHIconTableCell";
    USHIconTableCell *cell = (USHIconTableCell*)[self cellForTable:tableView withNibName:nibName];
    cell.indexPath = indexPath;
    if (accessory) {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (greyed) {
        cell.textLabel.textColor = [UIColor lightGrayColor];
    }
    else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    cell.selectedColor = [[USHSettings sharedInstance] tableSelectColor];
    cell.textLabel.text = text;
    cell.imageView.image = [UIImage imageNamed:icon];
    return cell;
}

+ (USHImageTableCell *) imageTableCellForTable:(UITableView *)tableView 
                                     indexPath:(NSIndexPath *)indexPath 
                                         image:(NSData *)image {
    return [USHTableCellFactory imageTableCellForTable:tableView indexPath:indexPath image:image removable:NO];
}

+ (USHImageTableCell *) imageTableCellForTable:(UITableView *)tableView
                                     indexPath:(NSIndexPath *)indexPath
                                     image:(NSData *)image
                                     removable:(BOOL)removable {
    NSString *nibName = @"USHImageTableCell";
    USHImageTableCell *cell = (USHImageTableCell*)[self cellForTable:tableView withNibName:nibName];
    cell.indexPath = indexPath;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.selectedColor = [[USHSettings sharedInstance] tableSelectColor];
    if (image != nil) {
        cell.imageView.image = [UIImage imageWithData:image];
    }
    else {
        cell.imageView.image = nil;
    }
    if (removable) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clear.png"]];
    }
    else {
        cell.accessoryView = nil;
    }
    return cell;
}

+ (USHImageTableCell *) imageTableCellForTable:(UITableView *)tableView
                                     indexPath:(NSIndexPath *)indexPath
                                     imageName:(NSString *)imageName {
    return [USHTableCellFactory imageTableCellForTable:tableView indexPath:indexPath imageName:imageName removable:NO];
}

+ (USHImageTableCell *) imageTableCellForTable:(UITableView *)tableView
                                     indexPath:(NSIndexPath *)indexPath
                                     imageName:(NSString *)imageName
                                     removable:(BOOL)removable {
    NSString *nibName = @"USHImageTableCell";
    USHImageTableCell *cell = (USHImageTableCell*)[self cellForTable:tableView withNibName:nibName];
    cell.indexPath = indexPath;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.selectedColor = [[USHSettings sharedInstance] tableSelectColor];
    if (imageName != nil) {
        cell.imageView.image = [UIImage imageNamed:imageName];
    }
    else {
        cell.imageView.image = nil;
    }
    if (removable) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clear.png"]];
    }
    else {
        cell.accessoryView = nil;
    }
    return cell;
}

+ (USHCommentTableCell *) commentTableCellForTable:(UITableView *)tableView 
                                         indexPath:(NSIndexPath *)indexPath 
                                           comment:(NSString *)comment
                                            author:(NSString *)author
                                              date:(NSString *)date
                                           pending:(BOOL)pending {
    NSString *nibName = @"USHCommentTableCell";
    USHCommentTableCell *cell = (USHCommentTableCell*)[self cellForTable:tableView withNibName:nibName];
    cell.indexPath = indexPath;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.selectedColor = [[USHSettings sharedInstance] tableSelectColor];
    cell.authorLabel.text = author;
    cell.commentLabel.text = comment;
    cell.dateLabel.text = date;
    if (pending) {
        cell.dateLabel.text = NSLocalizedString(@"Pending", nil);
        cell.dateLabel.textColor = [UIColor redColor];
    }
    else {
        cell.dateLabel.textColor = [UIColor grayColor];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

+ (USHWebTableCell *) webTableCellForTable:(UITableView *)tableView 
                                 indexPath:(NSIndexPath *)indexPath
                                       url:(NSString *)url {
    NSString *nibName = @"USHWebTableCell";
    USHWebTableCell *cell = (USHWebTableCell*)[self cellForTable:tableView withNibName:nibName];
    cell.indexPath = indexPath;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.selectedColor = [[USHSettings sharedInstance] tableSelectColor];
    if ([url isYouTubeLink]) {
        cell.backgroundColor = [UIColor blackColor];
        CGSize size = CGSizeMake([tableView contentWidth], [tableView contentWidth] * 0.75);
        NSString *html = [url youTubeEmbedCode:YES size:size];
        [cell.webView loadHTMLString:html baseURL:nil];
    }
    else {
        NSURL *nsurl = [NSURL URLWithString:url];
        NSURLRequest *request = [NSURLRequest requestWithURL:nsurl];
        [cell.webView loadRequest:request];
    }
    return cell;
}

+ (USHLocationTableCell *) locationTableCellForTable:(UITableView *)tableView 
                                           indexPath:(NSIndexPath *)indexPath 
                                               title:(NSString *)title
                                            subtitle:(NSString *)subtitle
                                            latitude:(NSNumber *)latitude
                                           longitude:(NSNumber *)longitude {
    NSString *nibName = @"USHLocationTableCell";
    USHLocationTableCell *cell = (USHLocationTableCell*)[self cellForTable:tableView withNibName:nibName];
    cell.indexPath = indexPath;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.selectedColor = [[USHSettings sharedInstance] tableSelectColor];
    [cell removeAllPins];
    [cell addPinWithTitle:title subtitle:subtitle latitude:latitude longitude:longitude];
    [cell showAllPins:NO];
    return cell;
}

+ (USHInputTableCell *) inputTableCellForTable:(UITableView *)tableView 
                                     indexPath:(NSIndexPath *)indexPath
                                      delegate:(NSObject<USHInputTableCellDelegate>*)delegate
                                   placeholder:(NSString *)placeholder
                                          text:(NSString *)text
                                          icon:(NSString *)icon {
    return [USHTableCellFactory inputTableCellForTable:tableView 
                                             indexPath:indexPath 
                                              delegate:delegate 
                                           placeholder:placeholder 
                                                  text:text 
                                                  icon:icon 
                                        capitalization:UITextAutocapitalizationTypeSentences
                                            correction:UITextAutocorrectionTypeDefault
                                              spelling:UITextSpellCheckingTypeDefault
                                              keyboard:UIKeyboardTypeDefault 
                                                  done:UIReturnKeyDefault];
}

+ (USHInputTableCell *) inputTableCellForTable:(UITableView *)tableView 
                                     indexPath:(NSIndexPath *)indexPath
                                      delegate:(NSObject<USHInputTableCellDelegate>*)delegate
                                   placeholder:(NSString *)placeholder
                                          text:(NSString *)text
                                          icon:(NSString *)icon
                                capitalization:(UITextAutocapitalizationType)autocapitalizationType
                                    correction:(UITextAutocorrectionType)autocorrectionType
                                      spelling:(UITextSpellCheckingType)spellCheckingType
                                      keyboard:(UIKeyboardType)keyboardType 
                                          done:(UIReturnKeyType) returnKeyType {    
    NSString *nibName = @"USHInputTableCell";
    USHInputTableCell *cell = (USHInputTableCell*)[self cellForTable:tableView withNibName:nibName];
    cell.indexPath = indexPath;
    cell.delegate = delegate;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.placeholder = placeholder;
    cell.text = text;
    cell.imageView.image = [UIImage imageNamed:icon];
    cell.textView.autocapitalizationType = autocapitalizationType;
    cell.textView.autocorrectionType = autocorrectionType;
    cell.textView.spellCheckingType = spellCheckingType;
    cell.textView.keyboardType = keyboardType;
    cell.textView.returnKeyType = returnKeyType;
    return cell;
}

+ (USHCheckBoxTableCell *) checkBoxTableCellForTable:(UITableView *)tableView 
                                           indexPath:(NSIndexPath *)indexPath
                                            delegate:(NSObject<USHCheckBoxTableCellDelegate>*)delegate
                                                text:(NSString *)text
                                             details:(NSString *)details
                                             checked:(BOOL)checked {
    return [USHTableCellFactory checkBoxTableCellForTable:tableView 
                                                indexPath:indexPath
                                                 delegate:delegate
                                                     text:text 
                                                  details:details 
                                                  checked:checked 
                                                    color:[UIColor blackColor]];
}

+ (USHCheckBoxTableCell *) checkBoxTableCellForTable:(UITableView *)tableView 
                                           indexPath:(NSIndexPath *)indexPath
                                            delegate:(NSObject<USHCheckBoxTableCellDelegate>*)delegate
                                                text:(NSString *)text
                                             details:(NSString *)details
                                             checked:(BOOL)checked
                                               color:(UIColor*)color {
    NSString *nibName = @"USHCheckBoxTableCell";
    USHCheckBoxTableCell *cell = (USHCheckBoxTableCell*)[self cellForTable:tableView withNibName:nibName];
    cell.indexPath = indexPath;
    cell.delegate = delegate;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = text;
    cell.textLabel.textColor = color;
    cell.detailsTextLabel.text = details;
    cell.detailsTextLabel.textColor = color;
    cell.checked = checked;
    return cell;
}

+ (USHSwitchTableCell *) switchTableCellForTable:(UITableView *)tableView
                                       indexPath:(NSIndexPath *)indexPath
                                        delegate:(NSObject<USHSwitchTableCellDelegate>*)delegate
                                            text:(NSString *)text
                                            icon:(NSString *)icon
                                              on:(BOOL)on {
    USHSwitchTableCell *cell = (USHSwitchTableCell*)[self cellForTable:tableView withNibName:@"USHSwitchTableCell"];
    cell.indexPath = indexPath;
    cell.delegate = delegate;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = text;
    if (icon != nil) {
         cell.imageView.image = [UIImage imageNamed:icon];
    }
    else {
         cell.imageView.image = nil;
    }
    cell.on = on;
    return cell;
}

+ (USHSliderTableCell *) sliderTableCellForTable:(UITableView *)tableView
                                       indexPath:(NSIndexPath *)indexPath
                                        delegate:(NSObject<USHSliderTableCellDelegate>*)delegate
                                            text:(NSString *)text
                                            icon:(NSString *)icon
                                           value:(NSInteger)value
                                             min:(NSInteger)min
                                             max:(NSInteger)max {
    return [USHTableCellFactory sliderTableCellForTable:tableView
                                              indexPath:indexPath
                                               delegate:delegate
                                                   text:text
                                                   icon:icon
                                                  value:value
                                                    min:min
                                                    max:max
                                                enabled:YES
                                                 suffix:nil];
}

+ (USHSliderTableCell *) sliderTableCellForTable:(UITableView *)tableView
                                       indexPath:(NSIndexPath *)indexPath
                                        delegate:(NSObject<USHSliderTableCellDelegate>*)delegate
                                            text:(NSString *)text
                                            icon:(NSString *)icon
                                           value:(NSInteger)value
                                             min:(NSInteger)min
                                             max:(NSInteger)max
                                         enabled:(BOOL)enabled
                                          suffix:(NSString*)suffix {
    USHSliderTableCell *cell = (USHSliderTableCell*)[self cellForTable:tableView withNibName:@"USHSliderTableCell"];
    cell.indexPath = indexPath;
    cell.delegate = delegate;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = text;
    cell.suffix = suffix;
    if (icon != nil) {
        cell.imageView.image = [UIImage imageNamed:icon];
    }
    else {
        cell.imageView.image = nil;
    }
    cell.min = min;
    cell.max = max;
    cell.value = value;
    cell.enabled = enabled;
    return cell;
}

@end
