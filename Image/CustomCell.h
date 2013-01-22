//
//  CustomCell.h
//  Image
//
//  Created by Ian on 2012/12/21.
//  Copyright (c) 2012年 com.yumemi.ian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "ClipView.h"

@protocol CustomCellDelegate;


@interface CustomCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *likedCount;
@property (weak, nonatomic) IBOutlet UIButton *starButton;
@property (weak, nonatomic) IBOutlet UILabel *starLabel;
@property (weak, nonatomic) IBOutlet UIView *commentview;
@property (weak, nonatomic) IBOutlet UIView *likesView;
@property (weak, nonatomic) IBOutlet UILabel *commentsCount;
@property(nonatomic, retain) NSString *isLiked;
@property(nonatomic, retain) NSString *isStared;


@property UIScrollView *scrollView;
@property ClipView *clipView;


+ (CGFloat)cellHeight;

@property (nonatomic) NSInteger index;
@property (nonatomic, assign) id <CustomCellDelegate> delegate;

@end


@protocol CustomCellDelegate
- (void)performCommentsSegue:(NSInteger)index;
@end