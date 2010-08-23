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

#import "Settings.h"
#import "SynthesizeSingleton.h"

@interface Settings ()

@end

@implementation Settings

SYNTHESIZE_SINGLETON_FOR_CLASS(Settings);

@synthesize email;

- (id) init {
	if ((self = [super init])) {
		self.email = [[NSUserDefaults standardUserDefaults] stringForKey:@"email"];
	}
	return self;
}

- (void)dealloc {
	[email release];
	[super dealloc];
}

- (void) save {
	DLog(@"");
	[[NSUserDefaults standardUserDefaults] setObject:self.email forKey:@"email"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
