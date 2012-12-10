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

#import "NSObject+USH.h"

@implementation NSObject (USH)

- (id)performSelector:(SEL)selector withObjects:(NSObject *)firstObject, ... {
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    if (signature && [self respondsToSelector:selector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:self];
        [invocation setSelector:selector];
        va_list args;
        va_start(args, firstObject);
        int index = 2;
        for (NSObject *object = firstObject; index < [signature numberOfArguments]; object = va_arg(args, NSObject*)) {
            if (object != [NSNull null]) {
                [invocation setArgument:&object atIndex:index];
            }
            index++;
        }
        va_end(args);
        [invocation retainArguments];
        [invocation performSelector:@selector(invoke) withObject:nil];
    }
    return self;
}

-(id)performSelectorOnMainThread:(SEL)selector waitUntilDone:(BOOL)wait withObjects:(NSObject *)firstObject, ... {
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    if (signature && [self respondsToSelector:selector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:self];
        [invocation setSelector:selector];
        va_list args;
        va_start(args, firstObject);
        int index = 2;
        for (NSObject *object = firstObject; index < [signature numberOfArguments]; object = va_arg(args, NSObject*)) {
            if (object != [NSNull null]) {
                [invocation setArgument:&object atIndex:index];
            } 
            index++;
        }  
        va_end(args);
        [invocation retainArguments];
        [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:wait];   
    }
    return self;
}

@end
