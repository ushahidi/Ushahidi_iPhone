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

#import "Messages.h"

@implementation Messages

+ (NSString *) errors {
	return NSLocalizedString(@"Errors", @"Errors");
}

+ (NSString *) title {
	return NSLocalizedString(@"Title", @"Title");
}

+ (NSString *) category {
	return NSLocalizedString(@"Category", @"Category");
}

+ (NSString *) location {
	return NSLocalizedString(@"Location", @"Location");
}

+ (NSString *) date {
	return NSLocalizedString(@"Date", @"Date");
}

+ (NSString *) description {
	return NSLocalizedString(@"Description", @"Description");
}

+ (NSString *) photos {
	return NSLocalizedString(@"Photos", @"Photos");
}

+ (NSString *) news {
	return NSLocalizedString(@"News", @"News");
}

+ (NSString *) noLocationSpecified {
	return NSLocalizedString(@"No Location Specified", @"No Location Specified");
}

+ (NSString *) noCategorySpecified {
	return NSLocalizedString(@"No Category Specified", @"No Category Specified");
}

+ (NSString *) noDateSpecified {
	return NSLocalizedString(@"No Date Specified", @"No Date Specified");
}

+ (NSString *) searchServers {
	return NSLocalizedString(@"Search deployments...", @"Search deployments...");
}

+ (NSString *) searchIncidents {
	return NSLocalizedString(@"Search incidents...", @"Search incidents...");
}
	
@end
