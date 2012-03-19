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
#import "IndexedTableCell.h"

@protocol YouTubeTableCellDelegate;

@interface YouTubeTableCell : IndexedTableCell<UIWebViewDelegate> {

@public
    UIWebView *webView;

@private
	id<YouTubeTableCellDelegate> delegate;    
}

@property (nonatomic, retain) UIWebView *webView;

- (id)initForDelegate:(id<YouTubeTableCellDelegate>)theDelegate reuseIdentifier:(NSString *)reuseIdentifier;
- (void) loadVideo:(NSString *)url;

@end

@protocol YouTubeTableCellDelegate <NSObject>

@optional

- (void) youtubeCellSelected:(YouTubeTableCell *)mapTableCell indexPath:(NSIndexPath *)indexPath;

@end