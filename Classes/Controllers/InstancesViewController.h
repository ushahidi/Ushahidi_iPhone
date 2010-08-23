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

#import <UIKit/UIKit.h>
#import "TableSearchViewController.h"
#import "Ushahidi.h"

@class IncidentsViewController;
@class AddInstanceViewController;

@interface InstancesViewController : TableSearchViewController<UshahidiDelegate> {
	
@public
	IBOutlet IncidentsViewController *incidentsViewController;
	IBOutlet AddInstanceViewController *addInstanceViewController;
}

@property(nonatomic, retain) IncidentsViewController *incidentsViewController;
@property(nonatomic, retain) AddInstanceViewController *addInstanceViewController;

- (IBAction) add:(id)sender;
- (IBAction) refresh:(id)sender;
- (IBAction) search:(id)sender;

@end
