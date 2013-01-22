//
//  ClipView.m
//  Image
//
//  Created by Ian on 2013/01/18.
//  Copyright (c) 2013年 com.yumemi.ian. All rights reserved.
//

#import "ClipView.h"
#import "CustomCell.h"

@implementation ClipView

@synthesize referanceScrollView = _referanceScrollView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setReferanceScrollView:(UIScrollView *)referanceScrollView{
    _referanceScrollView = referanceScrollView;
}

- (UIView *) hitTest:(CGPoint) point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event]) {
        return self.referanceScrollView;
    }
    return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
