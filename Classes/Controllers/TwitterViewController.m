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
#import "SA_OAuthTwitterEngine.h"
#import "LoadingViewController.h"
#import "TableCellFactory.h"
#import "AlertView.h"
#import "UIColor+Extension.h"
#import "TextTableCell.h"
#import "NSString+Extension.h"

@interface TwitterViewController ()

@property (nonatomic, retain) SA_OAuthTwitterEngine *twitter;
@property (nonatomic, retain) Bitly *bitly;

- (BOOL) hasRequiredInputs;
- (void) updateCharactersLeftLabel:(NSInteger)characters;

@end

@implementation TwitterViewController

@synthesize cancelButton, doneButton, logoutButton, userButton;
@synthesize tweet, twitter, bitly;

NSInteger const kTwitterLimit = 140;

typedef enum {
	TableSectionTweet
} TableSection;

- (IBAction) cancel:(id)sender {
	DLog(@"");
	[self.loadingView hide];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) done:(id)sender {
	DLog(@"");
	[self.tableView reloadData];
	UIViewController *twitterController = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:self.twitter delegate:self];
	if (twitterController) {
		[self presentModalViewController:twitterController animated:YES];
	}
	else {
		[self.loadingView showWithMessage:NSLocalizedString(@"Sending", nil)];
		[self.twitter sendUpdate:self.tweet];
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
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"TwitterUsername"];
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"TwitterOAuth"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	self.logoutButton.enabled = NO;
	self.userButton.title = nil;
	[self.loadingView hideAfterDelay:1.0];
}

- (BOOL) hasRequiredInputs {
	return self.tweet != nil && [self.tweet length] > 0;
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
	self.twitter = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
	self.twitter.consumerKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"TwitterKey"];
	self.twitter.consumerSecret = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"TwitterSecret"];
	//Bit.ly API
	self.bitly = [[Bitly alloc] init];
	self.bitly.login = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"BitlyLogin"];
	self.bitly.apiKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"BitlyApiKey"];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView reloadData];
	self.doneButton.enabled = [self hasRequiredInputs];
	[self updateCharactersLeftLabel:[self.tweet  length]];
	[self.tableView reloadData];
	NSString *twitterUsername = [[NSUserDefaults standardUserDefaults] objectForKey:@"TwitterUsername"];
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
	[self.alertView showInfoOnceOnly:NSLocalizedString(@"Customize your message, optionally click the Link button to shorten URLs, then press the Send button to share on Twitter.", nil)];
}

- (void)dealloc {
	[tableView release];
	[cancelButton release];
	[doneButton release];
	[loadingView release];
	[alertView release];
	[twitter release];
	[bitly release];
	[super dealloc];
}

#pragma mark -
#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionTweet) {
		TextViewTableCell *cell = [TableCellFactory getTextViewTableCellForDelegate:self table:theTableView indexPath:indexPath];
		cell.indexPath = indexPath;
		cell.limit = kTwitterLimit;
		[cell setText:self.tweet];
		return cell;	
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionTweet) {
		return 155;
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
#pragma mark SA_OAuthTwitterEngineDelegate

- (void) storeCachedTwitterOAuthData:(NSString *)data forUsername:(NSString *)username {
	DLog(@"OAUTH: %@", data);
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:@"TwitterOAuth"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername:(NSString *)username {
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"TwitterOAuth"];
}

#pragma mark -
#pragma mark SA_OAuthTwitterControllerDelegate

- (void) OAuthTwitterController:(SA_OAuthTwitterController *)theController authenticatedWithUsername:(NSString *)theUsername {
	DLog(@"Authenicated for %@", theUsername);
	self.logoutButton.enabled = YES;
	self.userButton.title = theUsername;
	[[NSUserDefaults standardUserDefaults] setObject:theUsername forKey:@"TwitterUsername"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self.loadingView showWithMessage:NSLocalizedString(@"Sending...", nil)];
	[self.twitter sendUpdate:self.tweet];
}

- (void) OAuthTwitterControllerFailed:(SA_OAuthTwitterController *)theController {
	DLog(@"Authentication Failed!");
	self.logoutButton.enabled = NO;
	self.userButton.title = nil;
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"TwitterUsername"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self.loadingView hide];
	[self.alertView showOkWithTitle:NSLocalizedString(@"Twitter Error", nil) andMessage:NSLocalizedString(@"Unable to authenticate", nil)];
	self.doneButton.enabled = [self hasRequiredInputs];
}

- (void) OAuthTwitterControllerCanceled:(SA_OAuthTwitterController *)theController {
	DLog(@"Authentication Canceled.");
	self.doneButton.enabled = [self hasRequiredInputs];
}

#pragma mark -
#pragma mark TwitterEngineDelegate

- (void) requestSucceeded:(NSString *) requestIdentifier {
	DLog(@"Request %@ succeeded", requestIdentifier);
	[self.loadingView showWithMessage:NSLocalizedString(@"Sent", nil)];
	[self performSelector:@selector(dismissModalView) withObject:nil afterDelay:1.5];
}

- (void) requestFailed:(NSString *)requestIdentifier withError:(NSError *)error {
	DLog(@"Request %@ failed with error: %@", requestIdentifier, error);
	[self.loadingView hide];
	[self.alertView showOkWithTitle:NSLocalizedString(@"Twitter Error", nil) andMessage:[error localizedDescription]];
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

@end
