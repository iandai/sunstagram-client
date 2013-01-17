//
//  CommnetCell.h
//  Image
//
//  Created by Ian on 2013/01/10.
//  Copyright (c) 2013年 com.yumemi.ian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommnetCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageview;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userComments;

@end
