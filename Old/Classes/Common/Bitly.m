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

#import "Bitly.h"
#import "JSON.h"
#import "NSData+Extension.h"
#import "ASIHTTPRequest.h"
#import "NSObject+Extension.h"
#import "NSError+Extension.h"
#import "Internet.h"

@interface Bitly ()

@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, retain) NSString *domain;

- (void) shortenUrlStarted:(ASIHTTPRequest *)request;
- (void) shortenUrlFinished:(ASIHTTPRequest *)request;
- (void) shortenUrlFailed:(ASIHTTPRequest *)request;

@end

@implementation Bitly

@synthesize queue, domain, login, apiKey;

- (id) init {
	if ((self = [super init])) {
		self.queue = [[NSOperationQueue alloc] init];
		[self.queue setMaxConcurrentOperationCount:1];
		self.domain = @"http://api.bit.ly";
	}
	return self;
}

- (void)dealloc {
	[queue release];
	[domain release];
	[login release];
	[apiKey release];
	[super dealloc];
}


- (void) shortenUrl:(NSString *)url forDelegate:(id<BitlyDelegate>)delegate {
	DLog(@"url:%@", url);
	
	NSMutableString *requestURL = [NSMutableString stringWithString:@"http://api.bit.ly/v3/shorten"];
	[requestURL appendFormat:@"?format=%@", @"json"];
	[requestURL appendFormat:@"&login=%@", self.login];
	[requestURL appendFormat:@"&apiKey=%@", self.apiKey];
	[requestURL appendFormat:@"&longUrl=%@", url];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestURL]];
	[request setDelegate:self];
	[request setShouldRedirect:YES];
	[request setDidStartSelector:@selector(shortenUrlStarted:)];
	[request setDidFinishSelector:@selector(shortenUrlFinished:)];
	[request setDidFailSelector:@selector(shortenUrlFailed:)];
	[request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:delegate, @"delegate",
																	url, @"original", nil]];
	
	[self.queue addOperation:request];
}

- (void) shortenUrlStarted:(ASIHTTPRequest *)request {
	DLog(@"REQUEST: %@", [request.originalURL absoluteString]);
}

- (void) shortenUrlFinished:(ASIHTTPRequest *)request {
	DLog(@"REQUEST: %@", [request.originalURL absoluteString]);
	DLog(@"STATUS: %@", [request responseStatusMessage]);
	id<BitlyDelegate> delegate = [request.userInfo objectForKey:@"delegate"];
	NSString *original = [request.userInfo objectForKey:@"original"];
	if ([request responseStatusCode] != HttpStatusOK) {
		NSError *error = [NSError errorWithDomain:self.domain 
											 code:[request responseStatusCode] 
										  message:[request responseStatusMessage]];
		[self dispatchSelector:@selector(urlShortened:original:shortened:error:)
						target:delegate 
					   objects:self, original, nil, error, nil];
	}
	else {
		DLog(@"RESPONSE: %@", [request responseString]);
		NSDictionary *json = [[request responseString] JSONValue];
		if (json != nil && [json isKindOfClass:[NSDictionary class]]) {
			if ([@"OK" isEqualToString:[json objectForKey:@"status_txt"]]) {
				NSDictionary *data = [json objectForKey:@"data"];
				if (data != nil && [data isKindOfClass:[NSDictionary class]]) {
					NSString *shortened = [data objectForKey:@"url"];
					DLog(@"SHORTENED: %@", shortened);
					[self dispatchSelector:@selector(urlShortened:original:shortened:error:) 
									target:delegate 
								   objects:self, original, shortened, nil, nil];
				}
				else {
					NSError *error = [NSError errorWithDomain:self.domain 
														 code:HttpStatusInternalServerError
													  message:NSLocalizedString(@"Invalid Server Response", nil)];
					[self dispatchSelector:@selector(urlShortened:url:error:) 
									target:delegate 
								   objects:self, original, nil, error, nil];
				}	
			}
			else {
				NSError *error = [NSError errorWithDomain:self.domain 
													 code:HttpStatusInternalServerError
												  message:[json objectForKey:@"status_txt"]];
				[self dispatchSelector:@selector(urlShortened:original:shortened:error:) 
								target:delegate 
							   objects:self, original, nil, error, nil];
			}
		}
		else {
			NSError *error = [NSError errorWithDomain:self.domain
												 code:HttpStatusInternalServerError
											  message:NSLocalizedString(@"Invalid Server Response", nil)];
			[self dispatchSelector:@selector(urlShortened:original:shortened:error:) 
							target:delegate 
						   objects:self, original, nil, error, nil];
		}
	}
}

- (void) shortenUrlFailed:(ASIHTTPRequest *)request {
	DLog(@"REQUEST: %@", [request.originalURL absoluteString]);
	DLog(@"STATUS: %@", [request responseStatusMessage]);
	DLog(@"ERROR: %@", [[request error] localizedDescription]);
	id<BitlyDelegate> delegate = [request.userInfo objectForKey:@"delegate"];
	NSString *original = [request.userInfo objectForKey:@"original"];
	[self dispatchSelector:@selector(urlShortened:original:shortened:error:) 
					target:delegate 
				   objects:self, original, nil, [request error], nil];
}

@end
