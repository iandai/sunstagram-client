//
//  UserProfileViewController.m
//  Image
//
//  Created by Ian on 2012/12/28.
//  Copyright (c) 2012年 com.yumemi.ian. All rights reserved.
//

#import "UserDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GlobalData.h"

@interface UserDetailViewController ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UILabel *followerCount;
@property (weak, nonatomic) IBOutlet UILabel *followingCount;
@property (weak, nonatomic) IBOutlet UILabel *photoCount;
@property (weak, nonatomic) IBOutlet UIButton *followerCountButton;

@end

@implementation UserDetailViewController
@synthesize previousUserid = _previousUserid;

- (IBAction)followClick:(id)sender {
    if ([self.followButton.titleLabel.text isEqualToString:@"Follow"]){
        [self.followButton setTitle: @"Unfollow" forState: UIControlStateNormal];
        NSString *followerCount = [NSString stringWithFormat:@"%d",[self.followerCountButton.titleLabel.text intValue] + 1];
        [self.followerCountButton setTitle: followerCount forState: UIControlStateNormal];
        
    }else{
        [self.followButton setTitle: @"Follow" forState: UIControlStateNormal];
        NSString *followerCount = [NSString stringWithFormat:@"%d",[self.followerCountButton.titleLabel.text intValue] - 1];
        [self.followerCountButton setTitle: followerCount forState: UIControlStateNormal];    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *userData = [self getUserData];
    self.navItem.title = [userData objectForKey:@"name"];
    self.photoCount.text = [NSString stringWithFormat:@"%@", [userData objectForKey:@"photo_count"]];
    NSString *followerCount = [NSString stringWithFormat:@"%@", [userData objectForKey:@"follower_count"]];
    [self.followerCountButton setTitle: followerCount forState: UIControlStateNormal];
    self.followingCount.text = [NSString stringWithFormat:@"%@", [userData objectForKey:@"following_count"]];
    NSString *avatarUrl = [userData objectForKey:@"avatar_url"];
    NSString *hostUrl = [GlobalData getHostUrl];
    NSMutableString *fileURL = [[NSMutableString alloc] initWithString:hostUrl];
    [fileURL appendString:avatarUrl];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    self.avatarView.image = [UIImage imageWithData:imageData];
    
    NSLog(@"**%d",self.previousUserid);
}

- (IBAction)clickFollower:(id)sender
{
    [self performSegueWithIdentifier:@"showFollowedUser" sender:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self.navigationController.viewControllers objectAtIndex:0] != self)
    {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [backButton setImage:[UIImage imageNamed:@"btn_header_prev_normal.png"] forState:UIControlStateNormal];
        [backButton setShowsTouchWhenHighlighted:TRUE];
        [backButton addTarget:self action:@selector(popViewControllerWithAnimation) forControlEvents:UIControlEventTouchDown];
        UIBarButtonItem *barBackItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.hidesBackButton = TRUE;
        self.navigationItem.leftBarButtonItem = barBackItem;
    }
    //加载NavigationBar的背景图片
    UINavigationController *navController = [self navigationController];
    UINavigationBar *navBar = [navController navigationBar];
    CGSize navSize = CGSizeMake(navBar.frame.size.width, navBar.frame.size.height);
    UIImage *scaledImage = [self scaleToSize:[UIImage imageNamed:@"header_user_name.png"] size:navSize];
    [navBar setBackgroundImage:scaledImage forBarMetrics: UIBarMetricsDefault];
}

-(void)popViewControllerWithAnimation {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)newsize{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(newsize);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, newsize.width, newsize.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

- (NSDictionary*)getUserData {
    // 同步请求
    // 初始化请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //获取当前user
    NSString *user_id =  [NSString stringWithFormat:@"%d", self.previousUserid];
    // 设置URL
    NSString *hostUrl = [GlobalData getHostUrl];
    NSString *urlstrtemp = [hostUrl stringByAppendingString:@"users/"];
    NSString *urlstrtemp1 = [urlstrtemp stringByAppendingString:user_id];
    NSString *urlstr = [urlstrtemp1 stringByAppendingString:@".json"];
    // 设置HTTP方法
    [request setURL:[NSURL URLWithString:urlstr]];
    [request setHTTPMethod:@"GET"];
    // 发送同步请求, 这里得returnData就是返回得数据了
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    // 将NSData数据转化为array
    NSError *e = nil;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options: NSJSONReadingMutableContainers error: &e];
    // 返回Data
    //TODO:如果为空，popup can not get data，connect problem
    return data;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
