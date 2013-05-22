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

#import "USHDatabase.h"
#import "NSBundle+USH.h"

@interface USHDatabase ()

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;
- (void)contextDidSave:(NSNotification *)notification;

@end

SYNTHESIZE_SINGLETON_FOR_CLASS_PROTOTYPE(USHDatabase);

@implementation USHDatabase

SYNTHESIZE_SINGLETON_FOR_CLASS(USHDatabase);

@synthesize name = _name;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (void)dealloc {
    [_name release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [super dealloc];
}

- (BOOL) saveChanges {
    @try {
        NSError *error;
        [self.managedObjectContext lock];
        if ([self.managedObjectContext save:&error]) {
            DLog(@"Saved");
            return YES;
        }
        else {
            DLog(@"Failed: %@", [error localizedDescription]);
            return NO;
        }
    }
    @catch (NSException *exception) {
        DLog(@"NSException %@", exception.description);
    }
    @finally {
        [self.managedObjectContext unlock];
    }
    return NO;
}

- (BOOL) remove:(id)model {
    if (model != nil) {
        [self.managedObjectContext deleteObject:model];
        return YES;
    }
    return NO;
}

- (BOOL) hasChanges {
    return [self.managedObjectContext hasChanges];
}

- (NSObject*) fetchOrInsertItemForName:(NSString*)name query:(NSString*)query param:(NSString*)param {
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext]];
    if (query != nil) {
        [request setPredicate:[NSPredicate predicateWithFormat:query, param]];
    }
    NSArray *items =  [self.managedObjectContext executeFetchRequest:request error:nil];
    return items != nil && items.count > 0 ? [items lastObject] : [self insertItemWithName:name];
}

- (NSObject*) fetchOrInsertItemForName:(NSString*)name query:(NSString*)query params:(NSString*)param, ... {
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext]];
    va_list args;
    va_start(args, param);
    if (query != nil) {
        NSMutableArray *params = [NSMutableArray array];
        for (NSString *arg = param; arg != nil; arg = va_arg(args, NSString*)) {
            [params addObject:arg];
        }
        if (params.count > 0) {
            [request setPredicate:[NSPredicate predicateWithFormat:query argumentArray:params]];
        }
        else {
            [request setPredicate:[NSPredicate predicateWithFormat:query]];
        }
    }
    va_end(args);
    NSArray *items = [self.managedObjectContext executeFetchRequest:request error:nil];
    return items != nil && items.count > 0 ? [items lastObject] : [self insertItemWithName:name];    
}

#pragma mark - Fetchers

- (id) insertItemWithName:(NSString*)name {
    return [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:self.managedObjectContext];
}

- (NSObject*) fetchItemForName:(NSString *)name query:(NSString*)query param:(NSString*)param {
    NSArray *items = [self fetchArrayForName:name query:query param:param sort:nil];
    return items != nil && items.count > 0 ? [items lastObject] : nil;
}

- (NSInteger) fetchCountForName:(NSString *)name query:(NSString*)query param:(NSString*)param {
    NSArray *items = [self fetchArrayForName:name query:query param:param sort:nil];
    return items != nil ? items.count : 0;
}

- (NSArray *) fetchArrayForName:(NSString *)name query:(NSString*)query param:(NSString*)param sort:(NSString *)sort, ... {
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext]];
    if (query != nil) {
        [request setPredicate:[NSPredicate predicateWithFormat:query, param]];
    }
    va_list args;
    va_start(args, sort);
    NSMutableArray *sortDescriptors = [NSMutableArray array];
    for (NSString *arg = sort; arg != nil; arg = va_arg(args, NSString*)) {
        [sortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:arg ascending:YES]];
    }
    if (sortDescriptors.count > 0) {
        [request setSortDescriptors:sortDescriptors];
    }
    va_end(args);
    return [self.managedObjectContext executeFetchRequest:request error:nil];
}

- (NSObject*) fetchItemForName:(NSString *)name query:(NSString*)query params:(NSString*)param, ... {
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext]];
    va_list args;
    va_start(args, param);
    if (query != nil) {
        NSMutableArray *params = [NSMutableArray array];
        for (NSString *arg = param; arg != nil; arg = va_arg(args, NSString*)) {
            [params addObject:arg];
        }
        if (params.count > 0) {
            [request setPredicate:[NSPredicate predicateWithFormat:query argumentArray:params]];
        }
        else {
            [request setPredicate:[NSPredicate predicateWithFormat:query]];
        }
    }
    va_end(args);
    NSArray *items =  [self.managedObjectContext executeFetchRequest:request error:nil];
    return items != nil && items.count > 0 ? [items lastObject] : nil;
}

- (NSInteger) fetchCountForName:(NSString *)name query:(NSString*)query params:(NSString*)param, ... {
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext]];
    va_list args;
    va_start(args, param);
    if (query != nil) {
        NSMutableArray *params = [NSMutableArray array];
        for (NSString *arg = param; arg != nil; arg = va_arg(args, NSString*)) {
            [params addObject:arg];
        }
        if (params.count > 0) {
            [request setPredicate:[NSPredicate predicateWithFormat:query argumentArray:params]];
        }
        else {
            [request setPredicate:[NSPredicate predicateWithFormat:query]];
        }
    }
    va_end(args);
    NSArray *items =  [self.managedObjectContext executeFetchRequest:request error:nil];
    return items != nil ? items.count : 0;
}

- (NSArray *) fetchArrayForName:(NSString *)name query:(NSString*)query params:(NSString*)param, ... {
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext]];
    va_list args;
    va_start(args, param);
    if (query != nil) {
        NSMutableArray *params = [NSMutableArray array];
        for (NSString *arg = param; arg != nil; arg = va_arg(args, NSString*)) {
            [params addObject:arg];
        }
        if (params.count > 0) {
            [request setPredicate:[NSPredicate predicateWithFormat:query argumentArray:params]];
        }
        else {
            [request setPredicate:[NSPredicate predicateWithFormat:query]];
        }
    }
    va_end(args);
    return [self.managedObjectContext executeFetchRequest:request error:nil];
}

#pragma mark - CoreData

- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSString *mainBundlePath = [[NSBundle mainBundle] resourcePath];
    NSString *frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bundle", self.name]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:frameworkBundlePath]){
        DLog(@"Bundle Exists: %@", frameworkBundlePath);
    }
    else {
        DLog(@"Bundle Does NOT Exist: %@", frameworkBundlePath);
    }
    NSBundle *frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    NSString *bundleResourcePath = [frameworkBundle pathForResource:self.name ofType:@"mom" inDirectory:[NSString stringWithFormat:@"%@.momd", self.name]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:bundleResourcePath]){
        DLog(@"Resource Exists: %@", bundleResourcePath);
    }
    else {
        DLog(@"Resource Does NOT Exist: %@", bundleResourcePath);
    }    
    NSURL *bundleResourceURL = [NSURL fileURLWithPath:bundleResourcePath];
    DLog(@"Resource URL:%@", bundleResourceURL);
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:bundleResourceURL];
    return __managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    NSURL *url = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", self.name]];
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if ([__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) {
        DLog(@"Database %@", url);
    }
    else {
        DLog(@"Schema Changed %@", error);
        if ([[NSFileManager defaultManager] removeItemAtURL:url error:&error]) {
            DLog(@"Database %@ Purged", url);
            if ([__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) {
                DLog(@"Database %@ Created", url);
            }
            else {
                DLog(@"Database Error %@", error);
                abort();
            }
        }
        else {
            DLog(@"Database %@ NOT Purged", url);
            abort();
        }
    }
    return __persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
