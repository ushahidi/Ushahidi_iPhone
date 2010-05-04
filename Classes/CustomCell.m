//
//  CustomCell.m
//  6StarLimousine
//
//  Created by Sunil Jagnani on 12/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell
@synthesize locationName,date1,verified,incName,incImage,lbl_Title,txt,lbl_setting,add_Label,showDate,showLoc;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		incName = [[UILabel alloc]initWithFrame:frame];
		incName.font = [UIFont boldSystemFontOfSize:18];
		incName.textAlignment = UITextAlignmentLeft;
		incName.backgroundColor = [UIColor clearColor];
		incName.textColor = [UIColor blackColor];
		[self.contentView addSubview:incName];		
		
		locationName = [[UILabel alloc]initWithFrame:frame];
		locationName.font = [UIFont systemFontOfSize:13];
		locationName.textAlignment = UITextAlignmentLeft;
		locationName.backgroundColor = [UIColor clearColor];
		locationName.textColor = [UIColor blackColor];	
		[self.contentView addSubview:locationName];		
		
		date1 = [[UILabel alloc]initWithFrame:frame];
		date1.font = [UIFont systemFontOfSize:13];
		date1.textAlignment = UITextAlignmentLeft;
		date1.backgroundColor = [UIColor clearColor];
		date1.textColor = [UIColor blackColor];	
		[self.contentView addSubview:date1];	
		
		showDate = [[UILabel alloc]initWithFrame:frame];
		showDate.font = [UIFont systemFontOfSize:13];
		showDate.textAlignment = UITextAlignmentLeft;
		showDate.backgroundColor = [UIColor clearColor];
		showDate.textColor = [UIColor blackColor];	
		showDate.hidden = TRUE;
		[self.contentView addSubview:showDate];	
		
		showLoc = [[UILabel alloc]initWithFrame:frame];
		showLoc.font = [UIFont systemFontOfSize:13];
		showLoc.textAlignment = UITextAlignmentLeft;
		showLoc.backgroundColor = [UIColor clearColor];
		showLoc.textColor = [UIColor blackColor];	
		showLoc.hidden = TRUE;
		[self.contentView addSubview:showLoc];	
		
		verified = [[UILabel alloc]initWithFrame:frame];
		verified.font = [UIFont systemFontOfSize:13];
		verified.textAlignment = UITextAlignmentLeft;
		verified.backgroundColor = [UIColor clearColor];
		verified.textColor = [UIColor blackColor];	
		[self.contentView addSubview:verified];	
		
		incImage = [[UIImageView alloc]init];
		incImage.image = [UIImage imageNamed:@"no_image.png"];
		incImage.hidden = TRUE;
		[self.contentView addSubview:incImage];
		
		lbl_Title = [[UILabel alloc]initWithFrame:frame];
		lbl_Title.font = [UIFont boldSystemFontOfSize:16];
		lbl_Title.textAlignment = UITextAlignmentLeft;
		lbl_Title.backgroundColor = [UIColor clearColor];
		lbl_Title.textColor = [UIColor blackColor];
		lbl_Title.hidden = TRUE;
		[self.contentView addSubview:lbl_Title];
		
		lbl_setting = [[UILabel alloc]initWithFrame:frame];
		lbl_setting.font = [UIFont systemFontOfSize:16];
		lbl_setting.textAlignment = UITextAlignmentLeft;
		lbl_setting.backgroundColor = [UIColor clearColor];
		lbl_setting.textColor = [UIColor blueColor];
		lbl_setting.hidden = TRUE;
		[self.contentView addSubview:lbl_setting];
		
		txt=[[UITextField alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
		txt.font=[UIFont systemFontOfSize:16];
		txt.borderStyle = UITextBorderStyleNone;
		txt.autocorrectionType = UITextAutocorrectionTypeNo;
		txt.contentVerticalAlignment = UIControlContentHorizontalAlignmentLeft;
		txt.textAlignment = UITextAlignmentLeft;	
		txt.hidden = TRUE;
		[self.contentView addSubview:txt];
		
		add_Label = [[UILabel alloc]initWithFrame:frame];
		add_Label.font = [UIFont systemFontOfSize:16];
		add_Label.textAlignment = UITextAlignmentLeft;
		add_Label.backgroundColor = [UIColor clearColor];
		add_Label.textColor = [UIColor blackColor];
		add_Label.hidden = TRUE;
		[self.contentView addSubview:add_Label];
	}
    return self;
}

-(void)layoutSubviews
{
	incImage.frame = CGRectMake(5, 10, 50, 50);
	incName.frame = CGRectMake(60, 12, 200, 25);
	date1.frame = CGRectMake(60, 60, 200, 20);
	showDate.frame = CGRectMake(110, 8, 175, 20);
	showLoc.frame = CGRectMake(80, 8, 175, 20);
	verified.frame = CGRectMake(60, 85, 200, 20);
	locationName.frame = CGRectMake(60, 35, 240, 20);
	lbl_Title.frame = CGRectMake(15, 5, 120, 25);
	lbl_setting.frame = CGRectMake(110, 0, 150, 40);
	txt.frame = CGRectMake(125, 8, 170, 30);
	add_Label.frame = CGRectMake(5,5,125,25);
	[super layoutSubviews];
}

- (void)dealloc {
    [super dealloc];
}

@end
