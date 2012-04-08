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

#import "TwitterViewController.h"
#import "LoadingViewController.h"
#import "TableCellFactory.h"
#import "AlertView.h"
#import "UIColor+Extension.h"
#import "TextTableCell.h"
#import "TextFieldTableCell.h"
#import "NSString+Extension.h"
#import "MGTwitterEngine.h"
#import "Settings.h"
#import "OAToken.h"

@interface TwitterViewController ()

@property (nonatomic, retain) MGTwitterEngine *twitter;
@property (nonatomic, retain) Bitly *bitly;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;

- (BOOL) hasRequiredInputs;
- (void) updateCharactersLeftLabel:(NSInteger)characters;

@end

@implementation TwitterViewController

@synthesize cancelButton, doneButton, logoutButton;
@synthesize tweet, twitter, bitly, username, password;

NSInteger const kTwitterLimit = 140;

typedef enum {
	TableSectionTweet,
	TableSectionUsername,
	TableSectionPassword
} TableSection;

#pragma mark -
#pragma mark Handlers

- (IBAction) cancel:(id)sender {
	DLog(@"");
	[self.loadingView hide];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) done:(id)sender {
	DLog(@"");
    [[Settings sharedSettings] setTwitterUsername:self.username];
    [[Settings sharedSettings] setTwitterPassword:self.password];
	[self.tableView reloadData];
	if (self.twitter.accessToken != nil) {
		[self.loadingView showWithMessage:NSLocalizedString(@"Sending...", nil)]; 
		[self.twitter sendUpdate:self.tweet];
	}
	else {
		[self.loadingView showWithMessage:NSLocalizedString(@"Authenticating...", nil)];
		[self.twitter setUsername:self.username];
		[self.twitter getXAuthAccessTokenForUsername:self.username password:self.password];
	}
}

- (IBAction) shorten:(id)sender {
	DLog(@"");
	[self.tableView reloadData];
	[self.loadingView showWithMessage:NSLocalizedString(@"Shortening...", nil)]; 
	for (NSString *word in [self.tweet componentsSeparatedByString:@" "]) {
		if ([word isValidURL] || [word hasPrefix:@"http://"]) {
			[self.bitly shortenUrl:word forDelegate:self];
		}
	}
}  

- (IBAction) logout:(id)sender {
	DLog(@"");
	[self.loadingView showWithMessage:NSLocalizedString(@"Logout...", nil)]; 
    [[Settings sharedSettings] setTwitterUsername:nil];
    [[Settings sharedSettings] setTwitterPassword:nil];
    [[Settings sharedSettings] setTwitterUserKey:nil];
    [[Settings sharedSettings] setTwitterUserSecret:nil];
    self.username = nil;
	self.password = nil;
	self.logoutButton.enabled = NO;
	self.doneButton.enabled = NO;
	self.twitter.accessToken = nil;
	[self.tableView reloadData];
	[self.loadingView hideAfterDelay:1.0];
}

- (BOOL) hasRequiredInputs {
	return	self.username != nil && [self.username length] > 0 &&
			self.password != nil && [self.password length] > 0;
}

- (void) dismissModalView {
	[self dismissModalViewControllerAnimated:YES];
}

- (void) updateCharactersLeftLabel:(NSInteger)characters {
	[self setFooter:[NSString stringWithFormat:@"%d / %d %@", characters, kTwitterLimit, NSLocalizedString(@"characters", nil)]
		  atSection:TableSectionTweet];	
}

#pragma mark -
#pragma mark UIView

- (void)viewDidLoad {
    [super viewDidLoad];
	self.twitter = [[MGTwitterEngine alloc] initWithDelegate:self];
	self.navigationBar.topItem.title = NSLocalizedString(@"Twitter", nil);
	self.doneButton.title = NSLocalizedString(@"Send", nil);
    self.doneButton.tintColor = [[Settings sharedSettings] doneButtonColor];
    
	NSString *twitterApiKey = [[Settings sharedSettings] twitterApiKey];
	NSString *twitterApiSecret = [[Settings sharedSettings] twitterApiSecret];
	DLog(@"Twitter key:%@ secret:%@", twitterApiKey, twitterApiSecret);
	[self.twitter setConsumerKey:twitterApiKey secret:twitterApiSecret];
	
	NSString *twitterUserKey = [[Settings sharedSettings] twitterUserKey];
	NSString *twitterUserSecret = [[Settings sharedSettings] twitterUserSecret];
	DLog(@"OAuth key:%@ secret:%@", twitterUserKey, twitterUserSecret);
	if ([NSString isNilOrEmpty:twitterUserKey] == NO && [NSString isNilOrEmpty:twitterUserSecret] == NO) {
		self.twitter.accessToken = [[OAToken alloc] initWithKey:twitterUserKey secret:twitterUserSecret];
	}
	else {
		self.twitter.accessToken = nil;
	}
	
    self.bitly = [[Bitly alloc] init];
	self.bitly.login = [[Settings sharedSettings] bitlyApiLogin];
	self.bitly.apiKey = [[Settings sharedSettings] bitlyApiKey];
	
	[self setHeader:NSLocalizedString(@"Tweet", nil) atSection:TableSectionTweet];
	[self setHeader:NSLocalizedString(@"Username", nil) atSection:TableSectionUsername];
	[self setHeader:NSLocalizedString(@"Password", nil) atSection:TableSectionPassword];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.twitter = nil;
	self.bitly = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.username = [[Settings sharedSettings] twitterUsername];
	self.password = [[Settings sharedSettings] twitterPassword];
	if ([NSString isNilOrEmpty:self.username] || [NSString isNilOrEmpty:self.password]) {
		self.logoutButton.enabled = NO;
	}
	else {
		self.logoutButton.enabled = YES;
	}
	self.doneButton.enabled = [self hasRequiredInputs];
	[self updateCharactersLeftLabel:[self.tweet length]];
	[self.tableView reloadData];
	[self.loadingView hide];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.alertView showInfoOnceOnly:NSLocalizedString(@"Customize your message, enter credentials then press the Send button to share on Twitter. Optionally click the Link button to shorten URLs.", nil)];
}

- (void)dealloc {
	[cancelButton release];
	[doneButton release];
	[logoutButton release];
	[twitter release];
	[bitly release];
	[tweet release];
	[username release];
	[password release];
	[super dealloc];
}

#pragma mark -
#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionTweet) {
		TextViewTableCell *cell = [TableCellFactory getTextViewTableCellForDelegate:self table:theTableView indexPath:indexPath];
		cell.limit = kTwitterLimit;
		[cell setPlaceholder:NSLocalizedString(@"Enter tweet", nil)];
		[cell setText:self.tweet];
		return cell;	
	}
	else if (indexPath.section == TableSectionUsername) {
		TextFieldTableCell *cell = [TableCellFactory getTextFieldTableCellForDelegate:self table:theTableView indexPath:indexPath];
		[cell setPlaceholder:NSLocalizedString(@"Enter username", nil)];
		[cell setText:self.username];
		[cell setIsPassword:NO];
		return cell;
	}
	else if (indexPath.section == TableSectionPassword) {
		TextFieldTableCell *cell = [TableCellFactory getTextFieldTableCellForDelegate:self table:theTableView indexPath:indexPath];
		[cell setPlaceholder:NSLocalizedString(@"Enter password", nil)];
		[cell setText:self.password];
		[cell setIsPassword:YES];
		return cell;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionTweet) {
		return 140;
	}
	if (indexPath.section == TableSectionUsername) {
		return 45;
	}
	if (indexPath.section == TableSectionPassword) {
		return 45;
	}
	return 0;
}

#pragma mark -
#pragma mark TextViewCellDelegate

- (void) textViewFocussed:(TextViewTableCell *)cell indexPath:(NSIndexPath *)indexPath {
	DLog(@"indexPath:[%d, %d]", indexPath.section, indexPath.row);
	[self performSelector:@selector(scrollToIndexPath:) withObject:indexPath afterDelay:0.3];
}

- (void) textViewChanged:(TextViewTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	DLog(@"section:%d row:%d text:%@", indexPath.section, indexPath.row, text);
	if (indexPath.section == TableSectionTweet) {
		self.tweet = text;
		[self updateCharactersLeftLabel:[text length]];
	}
	self.doneButton.enabled = [self hasRequiredInputs];
}

- (void) textViewReturned:(TextViewTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	DLog(@"indexPath:[%d, %d] text: %@", indexPath.section, indexPath.row, text);
	if (indexPath.section == TableSectionTweet) {
		self.tweet = text;
		[self updateCharactersLeftLabel:[text length]];
	}
	self.doneButton.enabled = [self hasRequiredInputs];
	[self.view endEditing:YES];
}

#pragma mark -
#pragma mark TextFieldTableCellDelegate

- (void) textFieldFocussed:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self performSelector:@selector(scrollToIndexPath:) withObject:indexPath afterDelay:0.3];
}

- (void) textFieldChanged:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	if (indexPath.section == TableSectionUsername) {
		self.username = text;
	}
	else if (indexPath.section == TableSectionPassword) {
		self.password = text;
	}
	self.twitter.accessToken = nil;
	self.doneButton.enabled = [self hasRequiredInputs];
}

- (void) textFieldReturned:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	if (indexPath.section == TableSectionUsername) {
		self.username = text;
	}
	else if (indexPath.section == TableSectionPassword) {
		self.password = text;
	}
	self.twitter.accessToken = nil;
	self.doneButton.enabled = [self hasRequiredInputs];
	[self.view endEditing:YES];
}

#pragma mark -
#pragma mark BitlyDelegate

- (void) urlShortened:(Bitly *)bitly original:(NSString *)original shortened:(NSString *)shortened error:(NSError *)error {
	DLog(@"original: %@ shortened: %@", original, shortened);
	[self.loadingView hide];
	if (error) {
		DLog(@"error: %@", [error localizedDescription]);
		[self.alertView showOkWithTitle:NSLocalizedString(@"Bitly Error", nil) 
							 andMessage:[error localizedDescription]];
	}
	else if (shortened) {
		self.tweet = [self.tweet stringByReplacingOccurrencesOfString:original
														   withString:shortened];
		[self updateCharactersLeftLabel:[self.tweet length]];
		[self.tableView reloadData];
	}
}

#pragma mark -
#pragma mark MGTwitterEngineDelegate methods

- (void)accessTokenReceived:(OAToken *)token forRequest:(NSString *)connectionIdentifier {
	DLog(@"key:%@ secret:%@", token.key, token.secret);
    
	[[Settings sharedSettings] setTwitterUserKey:token.key];
    [[Settings sharedSettings] setTwitterUserSecret:token.secret];
	
	[self.twitter setAccessToken:token];
	[self.loadingView showWithMessage:NSLocalizedString(@"Sending...", nil)];
	[self.twitter sendUpdate:self.tweet];
}

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier {
	DLog(@"%@ : %@", connectionIdentifier, statuses);
	[self.loadingView showWithMessage:NSLocalizedString(@"Sent", nil)];
	[self performSelector:@selector(dismissModalView) withObject:nil afterDelay:1.5];
}

- (void)requestSucceeded:(NSString *)connectionIdentifier {
	DLog(@"%@", connectionIdentifier);
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error {
	DLog(@"%@ : %@", connectionIdentifier, error);
	[self.loadingView hide];
	if ([[error domain] isEqualToString: @"HTTP"]) {
		switch ([error code]) {
			case 401: {
				// Unauthorized. The user's credentials failed to verify.
				[self.alertView showOkWithTitle:NSLocalizedString(@"Twitter Error", nil) 
									 andMessage:NSLocalizedString(@"Your username and password could not be verified. Double check that you entered them correctly and try again.", nil)];
				break;				
			}
			case 502: {
				// Bad gateway: twitter is down or being upgraded.
				[self.alertView showOkWithTitle:NSLocalizedString(@"Twitter Error", nil) 
									 andMessage:NSLocalizedString(@"Looks like Twitter is down or being updated. Please wait a few seconds and try again.", nil)];
				break;				
			}
			case 503: {
				// Service unavailable
				[self.alertView showOkWithTitle:NSLocalizedString(@"Twitter Error", nil) 
									 andMessage:NSLocalizedString(@"Looks like Twitter is overloaded. Please wait a few seconds and try again.", nil)];
				break;								
			}
			default: {
				[self.alertView showOkWithTitle:NSLocalizedString(@"Twitter Error", nil) 
									 andMessage:[error localizedDescription]];
				break;				
			}
		}
	}
	else {
		switch ([error code]) {
			case -1009: {
				[self.alertView showOkWithTitle:NSLocalizedString(@"No Internet Connection", nil) 
									 andMessage:NSLocalizedString(@"Sorry, it looks like you lost your Internet connection. Please reconnect and try again.", nil)];
				break;				
			}
			case -1200: {
				[self.alertView showOkWithTitle:NSLocalizedString(@"Twitter Error", nil) 
									 andMessage:NSLocalizedString(@"I couldn't connect to Twitter. This is most likely a temporary issue, please try again.", nil)];
				break;								
			}
			default: {				
				[self.alertView showOkWithTitle:NSLocalizedString(@"Twitter Error", nil) 
									 andMessage:[error localizedDescription]];
			}
		}
	}
}

@end
