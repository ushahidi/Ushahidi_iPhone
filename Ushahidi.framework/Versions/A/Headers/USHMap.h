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

typedef NS_ENUM(NSInteger, USHSort) {
    USHSortByDate,
    USHSortByTitle
};

@class USHCategory, USHCheckin, USHLocation, USHReport, USHUser;

@interface USHMap : NSManagedObject

@property (nonatomic, retain) NSDate * added;
@property (nonatomic, retain) NSDate * discovered;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * synced;
@property (nonatomic, retain) NSNumber * syncing;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * version;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) NSSet *reports;
@property (nonatomic, retain) NSSet *users;
@property (nonatomic, retain) NSSet *checkins;
@property (nonatomic, retain) USHLocation *locations;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *error;
@property (nonatomic, retain) NSNumber * opengeosms;
@property (nonatomic, retain) NSNumber * checkin;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *sms;

- (NSArray*) reportsWithCategory:(USHCategory*)category;
- (NSArray*) reportsWithCategory:(USHCategory*)category text:(NSString*)text;
- (NSArray*) reportsWithCategory:(USHCategory*)category text:(NSString*)text sort:(USHSort)sort;
- (NSArray*) reportsWithCategory:(USHCategory*)category text:(NSString*)text sort:(USHSort)sort ascending:(BOOL)ascending;

- (NSArray*) checkinsForUser:(USHUser*)user text:(NSString*)text;

- (NSArray*) reportsPending;
- (NSArray*) commentsPending;
- (NSArray*) checkinsPending;

- (NSArray*) reportsSortedBy:(NSString*)sort ascending:(BOOL)ascending;
- (NSArray*) reportsSortedByDate;
- (NSArray*) reportsSortedByTitle;

- (NSArray*) categoriesSortedBy:(NSString*)sort ascending:(BOOL)ascending;
- (NSArray*) categoriesSortedByPosition;

@end

@interface USHMap (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(USHCategory *)value;
- (void)removeCategoriesObject:(USHCategory *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;
- (void)addReportsObject:(USHReport *)value;
- (void)removeReportsObject:(USHReport *)value;
- (void)addReports:(NSSet *)values;
- (void)removeReports:(NSSet *)values;
- (void)addUsersObject:(USHUser *)value;
- (void)removeUsersObject:(USHUser *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;
- (void)addCheckinsObject:(USHCheckin *)value;
- (void)removeCheckinsObject:(USHCheckin *)value;
- (void)addCheckins:(NSSet *)values;
- (void)removeCheckins:(NSSet *)values;

@end
