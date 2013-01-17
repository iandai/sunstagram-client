//
//  SectionHeader.m
//  Image
//
//  Created by Ian on 2012/12/21.
//  Copyright (c) 2012年 com.yumemi.ian. All rights reserved.
//

#import "SectionHeader.h"

@interface SectionHeader()<UIGestureRecognizerDelegate>
@end

@implementation SectionHeader
@synthesize avatarImage = _avatarImage;
@synthesize userName = _userName;
@synthesize nameLabel = _nameLabel;
@synthesize timeLabel = _timeLabel;
@synthesize time = _time;
@synthesize index = _index;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializeState];
    }
    return self;
}

- (void)initializeState {
    self.alpha = 0.9;
    self.backgroundColor = [UIColor whiteColor];
}

-(void)setAvatarImage:(UIImage *)avatarImage{
    _avatarImage = avatarImage;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 3, 36, 36)];
    imageView.image = _avatarImage;
    [self addSubview:imageView];
    imageView = nil;
}

-(void)setUserName:(NSString *)userName{
    _userName = userName;
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(42, 0, 30, 40)];
    self.nameLabel.text = _userName;
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapName:)];
    [_nameLabel addGestureRecognizer:tapRecognizer];
    [self addSubview:self.nameLabel];
}

-(void)setTime:(NSString *)time{
    _time = time;
    UIFont *descFont = [UIFont fontWithName:@"HelveticaNeue" size:20];
    CGSize expectedStringlenth = [time sizeWithFont:descFont];
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - expectedStringlenth.width, 8, expectedStringlenth.width, expectedStringlenth.height)];
    self.timeLabel.text = _time;
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.timeLabel];
}

#pragma mark - UITapGestureRecognizer Selector

-(void)tapName:(UITapGestureRecognizer *)tap{
    //NSLog(@"TapName");
    [self.delegate performSegue:self.index];
}

@end








