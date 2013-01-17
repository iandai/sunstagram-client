//
//  CustomCell.h
//  Image
//
//  Created by Ian on 2012/12/21.
//  Copyright (c) 2012年 com.yumemi.ian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"

@interface CustomCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property UIImageView *image;
+ (CGFloat)cellHeight;
@end
