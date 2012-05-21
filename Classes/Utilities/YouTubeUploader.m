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

#import "YouTubeUploader.h"
#import "Settings.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ASIFormDataRequest.h"

@interface YouTubeUploader (private)
- (void) login;
- (void) prepareVideoUpload:(NSString *)filename;
- (NSString *) upload:(NSString *)file;
- (NSString *) mimetypeForFileAtPath:(NSString *)path;
@end

@implementation YouTubeUploader

@synthesize authToken;
@synthesize uploadURL;
@synthesize uploadToken;

@synthesize title;
@synthesize videoDescription;
@synthesize delegate;

-(void) uploadVideo:(NSString*)filepath {
    [self login];
    [self prepareVideoUpload:[filepath lastPathComponent]];
    
    NSString *address = [self upload:filepath];
    if (address) {
        [delegate youtubeUploaderDidFinish:self withYoutudeAddress:address];
    }else{
        [delegate youtubeUploaderDidFail:self];
    }
}

- (void) login {
    DLog(@"login");
    
    NSURL *url = [NSURL URLWithString:@"https://www.google.com/accounts/ClientLogin"];
    NSString *youtubeUsername = [Settings sharedSettings].youtubeLogin;
    NSString *youtubePassword = [Settings sharedSettings].youtubePassword;

    NSString *params = [[NSString alloc] initWithFormat:@"Email=%@&Passwd=%@&source=Ushahidi&service=youtube", youtubeUsername, youtubePassword];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    NSString *responseText = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    // The response is a collection of tokens split by newlines
    NSArray *tokens = [responseText componentsSeparatedByString:@"\n"];
    if ([tokens count] >= 3) {
        // Get the auth token as it's always last
        NSArray *newAuthToken = [[tokens objectAtIndex:2] componentsSeparatedByString:@"="];
        
        if ([newAuthToken count] >= 2) {
            self.authToken = [newAuthToken objectAtIndex:1];
        }
    }
}

- (void) prepareVideoUpload:(NSString *) filename {
    DLog(@"prepareVideoUpload");
    NSString *youtubeDeveloperKey = [Settings sharedSettings].youtubeDeveloperKey;

    NSString *xmlTitle = self.title;
    NSString *desc = self.videoDescription;
    NSString *category = @"Nonprofit";
    NSString *keywords = @"ushahidi";
    
    NSString *xml = [NSString stringWithFormat:
                     @"<?xml version=\"1.0\"?>"
                     @"<entry xmlns=\"http://www.w3.org/2005/Atom\" xmlns:media=\"http://search.yahoo.com/mrss/\" xmlns:yt=\"http://gdata.youtube.com/schemas/2007\">"
                     @"<media:group>"
                     @"<media:title type=\"plain\">%@</media:title>"
                     @"<media:description type=\"plain\">%@</media:description>"
                     @"<media:category scheme=\"http://gdata.youtube.com/schemas/2007/categories.cat\">%@</media:category>"
                     @"<media:keywords>%@</media:keywords>"
                     @"</media:group>"
                     @"</entry>", xmlTitle, desc, category, keywords];
    
    NSURL *url = [NSURL URLWithString:@"https://gdata.youtube.com/action/GetUploadToken"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"GoogleLogin auth=\"%@\"", self.authToken] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"2" forHTTPHeaderField:@"GData-Version"];
    [request setValue:[NSString stringWithFormat:@"key=%@", youtubeDeveloperKey] forHTTPHeaderField:@"X-GData-Key"];
    [request setValue:@"application/atom+xml; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%u", [xml length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSString *responseText = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    if (response != nil) {
        NSString *url = [[[[responseText componentsSeparatedByString:@"<response><url>"] objectAtIndex:1] componentsSeparatedByString:@"</url><token>"] objectAtIndex:0];
        
        NSString *token = [[[[responseText componentsSeparatedByString:@"</url><token>"] objectAtIndex:1] componentsSeparatedByString:@"</token></response>"] objectAtIndex:0];        
        
        self.uploadURL = url;
        self.uploadToken = token;
    }
}

- (NSString *) upload:(NSString *)file {
    DLog(@"upload %@", file);

    if (!self.uploadURL && !self.uploadToken) return nil;

    NSString *nextURL = @"http://ushahidi.com/";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?nexturl=%@", self.uploadURL, nextURL]];
        
    ASIFormDataRequest *dataRequest = [ASIFormDataRequest requestWithURL:url];
    [dataRequest addFile:file forKey:@"file"];
    [dataRequest setPostValue:self.uploadToken forKey:@"token"];
    [dataRequest startSynchronous];
    
    NSArray *location = [[[dataRequest url] absoluteString] componentsSeparatedByString:@"id="];
    DLog(@"uploaded to %@", location);
    
    if ([location count] >= 2) {
        NSString *videoURL = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", [location objectAtIndex:1]];
        return videoURL; 
    } 
    return nil;
}

@end
