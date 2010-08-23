//
//  Device.m
//  Ushahidi
//
//  Created by Dale Zak on 10-04-21.
//  Copyright 2010 Dale Zak. All rights reserved.
//

#import "Device.h"

@implementation Device

+ (BOOL) isIPad {
	BOOL iPad = NO;
#ifdef UI_USER_INTERFACE_IDIOM
	iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
	return iPad;
}

+ (BOOL) isGestureSupported {
	BOOL gesture = NO;
#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 30200)
	gesture = YES;
#endif
	return gesture;
}

@end
