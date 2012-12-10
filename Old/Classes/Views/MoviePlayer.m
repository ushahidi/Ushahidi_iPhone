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

#import "MoviePlayer.h"

@interface MoviePlayer ()

@property (nonatomic, retain) UIViewController *controller;
@property (nonatomic, retain) MPMoviePlayerController *playerController;
@property (nonatomic, retain) MPMoviePlayerViewController *playerViewController;

- (void) addObservers:(NSObject *)object;
- (void) willEnterFullscreen:(NSNotification*)notification;
- (void) didEnterFullscreen:(NSNotification*)notification;
- (void) willExitFullscreen:(NSNotification*)notification;
- (void) didExitFullscreen:(NSNotification*)notification;
- (void) playbackDidFinish:(NSNotification*)notification;

@end

@implementation MoviePlayer

@synthesize controller, playerController, playerViewController;

- (id) initWithController:(UIViewController *)theController {
	if (self = [super init]) {
		self.controller = theController;
	}
    return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[controller release];
	[playerController release];
	[playerViewController release];
    [super dealloc];
}

-(void)playMovie:(NSString *)url {
	DLog(@"playMovie: %@", url);
//	if ([NSClassFromString(@"MPMoviePlayerController") instancesRespondToSelector:@selector(view)]) {
//		MPMoviePlayerViewController *playerViewController = [[[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:url]] autorelease];
//		[playerViewController shouldAutorotateToInterfaceOrientation:YES];
//		
//		playerViewController.moviePlayer.movieSourceType = MPMovieSourceTypeUnknown;
//		playerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//		playerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
//		//playerViewController.moviePlayer.shouldAutoplay = YES;
//		
//		[self addObservers:playerViewController.moviePlayer];
//		
//		[self.controller presentMoviePlayerViewControllerAnimated:playerViewController];
//		
////		if (![playerViewController.moviePlayer isPreparedToPlay]) { 
////			[playerViewController.moviePlayer prepareToPlay]; 
////		}
//		//[playerViewController.moviePlayer stop];
//		[playerViewController.moviePlayer play];
//	}
//	else {
//		MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:url]];
//		moviePlayer.movieSourceType = MPMovieSourceTypeUnknown;
//		//[moviePlayer setShouldAutoplay:YES];
//		
//		[self addObservers:moviePlayer];
//		
//		[self.controller.view addSubview:moviePlayer.view];
//		
////		if (![moviePlayer isPreparedToPlay]) { 
////			[moviePlayer prepareToPlay]; 
////		}
//		[moviePlayer stop];
//		[moviePlayer play];
		
		self.playerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:url]];
		self.playerController.movieSourceType = MPMovieSourceTypeUnknown;
		self.playerController.view.frame = self.controller.view.frame;
		[self.playerController setFullscreen:YES animated:YES];
		
		[self addObservers:self.playerController];
		
		[self.controller.view addSubview:self.playerController.view];
		
		[self.playerController play];
	}
//}

- (void) addObservers:(NSObject *)object {
	DLog(@"%@", [object class]);
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterFullscreen:) name:MPMoviePlayerWillEnterFullscreenNotification object:object];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterFullscreen:) name:MPMoviePlayerDidEnterFullscreenNotification object:object];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willExitFullscreen:) name:MPMoviePlayerWillExitFullscreenNotification object:object];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didExitFullscreen:) name:MPMoviePlayerDidExitFullscreenNotification object:object];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:object];
}

- (void)willEnterFullscreen:(NSNotification*)notification {
    DLog(@"willEnterFullscreen: %@", notification);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerWillEnterFullscreenNotification object:[notification object]]; 
}

- (void)didEnterFullscreen:(NSNotification*)notification {
    DLog(@"didEnterFullscreen: %@", notification);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidEnterFullscreenNotification object:[notification object]]; 
}

- (void)willExitFullscreen:(NSNotification*)notification {
    DLog(@"willExitFullscreen: %@", notification);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerWillExitFullscreenNotification object:[notification object]];
}

- (void)didExitFullscreen:(NSNotification*)notification {
    DLog(@"didExitFullscreen: %@", notification);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:[notification object]];
}

- (void)playbackDidFinish:(NSNotification*)notification {
	NSNumber *reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    switch ([reason intValue]) {
        case MPMovieFinishReasonPlaybackEnded:
            DLog(@"playbackDidFinish. Reason: Playback Ended");         
			break;
        case MPMovieFinishReasonPlaybackError:
            DLog(@"playbackDidFinish. Reason: Playback Error");
			break;
        case MPMovieFinishReasonUserExited:
            DLog(@"playbackDidFinish. Reason: User Exited");
			break;
        default:
            break;
    }
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:[notification object]];
	if ([[notification object] isKindOfClass:[MPMoviePlayerViewController class]]) {
		MPMoviePlayerViewController *moviePlayer = (MPMoviePlayerViewController *)[notification object];
		[moviePlayer.moviePlayer stop];
		[self.controller dismissMoviePlayerViewControllerAnimated];
	}
	else if ([[notification object] isKindOfClass:[MPMoviePlayerController class]]) {
		MPMoviePlayerController *moviePlayer = (MPMoviePlayerController *)[notification object];
		[moviePlayer stop];
		[moviePlayer.view removeFromSuperview];
	}
}

@end
