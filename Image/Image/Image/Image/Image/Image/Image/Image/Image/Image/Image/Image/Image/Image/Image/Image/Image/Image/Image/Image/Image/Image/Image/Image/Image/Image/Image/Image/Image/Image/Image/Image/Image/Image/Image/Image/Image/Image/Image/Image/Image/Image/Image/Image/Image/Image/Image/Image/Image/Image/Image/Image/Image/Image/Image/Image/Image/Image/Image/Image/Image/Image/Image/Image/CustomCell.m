//
//  CustomCell.m
//  Image
//
//  Created by Ian on 2012/12/21.
//  Copyright (c) 2012年 com.yumemi.ian. All rights reserved.
//

#import "CustomCell.h"
#define IMAGE_HEIGHT 320

@implementation CustomCell

@synthesize image = _image;
@synthesize scrollView = _scrollView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.image.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeight {
    // This both encapsulates the height within the ReviewCell class, and provides
    // an approach for calling client (e.g. ReviewsViewController) to access the height
    // without duplicating that information all over the place.
    return IMAGE_HEIGHT;
}


@end
