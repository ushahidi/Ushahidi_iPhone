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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface USHDatabase : NSObject

@property (nonatomic, strong) NSString *name;

+ (instancetype) sharedInstance;

- (BOOL) remove:(id)model;

- (BOOL) hasChanges;
- (BOOL) saveChanges;

- (id) insertItemWithName:(NSString*)name;

- (NSObject*) fetchOrInsertItemForName:(NSString*)name query:(NSString*)query param:(NSString*)param;
- (NSObject*) fetchOrInsertItemForName:(NSString*)name query:(NSString*)query params:(NSString*)param,... NS_REQUIRES_NIL_TERMINATION;

- (NSArray *) fetchArrayForName:(NSString *)name query:(NSString*)query param:(NSString*)param sort:(NSString *)sort,... NS_REQUIRES_NIL_TERMINATION;
- (NSArray *) fetchArrayForName:(NSString *)name query:(NSString*)query params:(NSString*)param, ... NS_REQUIRES_NIL_TERMINATION;

- (NSObject*) fetchItemForName:(NSString *)name query:(NSString*)query param:(NSString*)param;
- (NSObject*) fetchItemForName:(NSString *)name query:(NSString*)query params:(NSString*)param, ... NS_REQUIRES_NIL_TERMINATION;

- (NSInteger) fetchCountForName:(NSString *)name query:(NSString*)query param:(NSString*)param;
- (NSInteger) fetchCountForName:(NSString *)name query:(NSString*)query params:(NSString*)param, ... NS_REQUIRES_NIL_TERMINATION;

@end
