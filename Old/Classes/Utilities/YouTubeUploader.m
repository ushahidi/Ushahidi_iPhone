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
#import "ASIFormDataRequest.h"
#import "NSString+Extension.h"
#import "NSDate+Extension.h"

@interface YouTubeUploader (private)
- (BOOL) loginUser;
- (BOOL) prepareVideo:(NSString *)filename;
- (BOOL) uploadFile:(NSString *)file;
@end

@implementation YouTubeUploader

@synthesize authToken;
@synthesize uploadURL;
@synthesize uploadToken;

@synthesize source;
@synthesize title;
@synthesize description;
@synthesize delegate;

- (void)dealloc {
    delegate = nil;
    [authToken release];
    [uploadURL release];
    [uploadToken release];
    [source release];
    [title release];
    [description release];
	[super dealloc];
}

- (BOOL) uploadVideo:(NSString*)filepath {
    DLog(@"FilePath: %@", filepath);
    return [self loginUser] && [self prepareVideo:[filepath lastPathComponent]] && [self uploadFile:filepath];
}

- (BOOL) loginUser {
    DLog(@"");
    if ([NSString isNilOrEmpty:[Settings sharedSettings].youtubeLogin] == NO &&
        [NSString isNilOrEmpty:[Settings sharedSettings].youtubePassword] == NO) {
        NSURL *url = [NSURL URLWithString:@"https://www.google.com/accounts/ClientLogin"];
        DLog(@"URL: %@", url);
        
        NSString *email = [Settings sharedSettings].youtubeLogin;
        NSString *password = [Settings sharedSettings].youtubePassword;
        NSString *params = [[NSString alloc] initWithFormat:@"Email=%@&Passwd=%@&source=Ushahidi&service=youtube", email, password];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSError *requestError;
        NSURLResponse *urlResponse = nil;
        
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
        if (response != nil) {
            NSString *responseText = [[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] autorelease];
            //DLog(@"RESPONSE: %@", responseText);
            NSArray *tokens = [responseText componentsSeparatedByString:@"\n"];
            if ([tokens count] >= 3) {
                NSArray *newAuthToken = [[tokens objectAtIndex:2] componentsSeparatedByString:@"="];
                if ([newAuthToken count] >= 2) {
                    self.authToken = [newAuthToken objectAtIndex:1];
                    return TRUE;
                }
            }   
        }
        else if (requestError) {
            if ([delegate respondsToSelector:@selector(youtubeUploaderDidFail:withError:)]) {
                [delegate youtubeUploaderDidFail:self withError:[requestError localizedDescription]];
            } 
        }
    }
    else {
        if ([delegate respondsToSelector:@selector(youtubeUploaderDidFail:withError:)]) {
            [delegate youtubeUploaderDidFail:self withError:NSLocalizedString(@"Login Failed", nil)];
        }
    }
    return FALSE;
}

- (BOOL) prepareVideo:(NSString *) filename {
    DLog(@"File: %@", filename);
    NSString *developerKey = [Settings sharedSettings].youtubeDeveloperKey;
    
    NSString *videoTitle = [NSString isNilOrEmpty:self.title] ? self.source : self.title;
    NSString *videoDescription = [NSString isNilOrEmpty:self.description] ? @"" : self.description;
    NSString *videoCategory = @"Nonprofit";
    NSString *videoKeywords = [NSString stringWithFormat:@"Ushahidi,%@", self.source];
    
    NSString *xml = [NSString stringWithFormat:
                     @"<?xml version=\"1.0\"?>"
                     @"<entry xmlns=\"http://www.w3.org/2005/Atom\" xmlns:media=\"http://search.yahoo.com/mrss/\" xmlns:yt=\"http://gdata.youtube.com/schemas/2007\">"
                     @"<media:group>"
                     @"<media:title type=\"plain\">%@</media:title>"
                     @"<media:description type=\"plain\">%@</media:description>"
                     @"<media:category scheme=\"http://gdata.youtube.com/schemas/2007/categories.cat\">%@</media:category>"
                     @"<media:keywords>%@</media:keywords>"
                     @"</media:group>"
                     @"</entry>", videoTitle, videoDescription, videoCategory, videoKeywords];
    
    NSURL *url = [NSURL URLWithString:@"https://gdata.youtube.com/action/GetUploadToken"];
    DLog(@"URL: %@", url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"GoogleLogin auth=\"%@\"", self.authToken] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"2" forHTTPHeaderField:@"GData-Version"];
    [request setValue:[NSString stringWithFormat:@"key=%@", developerKey] forHTTPHeaderField:@"X-GData-Key"];
    [request setValue:@"application/atom+xml; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%u", [xml length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];    
    if (response != nil) {
        NSString *responseText = [[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] autorelease];
        //DLog(@"RESPONSE: %@", responseText);
        if ([responseText rangeOfString:@"<response><url>"].location != NSNotFound) {
            NSString *url = [[[[responseText componentsSeparatedByString:@"<response><url>"] objectAtIndex:1] componentsSeparatedByString:@"</url><token>"] objectAtIndex:0];
            NSString *token = [[[[responseText componentsSeparatedByString:@"</url><token>"] objectAtIndex:1] componentsSeparatedByString:@"</token></response>"] objectAtIndex:0];        
            
            self.uploadURL = url;
            self.uploadToken = token;
            
            return TRUE;
        }
        else if ([responseText rangeOfString:@"NoLinkedYouTubeAccount"].location != NSNotFound) {
            if ([delegate respondsToSelector:@selector(youtubeUploaderDidFail:withError:)]) {
                [delegate youtubeUploaderDidFail:self withError:NSLocalizedString(@"No YouTube Linked Account", nil)];
            }
        }
        else {
            if ([delegate respondsToSelector:@selector(youtubeUploaderDidFail:withError:)]) {
                [delegate youtubeUploaderDidFail:self withError:NSLocalizedString(@"Authentication Failed", nil)];
            }
        }
    }
    else {
        if ([delegate respondsToSelector:@selector(youtubeUploaderDidFail:withError:)]) {
            [delegate youtubeUploaderDidFail:self withError:NSLocalizedString(@"Authentication Failed", nil)];
        }
    }
    return FALSE;
}

- (BOOL) uploadFile:(NSString *)file {
    DLog(@"File: %@", file);
    if ([NSString isNilOrEmpty:self.uploadURL] == NO && 
        [NSString isNilOrEmpty:self.uploadURL] == NO) {
        
        NSString *nextURL = @"http://ushahidi.com/";
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?nexturl=%@", self.uploadURL, nextURL]];
        
        ASIFormDataRequest *dataRequest = [ASIFormDataRequest requestWithURL:url];
        [dataRequest addFile:file forKey:@"file"];
        [dataRequest setPostValue:self.uploadToken forKey:@"token"];
        dataRequest.delegate = self;
        [dataRequest startAsynchronous];
        [delegate youtubeUploaderDidStart:self]; 
        
        return TRUE;
    }
    else {
        if ([delegate respondsToSelector:@selector(youtubeUploaderDidFail:withError:)]) {
            [delegate youtubeUploaderDidFail:self withError:NSLocalizedString(@"Authentication Failed", nil)];
        }
    }
    return FALSE;
}

#pragma mark -
#pragma mark ASIHTTEPRequest Delegate Methods

- (void)requestFailed:(ASIHTTPRequest *)request {
    if ([delegate respondsToSelector:@selector(youtubeUploaderDidFail:withError:)]) {
        [delegate youtubeUploaderDidFail:self withError:[request.error localizedDescription]];     
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSArray *location = [[[request url] absoluteString] componentsSeparatedByString:@"id="];
    DLog(@"Location: %@", location);
    if ([location count] >= 2) {
        NSString *videoURL = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", [location objectAtIndex:1]];
        DLog(@"URL: %@", videoURL);
        if ([delegate respondsToSelector:@selector(youtubeUploaderDidFinish:withAddress:)]) {
            [delegate youtubeUploaderDidFinish:self withAddress:videoURL];
        }
    } 
    else {
        if ([delegate respondsToSelector:@selector(youtubeUploaderDidFail:withError:)]) {
            [delegate youtubeUploaderDidFail:self withError:NSLocalizedString(@"Upload Failed", nil)];   
        }
    }
}

@end
