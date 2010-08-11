//
//  cameraview.m
//  UshahidiProj
//
//  Created by iSoft Solutions on 24/02/10.
//  Copyright 2010 iSoft Solutions. All rights reserved.
//

#import "cameraview.h"
#import "TabbarController.h"
#import "UshahidiProjAppDelegate.h"

@implementation cameraview

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

	
// Open Camera Album
-(void)openAlbums {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		UIPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		[self presentModalViewController:UIPicker animated:YES];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Error" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
		[self openAlbums];
	}
	else if(buttonIndex == 1)
	{
		[self openCamera];		
	}
	else
	{
		[self.view addSubview:viewImages];
		[self showImages];
	}
}

-(void)save_All
{
	for(int l = 0; l<i;l++)
	{
		[app.imgArray addObject:images[l]];
		[app.imgArray retain];
	}
	[self.navigationController popViewControllerAnimated:YES];
}
// Show Images Added
-(void)showImages 
{
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save_All)];
	if(scView)
	{
		[scView removeFromSuperview];
	}
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
	j = k = 0;
	
	for(int l = 0; l<i;l++)
	{
		UIImageView *img = [[UIImageView alloc] init];
		img.frame = CGRectMake(4+j, 4+k, 75, 75);
		
		UIImage* myImage = images[l];
		img.image = myImage;
		j = j + 4 + 75;
		if(l % 4 == 0 &&  l!= 0)
		{
			k=k + 4 + 75;
			j=0;
		}
		[scView addSubview:img];
	}
	self.view = scView;
}

- (void)openCamera {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		[self presentModalViewController:UIPicker animated:YES];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Camera is not available" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

// Add Photos to the Incident
-(void)add_Photo
{
	images[i] = imageView.image;
	[images[i] retain];
	i++;
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Photos Action"
															 delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
													otherButtonTitles:@"Photo from Library",@"Take New Photo", @"ViewImage", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view]; 
	[actionSheet release];
	
}

// Open ImagePickerController

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
	
	imageView.image = image;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add_Photo)];
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	app = [[UIApplication sharedApplication] delegate];
	UIPicker = [[UIImagePickerController alloc] init];
	UIPicker.allowsImageEditing = NO;
	UIPicker.delegate = self;
	
	tb = [[UIToolbar alloc] init];
	tb.barStyle = UIBarStyleDefault;
	[tb sizeToFit];
	CGRect rectArea = CGRectMake(0, 300, 320, 45);
	
	//Reposition and resize the receiver
	[tb setFrame:rectArea];
		
	i = 0;
	
	//Create a button
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Photos Action"
															 delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
													otherButtonTitles:@"Photo from Library",@"Take New Photo", @"ViewImage", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view]; // show from our table view (pops up in the middle of the table)
	[actionSheet release];
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
