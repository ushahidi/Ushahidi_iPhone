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

#import "API.h"
#import "UshahidiProjAppDelegate.h"
@implementation API

@synthesize endPoint;
@synthesize errorCode;
@synthesize errorDesc;
@synthesize responseData;
@synthesize responseJSON;

- (id)init {
	
	responseData = [[NSMutableData data] retain];
	app = [[UIApplication sharedApplication] delegate];
	return self;
}

-(NSMutableArray *)mapLocation
{
	NSError *error;
	NSURLResponse *response;
	NSDictionary *results;
	
	NSString *queryURL = [NSString stringWithFormat:@"http://%@/api?task=mapcenter",app.urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:queryURL]];
	
	responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	responseJSON = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	results = [responseJSON JSONValue];
	
	//categories
	NSMutableArray *mapcenters = [[results objectForKey:@"payload"] objectForKey:@"mapcenters"];
	return mapcenters;
	
}


- (NSMutableArray *)categoryNames {
	//[[NSURLConnection alloc] initWithRequest:request delegate:self];
	NSError *error;
	NSURLResponse *response;
	NSDictionary *results;
	
	NSString *queryURL = [NSString stringWithFormat:@"http://%@/api?task=categories",app.urlString];
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
	
	NSString *queryURL = [NSString stringWithFormat:@"http://%@/api?task=incidents&by=catid&id=%d",app.urlString, catid];
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
	int rno = [app.reports intValue];
	rno = 1;
	NSString *queryURL = [NSString stringWithFormat:@"http://%@/api?task=incidents&by=all&limit=%d&sort=1",app.urlString,rno];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:queryURL]];
	
	responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	responseJSON = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	results = [responseJSON JSONValue];
	
	//categories
	NSMutableArray *incidents = [[results objectForKey:@"payload"] objectForKey:@"incidents"];
	return incidents;
}

- (BOOL)postIncidentWithDictionary:(NSMutableDictionary *)incidentinfo {
	//[[NSURLConnection alloc] initWithRequest:request delegate:self];
	NSError *error;
	NSURLResponse *response;
	NSDictionary *results;
	
	NSString *queryURL = [NSString stringWithFormat:@"http://%@/api?task=report",app.urlString];
	//	//NSString *queryURL = [NSString stringWithFormat:@"http://stopstockouts.org/ushahidi/api?task=report"];
	//	
	//	//form the rest of the url from the dict
	NSEnumerator *enumerator = [incidentinfo keyEnumerator];
	id key;
	
	while ((key = [enumerator nextObject])) {
		NSString *valueString = [incidentinfo objectForKey:key];
		NSString *keyString = (NSString *)key;
		queryURL = [NSString stringWithFormat:@"%@&%@=%@", queryURL, [self urlEncode:keyString], [self urlEncode:valueString]];
	}
	
	//	NSData *aData = [queryURL dataUsingEncoding: NSASCIIStringEncoding];
	//	NSMutableURLRequest *request = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString: queryURL]]; 
	//	[request setHTTPMethod: @"POST" ];
	//	[request setValue:@"text/plain" forHTTPHeaderField:@"Content-type"];
	//	[request setHTTPBody:[aData JSONFragment]];
	
	
	NSString *requestString = [NSString stringWithFormat:@"%@", queryURL, nil];
	NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
	NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", queryURL]]];
	[request setHTTPMethod: @"POST"];	
	[request setHTTPBody:requestData];
	NSData *returnData = [ NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil ];
	NSString *returnString = [[NSString alloc] initWithData:returnData encoding: NSUTF8StringEncoding];
	results = [returnString JSONValue];
	
	
	responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	responseJSON = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	results = [responseJSON JSONValue];
	
	NSString *success = (NSString *)[[results objectForKey:@"payload"] objectForKey:@"success"];
	//[response release];
	//[results release];
	
	if([success isEqual:@"true"])
		return YES;
	else
		return NO;
	
	 
}

- (BOOL)postIncidentWithDictionaryWithPhoto:(NSMutableDictionary *)incidentinfo {
	
	NSString *queryURL = [NSString stringWithFormat:@"http://%@/api?task=report",app.urlString];
	//NSURL *nsurl = [NSString stringWithFormat:@"http://%@/api?task=report",app.urlString];
	NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", queryURL]]];
	//[request setURL:nsurl];  
	[request setHTTPMethod:@"POST"];  
	
	NSString *boundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];  
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];  
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];  
	
	//[incidentinfo objectForKey:@"task"];
	NSString *param1 = 	[incidentinfo objectForKey:@"incident_title"];
	NSString *param2 = [incidentinfo objectForKey:@"incident_description"];
	NSString *param3 =[incidentinfo objectForKey:@"incident_date"];
	NSString *param4 =[incidentinfo objectForKey:@"incident_hour"];
	NSString *param5 =[incidentinfo objectForKey:@"incident_minute"];
	NSString *param6 =[incidentinfo objectForKey:@"incident_ampm"];
	NSString *param7 =[incidentinfo objectForKey:@"incident_category"];
	NSString *param8 =[incidentinfo objectForKey:@"latitude"];
	NSString *param9 =[incidentinfo objectForKey:@"longitude"];
	NSString *param10 =[incidentinfo objectForKey:@"location_name"];
	NSString *param11 =[incidentinfo objectForKey:@"person_first"];
	NSString *param12 =[incidentinfo objectForKey:@"person_last"];
	NSString *param13 =[incidentinfo objectForKey:@"person_email"];
	
	
	/* 
	 now lets create the body of the post 
	 */  
	NSMutableData *body = [NSMutableData data];  
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];   
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"incident_title\"\r\n\r\n%@", param1] dataUsingEncoding:NSUTF8StringEncoding]];  
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];  
	//Tags  
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"incident_description\"\r\n\r\n%@", param2] dataUsingEncoding:NSUTF8StringEncoding]];  
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];  
	//Status  
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"incident_date\"\r\n\r\n%@", param3] dataUsingEncoding:NSUTF8StringEncoding]];  
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];  
	//customerID  
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"incident_hour\"\r\n\r\n%@", param4] dataUsingEncoding:NSUTF8StringEncoding]];  
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];  
	//customerName  
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"incident_minute\"\r\n\r\n%@", param5] dataUsingEncoding:NSUTF8StringEncoding]];  
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];  
	//
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"incident_ampm\"\r\n\r\n%@", param6] dataUsingEncoding:NSUTF8StringEncoding]];  
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];  
	//
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"incident_category\"\r\n\r\n%@", param7] dataUsingEncoding:NSUTF8StringEncoding]];  
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];  
	//
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"latitude\"\r\n\r\n%@", param8] dataUsingEncoding:NSUTF8StringEncoding]];  
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];  
	//
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"longitude\"\r\n\r\n%@", param9] dataUsingEncoding:NSUTF8StringEncoding]];  
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];  
	//
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"location_name\"\r\n\r\n%@", param10] dataUsingEncoding:NSUTF8StringEncoding]];  
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]]; 
	//
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"person_first\"\r\n\r\n%@", param11] dataUsingEncoding:NSUTF8StringEncoding]];  
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]]; 
	//
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"person_last\"\r\n\r\n%@", param12] dataUsingEncoding:NSUTF8StringEncoding]];  
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	//
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"person_email\"\r\n\r\n%@", param13] dataUsingEncoding:NSUTF8StringEncoding]];  
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	//
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"task\"\r\n\r\n%@", @"report"] dataUsingEncoding:NSUTF8StringEncoding]];  
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	//Image 
	UIImage *img[100];
	NSData *imageData[100];
	arrData = [[NSMutableArray alloc] init];
	arrImage = [[NSMutableArray alloc] init]; 
	
	for(int i = 0; i <[app.imgArray count]; i ++)
	{
	img[i] = [app.imgArray objectAtIndex:i];
	imageData[i] = UIImageJPEGRepresentation(img[i], 90);
	[arrData addObject:imageData[i]];
	[arrData retain];
	[arrImage addObject:img[i]];
	[arrImage retain];
	}
	
	// i = 1;
//	img[i] = [app.imgArray objectAtIndex:i];
//	imageData[i] = UIImageJPEGRepresentation(img[i], 90);
//	[arrData addObject:imageData[i]];
//	[arrData retain];
//	[arrImage addObject:img[i]];
//	[arrImage retain];
	
	if([app.imgArray count] >0)
	{
		[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"incident_photo[]\"; filename=\"1.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];  
		[body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
		[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]]; 
		for(int i = 0; i<[arrData count]; i++)
		{
			[body appendData:[NSData dataWithData:[arrData objectAtIndex:i]]]; 
		}
		[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]]; 
	}
	

		
//	
//	 i = 1;
//	img[i] = [app.imgArray objectAtIndex:i];
//	imageData[i] = UIImageJPEGRepresentation(img[i], 90);
//	[arrData addObject:imageData[i]];
//	[arrData retain];
//	[arrImage addObject:img[i]];
//	[arrImage retain];
//	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"incident_photo[]\"; filename=\"%d.jpg\"\r\n",i] dataUsingEncoding:NSUTF8StringEncoding]];  
//	[body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];  
//	[body appendData:[NSData dataWithData:[arrData objectAtIndex:i]]]; 
//	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];  

	

	//}
	//}
	// setting the body of the post to the reqeust  
	[request setHTTPBody:body]; 
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];  
	//responseJSON = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	NSDictionary *results;
	
	NSString *returnString = [[NSString alloc] initWithData:returnData encoding: NSUTF8StringEncoding];
	results = [returnString JSONValue];
	//results = [returnData JSONValue];
		
		NSString *success = (NSString *)[[results objectForKey:@"payload"] objectForKey:@"success"];
		
	//[error release];
	//[response release];
	//[results release];
		
		if([success isEqual:@"true"])
			return YES;
		else
			return NO;
	

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
