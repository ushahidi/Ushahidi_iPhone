//
//  API.m
//  Ushahidi
//
//  Created by Wilfred Mworia on 9/21/09.
//  Copyright 2009 African Pixel. All rights reserved.
//

#import "API.h"


@implementation API

@synthesize endPoint;
@synthesize errorCode;
@synthesize errorDesc;
@synthesize responseData;
@synthesize responseJSON;

- (id)init {
	responseData = [[NSMutableData data] retain];
	return self;
}

/*- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	responseJSON = @"";
	errorCode = @"101";
	errorDesc = [NSString stringWithFormat:@"Connection failed: %@", [error description]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[connection release];
	
	responseJSON = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	[responseData release];
	
	NSArray *luckyNumbers = [responseString JSONValue];
	
	NSMutableString *text = [NSMutableString stringWithString:@"Lucky numbers:\n"];
	
	for (int i = 0; i < [luckyNumbers count]; i++)
		[text appendFormat:@"%@\n", [luckyNumbers objectAtIndex:i]];
	
	
}*/

- (NSMutableArray *)categoryNames {
	//[[NSURLConnection alloc] initWithRequest:request delegate:self];
	NSError *error;
	NSURLResponse *response;
	NSDictionary *results;
	
	NSString *queryURL = [NSString stringWithFormat:@"http://demo.ushahidi.com/api?task=categories"];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:queryURL]];
	
	responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	responseJSON = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	results = [responseJSON JSONValue];
	
	//categories
	NSMutableArray *categories = [[results objectForKey:@"payload"] objectForKey:@"categories"];
	//[error release];
	//[response release];
	//[results release];
	
	return categories;
}

- (NSMutableArray *)incidentsByCategoryId:(int)catid {
	//[[NSURLConnection alloc] initWithRequest:request delegate:self];
	NSError *error;
	NSURLResponse *response;
	NSDictionary *results;
	
	NSString *queryURL = [NSString stringWithFormat:@"http://demo.ushahidi.com/api?task=incidents&by=catid&id=%d", catid];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:queryURL]];
	
	responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	responseJSON = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	results = [responseJSON JSONValue];
	
	//categories
	NSMutableArray *incidents = [[results objectForKey:@"payload"] objectForKey:@"incidents"];
	//[error release];
	//[response release];
	//[results release];
	
	return incidents;
}

- (NSMutableArray *)allIncidents {
	//[[NSURLConnection alloc] initWithRequest:request delegate:self];
	NSError *error;
	NSURLResponse *response;
	NSDictionary *results;
	
	NSString *queryURL = [NSString stringWithFormat:@"http://demo.ushahidi.com/api?task=incidents&by=all"];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:queryURL]];
	
	responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	responseJSON = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	results = [responseJSON JSONValue];
	
	//categories
	NSMutableArray *incidents = [[results objectForKey:@"payload"] objectForKey:@"incidents"];
	//[error release];
	//[response release];
	//[results release];
	
	return incidents;
}

- (BOOL)postIncidentWithDictionary:(NSMutableDictionary *)incidentinfo {
	//[[NSURLConnection alloc] initWithRequest:request delegate:self];
	NSError *error;
	NSURLResponse *response;
	NSDictionary *results;
	
	NSString *queryURL = [NSString stringWithFormat:@"http://demo.ushahidi.com/api?task=report"];
	//NSString *queryURL = [NSString stringWithFormat:@"http://stopstockouts.org/ushahidi/api?task=report"];
	
	//form the rest of the url from the dict
	NSEnumerator *enumerator = [incidentinfo keyEnumerator];
	id key;
	
	while ((key = [enumerator nextObject])) {
		NSString *valueString = [incidentinfo objectForKey:key];
		NSString *keyString = (NSString *)key;
		queryURL = [NSString stringWithFormat:@"%@&%@=%@", queryURL, [self urlEncode:keyString], [self urlEncode:valueString]];
	}

	NSMutableURLRequest *request = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString: queryURL ] ]; 
	
	[request setHTTPMethod: @"POST" ];
	[request setValue:@"text/plain" forHTTPHeaderField:@"Content-type"];
	[request setHTTPBody:[NSData data]];

	
	responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	responseJSON = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	results = [responseJSON JSONValue];
	
	NSString *success = (NSString *)[[results objectForKey:@"payload"] objectForKey:@"success"];
	
	
	//[error release];
	//[response release];
	//[results release];
	
	if([success isEqual:@"false"])
		return NO;
	else
		return YES;
	 
}

- (BOOL)postIncidentWithDictionary:(NSMutableDictionary *)incidentinfo andPhotoDataDictionary:(NSMutableDictionary *) photoData {
	return NO;
}

- (NSString *)urlEncode:(NSString *)string {
	return [string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}


- (void)dealloc {
	[endPoint release];
	[errorCode release];
	[errorDesc release];
	if(responseData != nil)
		[responseData release];
	[responseJSON release];
	[super dealloc];
}

@end
