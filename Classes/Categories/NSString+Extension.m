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

#import "NSString+Extension.h"

@implementation NSString (Extension)

+ (NSString *)getUUID {
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	return [(NSString *)string autorelease];
}

+ (BOOL) isNilOrEmpty:(NSString *)string {
	return string == nil || [string length] == 0;
}

- (BOOL) anyWordHasPrefix:(NSString *)prefix {
	if (prefix == nil || [prefix length] == 0) {
		return YES;
	}
	for(NSString *word in [[self lowercaseString] componentsSeparatedByString:@" "]) {
		if ([word hasPrefix:[prefix lowercaseString]]) {
			return YES;
		}
	}
	return NO;
}

- (NSString *)stringByTrimmingSuffix:(NSString *)suffix {
    if([self hasSuffix:suffix]) {
		self = [self substringToIndex:[self length] - [suffix length]];
	}
    return self;
}

- (BOOL) isUUID {
	NSString *guidRegex = @"^(\\{){0,1}[0-9a-fA-F]{8}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{12}(\\}){0,1}$"; 
    NSPredicate *guidTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", guidRegex]; 
    return [guidTest evaluateWithObject:self];
}

- (BOOL) isValidEmail {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    return [emailTest evaluateWithObject:self];
}

- (BOOL) isValidURL {
	NSString *urlRegex = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+(:[0-9]+)?(/|/([\\w#!:\\.\\?\\+=&%@!\\-\\/\\(\\)]+))?";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex]; 
    return [urlTest evaluateWithObject:self];
}

+ (NSString *)stringByAppendingPathComponents:(NSString *)string, ... {
    va_list args;
    va_start(args, string);
	NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *filePath = [filePaths objectAtIndex:0];
	for (NSString *arg = string; arg != nil; arg = va_arg(args, NSString*)) {
		if (arg != nil && [arg length] > 0) {
			filePath = [filePath stringByAppendingPathComponent:arg];
		}
	}
	va_end(args);
	return filePath;
}

- (NSString *) appendUrlStringWithFormat:(NSString *)format, ... {
	va_list arguments;
    va_start(arguments, format);
	
    NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:arguments];
	NSURL *domainURL = [NSURL URLWithString:self];
	
	NSURL *fullURL = [NSURL URLWithString:formattedString relativeToURL:domainURL];
	[formattedString release];
	
	va_end(arguments);
	
	return [fullURL absoluteString];
}

static NSDictionary *escapeEntities() {
    static NSDictionary *entities = NULL;
    if(entities == NULL) {
        [NSDictionary dictionaryWithObjectsAndKeys:
		 //Reserved Characters in HTML
		 @"\"", @"&quot;", //quotation mark
		 @"'", @"&apos;", //apostrophe 
		 @"&", @"&amp;", //ampersand
		 @"<", @"&lt;", //less-than
		 @">", @"&gt;", //greater-than
		 //ISO 8859-1 Characters
		 @"À", @"&Agrave;", //capital a, grave accent
		 @"Á", @"&Aacute;", //capital a, acute accent
		 @"Â", @"&Acirc;", //capital a, circumflex accent
		 @"Ã", @"&Atilde;", //capital a, tilde
		 @"Ä", @"&Auml;", //capital a, umlaut mark
		 @"Å", @"&Aring;", //capital a, ring
		 @"Æ", @"&AElig;", //capital ae
		 @"Ç", @"&Ccedil;", //capital c, cedilla
		 @"È", @"&Egrave;", //capital e, grave accent
		 @"É", @"&Eacute;", //capital e, acute accent
		 @"Ê", @"&Ecirc;", //capital e, circumflex accent
		 @"Ë", @"&Euml;", //capital e, umlaut mark
		 @"Ì", @"&Igrave;", //capital i, grave accent
		 @"Í", @"&Iacute;", //capital i, acute accent
		 @"Î", @"&Icirc;", //capital i, circumflex accent
		 @"Ï", @"&Iuml;", //capital i, umlaut mark
		 @"Ð", @"&ETH;", //capital eth, Icelandic
		 @"Ñ", @"&Ntilde;", //capital n, tilde
		 @"Ò", @"&Ograve;", //capital o, grave accent
		 @"Ó", @"&Oacute;", //capital o, acute accent
		 @"Ô", @"&Ocirc;", //capital o, circumflex accent
		 @"Õ", @"&Otilde;", //capital o, tilde
		 @"Ö", @"&Ouml;", //capital o, umlaut mark
		 @"Ø", @"&Oslash;", //capital o, slash
		 @"Ù", @"&Ugrave;", //capital u, grave accent
		 @"Ú", @"&Uacute;", //capital u, acute accent
		 @"Û", @"&Ucirc;", //capital u, circumflex accent
		 @"Ü", @"&Uuml;", //capital u, umlaut mark
		 @"Ý", @"&Yacute;", //capital y, acute accent
		 @"Þ", @"&THORN;", //capital THORN, Icelandic
		 @"ß", @"&szlig;", //small sharp s, German
		 @"à", @"&agrave;", //small a, grave accent
		 @"á", @"&aacute;", //small a, acute accent
		 @"â", @"&acirc;", //small a, circumflex accent
		 @"ã", @"&atilde;", //small a, tilde
		 @"ä", @"&auml;", //small a, umlaut mark
		 @"å", @"&aring;", //small a, ring
		 @"æ", @"&aelig;", //small ae
		 @"ç", @"&ccedil;", //small c, cedilla
		 @"è", @"&egrave;", //small e, grave accent
		 @"é", @"&eacute;", //small e, acute accent
		 @"ê", @"&ecirc;", //small e, circumflex accent
		 @"ë", @"&euml;", //small e, umlaut mark
		 @"ì", @"&igrave;", //small i, grave accent
		 @"í", @"&iacute;", //small i, acute accent
		 @"î", @"&icirc;", //small i, circumflex accent
		 @"ï", @"&iuml;", //small i, umlaut mark
		 @"ð", @"&eth;", //small eth, Icelandic
		 @"ñ", @"&ntilde;", //small n, tilde
		 @"ò", @"&ograve;", //small o, grave accent
		 @"ó", @"&oacute;", //small o, acute accent
		 @"ô", @"&ocirc;", //small o, circumflex accent
		 @"õ", @"&otilde;", //small o, tilde
		 @"ö", @"&ouml;", //small o, umlaut mark
		 @"ø", @"&oslash;", //small o, slash
		 @"ù", @"&ugrave;", //small u, grave accent
		 @"ú", @"&uacute;", //small u, acute accent
		 @"û", @"&ucirc;", //small u, circumflex accent
		 @"ü", @"&uuml;",  //small u, umlaut mark
		 @"ý", @"&yacute;", //small y, acute accent
		 @"þ", @"&thorn;", //small thorn, Icelandic
		 @"ÿ", @"&yuml;", //small y, umlaut mark
		 //ISO 8859-1 Symbols
		 @" ", @"&nbsp;", //non-breaking space
		 @"¡", @"&iexcl;", //inverted exclamation mark
		 @"¢", @"&cent;", //cent
		 @"£", @"&pound;", //pound
		 @"¤", @"&curren;", //currency
		 @"¥", @"&yen;", //yen
		 @"¦", @"&brvbar;", //broken vertical bar
		 @"§", @"&sect;", //section
		 @"¨", @"&uml;", //spacing diaeresis
		 @"©", @"&copy;", //copyright
		 @"ª", @"&ordf;", //feminine ordinal indicator
		 @"«", @"&laquo;", //angle quotation mark (left)
		 @"¬", @"&not;", //negation
		 @"®", @"&reg;", //registered trademark
		 @"¯", @"&macr;", //spacing macron
		 @"°", @"&deg;", //degree
		 @"±", @"&plusmn;", //plus-or-minus
		 @"¹", @"&sup1;", //superscript 1
		 @"²", @"&sup2;", //superscript 2
		 @"³", @"&sup3;", //superscript 3
		 @"´", @"&acute;", //spacing acute
		 @"µ", @"&micro;", //micro
		 @"¶", @"&para;", //paragraph
		 @"·", @"&middot;", //middle dot
		 @"¸", @"&cedil;", //spacing cedilla
		 @"º", @"&ordm;", //masculine ordinal indicator
		 @"»", @"&raquo;", //angle quotation mark (right)
		 @"¼", @"&frac14;", //fraction 1/4
		 @"½", @"&frac12;", //fraction 1/2
		 @"¾", @"&frac34;", //fraction 3/4
		 @"¿", @"&iquest;", //inverted question mark
		 @"×", @"&times;", //multiplication
		 @"÷", @"&divide;", //division
		 nil];
    }
    return [[entities retain] autorelease];
}

+ (NSString *) stringByEscapingCharacters:(NSString *)string {
	if ([NSString isNilOrEmpty:string] == NO) {
		NSString *escaped = [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSDictionary *entities = escapeEntities();
		for (NSString *entity in [entities allKeys]) {
			if ([escaped rangeOfString:entity].location != NSNotFound) {
				escaped = [escaped stringByReplacingOccurrencesOfString:entity withString:[entities objectForKey:entity]];	
			}
		}
		return escaped;
	}
	return nil;
}

@end
