//
//  PhotocaptionViewController.m
//  Image
//
//  Created by Ian on 2012/12/19.
//  Copyright (c) 2012年 com.yumemi.ian. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "PhotocaptionViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HomeViewController.h"
#import "GlobalData.h"
#import "NSStringAdditions.h"   //Base64 encoding


@interface PhotocaptionViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *backview1;
@property (weak, nonatomic) IBOutlet UIView *backview2;
@property (weak, nonatomic) IBOutlet UIView *backview3;
@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet UIImageView *image3;
@property (weak, nonatomic) IBOutlet UITextView *caption1;
@property (weak, nonatomic) IBOutlet UITextView *caption2;
@property (weak, nonatomic) IBOutlet UITextView *caption3;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButtton;

@property NSMutableArray *posts;
@property NSString *hosturl;
@property NSString *returnStatus;
@property UIBackgroundTaskIdentifier backgroundTask;
@property (weak, nonatomic) IBOutlet UINavigationItem *barItems;

@end

@implementation PhotocaptionViewController

@synthesize previousImages = _previousImages;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.backview1.layer.cornerRadius = 5;
    self.backview2.layer.cornerRadius = 5;
    self.backview3.layer.cornerRadius = 5;
    
    //如果拍了3张照片则进入下一页面，否则返回主页面
    if (self.previousImages.count == 3) {
        self.image1.image = [self.previousImages objectAtIndex:0];//[UIImage imageNamed:@"instagram-4.jpg"];
        [self.image1.layer setBorderWidth:5];
        self.image2.image = [self.previousImages objectAtIndex:1];
        [self.image2.layer setBorderWidth:5];
        self.image3.image = [self.previousImages objectAtIndex:2];
        [self.image3.layer setBorderWidth:5];
   }
    
    //指定本身为代理
    self.caption1.delegate = self;
    self.caption2.delegate = self;
    self.caption3.delegate = self;

    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    [self.contentView addGestureRecognizer:gesture];
}

- (IBAction)sharePost:(UIBarButtonItem *)sender {
    //添加spinner
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.barItems.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    //主线程负责UI显示，download线程负责上传照片
    dispatch_queue_t downloadQueue = dispatch_queue_create("data downloader",NULL);
    dispatch_async(downloadQueue,^{
        [self postPhotos];
        dispatch_async(dispatch_get_main_queue(),^{
            
            self.barItems.rightBarButtonItem = sender;
            [self performSegueWithIdentifier:@"showFeedpage" sender:self];

        });
    });
}

//返回Home页面
- (IBAction)backButton:(id)sender {
    [self returnhome];
}

-(void)returnhome {
   [self performSegueWithIdentifier:@"showFeedpage" sender:self];
}

- (NSArray *)getCaption {
    NSArray *captions = [[NSArray alloc] initWithObjects:self.caption1.text, self.caption2.text, self.caption3.text, nil];
    return captions;
}

- (void)postPhotos {
    // Base64 Encoding image 
    NSData *imageData1 = UIImageJPEGRepresentation(self.image1.image, 1.0);
    NSData *imageData2 = UIImageJPEGRepresentation(self.image2.image, 1.0);
    NSData *imageData3 = UIImageJPEGRepresentation(self.image3.image, 1.0);
    NSString *imageString1 = [NSString base64StringFromData:imageData1 length:imageData1.length];
    NSString *imageString2 = [NSString base64StringFromData:imageData2 length:imageData2.length];
    NSString *imageString3 = [NSString base64StringFromData:imageData3 length:imageData3.length];
    
    //获取当前user_id
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [userDefaultes stringForKey:@"user_id"];
    
    // 创建params
    NSDictionary *postData1= [NSDictionary dictionaryWithObjectsAndKeys:user_id, @"user_id", @"111", @"content",imageString1, @"photo", nil];
    NSDictionary *postData2= [NSDictionary dictionaryWithObjectsAndKeys:user_id, @"user_id", @"222", @"content",imageString2, @"photo", nil];
    NSDictionary *postData3= [NSDictionary dictionaryWithObjectsAndKeys:user_id, @"user_id", @"333", @"content",imageString3, @"photo", nil];
    NSDictionary *postDatas= [NSDictionary dictionaryWithObjectsAndKeys: postData1, @"postData1", postData2, @"postData2",postData3, @"postData3", nil];


    NSURLResponse *response = nil;
    NSError *error = nil;
    NSString *host = [GlobalData getHostUrl];
    NSString *urlstr = [host stringByAppendingString:@"posts.json"];
    NSURL *url = [NSURL URLWithString:urlstr];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    //httpClient.parameterEncoding = AFFormURLParameterEncoding;
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:[url path] parameters:postDatas];
    NSData *responseObject = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *response_str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    NSLog(@"%@", response_str);
    
    
    //post params并获得返回值
//    NSString *host = [GlobalData getHostUrl];
//    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:host]];
//    [client postPath:@"posts.json" parameters:postDatas success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@", @"here");
//        [self performSegueWithIdentifier:@"showFeedpage" sender:self];
//
////        NSString *response_str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
////        NSRange range = [response_str rangeOfString:@"ok"];
////        if (range.location == NSNotFound)
////        {
////            self.returnStatus = @"Not OK";
////        } else {
////            self.returnStatus = @"OK";
////        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@", [error localizedDescription]);
//    }];
    
    //return YES;
    
    //返回值包含ok则，返回yes，否则返回no
//    if (self.returnStatus == @"OK")
//    {
//        return YES;
//    }else {
//        return NO;
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//UITextView的协议方法，当开始编辑时监听
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if([textView isEqual:self.caption3])
    {
        NSTimeInterval animationDuration=0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        float width = self.view.frame.size.width;
        float height = self.view.frame.size.height;
        //上移40个单位，按实际情况设置
        CGRect rect=CGRectMake(0.0f,-190,width,height);
        self.view.frame=rect;
        [UIView commitAnimations];
    }
    if([textView isEqual:self.caption2])
    {
        NSTimeInterval animationDuration=0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        float width = self.view.frame.size.width;
        float height = self.view.frame.size.height;
        //上移40个单位，按实际情况设置
        CGRect rect=CGRectMake(0.0f,-60,width,height);
        self.view.frame=rect;
        [UIView commitAnimations];
    }
    return YES;
}

//隐藏键盘的方法
-(void)hidenKeyboard
{
    [self.caption1 resignFirstResponder];
    [self.caption2 resignFirstResponder];
    [self.caption3 resignFirstResponder];
    [self resumeView];
}

//恢复原始视图位置
-(void)resumeView
{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    //如果当前View是父视图，则Y为20个像素高度，如果当前View为其他View的子视图，则动态调节Y的高度
    float Y = 20.0f;
    CGRect rect=CGRectMake(0.0f,Y,width,height);
    self.view.frame=rect;
    [UIView commitAnimations];
}

//解决bug：CGContextSaveGState: invalid context 0x0
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0))
    {
        // Acquired additional time
        UIDevice *device = [UIDevice currentDevice];
        BOOL backgroundSupported = NO;
        if ([device respondsToSelector:@selector(isMultitaskingSupported)])
        {
            backgroundSupported = device.multitaskingSupported;
        }
        if (backgroundSupported)
        {
            self.backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
                [application endBackgroundTask:self.backgroundTask];
                self.backgroundTask = UIBackgroundTaskInvalid;
            }];
        }
    }
}
@end
