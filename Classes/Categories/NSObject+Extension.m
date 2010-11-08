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

#import "NSObject+Extension.h"

@implementation NSObject (Extension)

- (void)dispatchSelector:(SEL)selector
				  target:(id)target
				 objects:(id)firstArgument, ... {
	DLog(@"dispatchSelector: %@", [target class]);
	if(target && [target respondsToSelector:selector]) {
		NSMethodSignature *signature = [target methodSignatureForSelector:selector];
        if(signature) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            @try {
                [invocation setTarget:target];
				[invocation setSelector:selector];
				int index = 2; // self, _cmd, ...
				[invocation setArgument:firstArgument atIndex:index];
				index++;
				va_list arguments;
				va_start(arguments, firstArgument);
				while (index < [signature numberOfArguments]) {
					id argument = va_arg(arguments, id);
					[invocation setArgument:&argument atIndex:index];
					index++;
				}
				va_end(arguments);
				[invocation retainArguments];
                if ([NSThread isMainThread]) {
					[invocation invoke];
				} 
				else {
					[invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:NO];
				}
			}
			@catch (NSException *e) {
				DLog(@"NSException: %@", e)
			}
        }
	}
}

@end
