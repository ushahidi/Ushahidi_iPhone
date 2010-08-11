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

#import "photosViewController.h"


@implementation photosViewController
@synthesize photoDict;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
   
	// Show Photos of the Incidents in ScrollView
	
	scView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, 320, 480)];
	[scView setContentSize:CGSizeMake(320, 2000)];
	scView.scrollsToTop = NO;
	scView.scrollEnabled = YES;
	scView.pagingEnabled = NO;
	scView.bounces = YES;
	scView.delegate = self;
	scView.alwaysBounceVertical=YES;
	scView.showsVerticalScrollIndicator=TRUE;
	int j,k; 
	j= k = 0;
	NSString *url = @"http://demo.ushahidi.com/media/uploads/";
	NSArray *arrMedia = [photoDict objectForKey:@"media"];
	for(int i = 0; i<[arrMedia count];i++)
	{
		UIImageView *img = [[UIImageView alloc] init];
		img.frame = CGRectMake(4+j, 4+k, 75, 75);
		NSMutableDictionary *tdict = [arrMedia objectAtIndex:i];
		NSString *photoStr = [tdict objectForKey:@"mediathumb"];
		UIImage* myImage = [UIImage imageWithData: 
							[NSData dataWithContentsOfURL: 
							 [NSURL URLWithString: [NSString stringWithFormat:@"%@%@",url,photoStr]]]];
		img.image = myImage;
		j = j + 4 + 75;
		if(i % 4 == 0 &&  i!= 0)
		{
			k=k + 4 + 75;
			j=0;
		}
		[scView addSubview:img];
	}
	self.view = scView;
	[super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
