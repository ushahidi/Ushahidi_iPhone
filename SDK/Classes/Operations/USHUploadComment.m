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

#import "USHUploadComment.h"
#import "USHMap.h"
#import "USHReport.h"
#import "USHComment.h"
#import "SBJson.h"
#import "Ushahidi.h"

@interface USHUploadComment ()

@end

@implementation USHUploadComment

@synthesize comment = _comment;

- (id) initWithDelegate:(NSObject<USHUploadDelegate>*)delegate
               callback:(NSObject<UshahidiDelegate>*)callback
                    map:(USHMap *)map
                comment:(USHComment*)comment {
    if ((self = [super initWithDelegate:delegate
                               callback:callback
                                    map:map
                                    api:@"api?task=comments&action=add"])) {
        [self setValue:@"comments" forKey:@"task"];
        [self setValue:@"add" forKey:@"action"];
        [self setValue:comment.text forKey:@"comment_description"];
        [self setValue:comment.author forKey:@"comment_author"];
        [self setValue:comment.email forKey:@"comment_email"];
        if (comment.report != nil) {
            USHReport *report = comment.report;
            [self setValue:report.identifier forKey:@"incident_id"];
        }
        else {
            //TODO set comment for other types
        }
        self.comment = comment;
    }
    return self;
}

- (void)dealloc {
    [_comment release];
    [super dealloc];
}

@end
