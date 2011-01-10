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
#import "XAuthTwitterEngineDelegate.h"
#import "XAuthTwitterEngine.h"
#import "LoadingViewController.h"
#import "TableCellFactory.h"
#import "AlertView.h"
#import "UIColor+Extension.h"
#import "TextTableCell.h"
#import "TextFieldTableCell.h"
#import "NSString+Extension.h"

@interface TwitterViewController ()

@property (nonatomic, retain) XAuthTwitterEngine *twitter;
@property (nonatomic, retain) Bitly *bitly;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;

- (BOOL) hasRequiredInputs;
- (void) updateCharactersLeftLabel:(NSInteger)characters;

@end

@implementation TwitterViewController

@synthesize cancelButton, doneButton, logoutButton, userButton;
@synthesize tweet, twitter, bitly, username, password;

#define kBitlyLogin @"BitlyLogin"
#define kBitlyApiKey @"BitlyApiKey"
#define kTwitterKey @"TwitterKey"
#define kTwitterSecret @"TwitterSecret"
#define kTwitterUsername @"TwitterUsername"
#define kTwitterPassword @"TwitterPassword"
#define kTwitterOAuth @"TwitterOAuth"

NSInteger const kTwitterLimit = 140;

typedef enum {
	TableSectionTweet,
	TableSectionUsername,
	TableSectionPassword
} TableSection;

- (IBAction) cancel:(id)sender {
	DLog(@"");
	[self.loadingView hide];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) done:(id)sender {
	DLog(@"");
	[[NSUserDefaults standardUserDefaults] setObject:self.username forKey:kTwitterUsername];
	[[NSUserDefaults standardUserDefaults] setObject:self.password forKey:kTwitterPassword];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self.tableView reloadData];
	[self.loadingView showWithMessage:NSLocalizedString(@"Sending...", nil)]; 
	if ([self cachedTwitterOAuthDataForUsername:self.username] != nil) {
		[self.twitter sendUpdate:self.tweet];
	}
	else {
		[self.twitter exchangeAccessTokenForUsername:self.username password:self.password];
	}
}

- (IBAction) shorten:(id)sender {
	DLog(@"");
	[self.tableView reloadData];
	[self.loadingView showWithMessage:NSLocalizedString(@"Shortening...", nil)]; 
	for (NSString *word in [self.tweet componentsSeparatedByString:@" "]) {
		if ([word isValidURL]) {
			[self.bitly shortenUrl:word forDelegate:self];
		}
	}
}  

- (IBAction) user:(id)sender {
	DLog(@"");
	NSString *twitterUsername = [[NSUserDefaults standardUserDefaults] objectForKey:@"TwitterUsername"];
	if ([NSString isNilOrEmpty:twitterUsername]) {
		[self.alertView showOkWithTitle:NSLocalizedString(@"Twitter Account", nil) andMessage:NSLocalizedString(@"Not Logged In", nil)];
	}
	else {
		[self.alertView showOkWithTitle:NSLocalizedString(@"Twitter Account", nil) andMessage:twitterUsername];
	}
}

- (IBAction) logout:(id)sender {
	DLog(@"");
	[self.loadingView showWithMessage:NSLocalizedString(@"Logout...", nil)]; 
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:kTwitterUsername];
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:kTwitterPassword];
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:kTwitterOAuth];
	[[NSUserDefaults standardUserDefaults] synchronize];
	self.logoutButton.enabled = NO;
	self.userButton.title = nil;
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
	self.tableView.backgroundColor = [UIColor ushahidiDarkTan];
	//Twitter API
	self.twitter = [[XAuthTwitterEngine alloc] initXAuthWithDelegate:self];
	self.twitter.consumerKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:kTwitterKey];
	self.twitter.consumerSecret = [[[NSBundle mainBundle] infoDictionary] objectForKey:kTwitterSecret];
	//Bit.ly API
	self.bitly = [[Bitly alloc] init];
	self.bitly.login = [[[NSBundle mainBundle] infoDictionary] objectForKey:kBitlyLogin];
	self.bitly.apiKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:kBitlyApiKey];
	
	[self setHeader:NSLocalizedString(@"Tweet", nil) atSection:TableSectionTweet];
	[self setHeader:NSLocalizedString(@"Username", nil) atSection:TableSectionUsername];
	[self setHeader:NSLocalizedString(@"Password", nil) atSection:TableSectionPassword];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView reloadData];
	self.doneButton.enabled = [self hasRequiredInputs];
	[self updateCharactersLeftLabel:[self.tweet  length]];
	[self.tableView reloadData];
	NSString *twitterUsername = [[NSUserDefaults standardUserDefaults] objectForKey:kTwitterUsername];
	if ([NSString isNilOrEmpty:twitterUsername]) {
		self.logoutButton.enabled = NO;
		self.userButton.title = nil;
	}
	else {
		self.logoutButton.enabled = YES;
		self.userButton.title = twitterUsername;
	}
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
	[userButton release];
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
	self.doneButton.enabled = [self hasRequiredInputs];
}

- (void) textFieldReturned:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	if (indexPath.section == TableSectionUsername) {
		self.username = text;
	}
	else if (indexPath.section == TableSectionPassword) {
		self.password = text;
	}
	self.doneButton.enabled = [self hasRequiredInputs];
}

#pragma mark -
#pragma mark SA_OAuthTwitterEngineDelegate

- (void) storeCachedTwitterOAuthData:(NSString *)data forUsername:(NSString *)username {
	DLog(@"OAUTH: %@", data);
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:@"TwitterOAuth"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self.twitter sendUpdate:self.tweet];
}

- (NSString *) cachedTwitterOAuthDataForUsername:(NSString *)username {
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"TwitterOAuth"];
}

#pragma mark -
#pragma mark BitlyDelegate

- (void) urlShortened:(Bitly *)bitly original:(NSString *)original shortened:(NSString *)shortened error:(NSError *)error {
	DLog(@"original: %@", original);
	DLog(@"shortened: %@", shortened);
	[self.loadingView hide];
	if (error) {
		DLog(@"error: %@", [error localizedDescription]);
		[self.alertView showOkWithTitle:NSLocalizedString(@"Bitly Error", nil) andMessage:[error localizedDescription]];
	}
	else if (shortened) {
		self.tweet = [self.tweet stringByReplacingOccurrencesOfString:original
														   withString:shortened];
		[self.tableView reloadData];
	}
}

#pragma mark -
#pragma mark XAuthTwitterEngineDelegate methods

- (void) storeCachedTwitterXAuthAccessTokenString:(NSString *)tokenString forUsername:(NSString *)username {
	DLog(@"Access token string returned: %@", tokenString);
	[[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:kTwitterOAuth];
	[[NSUserDefaults standardUserDefaults] synchronize];
	self.doneButton.enabled = YES;
}

- (NSString *) cachedTwitterXAuthAccessTokenStringForUsername:(NSString *)username {
	NSString *accessTokenString = [[NSUserDefaults standardUserDefaults] objectForKey:kTwitterOAuth];
	DLog(@"About to return access token string: %@", accessTokenString);
	return accessTokenString;
}

- (void) twitterXAuthConnectionDidFailWithError:(NSError *)error {
	DLog(@"Error: %@", error);
	[self.loadingView hide];
	[self.alertView showOkWithTitle:NSLocalizedString(@"Twitter Error", nil) 
						 andMessage:NSLocalizedString(@"Please check your username and password and try again.", nil)];
}

#pragma mark -
#pragma mark MGTwitterEngineDelegate methods

- (void)requestSucceeded:(NSString *)connectionIdentifier {
	DLog(@"Twitter request succeeded: %@", connectionIdentifier);
	[self.loadingView showWithMessage:NSLocalizedString(@"Sent", nil)];
	[self performSelector:@selector(dismissModalView) withObject:nil afterDelay:1.5];
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error {
	DLog(@"Twitter request failed: %@ with error:%@", connectionIdentifier, error);
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
