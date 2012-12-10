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

#import "NSURL+USH.h"

@implementation NSURL (USH)

+ (NSURL *) URLWithStrings:(NSString *)string, ... {
    va_list args;
    va_start(args, string);
	NSURL *url = [NSURL URLWithString:string];
	for (NSString *arg = string; arg != nil; arg = va_arg(args, NSString*)) {
		url = [NSURL URLWithString:arg relativeToURL:url];
	}
	va_end(args);
	return url;
}

- (NSString *) domainString {
    if (self.self.scheme != nil && self.host != nil) {
        return [NSString stringWithFormat:@"%@://%@", self.scheme, self.host];
    }
    NSArray *parts = [self.absoluteString componentsSeparatedByString:@"/"];
    for (NSString *part in parts) {
        if ([part rangeOfString:@"."].location != NSNotFound){
            return [NSString stringWithFormat:@"http://%@", part];
        }
    }
    return nil;
}

- (NSURL *) domainURL {
    return [NSURL URLWithString:self.domainString];
}

- (NSArray *)parameterArray {
    if (![self query]) {
        return nil;
    }
    NSScanner *scanner = [NSScanner scannerWithString:[self query]];
    if (!scanner) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray array];
    NSString *key;
    NSString *value;
    while (![scanner isAtEnd]) {
        if (![scanner scanUpToString:@"=" intoString:&key]) {
            key = nil;
        }
        [scanner scanString:@"=" intoString:nil];
        if (![scanner scanUpToString:@"&" intoString:&value]) {
            value = nil;
        }
        [scanner scanString:@"&" intoString:nil];
        key = [key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (key) {
            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                   key, @"key", value, @"value", nil]];
        }
    }
    return array;
}

- (NSDictionary *)parameterDictionary {
    if (![self query]) {
        return nil;
    }
    NSArray *parameterArray = [self parameterArray];
    NSArray *keys = [parameterArray valueForKey:@"key"];
    NSArray *values = [parameterArray valueForKey:@"value"];
    return [NSDictionary dictionaryWithObjects:values forKeys:keys];
}

@end
