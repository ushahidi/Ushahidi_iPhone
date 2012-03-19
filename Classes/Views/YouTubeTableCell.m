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

#import "YouTubeTableCell.h"
#import "NSString+Extension.h"

@interface YouTubeTableCell ()

@property (nonatomic, assign) id<YouTubeTableCellDelegate> delegate;

@end

@implementation YouTubeTableCell

@synthesize webView;
@synthesize delegate;

- (void) loadVideo:(NSString *)url {
    NSString *htmlString = [url youTubeEmbedCode:YES size:self.contentView.frame.size];
    [self.webView loadHTMLString:htmlString baseURL:nil];
}

#pragma mark -
#pragma mark UITableViewCell

- (id)initForDelegate:(id<YouTubeTableCellDelegate>)theDelegate reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		self.delegate = theDelegate;
		self.webView = [[UIWebView alloc] initWithFrame:CGRectInset(self.contentView.frame, 10, 10)];
		self.webView.delegate = self;
		self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.contentView addSubview:self.webView];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.accessoryType = UITableViewCellAccessoryNone;
	}
    return self;
}

- (void)dealloc {
	delegate = nil;
	[webView release];
	[super dealloc];
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}

@end
