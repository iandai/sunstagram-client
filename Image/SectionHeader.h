//
//  SectionHeader.h
//  Image
//
//  Created by Ian on 2012/12/21.
//  Copyright (c) 2012年 com.yumemi.ian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"

@protocol SectionHeaderDelegate;

@interface SectionHeader : UIView 
@property(nonatomic, retain) UIImage *avatarImage;
@property(nonatomic, retain) UILabel *nameLabel;
@property(nonatomic, retain) NSString *userName;
@property(nonatomic, retain) UILabel *timeLabel;
@property(nonatomic, retain) NSString *time;
@property(nonatomic, retain) NSString *userId;
@property(nonatomic) NSInteger index;


@property (nonatomic, assign) id <SectionHeaderDelegate> delegate;


@end

@protocol SectionHeaderDelegate
- (void)performSegue:(NSInteger)index;
@end





