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

@class USHCheckin, USHComment, USHMap;

@interface USHUser : NSManagedObject

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *color;
@property (nonatomic, retain) NSSet *checkins;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) USHMap *map;

@end

@interface USHUser (CoreDataGeneratedAccessors)

- (void)addCheckinsObject:(USHCheckin *)value;
- (void)removeCheckinsObject:(USHCheckin *)value;
- (void)addCheckins:(NSSet *)values;
- (void)removeCheckins:(NSSet *)values;
- (void)addCommentsObject:(USHComment *)value;
- (void)removeCommentsObject:(USHComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;
@end
