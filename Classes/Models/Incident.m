/*****************************************************************************
 ** Copyright (c) 2010 Ushahidi Inc
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

#import "Incident.h"
#import "Location.h"
#import "Photo.h"
#import "Category.h"
#import "News.h"
#import "Sound.h"
#import "Video.h"
#import "NSDate+Extension.h"
#import "NSDictionary+Extension.h"
#import "NSString+Extension.h"
#import "IncidentCustomField.h"

@interface Incident ()

- (BOOL) hasMedia:(Media *)media inCollection:(NSArray *)collection;

@end

@implementation Incident

@synthesize identifier, title, description, date;
@synthesize map;
@synthesize active, verified, uploading, pending, userLocation;
@synthesize news, photos, sounds, videos, categories, customFormEntries,customFields;
@synthesize location, latitude, longitude;
@synthesize errors;

- (id)initWithDefaultValues {
	if (self = [super init]) {
		self.news = [[NSMutableArray alloc] initWithCapacity:0];
		self.photos = [[NSMutableArray alloc] initWithCapacity:0];
		self.sounds = [[NSMutableArray alloc] initWithCapacity:0];
		self.videos = [[NSMutableArray alloc] initWithCapacity:0];
		self.categories = [[NSMutableArray alloc] initWithCapacity:0];
		self.latitude = nil;
		self.longitude = nil;
		self.date = [self dateWithZeroSeconds:[NSDate date]];
		self.userLocation = YES;
        self.customFormEntries = [[NSMutableDictionary alloc] initWithCapacity:0];
        self.customFields = [[NSMutableArray alloc] initWithCapacity:0];
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [self initWithDefaultValues]) {
		if (dictionary != nil) {
			DLog(@"inspection: %@", dictionary);
			self.identifier = [dictionary stringForKey:@"incidentid"];
			self.title = [dictionary stringForKey:@"incidenttitle"];
			self.description = [dictionary stringForKey:@"incidentdescription"];
			self.active = [dictionary boolForKey:@"incidentactive"];
			self.verified = [dictionary boolForKey:@"incidentverified"];
			NSString *dateString = [dictionary objectForKey:@"incidentdate"];
			if (dateString != nil) {
				self.date = [self dateWithZeroSeconds:[NSDate dateFromString:dateString]];
			}
			self.location = [dictionary stringForKey:@"locationname"];
			self.latitude = [dictionary stringForKey:@"locationlatitude"];
			self.longitude = [dictionary stringForKey:@"locationlongitude"];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.identifier forKey:@"identifier"];
	[encoder encodeObject:self.title forKey:@"title"];
	[encoder encodeObject:self.description forKey:@"description"];
	[encoder encodeObject:self.date forKey:@"date"];
	[encoder encodeBool:self.active forKey:@"active"];
	[encoder encodeBool:self.verified forKey:@"verified"];
	[encoder encodeBool:self.pending forKey:@"pending"];
	[encoder encodeBool:self.userLocation forKey:@"userLocation"];
	[encoder encodeObject:self.news forKey:@"news"];
	[encoder encodeObject:self.photos forKey:@"photos"];
	[encoder encodeObject:self.sounds forKey:@"sounds"];
	[encoder encodeObject:self.videos forKey:@"videos"];
	[encoder encodeObject:self.categories forKey:@"categories"];
	[encoder encodeObject:self.location forKey:@"location"];
	[encoder encodeObject:self.latitude forKey:@"latitude"];
	[encoder encodeObject:self.longitude forKey:@"longitude"];
	if (self.map != nil) {
        [encoder encodeObject:UIImagePNGRepresentation(self.map) forKey:@"map"];
	} 
	else {
		[encoder encodeObject:nil forKey:@"map"];
	}
    if(self.customFormEntries != nil){
        [encoder encodeObject:self.customFormEntries forKey:@"customFormEntries"];
    }else{
        [encoder encodeObject:nil forKey:@"customFormEntries"];
    }
    
    if(self.customFormEntries != nil){
       [encoder encodeObject:self.customFields forKey:@"customFields"];
    }else{
        [encoder encodeObject:nil forKey:@"customFields"];
    }
    
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.identifier = [decoder decodeObjectForKey:@"identifier"];
		self.title = [decoder decodeObjectForKey:@"title"];
		self.description = [decoder decodeObjectForKey:@"description"];
		self.date = [decoder decodeObjectForKey:@"date"];
		self.active = [decoder decodeBoolForKey:@"active"];
		self.verified = [decoder decodeBoolForKey:@"verified"];
		self.pending = [decoder decodeBoolForKey:@"pending"];
		self.userLocation = [decoder decodeBoolForKey:@"userLocation"];
		self.location = [decoder decodeObjectForKey:@"location"];
		self.latitude = [decoder decodeObjectForKey:@"latitude"];
		self.longitude = [decoder decodeObjectForKey:@"longitude"];
		NSData *mapData = [decoder decodeObjectForKey:@"map"];
		if (mapData != nil) {
			self.map = [UIImage imageWithData:mapData];
		}
		self.news = [decoder decodeObjectForKey:@"news"];
		if (self.news == nil) self.news = [NSMutableArray array];
		
		self.photos = [decoder decodeObjectForKey:@"photos"];
		if (self.photos == nil) self.photos = [NSMutableArray array];
		
		self.videos = [decoder decodeObjectForKey:@"videos"];
		if (self.videos == nil) self.videos = [NSMutableArray array];
		
		self.sounds = [decoder decodeObjectForKey:@"sounds"];
		if (self.sounds == nil) self.sounds = [NSMutableArray array];
		
		self.categories = [decoder decodeObjectForKey:@"categories"];
		if (self.categories == nil) self.categories = [NSMutableArray array];
        
        self.customFormEntries = [decoder decodeObjectForKey:@"customFormEntries"];
        if (self.customFormEntries == nil) self.customFormEntries = [NSMutableDictionary dictionary];
        
        self.customFields = [decoder decodeObjectForKey:@"customFields"];
        if (self.customFields == nil) self.customFields = [NSMutableArray array];
	}
	return self;
}

- (BOOL) hasURL {
	return self.identifier != nil && [self.identifier isUUID] == NO;
}

- (BOOL) matchesString:(NSString *)string {
	if (self.title != nil && [self.title anyWordHasPrefix:string]) {
		return YES;
	}
	if (self.location != nil && [self.location anyWordHasPrefix:string]) {
		return YES;
	}
	for (Category *category in self.categories) {
		if ([category.title anyWordHasPrefix:string]) {
			return YES;
		}
	}
	return NO;
}

- (BOOL) isDuplicate:(Incident *)incident {
	NSString *selfLat = [NSString stringWithFormat:@"%@ %@",self.latitude,@"." ];
    NSString *selfLon = [NSString stringWithFormat:@"%@ %@",self.longitude,@"." ];
    NSString *incidentLat = [NSString stringWithFormat:@"%@ %@",incident.latitude,@"." ];
    NSString *incidentLon = [NSString stringWithFormat:@"%@ %@",incident.longitude,@"." ];
    
    return	[self.title isEqualToString:incident.title] &&
			[self.description isEqualToString:incident.description] &&
			[self.date isEqualToDate:incident.date] &&
			[self.location isEqualToString:incident.location] &&
			[selfLat isEqualToString:incidentLat] &&
			[selfLon isEqualToString:incidentLon];
}

- (NSString *) dateTimeString {
	return self.date != nil ? [self.date dateToString:@"h:mm a, ccc, MMM d, yyyy"] : nil;
}

- (NSString *) dateString {
	return self.date != nil ? [self.date dateToString:@"cccc, MMMM d, yyyy"] : nil;
}

- (NSString *) timeString {
	return self.date != nil ? [self.date dateToString:@"h:mm a"] : nil;
}

- (NSString *) dateDayMonthYear {
	return self.date != nil ? [self.date dateToString:@"MM/dd/yyyy"] : nil;
}

- (NSString *) date12Hour {
	return self.date != nil ? [self.date dateToString:@"hh"] : nil;
}

- (NSString *) date24Hour {
	return self.date != nil ? [self.date dateToString:@"HH"] : nil;
}

- (NSString *) dateMinute {
	return self.date != nil ? [self.date dateToString:@"mm"] : nil;
}

- (NSString *) dateAmPm {
	if (self.date != nil) {
		NSCalendar *calendar = [NSCalendar currentCalendar];
		NSDateComponents *components = [calendar components:kCFCalendarUnitHour fromDate:self.date];
		NSString *value = [components hour] >= 12 ? @"pm" : @"am";
		return value;
	}
	return nil;
}

- (void) addPhoto:(Photo *)photo {
	if ([self hasMedia:photo inCollection:self.photos] == NO) {
		if ([photo identifier] != nil) {
			DLog(@"addPhoto: %@", [photo identifier]);
		}
		else {
			DLog(@"addPhoto: NEW PHOTO");
		}
		[self.photos addObject:photo];
	}
}

- (void) addNews:(News *)article {
	if ([self hasMedia:article inCollection:self.news] == NO) {
		DLog(@"addNews: %@", [article identifier]);
		[self.news addObject:article];
	}
}

- (void) addSound:(Sound *)sound {
	if ([self hasMedia:sound inCollection:self.sounds] == NO) {
		DLog(@"addSound: %@", [sound identifier]);
		[self.sounds addObject:sound];
	}
}

- (void) addVideo:(Video *)video {
	if ([self hasMedia:video inCollection:self.videos] == NO) {
		DLog(@"addVideo: %@", [video identifier]);
		[self.videos addObject:video];	
	}
}

- (BOOL) hasMedia:(Media *)media inCollection:(NSArray *)collection {
	if (media.identifier != nil) {
		for (Media *existing in collection) {
			if ([existing.identifier isEqualToString:media.identifier]) {
				return YES;
			}
		}
	}
	return NO;
}

- (void) addCategory:(Category *)category {
	DLog(@"%@", category.title);
	if ([self.categories containsObject:category] == NO) {
		[self.categories addObject:category];
	}
}

- (void) removeCategory:(Category *)category {
	DLog(@"%@", category.title);
	if ([self.categories containsObject:category]) {
		[self.categories removeObject:category];
	}
}

- (BOOL) hasCategory:(Category *)category {
	for (Category *current in self.categories) {
        NSString *currentIdentifier = [NSString stringWithFormat:@"%@%@",current.identifier,@"."];
        NSString *categoryIdentifier = [NSString stringWithFormat:@"%@%@",category.identifier,@"."];
		if ([currentIdentifier isEqualToString:categoryIdentifier]) {
			return YES;
		}
	}
	return NO;
}

- (NSString *) categoryIDs {
	NSMutableString *categoryIDs = [NSMutableString string];
	for (Category *category in self.categories) {
		if ([categoryIDs length] > 0) {
			[categoryIDs appendFormat:@","];
		}
		[categoryIDs appendFormat:@"%@", category.identifier];
	}
	return categoryIDs;
}

- (NSString *) categoryNames {
	return [self categoryNamesWithDefaultText:nil];
}

- (NSString *) categoryNamesWithDefaultText:(NSString *)defaultText {
	NSMutableString *categoryNames = [NSMutableString string];
	for (Category *category in self.categories) {
		if ([categoryNames length] > 0) {
			[categoryNames appendFormat:@","];
		}
		[categoryNames appendFormat:@"%@", category.title];
	}
	return [categoryNames length] > 0 ? categoryNames : defaultText;
}

- (UIImage *) getFirstPhotoThumbnail {
	for (Photo *photo in self.photos) {
		if (photo.thumbnail != nil) {
			return photo.thumbnail;
		}
		if (photo.image != nil) {
			return photo.image;
		}
	} 
	return nil;
}

- (void) removePhotoAtIndex:(NSInteger)index {
	[self.photos removeObjectAtIndex:index];
}

- (void) removeVideoAtIndex:(NSInteger)index {
	[self.videos removeObjectAtIndex:index];
}


- (BOOL) hasTitle {
	return  self.title != nil && self.title.length > 0;
}

- (BOOL) hasDescription {
	return self.description != nil && self.description.length > 0;
}

- (BOOL) hasLocation {
	return	self.location != nil && self.location.length > 0 &&
			self.latitude != nil && self.latitude.length > 0 &&
			self.longitude != nil && self.longitude.length > 0;
}

- (BOOL) hasDate {
	return self.date != nil;
}

- (BOOL) hasCategory {
	return self.categories != nil && self.categories.count > 0;
}

- (BOOL) hasPhotos {
	return self.photos != nil && [self.photos count] > 0;
}

- (NSString *) coordinates {
	return self.latitude != nil && self.longitude != nil 
		? [NSString stringWithFormat:@"%@, %@", self.latitude, self.longitude] : nil;
}

- (NSArray *) photoImages {
	NSMutableArray *images = [NSMutableArray arrayWithCapacity:[self.photos count]];
	for (Photo *photo in self.photos) {
		[images addObject:photo.image];
	}
	return images;
}

- (NSComparisonResult)compareByTitle:(Incident *)incident {
	return [self.title localizedCaseInsensitiveCompare:incident.title];
}

- (NSComparisonResult)compareByDate:(Incident *)incident {
	return [incident.date compare:self.date];
}

- (NSComparisonResult)compareByVerified:(Incident *)incident {
	return incident.verified > self.verified;
}

- (void)addCustomFieldCheckBoxChoice:(NSString *)value forFieldID:(NSInteger) customFieldId choiceNum:(NSInteger)choiceNum{
    
    if(customFormEntries == nil){
        customFormEntries = [[NSMutableDictionary alloc] init];
    }
    
    [customFormEntries setObject:value forKey:[NSString stringWithFormat:@"%@[%d-%d]",customFieldUploadText,customFieldId,choiceNum]];
    
    IncidentCustomField *currentCustomField = nil;
    for(IncidentCustomField *custField in customFields){
        if(custField.fieldID == customFieldId){
            currentCustomField = custField;
        }
    }
    if(currentCustomField != nil){
        NSMutableString *tempSelectedValue = [[NSMutableString alloc] init];
        for (int i = 0; i < [currentCustomField.defaultValues count] ; i++){
            NSString *tempValue = [self getCustomFieldCheckBoxValue:customFieldId choiceNum:i];
            if([tempValue length] > 0){
                [tempSelectedValue appendString:tempValue];
                [tempSelectedValue appendString:@", "];
            }
        }
        if([tempSelectedValue length] > 0){
            currentCustomField.fieldResponse = [tempSelectedValue substringToIndex:[tempSelectedValue length] - 2];
        }else{
            currentCustomField.fieldResponse = [[NSString alloc]initWithString:@""];
        }
    }

    
    
}
    
- (void)removeCustomFieldCheckBoxChoice:(NSInteger) customFieldId choiceNum:(NSInteger)choiceNum{
    
    if((customFormEntries != nil)&&([customFormEntries count] > 0)){
        NSArray *keys = [customFormEntries allKeys];
        if([keys containsObject:[NSString stringWithFormat:@"%@[%d-%d]",customFieldUploadText,customFieldId,choiceNum]]){
            [customFormEntries removeObjectForKey:[NSString stringWithFormat:@"%@[%d-%d]",customFieldUploadText,customFieldId,choiceNum]];
        }
    }
    
    IncidentCustomField *currentCustomField = nil;
    for(IncidentCustomField *custField in customFields){
        if(custField.fieldID == customFieldId){
            currentCustomField = custField;
        }
    }
    if(currentCustomField != nil){
        NSMutableString *tempSelectedValue = [[NSMutableString alloc] init];
        for (int i = 0; i < [currentCustomField.defaultValues count] ; i++){
            NSString *tempValue = [self getCustomFieldCheckBoxValue:customFieldId choiceNum:i];
            if([tempValue length] > 0){
                [tempSelectedValue appendString:tempValue];
                [tempSelectedValue appendString:@", "];
            }
        }
        if([tempSelectedValue length] > 0){
            currentCustomField.fieldResponse = [tempSelectedValue substringToIndex:[tempSelectedValue length] - 2];
        }else{
            currentCustomField.fieldResponse = [[NSString alloc]initWithString:@""];
        }
    }
    
}

- (NSString *)getCustomFieldCheckBoxValue:(NSInteger) customFieldId choiceNum:(NSInteger)choiceNum{
    if((customFormEntries != nil)&&([customFormEntries count] > 0)){
       return  [customFormEntries objectForKey:[NSString stringWithFormat:@"%@[%d-%d]",customFieldUploadText,customFieldId,choiceNum]];
    }
    return nil;
}

- (void)addUpdateCustomFieldValue:(NSDictionary *)value forFieldID:(NSInteger) customFieldID{
    
    
    if(customFormEntries == nil){
        customFormEntries = [[NSMutableDictionary alloc] init];
    }
    
    [customFormEntries setObject:value forKey:[NSString stringWithFormat:@"%@[%d]",customFieldUploadText,customFieldID]];
    
    IncidentCustomField *currentCustomField = [[IncidentCustomField alloc]init];
    for(IncidentCustomField *custField in customFields){
        if(custField.fieldID == customFieldID){
            currentCustomField = custField;
        }
    }
    if(currentCustomField != nil){
        if([self getCustomFieldValue:customFieldID] != nil){
            currentCustomField.fieldResponse = [[NSString alloc]initWithString:[self getCustomFieldValue:customFieldID]];
        }else{
            currentCustomField.fieldResponse = [[NSString alloc]initWithString:@""];
        }
    }
}

- (void)removeCustomField:(NSInteger) customFieldID{
    if((customFormEntries != nil)&&([customFormEntries count] > 0)){
        NSArray *keys = [customFormEntries allKeys];
        if([keys containsObject:[NSString stringWithFormat:@"%@[%d]",customFieldUploadText,customFieldID]]){
            [customFormEntries removeObjectForKey:[NSString stringWithFormat:@"%@[%d]",customFieldUploadText,customFieldID]];
        }
    }
    IncidentCustomField *currentCustomField = nil;
    for(IncidentCustomField *custField in customFields){
        if(custField.fieldID == customFieldID){
            currentCustomField = custField;
        }
    }
    if(currentCustomField != nil){
        if([self getCustomFieldValue:customFieldID] != nil){
            currentCustomField.fieldResponse = [[NSString alloc]initWithString:[self getCustomFieldValue:customFieldID]];
        }else{
            currentCustomField.fieldResponse = [[NSString alloc]initWithString:@""];
        }
    }
}

- (NSString *)getCustomFieldValue:(NSInteger) customFieldID{
    
    if((customFormEntries != nil)&&([customFormEntries count] > 0)){
       return [customFormEntries objectForKey:[NSString stringWithFormat:@"%@[%d]",customFieldUploadText,customFieldID]];
    }
    return nil;
}

- (NSDate *)dateWithZeroSeconds:(NSDate *)dateTmp
{
    NSTimeInterval time = floor([dateTmp timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    return  [NSDate dateWithTimeIntervalSinceReferenceDate:time];
}

- (void)dealloc {
	[identifier release];
	[title release];
	[description release];
	[date release];
	[location release];
	[latitude release];
	[longitude release];
	[news release];
	[photos release];
	[sounds release];
	[videos release];
	[categories release];
	[errors release];
	[map release];
    [customFormEntries release];
    [customFields release];
	[super dealloc];
}

@end
