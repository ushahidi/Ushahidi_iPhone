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

#import "UIDevice+Extension.h"
#import "NSString+Extension.m"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@interface UIDevice(Private)

- (NSString *) macAddress;

@end

@implementation UIDevice (Extension)

- (NSString *) macAddress {    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        return NULL;
    }
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        return NULL;
    }
    if ((buf = malloc(len)) == NULL) {
        return NULL;
    }
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", 
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

- (NSString *) uniqueDeviceIdentifier{
    NSString *macAddress = [[UIDevice currentDevice] macAddress];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    return [[NSString stringWithFormat:@"%@%@", macAddress, bundleIdentifier] MD5];
}

- (NSString *) uniqueGlobalDeviceIdentifier{
    return [[[UIDevice currentDevice] macAddress] MD5];
}

@end
