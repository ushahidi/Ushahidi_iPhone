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

#import "USHCheckinDetailsViewController.h"
#import "USHTableCellFactory.h"
#import <Ushahidi/USHDevice.h>
#import <Ushahidi/USHMap.h>
#import <Ushahidi/USHCheckin.h>
#import <Ushahidi/USHPhoto.h>
#import <Ushahidi/USHVideo.h>
#import <Ushahidi/USHNews.h>
#import <Ushahidi/USHSound.h>
#import <Ushahidi/USHComment.h>
#import <Ushahidi/UIBarButtonItem+USH.h>
#import <Ushahidi/NSString+USH.h>
#import <Ushahidi/UITableView+USH.h>
#import "USHImageViewController.h"
#import "USHLocationViewController.h"
#import "USHSettings.h"
#import "USHTextTableCell.h"
#import "USHIconTableCell.h"
#import "USHImageTableCell.h"
#import "USHWebTableCell.h"
#import "USHLocationTableCell.h"
#import "USHCommentTableCell.h"
#import "USHCommentAddViewController.h"
#import "USHAnalytics.h"

@interface USHCheckinDetailsViewController ()

@property (strong, nonatomic) USHShareController *shareController;

- (NSString*) checkinText;

@end

@implementation USHCheckinDetailsViewController

@synthesize map = _map;
@synthesize checkin = _checkin;
@synthesize checkins = _checkins;
@synthesize pager = _pager;
@synthesize imageViewController = _imageViewController;
@synthesize locationViewController = _locationViewController;
@synthesize shareController = _shareController;
@synthesize commentAddViewController = _commentAddViewController;

typedef enum {
    TableSectionMessage,
    TableSectionName,
    TableSectionDate,
    TableSectionImage,
    TableSectionLocation,
    TableSectionComments,
    TableSections
} TableSection;

typedef enum {
    TableSectionLocationRowText,
    TableSectionLocationRowMap,
    TableSectionLocationRows
} TableSectionLocationRow;

typedef enum {
    PageActionPrev,
    PageActionNext
} PageAction;

#pragma mark - IBActions

- (IBAction)comment:(id)sender event:(UIEvent*)event {
    DLog(@"");
    self.commentAddViewController.map = self.map;
    //self.commentAddViewController.checkins = self.checkin;
    self.commentAddViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    self.commentAddViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:self.commentAddViewController animated:YES];
}

- (IBAction)share:(id)sender event:(UIEvent*)event {
    [self.shareController showShareForEvent:event];
}

- (IBAction)page:(id)sender event:(UIEvent*)event {
    NSInteger index = [self.checkins indexOfObject:self.checkin];
    if (self.pager.selectedSegmentIndex == PageActionPrev) {
        index = index - 1;
        self.checkin = [self.checkins objectAtIndex:index];
    }
    else if (self.pager.selectedSegmentIndex == PageActionNext) {
        index = index + 1;
        self.checkin = [self.checkins objectAtIndex:index];
    }
    self.navigationItem.title = [NSString stringWithFormat:@"%d / %d", index + 1, self.checkins.count];
    [self.pager setEnabled:index > 0 forSegmentAtIndex:PageActionPrev];
    [self.pager setEnabled:index + 1 < self.checkins.count forSegmentAtIndex:PageActionNext];
    [self.tableView reloadData];
}

#pragma mark - UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.shareController = [[USHShareController alloc] initWithController:self];
    
    [USHAnalytics sendScreenView:USHAnalyticsCheckinDetailsVCName];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.shareController = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DLog(@"%@", self.map.name);
    NSInteger index = [self.checkins indexOfObject:self.checkin];
    self.navigationItem.title = [NSString stringWithFormat:@"%d / %d", index + 1, self.checkins.count];
    [self.pager setEnabled:index > 0 forSegmentAtIndex:PageActionPrev];
    [self.pager setEnabled:index + 1 < self.checkins.count forSegmentAtIndex:PageActionNext];
}

#pragma mark - UITableViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TableSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == TableSectionImage) {
        return self.checkin.image != nil ? 1 : 0;
    }
    if (section == TableSectionLocation) {
        return TableSectionLocationRows;
    }
    if (section == TableSectionComments) {
        return 0;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableSectionMessage) {
        return [USHTableCellFactory iconTableCellForTable:tableView
                                                indexPath:indexPath
                                                     text:self.checkin.message
                                                     icon:@"checkin_dark.png"];
    }
    else if (indexPath.section == TableSectionName) {
        NSString *name = [NSString isNilOrEmpty:self.checkin.user.name] ? NSLocalizedString(@"Anonymous", nil) : self.checkin.user.name;
        return [USHTableCellFactory iconTableCellForTable:tableView
                                                indexPath:indexPath
                                                     text:name
                                                     icon:@"user.png"];
    }
    else if (indexPath.section == TableSectionDate) {
        return [USHTableCellFactory iconTableCellForTable:tableView
                                                indexPath:indexPath
                                                     text:[self.checkin dateFormatted:@"h:mm a, MMMM d, yyyy"]
                                                     icon:@"time.png"];
    }
    else if (indexPath.section == TableSectionLocation) {
        if (indexPath.row == TableSectionLocationRowText) {
            return [USHTableCellFactory iconTableCellForTable:tableView
                                                    indexPath:indexPath
                                                         text:[NSString stringWithFormat:@"%.8f, %.8f", self.checkin.latitude.floatValue, self.checkin.longitude.floatValue]
                                                         icon:@"map.png"
                                                    accessory:YES];
        }
        else if (indexPath.row == TableSectionLocationRowMap) {
            return [USHTableCellFactory locationTableCellForTable:tableView
                                                        indexPath:indexPath
                                                            title:self.checkin.message
                                                         subtitle:[NSString stringWithFormat:@"%.8f, %.8f", self.checkin.latitude.floatValue, self.checkin.longitude.floatValue]
                                                         latitude:self.checkin.latitude
                                                        longitude:self.checkin.longitude];
        }
    }
    else if (indexPath.section == TableSectionImage) {
        return [USHTableCellFactory imageTableCellForTable:tableView
                                                 indexPath:indexPath
                                                     image:self.checkin.image];
    }
    else if (indexPath.section == TableSectionComments) {
//        if (self.checkin.comments.count > 0) {
//            USHComment *comment = [[self.checkin commentsSortedByDate] objectAtIndex:indexPath.row];
//            return [USHTableCellFactory commentTableCellForTable:tableView
//                                                       indexPath:indexPath
//                                                         comment:comment.text
//                                                          author:comment.author
//                                                            date:[comment dateFormatted:@"h:mm a, MMMM d, yyyy"]
//                                                         pending:[comment.pending boolValue]];
//        }
//        else {
//            return [USHTableCellFactory iconTableCellForTable:tableView
//                                                    indexPath:indexPath
//                                                         text:NSLocalizedString(@"No comments", nil)
//                                                         icon:@"comments.png"];
//        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == TableSectionImage) {
        if (self.checkin.image != nil) {
            UIImage *image = [UIImage imageWithData:self.checkin.image];
            self.imageViewController.name = self.checkinText;
            self.imageViewController.url = nil;
            self.imageViewController.images = [NSArray arrayWithObject:image];
            self.imageViewController.image = image;
            [self.navigationController pushViewController:self.imageViewController animated:YES];
        }
    }
    else if (indexPath.section == TableSectionLocation) {
        self.locationViewController.title = self.checkinText;
        self.locationViewController.latitude = self.checkin.latitude;
        self.locationViewController.longitude = self.checkin.longitude;
        [self.navigationController pushViewController:self.locationViewController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableSectionLocation && indexPath.row == TableSectionLocationRowMap) {
        return 200;
    }
    if (indexPath.section == TableSectionImage && self.checkin.image != nil) {
        return 200;
    }
//    if (indexPath.section == TableSectionComments && self.report.comments.count > 0) {
//        USHComment *comment = [[self.report commentsSortedByDate] objectAtIndex:indexPath.row];
//        return [USHCommentTableCell heightForTable:tableView text:comment.text];
//    }
    return 44;
}

#pragma mark - USHShareController

- (NSString*) checkinText {
    NSString *name = [NSString isNilOrEmpty:self.checkin.user.name] ? NSLocalizedString(@"Anonymous", nil) : self.checkin.user.name;
    NSString *date = [self.checkin dateFormatted:@"h:mm a, MMMM d, yyyy"];
    NSString *text = [NSString stringWithFormat:@"\"%@\" - %@, %@", self.checkin.message, name, date];
    return text;
}

- (void) sharePrintText:(USHShareController*)share {
    [self.shareController printText:self.checkinText title:self.checkin.message];
}

- (void) shareCopyText:(USHShareController*)share {
    [self.shareController copyText:self.checkinText];
}

- (void) shareSendSMS:(USHShareController*)share {
    [self.shareController sendSMS:self.checkinText];
}

- (void) shareSendEmail:(USHShareController*)share {
    [self.shareController sendEmail:self.checkinText subject:self.map.name attachment:self.checkin.image fileName:@"checkin.jpg" recipient:nil];
}

- (void) shareSendTweet:(USHShareController*)share {
    UIImage *image = self.checkin.image != nil ? [UIImage imageWithData:self.checkin.image] : nil;
    [self.shareController sendTweet:self.checkinText url:self.map.url image:image];
}

- (void) sharePostFacebook:(USHShareController*)share {
    UIImage *image = self.checkin.image != nil ? [UIImage imageWithData:self.checkin.image] : nil;
    [self.shareController postFacebook:self.checkinText url:self.map.url image:image];
}

@end
