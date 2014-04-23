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

#import "USHReportDetailsViewController.h"
#import "USHTableCellFactory.h"
#import <Ushahidi/USHDevice.h>
#import <Ushahidi/USHMap.h>
#import <Ushahidi/USHReport.h>
#import <Ushahidi/USHPhoto.h>
#import <Ushahidi/USHVideo.h>
#import <Ushahidi/USHNews.h>
#import <Ushahidi/USHSound.h>
#import <Ushahidi/USHComment.h>
#import <Ushahidi/UIBarButtonItem+USH.h>
#import <Ushahidi/NSString+USH.h>
#import <Ushahidi/UITableView+USH.h>
#import "USHWebViewController.h"
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

@interface USHReportDetailsViewController ()

@property (strong, nonatomic) USHShareController *shareController;

@end

@implementation USHReportDetailsViewController

@synthesize map = _map;
@synthesize report = _report;
@synthesize reports = _reports;
@synthesize pager = _pager;
@synthesize webViewController = _webViewController;
@synthesize imageViewController = _imageViewController;
@synthesize locationViewController = _locationViewController;
@synthesize shareController = _shareController;
@synthesize commentAddViewController = _commentAddViewController;
@synthesize starredButton = _starredButton;

typedef enum {
    TableSectionTitle,
    TableSectionVerified,
    TableSectionDescription,
    TableSectionCategory,
    TableSectionDate,
    TableSectionLocation,
    TableSectionPhotos,
    TableSectionVideos,
    TableSectionNews,
    TableSectionComments,
    TableSections
} TableSection;

typedef enum {
    TableSectionLocationRowAddress,
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
    self.commentAddViewController.report = self.report;
    self.commentAddViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    self.commentAddViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:self.commentAddViewController animated:YES];
}

- (IBAction)share:(id)sender event:(UIEvent*)event {
    [self.shareController showShareForEvent:event];
}

- (IBAction)page:(id)sender event:(UIEvent*)event {
    NSInteger index = [self.reports indexOfObject:self.report];
    if (self.pager.selectedSegmentIndex == PageActionPrev) {
        index = index - 1;
        self.report = [self.reports objectAtIndex:index];
        self.report.viewed = [NSDate date];
    }
    else if (self.pager.selectedSegmentIndex == PageActionNext) {
        index = index + 1;
        self.report = [self.reports objectAtIndex:index];
        self.report.viewed = [NSDate date];
    }
    if (self.report.starred.boolValue) {
        self.starredButton.image = [UIImage imageNamed:@"starred.png"];
    }
    else {
        self.starredButton.image = [UIImage imageNamed:@"unstarred.png"];
    }
    self.navigationItem.title = [NSString stringWithFormat:@"%d / %d", index + 1, self.reports.count];
    [self.pager setEnabled:index > 0 forSegmentAtIndex:PageActionPrev];
    [self.pager setEnabled:index + 1 < self.reports.count forSegmentAtIndex:PageActionNext];
    [self.tableView reloadData];
}

- (IBAction)star:(id)sender event:(UIEvent*)event {
    if (self.report.starred.boolValue) {
        self.report.starred = [NSNumber numberWithBool:NO];
        self.starredButton.image = [UIImage imageNamed:@"unstarred.png"];
    }
    else {
        self.report.starred = [NSNumber numberWithBool:YES];
        self.starredButton.image = [UIImage imageNamed:@"starred.png"];
    }
    [[Ushahidi sharedInstance] saveChanges];
}

#pragma mark - UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.shareController = [[USHShareController alloc] initWithController:self];
    self.backBarButtonTitle = NSLocalizedString(@"Details", nil);
    [self adjustToolBarHeight];
    
    [USHAnalytics sendScreenView:USHAnalyticsReportDetailsVCName];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.shareController = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DLog(@"%@", self.map.name);
    self.report.viewed = [NSDate date];
    if (self.report.starred.boolValue) {
        self.starredButton.image = [UIImage imageNamed:@"starred.png"];
    }
    else {
        self.starredButton.image = [UIImage imageNamed:@"unstarred.png"];
    }
    NSInteger index = [self.reports indexOfObject:self.report];
    self.navigationItem.title = [NSString stringWithFormat:@"%d / %d", index + 1, self.reports.count];
    [self.pager setEnabled:index > 0 forSegmentAtIndex:PageActionPrev];
    [self.pager setEnabled:index + 1 < self.reports.count forSegmentAtIndex:PageActionNext];
}

#pragma mark - UITableViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TableSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == TableSectionPhotos) {
        return self.report.photos.count > 0 ? self.report.photos.count : 1;
    }
    if (section == TableSectionVideos) {
        return self.report.videos.count > 0 ? self.report.videos.count : 1;
    }
    if (section == TableSectionNews) {
        return self.report.news.count > 0 ? self.report.news.count : 1;
    }
    if (section == TableSectionComments) {
        return self.report.comments.count > 0 ? self.report.comments.count : 1;
    }
    if (section == TableSectionLocation) {
        return TableSectionLocationRows;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableSectionTitle) {
        return [USHTableCellFactory iconTableCellForTable:tableView 
                                                indexPath:indexPath 
                                                     text:self.report.title 
                                                     icon:@"title.png"];
    }
    else if (indexPath.section == TableSectionVerified) {
        NSString *text = [self.report.verified boolValue] ? NSLocalizedString(@"Verified", nil) : NSLocalizedString(@"Not verified", nil);
        return [USHTableCellFactory iconTableCellForTable:tableView 
                                                indexPath:indexPath 
                                                     text:text 
                                                     icon:[self.report.verified boolValue] ? @"verified.png" : @"unverified.png"];
    }
    else if (indexPath.section == TableSectionDescription) {
        return [USHTableCellFactory iconTableCellForTable:tableView
                                                indexPath:indexPath 
                                                     text:self.report.desc 
                                                     icon:@"description.png"];
    }
    else if (indexPath.section == TableSectionCategory) {
        return [USHTableCellFactory iconTableCellForTable:tableView 
                                                indexPath:indexPath 
                                                     text:[self.report categoryTitles:@", "] 
                                                     icon:@"category.png"];
    }
    else if (indexPath.section == TableSectionDate) {
        return [USHTableCellFactory iconTableCellForTable:tableView 
                                                indexPath:indexPath 
                                                     text:[self.report dateFormatted:@"h:mm a, MMMM d, yyyy"] 
                                                     icon:@"time.png"];
    }
    else if (indexPath.section == TableSectionLocation) {
        if (indexPath.row == TableSectionLocationRowAddress) {
            return [USHTableCellFactory iconTableCellForTable:tableView 
                                                    indexPath:indexPath 
                                                         text:self.report.location
                                                         icon:@"map.png"
                                                    accessory:YES];
        }
        else if (indexPath.row == TableSectionLocationRowMap) {
            if (self.report.snapshot != nil) {
                return [USHTableCellFactory imageTableCellForTable:tableView
                                                         indexPath:indexPath
                                                             image:self.report.snapshot];
            }
            return [USHTableCellFactory locationTableCellForTable:tableView 
                                                        indexPath:indexPath
                                                            title:self.report.location
                                                         subtitle:[NSString stringWithFormat:@"%@, %@", self.report.latitude, self.report.longitude]
                                                         latitude:self.report.latitude 
                                                        longitude:self.report.longitude];
        }
    }
    else if (indexPath.section == TableSectionPhotos) {
        if (self.report.photos.count > 0) {
            USHPhoto *photo = [[self.report.photos allObjects] objectAtIndex:indexPath.row];
            return [USHTableCellFactory imageTableCellForTable:tableView 
                                                     indexPath:indexPath 
                                                         image:photo.image];
        }
        else {
            return [USHTableCellFactory iconTableCellForTable:tableView 
                                                       indexPath:indexPath 
                                                            text:NSLocalizedString(@"No photos", nil) 
                                                            icon:@"photo.png"]; 
        }
    }
    else if (indexPath.section == TableSectionVideos) {        
        if (self.report.videos.count > 0) {
            USHVideo *video = [[self.report.videos allObjects] objectAtIndex:indexPath.row];
            if ([video.url isYouTubeLink]) {
                return [USHTableCellFactory webTableCellForTable:tableView 
                                                       indexPath:indexPath 
                                                             url:video.url];                
            }
            else {
                return [USHTableCellFactory iconTableCellForTable:tableView 
                                                        indexPath:indexPath 
                                                             text:video.url 
                                                             icon:@"video.png"];
            }
        }
        else {
            return [USHTableCellFactory iconTableCellForTable:tableView 
                                                    indexPath:indexPath 
                                                         text:NSLocalizedString(@"No videos", nil) 
                                                         icon:@"video.png"];  
        }
    }
    else if (indexPath.section == TableSectionNews) {
        if (self.report.news.count > 0) {
            USHNews *news = [[self.report.news allObjects] objectAtIndex:indexPath.row];
            return [USHTableCellFactory iconTableCellForTable:tableView 
                                                    indexPath:indexPath 
                                                         text:news.url 
                                                         icon:@"web.png"
                                                    accessory:YES];    
        }
        else {
            return [USHTableCellFactory iconTableCellForTable:tableView 
                                                    indexPath:indexPath 
                                                         text:NSLocalizedString(@"No webpages", nil) 
                                                         icon:@"web.png"];   
        }
    }
    else if (indexPath.section == TableSectionComments) {
        if (self.report.comments.count > 0) {
            USHComment *comment = [[self.report commentsSortedByDate] objectAtIndex:indexPath.row];
            return [USHTableCellFactory commentTableCellForTable:tableView 
                                                       indexPath:indexPath 
                                                         comment:comment.text 
                                                          author:comment.author 
                                                            date:[comment dateFormatted:@"h:mm a, MMMM d, yyyy"]
                                                         pending:[comment.pending boolValue]];
        }
        else {
            return [USHTableCellFactory iconTableCellForTable:tableView 
                                                    indexPath:indexPath 
                                                         text:NSLocalizedString(@"No comments", nil) 
                                                         icon:@"comment.png"];
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == TableSectionNews) {
        if (self.report.news.count > 0) {
            USHNews *news = [[self.report.news allObjects] objectAtIndex:indexPath.row];
            self.webViewController.url = news.url;
            [self.navigationController pushViewController:self.webViewController animated:YES];
        }
    }
    else if (indexPath.section == TableSectionPhotos) {
        if (self.report.photos.count > 0) {
            NSMutableArray *images = [NSMutableArray arrayWithCapacity:self.report.photos.count];
            for (USHPhoto *photo in [self.report.photos allObjects]) {
                [images addObject:[UIImage imageWithData:photo.image]];
            }
            self.imageViewController.name = self.report.title;
            self.imageViewController.url = self.report.url;
            self.imageViewController.images = images;
            self.imageViewController.image = [images objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:self.imageViewController animated:YES];
        }
    }
    else if (indexPath.section == TableSectionLocation) {
        if (indexPath.row == TableSectionLocationRowAddress) {
            self.locationViewController.title = self.report.location;
            self.locationViewController.latitude = self.report.latitude;
            self.locationViewController.longitude = self.report.longitude;
            [self.navigationController pushViewController:self.locationViewController animated:YES];
        }
        else if (indexPath.row == TableSectionLocationRowMap) {
            UIImage *image = [UIImage imageWithData:self.report.snapshot];
            self.imageViewController.name = self.report.title;
            self.imageViewController.url = self.report.url;
            self.imageViewController.images = [NSArray arrayWithObject:image];
            self.imageViewController.image = image;
            [self.navigationController pushViewController:self.imageViewController animated:YES];
            self.imageViewController.title = self.report.location;
        }
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableSectionLocation) {
        if (indexPath.row == TableSectionLocationRowAddress) {
             return [USHTextTableCell heightForTable:tableView text:self.report.location];
        }
        else if (indexPath.row == TableSectionLocationRowMap) {
            return 200;
        }
    }
    if (indexPath.section == TableSectionPhotos && self.report.photos.count > 0) {
        return 200;
    }
    if (indexPath.section == TableSectionVideos && self.report.videos.count > 0) {
        return [tableView contentWidth] * 0.75;
    }
    if (indexPath.section == TableSectionTitle) {
        return [USHIconTableCell heightForTable:tableView text:self.report.title];
    }
    if (indexPath.section == TableSectionDescription) {
        return [USHIconTableCell heightForTable:tableView text:self.report.desc];
    }
    if (indexPath.section == TableSectionCategory) {
        return [USHIconTableCell heightForTable:tableView text:[self.report categoryTitles:@", "]];
    }
    if (indexPath.section == TableSectionComments && self.report.comments.count > 0) {
        USHComment *comment = [[self.report commentsSortedByDate] objectAtIndex:indexPath.row];
        return [USHCommentTableCell heightForTable:tableView text:comment.text];
    }
    return 44;
}

#pragma mark - USHShareController

- (void) shareOpenURL:(USHShareController*)share {
    [self.shareController openURL:self.report.url];
}

- (void) sharePrintText:(USHShareController*)share {
    NSString *print = [NSString stringByAppendingWithToken:@"\n\n" count:4 words:self.map.name, self.report.title, self.report.desc, self.report.url, nil]; 
    [self.shareController printText:print title:self.report.title];
}

- (void) shareCopyText:(USHShareController*)share {
    NSString *clipboard = [NSString stringByAppendingWithToken:@"\n\n" count:4 words:self.map.name, self.report.title, self.report.desc, self.report.url, nil];
    [self.shareController copyText:clipboard];
}

- (void) shareSendSMS:(USHShareController*)share {
    NSString *sms = [NSString stringByAppendingWithToken:@" " count:3 words:self.map.name, self.report.title, self.report.url, nil];   
    [self.shareController sendSMS:sms];
}

- (void) shareSendEmail:(USHShareController*)share {
    NSString *subject = [NSString stringByAppendingWithToken:@" : " count:2 words:self.map.name, self.report.title, nil];
    NSString *body = [NSString stringByAppendingWithToken:@"<br/><br/>" count:4 words:self.map.name, self.report.title, self.report.url, self.report.desc, nil];  
    [self.shareController sendEmail:body subject:subject attachment:nil fileName:nil recipient:nil];
}

- (void) shareSendTweet:(USHShareController*)share {
    NSString *tweet = [NSString stringByAppendingWithToken:@" " count:2 words:self.map.name, self.report.title, nil];
    [self.shareController sendTweet:tweet url:self.report.url];
}

- (void) shareShowQRCode:(USHShareController*)share {
    [self.shareController showQRCode:self.report.url title:self.report.title];
}

- (void) sharePostFacebook:(USHShareController*)share {
    NSString *message = [NSString stringWithFormat:@"%@ %@", self.map.name, self.report.title];
    [self.shareController postFacebook:message url:self.report.url];
}

@end
