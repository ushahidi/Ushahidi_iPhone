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

#import "USHDevice.h"
#import "NSString+USH.h"
#import "UIDevice+USH.h"

@implementation USHDevice

+ (BOOL) isIPad {
	BOOL iPad = NO;
#ifdef UI_USER_INTERFACE_IDIOM
	iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
	return iPad;
}

+ (BOOL) isIPhone {
	BOOL iPhone = NO;
#ifdef UI_USER_INTERFACE_IDIOM
	iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
#endif
	return iPhone;
}

+ (BOOL) isGestureSupported {
	BOOL gesture = NO;
#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 30200)
	gesture = YES;
#endif
	return gesture;
}

+ (NSString *) deviceVersion {
	return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *) deviceModel {
	return [[UIDevice currentDevice] model];
}

+ (BOOL) isPortraitMode {
    return ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait) || 
           ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown);
}

+ (BOOL) isLandscapeMode {
    return ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) || 
           ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight);
}

@end
