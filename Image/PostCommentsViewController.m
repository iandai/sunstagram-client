//
//  PostCommentsViewController.m
//  Image
//
//  Created by Ian on 2013/01/09.
//  Copyright (c) 2013年 com.yumemi.ian. All rights reserved.
//

#import "PostCommentsViewController.h"
#import "CommnetCell.h"
#import "GlobalData.h"


@interface PostCommentsViewController ()<UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *commentText;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *commentsArray;
@property NSMutableArray *comments;
@end

@implementation PostCommentsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];    
    
    //prepare data
    NSDictionary *comment1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"zn",@"user_name",@"Nice Picture",@"content",[UIImage imageNamed:@"avata_zhangning.jpg"],@"avatar",nil];
    NSDictionary *comment2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"hisatomi",@"user_name",@"I like this Picture.",@"content",[UIImage imageNamed:@"avatar_hisatomo.jpg"],@"avatar",nil];
    self.comments = [[NSMutableArray alloc] init];
    [self.comments addObject:comment1];
    [self.comments addObject:comment2];
    //NSDictionary *postArray = [self getPostData];
    //self.comments = comment1;//[postArray objectForKey:@"comments"];
    //指定本身为代理
    self.commentText.delegate = self;
    //注册键盘响应事件方法
    [self.commentText addTarget:self action:@selector(nextOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gesture];
}

-(void)popViewControllerWithAnimation {
    [self.navigationController popViewControllerAnimated:YES];
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

- (NSDictionary*)getPostData {
    // 初始化请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    // 设置URL
    NSString *hostUrl = [GlobalData getHostUrl];
    NSString *urlstr = [hostUrl stringByAppendingString:@"posts/31.json"];
    [request setURL:[NSURL URLWithString:urlstr]];
    // 设置HTTP方法
    [request setHTTPMethod:@"GET"];
    // 发送同步请求, 这里得returnData就是返回得数据了
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    // 将NSData数据转化为array
    NSError *e = nil;
    NSDictionary *item = [NSJSONSerialization JSONObjectWithData:responseData options: NSJSONReadingMutableContainers error: &e];
    // 返回Data
    //TODO:如果为空，connect problem
    return item;
}

- (IBAction)sendButtonClicked:(id)sender
{
    //insert a row
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.comments.count inSection:0];
    [indexPaths addObject: indexPath];
    
    NSDictionary *comment = [[NSDictionary alloc] initWithObjectsAndKeys:@"Ian",@"user_name",self.commentText.text,@"content",[UIImage imageNamed:@"rsz_2avatar_ian.jpg"],@"avatar",nil];
    [self.comments addObject:comment];
    
    //[self.tableView reloadData];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewScrollPositionNone];
    [self.tableView endUpdates];
    self.commentText.text = nil;
    [self hidenKeyboard];
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
    CGRect rect=CGRectMake(0.0f,-166,width,height);
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
    float Y = 0.0f;
    CGRect rect=CGRectMake(0.0f,Y,width,height);
    self.view.frame=rect;
    [UIView commitAnimations];
}

//隐藏键盘的方法
-(void)hidenKeyboard
{
    [self.commentText resignFirstResponder];
    [self resumeView];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomCommentCell";
    CommnetCell *cell = (CommnetCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomCommentTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *comment = [self.comments objectAtIndex:indexPath.row];
    cell.userName.text = [comment objectForKey:@"content"];
    cell.userComments.text = [comment objectForKey:@"user_name"];
    cell.avatarImageview.image = [comment objectForKey:@"avatar"];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
