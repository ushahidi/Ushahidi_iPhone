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

#import "ASIHTTPRequest+Extension.h"
#import "Deployment.h"
#import "Incident.h"
#import "Ushahidi.h"
#import "Photo.h"
#import "Checkin.h"

#define kDelegateKey @"delegate"
#define kDeploymentKey @"deployment"
#define kIncidentKey @"incident"
#define kPhotoKey @"photo"
#define kCheckinKey @"checkin"

@implementation ASIHTTPRequest (Extension)

- (id<UshahidiDelegate>) getDelegate {
	return [self.userInfo objectForKey:kDelegateKey];
}

- (Deployment *) getDeployment {
	return [self.userInfo objectForKey:kDeploymentKey];
}

- (Incident *) getIncident {
	return [self.userInfo objectForKey:kIncidentKey];
}

- (Photo *) getPhoto {
	return [self.userInfo objectForKey:kPhotoKey];
}

- (Checkin *) getCheckin {
	return [self.userInfo objectForKey:kCheckinKey];
}

- (void) attachDelegate:(id<UshahidiDelegate>)theDelegate {
	NSMutableDictionary *mutableUserInfo = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
	[mutableUserInfo setObject:theDelegate forKey:kDelegateKey];
	self.userInfo = mutableUserInfo;
}

- (void) attachDeployment:(Deployment *)deployment {
	NSMutableDictionary *mutableUserInfo = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
	[mutableUserInfo setObject:deployment forKey:kDeploymentKey];
	self.userInfo = mutableUserInfo;
}

- (void) attachIncident:(Incident *)incident {
	NSMutableDictionary *mutableUserInfo = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
	[mutableUserInfo setObject:incident forKey:kIncidentKey];
	self.userInfo = mutableUserInfo;
}

- (void) attachPhoto:(Photo *)photo {
	NSMutableDictionary *mutableUserInfo = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
	[mutableUserInfo setObject:photo forKey:kPhotoKey];
	self.userInfo = mutableUserInfo;
}

- (void) attachCheckin:(Checkin *)checkin {
	NSMutableDictionary *mutableUserInfo = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
	[mutableUserInfo setObject:checkin forKey:kCheckinKey];
	self.userInfo = mutableUserInfo;
}

@end
