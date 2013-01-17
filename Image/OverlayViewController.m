//
//  OverlayViewController.m
//  Image
//
//  Created by Ian on 2012/12/14.
//  Copyright (c) 2012年 com.yumemi.ian. All rights reserved.
//

#import "OverlayViewController.h"


@interface OverlayViewController ( )

@property (nonatomic) NSInteger count;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *startStopButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;

// camera page (overlay view)
- (IBAction)done:(id)sender;
- (IBAction)startStop:(id)sender;

@end


@implementation OverlayViewController

@synthesize imagePickerController = _imagePickerController;
@synthesize delegate = _delegate;
@synthesize count = _count;


#pragma mark OverlayViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {        
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
    }
    return self;
}

- (void)setupImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    self.imagePickerController.sourceType = sourceType;
    self.imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;

    _count = -1;
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        // user wants to use the camera interface
        self.imagePickerController.showsCameraControls = NO;
        
        if ([[self.imagePickerController.cameraOverlayView subviews] count] == 0)
        {
            // setup our custom overlay view for the camera
            // ensure that our custom view's frame fits within the parent frame
            CGRect overlayViewFrame = self.imagePickerController.cameraOverlayView.frame;
            CGRect newFrame = CGRectMake(0.0,
                                         CGRectGetHeight(overlayViewFrame) -
                                         self.view.frame.size.height - 10.0,
                                         CGRectGetWidth(overlayViewFrame),
                                         self.view.frame.size.height + 10.0);
            self.view.frame = newFrame;
            //挡住上面
            UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 110)];
            backView.backgroundColor = [UIColor blackColor];
            [self.imagePickerController.cameraOverlayView addSubview:backView];
            
            [self.imagePickerController.cameraOverlayView addSubview:self.view];
        }
    }    
}

- (IBAction)startStop:(id)sender
{

    // TODO: set wait function until didFinishPickingMediaWithInfo returns the message
    [self.imagePickerController takePicture];
    _count =  ++_count % 3;
    //在拍摄过程中，取消startStopButton的可按性，连续点击2次会导致app crash
    self.startStopButton.enabled = false;
    self.cancelButton.enabled = false;
}

- (IBAction)done:(id)sender
{
    [self finishAndUpdate];
}

// update the UI after an image has been chosen or picture taken
//
- (void)finishAndUpdate
{
    [self.delegate didFinishWithCamera];  // tell our delegate we are done with the camera
}

// this get called when an image has been chosen from the library or taken from the camera
//
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    CGSize newsize = CGSizeMake(image.size.width/10, image.size.height/10);
    //消除照片的旋转信息，压缩照片缩小10倍 （原照片带有旋转信息，会在显示的时候自动旋转）
    UIImage *normoalimage = [self normalizedImage:image scaledToSize:newsize];
    image = nil;
    //Crop the impage，消除上部挡住的部分
    CGRect croprect = CGRectMake(0,normoalimage.size.height*11/36,normoalimage.size.width,normoalimage.size.height*25/36);
    CGImageRef imageRef = CGImageCreateWithImageInRect([normoalimage CGImage], croprect);
    normoalimage = nil;
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    //释放内存
    CGImageRelease(imageRef);
    
    switch (_count)
    {
        case 0:
        {
            CGRect labelRect = CGRectMake(0.0,0.0,100,100);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:labelRect];
            [imageView setImage:croppedImage];
            [self.imagePickerController.cameraOverlayView addSubview:imageView];
            self.startStopButton.enabled = true;
            break;
        }
        case 1:
        {
            CGRect labelRect = CGRectMake(110,0,100,100);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:labelRect];
            [imageView setImage:croppedImage];
            [self.imagePickerController.cameraOverlayView addSubview:imageView];
            self.startStopButton.enabled = true;
            break;
        }
        case 2:
        {
            CGRect labelRect = CGRectMake(220,0,100,100);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:labelRect];
            [imageView setImage:croppedImage];
            [self.imagePickerController.cameraOverlayView addSubview:imageView];
            self.startStopButton.enabled = false;
            break;
        }
    }
    
    //拍照结束，恢复button可按性
    self.cancelButton.enabled = true;
    //give the taken picture to our delegate
    if (self.delegate)
        [self.delegate didTakePicture:croppedImage];

}

- (UIImage *)normalizedImage:(UIImage *)originalimage scaledToSize:(CGSize)newSize {
    if (originalimage.imageOrientation == UIImageOrientationUp) {
        UIGraphicsBeginImageContext(newSize);        
        [originalimage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];        
        UIImage* normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();        
        return normalizedImage;
    }
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, originalimage.scale);
    [originalimage drawInRect:(CGRect){0, 0, newSize}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.delegate didFinishWithCamera];    // tell our delegate we are finished with the picker
}

@end
