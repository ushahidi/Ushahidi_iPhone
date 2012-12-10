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

@class USHMap, USHReport;

@interface USHCategory : NSManagedObject

@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) USHMap *map;
@property (nonatomic, retain) NSSet *reports;

@end

@interface USHCategory (CoreDataGeneratedAccessors)

- (void)addReportsObject:(USHReport *)value;
- (void)removeReportsObject:(USHReport *)value;
- (void)addReports:(NSSet *)values;
- (void)removeReports:(NSSet *)values;
@end
