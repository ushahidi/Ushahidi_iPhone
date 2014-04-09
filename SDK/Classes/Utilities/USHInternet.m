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

#import "USHInternet.h"
#import "UIAlertView+USH.h"
#import "Reachability.h"

@interface USHInternet ()

@property (assign, nonatomic) id<USHInternetDelegate> delegate;
@property (strong, nonatomic) Reachability *network;
@property (strong, nonatomic) Reachability *wifi;

- (void) reachabilityChanged:(NSNotification *)notification;

@end

@implementation USHInternet

@synthesize network = _network;
@synthesize wifi = _wifi;
@synthesize delegate = _delegate;

+ (instancetype) sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (id) init {
    if (self = [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(reachabilityChanged:) 
                                                     name:kReachabilityChangedNotification 
                                                   object:nil];
        self.network = [Reachability reachabilityForInternetConnection];
        self.wifi = [Reachability reachabilityForLocalWiFi];
    }
    return self;
}

- (void)dealloc {
    _delegate = nil;
    [_network release];
    [_wifi release];
    [super dealloc];
}

- (void) listenWithDelegate:(id<USHInternetDelegate>)delegate {
    self.delegate = delegate;
    [self.wifi startNotifier];
    [self.network startNotifier];
}

- (void)stop {
    DLog(@"");
    [self.wifi stopNotifier];
    [self.network stopNotifier];
}

- (BOOL) hasNetwork {
    NetworkStatus status = [self.network currentReachabilityStatus];
    if (status == NotReachable) {
        DLog(@"NotReachable");
    }
    else if (status == ReachableViaWWAN) {
        DLog(@"ReachableViaWWAN");
    }
    else if (status == ReachableViaWiFi) {
        DLog(@"ReachableViaWiFi");
    }
    return status != NotReachable;
}

- (BOOL) hasWiFi {
    NetworkStatus status = [self.wifi currentReachabilityStatus];
    if (status == NotReachable) {
        DLog(@"NotReachable");
    }
    else if (status == ReachableViaWWAN) {
        DLog(@"ReachableViaWWAN");
    }
    else if (status == ReachableViaWiFi) {
        DLog(@"ReachableViaWiFi");
    }
    return status == ReachableViaWiFi;
}

- (void)alertNetworkNotAvailable:(id<UIAlertViewDelegate>)delegate {
    [UIAlertView showWithTitle:NSLocalizedString(@"No Internet Connection", nil) 
                       message:NSLocalizedString(@"Please verify your internet connection and try again.", nil) 
                      delegate:delegate 
                        cancel:NSLocalizedString(@"OK", nil) 
                       buttons:nil];
}

- (void)alertWifFiNotAvailable:(id<UIAlertViewDelegate>)delegate {
    [UIAlertView showWithTitle:NSLocalizedString(@"No Wi-Fi Connection", nil) 
                       message:NSLocalizedString(@"Unable to connect to the internet via Wi-Fi. Click 'Settings' to change your synchronize settings.", nil) 
                      delegate:delegate 
                        cancel:NSLocalizedString(@"OK", nil) 
                       buttons:NSLocalizedString(@"Settings", nil), nil];
}

- (BOOL) isSettings:(NSString*)button {
    return [NSLocalizedString(@"Settings", nil) isEqualToString:button];
}

- (void) reachabilityChanged:(NSNotification *)notification {
    DLog(@"NSNotification:%@", notification);
    Reachability *reachability = [notification object];
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (reachability == self.network) {
        DLog(@"Network:%d", status);
        [self.delegate networkChanged:self connected:status == ReachableViaWWAN]; 
    }
    else if (reachability == self.wifi) {
        DLog(@"Wi-Fi:%d", status);
        [self.delegate wifiChanged:self connected:status == ReachableViaWiFi]; 
    }
}

@end
