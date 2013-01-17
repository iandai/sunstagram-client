//
//  ImageViewController.m
//  Image
//
//  Created by Ian on 2012/12/13.
//  Copyright (c) 2012年 com.yumemi.ian. All rights reserved.
//

#import "ImageViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ImageViewController ()

@property (nonatomic, retain) OverlayViewController *overlayViewController;
@property (nonatomic, retain) NSMutableArray *capturedImages;

@end

@implementation ImageViewController
@synthesize overlayViewController = _overlayViewController;

- (void)viewDidLoad
{
    self.overlayViewController =[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil];
    // as a delegate we will be notified when pictures are taken and when to dismiss the image picker
    self.overlayViewController.delegate = self;
    //照片存放临时array
    self.capturedImages = [NSMutableArray array];
    //显示ImagePicker
    [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
   
}


- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType
{

    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        [self.overlayViewController setupImagePicker:sourceType];
        [self presentViewController:self.overlayViewController.imagePickerController animated:YES completion:NULL];
    }
}


-(void)animationCompleted
{
    NSLog(@"Animation Completed");
}

-(void)dismissImagePicker
{
    [self dismissViewControllerAnimated:YES completion:^{[self performSegueWithIdentifier:@"showPostpage" sender:self];}];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showPostpage"]){
        [segue.destinationViewController performSelector:@selector(setPreviousImages:) withObject:self.capturedImages];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissImagePicker];
}

// as a delegate we are being told a picture was taken
- (void)didTakePicture:(UIImage *)picture
{
    [self.capturedImages addObject:picture];
    NSLog(@"Animation Completed %@", self.capturedImages);

}

// as a delegate we are told to finished with the camera
- (void)didFinishWithCamera
{
    [self dismissImagePicker];
}


@end
