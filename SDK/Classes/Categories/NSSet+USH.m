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

#import "NSSet+USH.h"

@implementation NSSet (USH)

- (NSArray*) sortedBy:(NSString*)sort ascending:(BOOL)ascending {
    NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:sort ascending:ascending] autorelease];
    NSArray *descriptors = [NSArray arrayWithObject:descriptor];
    return [[self allObjects] sortedArrayUsingDescriptors:descriptors]; 
}

- (NSArray*) sortedBy:(NSString*)sort1 andBy:(NSString*)sort2 ascending:(BOOL)ascending {
    NSSortDescriptor *descriptor1 = [[[NSSortDescriptor alloc] initWithKey:sort1 ascending:ascending] autorelease];
    NSSortDescriptor *descriptor2 = [[[NSSortDescriptor alloc] initWithKey:sort2 ascending:ascending] autorelease];
    NSArray *descriptors = [NSArray arrayWithObjects:descriptor1, descriptor2, nil];
    return [[self allObjects] sortedArrayUsingDescriptors:descriptors];
}

- (NSObject*) objectAtIndex:(NSInteger)index {
    return [[self allObjects] objectAtIndex:index];
}

@end
