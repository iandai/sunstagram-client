//
//  OverlayViewController.h
//  Image
//
//  Created by Ian on 2012/12/14.
//  Copyright (c) 2012年 com.yumemi.ian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>

@protocol OverlayViewControllerDelegate;

@interface OverlayViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    id <OverlayViewControllerDelegate> delegate;
}

@property (nonatomic, assign) id <OverlayViewControllerDelegate> delegate;
@property (nonatomic, retain) UIImagePickerController *imagePickerController;

- (void)setupImagePicker:(UIImagePickerControllerSourceType)sourceType;

@end

@protocol OverlayViewControllerDelegate
- (void)didTakePicture:(UIImage *)picture;
- (void)didFinishWithCamera;
@end