//
//  UserListViewController.m
//  Image
//
//  Created by Ian on 2012/12/17.
//  Copyright (c) 2012年 com.yumemi.ian. All rights reserved.
//

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "GlobalData.h"

@interface LoginViewController ()<NSURLConnectionDataDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property UIBackgroundTaskIdentifier backgroundTask;
@property NSMutableDictionary *userInfo;

@end

@implementation LoginViewController
@synthesize responseData = _responseData;
@synthesize backgroundTask = _backgroundTask;

- (IBAction)loginAndshowhome:(id)sender {
    //在Login Lable上添加spinner
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    spinner.center = self.loginButton.center;
    [self.view addSubview:spinner];
    //删掉Login几个字
    [self.loginButton setTitle:@"" forState:UIControlStateNormal];
    //多线程等待login的加载    
    dispatch_queue_t downloadQueue = dispatch_queue_create("data downloader",NULL);
    dispatch_async(downloadQueue,^{
        NSString *returnedValue = [self loginConnection];
        dispatch_async(dispatch_get_main_queue(),^{
            if(returnedValue == @"ok"){
                [self performSegueWithIdentifier:@"ShowMyPage" sender:self];
            }else if(returnedValue == @"Authentification Failed"){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentification Failed." message:@"Authentification Failed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                spinner.hidden = YES;
                [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection failed." message:@"Not able to connect to server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                spinner.hidden = YES;
                [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
            }
        });
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.view.window insertSubview:imageView belowSubview:self.view ];
    //指定本身为代理
    self.userNameText.delegate = self;
    self.passwordText.delegate = self;
    //指定编辑时键盘的return键类型
    self.userNameText.returnKeyType = UIReturnKeyNext;
    self.passwordText.returnKeyType = UIReturnKeyDefault;
    //注册键盘响应事件方法
    [self.userNameText addTarget:self action:@selector(nextOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwordText addTarget:self action:@selector(nextOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gesture];
}

//发送登陆信息，并获得结果
- (NSString *)loginConnection {
    NSString* returnValue = @"";
    //准备url
    NSString *host = [GlobalData getHostUrl];
    NSString *urlstr = [host stringByAppendingString:@"login.json"];
    NSURL *url = [NSURL URLWithString:urlstr];
    //准备数据
    NSData *postData = [[@"name=" stringByAppendingFormat:@"%@%@%@",self.userNameText.text,@"&password=",self.passwordText.text] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    //发送请求
    NSHTTPURLResponse* urlResponse = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    // 解析post请求结果 1.无法连接到服务器 2.无返回结果  3.Authentification failed 4.Succeed,save to userDefaults
    if ([error localizedDescription]) { // 返回错误，弹出无法连接到server
        returnValue = @"not able to connect to server";
    } else {
        if (responseData) {  //返回OK，(保存user数据，进入下页面)；返回No，则popup提示；无返回值，则返回Error
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
            NSRange range1 = [[responseDict objectForKey:@"status"] rangeOfString:@"OK"];
            if (range1.location != NSNotFound){
                //保存user_id
                NSDictionary *reponseUser = [responseDict objectForKey:@"user"];
                NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
                [userDefaultes setObject:[reponseUser objectForKey:@"id"] forKey:@"user_id"];
                returnValue = @"ok";
            }
            NSRange range2 = [[responseDict objectForKey:@"status"] rangeOfString:@"Authentification Failed"];
            if (range2.location != NSNotFound){
                returnValue = @"Authentification Failed";
            }
        } 
    }
    return returnValue;
}

//UITextField的协议方法，当开始编辑时监听
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    //上移30个单位，按实际情况设置
    CGRect rect=CGRectMake(0.0f,-30,width,height);
    self.view.frame=rect;
    [UIView commitAnimations];
    return YES;
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

//隐藏键盘的方法
-(void)hidenKeyboard
{
    [self.userNameText resignFirstResponder];
    [self.passwordText resignFirstResponder];
    [self resumeView];
}

//点击键盘上的Return按钮响应的方法
-(IBAction)nextOnKeyboard:(UITextField *)sender
{
    if (sender == self.userNameText) {
        [self.passwordText becomeFirstResponder];
    }else if (sender == self.passwordText){
        [self hidenKeyboard];
    }
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


//- (void)downloadJSONFromURL {
//    // Create the request.
//    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:3000/users.json"]
//                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                          timeoutInterval:60.0];
//    // create the connection with the request
//    // and start loading the data
//    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
//    if (theConnection) {
//        // Create the NSMutableData to hold the received data.
//        // receivedData is an instance variable declared elsewhere.
//      
//        _responseData = [NSMutableData data];
//        
//        //NSData *receivedData = [[NSData alloc] init];
//        //receivedData = [NSMutableData data];
//      //  NSLog(@"yougunai  %@",receivedData1);
//
//    } else {
//        // Inform the user that the connection failed.
//    }
//}
//
//
//-(void)postJson {
//    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//                            self.name.text, @"name",
//                            self.password.text, @"password",
//                            nil];
//
//    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:
//                            [NSURL URLWithString:@"http://localhost:3000/"]];
//    
//    [client postPath:@"/login.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        self.userInfo = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//        NSLog(@"Response: %@", [self.userInfo objectForKey:@"status"]);
//        [self performSegueWithIdentifier:@"ShowMyPage" sender:self];
//
//   ////   NSString *response_str = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@", [error localizedDescription]);
//    }];
//}
//
//
//-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
//    [self.responseData appendData:data];
//    NSString *test = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
//    NSLog(@"%@",test);
//}

//-(void)postJson {
//    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//                            self.name.text, @"name",
//                            self.password.text, @"password",
//                            nil];
//
//    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:
//                            [NSURL URLWithString:@"http://localhost:3000/"]];
//
//    [client postPath:@"/login.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        self.userInfo = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//        NSLog(@"Response: %@", [self.userInfo objectForKey:@"status"]);
//        [self performSegueWithIdentifier:@"ShowMyPage" sender:self];
//
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@", [error localizedDescription]);
//    }];
//}

@end
