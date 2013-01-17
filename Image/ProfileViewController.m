//
//  ProfileViewController.m
//  
//
//  Created by Ian on 2013/01/08.
//
//

#import "ProfileViewController.h"
#import "GlobalData.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *photoCount;
@property (weak, nonatomic) IBOutlet UILabel *followerCount;
@property (weak, nonatomic) IBOutlet UILabel *followingCount;

@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)logout:(UIBarButtonItem *)sender
{
    //删除UserDefaults数据
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    userDefaultes = nil;
    [self performSegueWithIdentifier:@"showLoginPage" sender:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *userData = [self getUserData];
    self.navItem.title = [userData objectForKey:@"name"];
    self.photoCount.text = [NSString stringWithFormat:@"%@", [userData objectForKey:@"photo_count"]];
    self.followerCount.text = [NSString stringWithFormat:@"%@", [userData objectForKey:@"follower_count"]];    
    self.followingCount.text = [NSString stringWithFormat:@"%@", [userData objectForKey:@"following_count"]];
    NSString *avatarUrl = [userData objectForKey:@"avatar_url"];
    NSString *hostUrl = [GlobalData getHostUrl];
    NSMutableString *fileURL = [[NSMutableString alloc] initWithString:hostUrl];
    [fileURL appendString:avatarUrl];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    self.avatarImage.image = [UIImage imageWithData:imageData];
    
    //加载NavigationBar的背景图片
    UINavigationController *navController = [self navigationController];
    UINavigationBar *navBar = [navController navigationBar];
    CGSize navSize = CGSizeMake(navBar.frame.size.width, navBar.frame.size.height);
    UIImage *scaledImage = [self scaleToSize:[UIImage imageNamed:@"header_user_name.png"] size:navSize];
    [navBar setBackgroundImage:scaledImage forBarMetrics: UIBarMetricsDefault];
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
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [userDefaultes stringForKey:@"user_id"];
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
