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

#import "USHSettings.h"
#import <Ushahidi/UIColor+USH.h>
#import <Ushahidi/NSString+USH.h>
#import <Ushahidi/NSDictionary+USH.h>

@interface USHSettings ()

@end

@implementation USHSettings

+ (instancetype) sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (NSString *) appName {
    return [self stringFromBundleForKey:@"CFBundleName"];
}

- (NSString *) appVersion {
    return [self stringFromBundleForKey:@"CFBundleVersion"];
}

- (NSString *) appDescription {
    return [self stringFromBundleForKey:@"USHAppDescription"];
}

- (NSString *) mapName {
    return [self stringFromBundleForKey:@"CFBundleName"];
}

- (NSString *) mapURL {
    return [self stringFromBundleForKey:@"USHMapURL"];
}

- (BOOL) hasMapURL {
    return [NSString isNilOrEmpty:self.mapURL] == NO;
}

- (NSDictionary *) mapURLs {
    return [self dictionaryFromBundleForKey:@"USHMapURLS"];
}

- (BOOL) hasMapURLS {
    return self.mapURLs != nil && self.mapURLs.count > 0;
}

- (NSString *) supportURL {
    return [self stringFromBundleForKey:@"USHSupportURL"];
}

- (NSString *) supportEmail {
    return [self stringFromBundleForKey:@"USHSupportEmail"];
}

- (NSString *) appStoreURL {
    return [self stringFromBundleForKey:@"USHAppStoreURL"];
}

- (NSString *) termsOfServiceURL {
    return [self stringFromBundleForKey:@"USHTermsOfServiceURL"];
}

- (NSString *) privacyPolicyURL {
    return [self stringFromBundleForKey:@"USHPrivacyPolicyURL"];
}

- (NSString *) contactFirstName {
    return [self stringFromDefaultsForKey:@"contactFirstName" defaultValue:nil];
}

- (void) setContactFirstName:(NSString *)contactFirstName {
    [self setString:contactFirstName forKey:@"contactFirstName"];
}

- (NSString *) contactLastName {
    return [self stringFromDefaultsForKey:@"contactLastName" defaultValue:nil];
}

- (void) setContactLastName:(NSString *)contactLastName {
    [self setString:contactLastName forKey:@"contactLastName"];
}

- (NSString *) contactEmailAddress {
    return [self stringFromDefaultsForKey:@"contactEmailAddress" defaultValue:nil];
}

- (void) setContactEmailAddress:(NSString *)contactEmailAddress {
    [self setString:contactEmailAddress forKey:@"contactEmailAddress"];
}

- (NSString*) contactFullName {
    return [NSString stringByAppendingWithToken:@" " count:2 words:self.contactFirstName, self.contactLastName, nil];
}

- (BOOL) hideStatusBar {
    return [self boolFromDefaultsForKey:@"hideStatusBar" defaultValue:NO];
}

- (void) setHideStatusBar:(BOOL)hideStatusBar {
    [self setBool:hideStatusBar forKey:@"hideStatusBar"];
}

- (BOOL) showBadgeNumber {
    return [self boolFromDefaultsForKey:@"showBadgeNumber" defaultValue:YES];
}

- (void) setShowBadgeNumber:(BOOL)showBadgeNumber {
    [self setBool:showBadgeNumber forKey:@"showBadgeNumber"];
}

- (BOOL) downloadMaps {
    return [self boolFromDefaultsForKey:@"downloadMaps" defaultValue:NO];
}

- (void) setDownloadMaps:(BOOL)downloadMaps {
    [self setBool:downloadMaps forKey:@"downloadMaps"];
}

- (BOOL) downloadPhotos {
    return [self boolFromDefaultsForKey:@"downloadPhotos" defaultValue:YES];
}

- (void) setDownloadPhotos:(BOOL)downloadPhotos {
    [self setBool:downloadPhotos forKey:@"downloadPhotos"];
}

- (BOOL) resizePhotos {
    return [self boolFromDefaultsForKey:@"resizePhotos" defaultValue:NO];
}

- (void) setResizePhotos:(BOOL)resizePhotos {
    [self setBool:resizePhotos forKey:@"resizePhotos"];
}

- (CGFloat) imageWidth {
    return [self floatFromDefaultsForKey:@"imageWidth" defaultValue:500];
}

- (void) setImageWidth:(CGFloat)imageWidth {
    [self setFloat:imageWidth forKey:@"imageWidth"];
}

- (UIColor *) navBarColor {
    return [self colorFromBundleForKey:@"USHNavBarColor"];
}

- (BOOL) openGeoSMS {
    return [self boolFromDefaultsForKey:@"openGeoSMS" defaultValue:NO];
}

- (void) setOpenGeoSMS:(BOOL)openGeoSMS {
    [self setBool:openGeoSMS forKey:@"openGeoSMS"];
}

- (NSInteger) downloadLimit {
    return [self integerFromDefaultsForKey:@"downloadLimit" defaultValue:25];
}

- (void) setDownloadLimit:(NSInteger)downloadLimit {
    [self setInteger:downloadLimit forKey:@"downloadLimit"];
}

- (BOOL) termsOfService {
    return [self boolFromDefaultsForKey:@"termsOfService" defaultValue:NO];
}

- (void) setTermsOfService:(BOOL)termsOfService {
    [self setBool:termsOfService forKey:@"termsOfService"];
}

- (UIColor *) tabBarColor {
    return [self colorFromBundleForKey:@"USHTabBarColor"];
}

- (UIColor *) toolBarColor {
    return [self colorFromBundleForKey:@"USHToolBarColor"];
}

- (UIColor *) searchBarColor {
    return [self colorFromBundleForKey:@"USHSearchBarColor"];
}

- (UIColor *) tableBackColor {
    return [self colorFromBundleForKey:@"USHTableBackColor"];
}

- (UIColor *) tableRowColor {
    return [self colorFromBundleForKey:@"USHTableRowColor"];
}

- (UIColor *) tableHeaderColor {
    return [self colorFromBundleForKey:@"USHTableHeaderColor"];
}

- (UIColor *) tableSelectColor {
    return [self colorFromBundleForKey:@"USHTableSelectColor"];
}

- (UIColor *) buttonDoneColor {
    return [self colorFromBundleForKey:@"USHButtonDoneColor"];
}

- (UIColor *) refreshControlColor {
    return [self colorFromBundleForKey:@"USHRefreshControlColor"];
}

- (NSString *) youtubeUsername {
    return [self stringFromBundleForKey:@"USHYouTubeUsername"];
}

- (NSString *) youtubePassword {
    return [self stringFromBundleForKey:@"USHYouTubePassword"];
}

- (NSString *) youtubeDeveloperKey {
    return [self stringFromBundleForKey:@"USHYouTubeDeveloperKey"];
}

- (BOOL) youtubeCredentials {
    return  [NSString isNilOrEmpty:self.youtubeUsername] == NO &&
            [NSString isNilOrEmpty:self.youtubePassword] == NO &&
            [NSString isNilOrEmpty:self.youtubeDeveloperKey] == NO;
}

- (BOOL) showReportList {
    return [self boolFromBundleForKey:@"USHShowReportList" defaultValue:YES];
}

- (BOOL) showReportButton {
    return [self boolFromBundleForKey:@"USHShowReportButton" defaultValue:YES];
}

- (BOOL) sortReportsByDate {
    return [self boolFromBundleForKey:@"USHSortReportsByDate" defaultValue:YES];
}

@end
