//
//  CustomCell.m
//  Image
//
//  Created by Ian on 2012/12/21.
//  Copyright (c) 2012年 com.yumemi.ian. All rights reserved.
//

#import "CustomCell.h"
#define IMAGE_HEIGHT 320

@interface CustomCell()
@end

@implementation CustomCell

@synthesize scrollView = _scrollView;
@synthesize commentview = _commentview;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeight
{
    // This both encapsulates the height within the ReviewCell class, and provides
    // an approach for calling client (e.g. ReviewsViewController) to access the height
    // without duplicating that information all over the place.
    
    return IMAGE_HEIGHT;
}

- (IBAction)clickLikeBotton:(id)sender
{
    
    if ([self.isLiked isEqualToString:@"NO"])
    {
        //变成红心
        UIImage *buttonImageNormal = [UIImage imageNamed:@"btn_nice_selected.png"];
        [self.likeButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
        //Liked + 1
        int temp = [self.likedCount.text intValue] + 1;
        self.likedCount.text = [NSString stringWithFormat:@"%d", temp];
        //讲标签设置为已经喜欢
        self.isLiked = @"YES";
        
        //TODO: pass viariable to net.
    } else {
        //变成黑红心
        UIImage *buttonImageNormal = [UIImage imageNamed:@"btn_nice_disabled.png"];
        [self.likeButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
        //Liked + 1
        int temp = [self.likedCount.text intValue] - 1;
        self.likedCount.text = [NSString stringWithFormat:@"%d", temp];
        //讲标签设置为不喜欢
        self.isLiked = @"NO";
        //TODO: pass viariable to net.
    }
}

- (IBAction)clickStarBotton:(id)sender
{
    if ([self.isStared isEqualToString:@"NO"])
    {
        UIImage *buttonImageNormal = [UIImage imageNamed:@"btn_fav_selected.png"];
        [self.starButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
        int temp = [self.starLabel.text intValue] + 1;
        self.starLabel.text = [NSString stringWithFormat:@"%d", temp];
        self.isStared = @"YES";        
        //TODO: pass viariable to net.
    } else {
        UIImage *buttonImageNormal = [UIImage imageNamed:@"btn_fav_disabled.png"];
        [self.starButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
        int temp = [self.starLabel.text intValue] - 1;
        self.starLabel.text = [NSString stringWithFormat:@"%d", temp];
        //讲标签设置为不喜欢
        self.isStared = @"NO";
        //TODO: pass viariable to net.
    }
}

- (IBAction)clickCommentButton:(id)sender
{
    [self.delegate performCommentsSegue:self.index];
}


@end
