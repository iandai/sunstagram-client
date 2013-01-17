//
//  HomeViewController.m
//  Image
//
//  Created by Ian on 2012/12/19.
//  Copyright (c) 2012年 com.yumemi.ian. All rights reserved.
//

#import "HomeViewController.h"
#import "CustomCell.h"
#import "SectionHeader.h"
#import "UserDetailViewController.h"
#import "GlobalData.h"
#import <QuartzCore/QuartzCore.h>
#define HEADER_HEIGHT 42


@interface HomeViewController ()  <UITableViewDelegate, UITableViewDataSource, SectionHeaderDelegate, CustomCellDelegate>

@property NSInteger data_rows;
@property NSArray *array;
@property NSMutableArray *titleAvatar;
@property NSMutableArray *titleName;
@property NSMutableArray *titleTime;
@property NSMutableArray *postImagesUrl;
@property NSMutableArray *postImagesUrl1;
@property NSMutableArray *postImagesUrl2;
@property NSMutableArray *postImages;
@property NSMutableArray *postImages1;
@property NSMutableArray *postImages2;
@property NSMutableArray *avatarImages;
@property NSMutableArray *userIds;
@property NSMutableArray *likedCount;
@property NSMutableArray *isLikedArray;
@property NSMutableArray *commentsCount;
@property NSMutableArray *commentsArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableData *responseData;
@property NSInteger selectedIndex;

@end

@implementation HomeViewController

@synthesize previousPosts = _previousPosts;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //加载数据
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    //加载NavigationBar的背景图片
    UINavigationController *navController = [self navigationController];
    UINavigationBar *navBar = [navController navigationBar];
    CGSize navSize = CGSizeMake(navBar.frame.size.width, navBar.frame.size.height);
    UIImage *scaledImage = [self scaleToSize:[UIImage imageNamed:@"wall-header_title.png"] size:navSize];
    [navBar setBackgroundImage:scaledImage forBarMetrics: UIBarMetricsDefault];
    //加载BackButton,Comment页实现
    //加载刷新按钮图片
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_header_update_normal.png"]]];
    self.navigationItem.rightBarButtonItem = item;
    //给刷新按钮添加点击动作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refresh:)];
    gesture.numberOfTapsRequired = 1;
    [self.navigationItem.rightBarButtonItem.customView addGestureRecognizer:gesture];
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

- (void) loadData{
    NSArray *array = [self getFeedData];
    self.data_rows = array.count;
    self.titleAvatar = [[NSMutableArray alloc] initWithCapacity:array.count];
    self.titleName = [[NSMutableArray alloc] initWithCapacity:array.count];
    self.titleTime = [[NSMutableArray alloc] initWithCapacity:array.count];
    self.postImagesUrl = [[NSMutableArray alloc] initWithCapacity:array.count];
    self.postImagesUrl1 = [[NSMutableArray alloc] initWithCapacity:array.count];
    self.postImagesUrl2 = [[NSMutableArray alloc] initWithCapacity:array.count];
    self.userIds = [[NSMutableArray alloc] initWithCapacity:array.count];
    self.likedCount = [[NSMutableArray alloc] initWithCapacity:array.count];
    self.commentsCount = [[NSMutableArray alloc] initWithCapacity:array.count];
    self.commentsArray = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSDictionary *object in array) {
        [self.titleAvatar addObject:[object objectForKey:@"user_avatar"]];
        [self.titleName addObject:[object objectForKey:@"user_name"]];
        [self.titleTime addObject:[object objectForKey:@"created_time"]];
        [self.postImagesUrl addObject:[object objectForKey:@"photo_url"]];
        [self.postImagesUrl1 addObject:[object objectForKey:@"photo1_url"]];
        [self.postImagesUrl2 addObject:[object objectForKey:@"photo2_url"]];
        [self.userIds addObject:[object objectForKey:@"user_id"]];
        [self.likedCount addObject:[object objectForKey:@"liked_count"]];
        [self.commentsCount addObject:[object objectForKey:@"comments_count"]];
        [self.commentsArray addObject:[object objectForKey:@"comments"]];
    }
    [self downloadImage];
    [self downloadAvatar];
}

- (NSArray*)getFeedData {
    // 同步请求
    // 初始化请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //获取当前user
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [userDefaultes stringForKey:@"user_id"];
    // 设置URL
    NSString *hostUrl = [GlobalData getHostUrl];
    NSString *urlstrtemp = [hostUrl stringByAppendingString:@"feed.json?user_id="];
    NSString *urlstr = [urlstrtemp stringByAppendingString:user_id];
    
    [request setURL:[NSURL URLWithString:urlstr]];
    // 设置HTTP方法
    [request setHTTPMethod:@"GET"];
    // 发送同步请求, 这里得returnData就是返回得数据了
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    // 将NSData数据转化为array
    NSError *e = nil;
    NSArray *post_items = [NSJSONSerialization JSONObjectWithData:responseData options: NSJSONReadingMutableContainers error: &e];
    // 返回Data
    //TODO:如果为空，popup can not get data，connect problem
    return post_items;
}

//取postImage array的当前Index，并转化URL，下载
- (void) downloadAvatar {
    //初始化Image Array
    self.avatarImages = [[NSMutableArray alloc] initWithCapacity:self.titleAvatar.count];
    for (NSString *imageUrl in self.titleAvatar) {
        NSString *hostUrl = [GlobalData getHostUrl];
        NSMutableString *fileURL = [[NSMutableString alloc] initWithString:hostUrl];
        [fileURL appendString:imageUrl];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
        [self.avatarImages addObject:data];
    }
}

- (void) downloadImage {
    //初始化Image Array
    self.postImages = [[NSMutableArray alloc] initWithCapacity:self.postImagesUrl.count];
    self.postImages1 = [[NSMutableArray alloc] initWithCapacity:self.postImagesUrl1.count];
    self.postImages2 = [[NSMutableArray alloc] initWithCapacity:self.postImagesUrl2.count];
    for (NSString *imageUrl in self.postImagesUrl) {
        NSString *hostUrl = [GlobalData getHostUrl];
        NSMutableString *fileURL = [[NSMutableString alloc] initWithString:hostUrl];
        [fileURL appendString:imageUrl];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
        [self.postImages addObject:data];
    }
    for (NSString *imageUrl in self.postImagesUrl1) {
        NSString *hostUrl = [GlobalData getHostUrl];
        NSMutableString *fileURL = [[NSMutableString alloc] initWithString:hostUrl];
        [fileURL appendString:imageUrl];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
        [self.postImages1 addObject:data];
    }
    for (NSString *imageUrl in self.postImagesUrl2) {
        NSString *hostUrl = [GlobalData getHostUrl];
        NSMutableString *fileURL = [[NSMutableString alloc] initWithString:hostUrl];
        [fileURL appendString:imageUrl];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
        [self.postImages2 addObject:data];
    }
}
- (IBAction)refresh:(UIBarButtonItem *)sender {
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader",NULL);
    dispatch_async(downloadQueue,^{
        [self loadData];
        dispatch_async(dispatch_get_main_queue(),^{
            UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_header_update_normal.png"]]];
            self.navigationItem.rightBarButtonItem = item;
        });
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.data_rows;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Custom Table Cell";
    
    CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    //在Image中加载照片
    UIImage *image1 = [UIImage imageWithData:[self.postImages objectAtIndex:indexPath.section]];
    UIImageView* imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, cell.scrollView.frame.size.height)];
    [imageView1 setContentMode:UIViewContentModeScaleToFill];
    [imageView1 setImage:image1];
    [cell.scrollView addSubview:imageView1];
    
    UIImage *image2 = [UIImage imageWithData:[self.postImages1 objectAtIndex:indexPath.section]];
    UIImageView* imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(320,0,320,cell.scrollView.bounds.size.height)];
    [imageView2 setContentMode:UIViewContentModeScaleToFill];
    [imageView2 setImage:image2];
    [cell.scrollView addSubview:imageView2];
    
    UIImage *image3 = [UIImage imageWithData:[self.postImages2 objectAtIndex:indexPath.section]];
    UIImageView* imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(640,0,320,cell.scrollView.bounds.size.height)];
    [imageView3 setContentMode:UIViewContentModeScaleToFill];
    [imageView3 setImage:image3];
    [cell.scrollView addSubview:imageView3];
    //这个属性很重要，它可以决定是横向还是纵向滚动，一般来说也是其中的 View 的总宽度，和总的高度
    cell.scrollView.contentSize = CGSizeMake(960, cell.scrollView.frame.size.height);
    //用它指定 ScrollView 中内容的当前位置，即相对于 ScrollView 的左上顶点的偏移
    cell.scrollView.contentOffset = CGPointMake(0, 0);
    cell.scrollView.pagingEnabled = YES;
    
    //被喜欢的次数
    NSString *likedString = [NSString stringWithFormat:@"%@", [self.likedCount objectAtIndex:indexPath.section]];
    cell.likedCount.text = likedString;    
    //Login user has liked the post
    NSString *isLiked = @"NO";
    if ([isLiked isEqualToString:@"YES"])
    {
        UIImage *buttonImageNormal = [UIImage imageNamed:@"btn_nice_selected.png"];
        [cell.likeButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
        cell.isLiked = @"YES";
    }else{
        UIImage *buttonImageNormal = [UIImage imageNamed:@"btn_nice_disabled.png"];
        [cell.likeButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
        cell.isLiked = @"NO";
    }
    
    //Star显示，被star的次数未实现
    NSString *isStared = @"NO";
    if ([isStared isEqualToString:@"YES"])
    {
        UIImage *buttonImageNormal = [UIImage imageNamed:@"btn_fav_selected.png"];
        [cell.starButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
        cell.isStared = @"YES";
    }else{
        UIImage *buttonImageNormal = [UIImage imageNamed:@"btn_fav_disabled.png"];
        [cell.starButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
        cell.isStared = @"NO";
    }
    
    //评论的次数
    NSString *commentsNumber = [NSString stringWithFormat:@"%@", [self.commentsCount objectAtIndex:indexPath.section]];
    cell.commentsCount.text = commentsNumber;
    
//    //获取文本高度
//    CGSize constraint = CGSizeMake(320,2000.0f);
//    CGSize size = [@"Text" sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
//    CGFloat height = size.height;
//    
//    //加载评论
//    NSArray *commentsOfPost = [self.commentsArray objectAtIndex:indexPath.section];
//    NSLog(@"%d",indexPath.section);
//    if (commentsOfPost) {
//        for (int i = 0; i < commentsOfPost.count; i ++){
//            //获取每个评论的username和content
//            NSDictionary *comment = [commentsOfPost objectAtIndex:i];
//            NSString *userName = [comment objectForKey:@"user_name"];
//            NSString *content = [comment objectForKey:@"content"];
//            //调整加载的label高度
//            UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(0,350+i*height*2,320,height)];
//            lblName.text = userName;
//            UILabel *lblComment = [[UILabel alloc]initWithFrame:CGRectMake(0,350+height+i*height*2,320,height)];
//            lblComment.text = content;
//            //添加到contentView中             
//            [cell.contentView addSubview:lblName];
//            [cell.contentView addSubview:lblComment];
//        }
//    }
    
    //设置comments button的delegate
    cell.delegate = self;
    cell.index = indexPath.section;
    //返回Cell
    return cell;
}

//画下划线
-(UILabel *)setLabelUnderline:(UILabel *)label{
    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:label.frame.size lineBreakMode:label.lineBreakMode];
    UIView *viewUnderline=[[UIView alloc] init];
    CGFloat xOrigin=0;
    switch (label.textAlignment) {
        case NSTextAlignmentCenter:
            xOrigin=(label.frame.size.width - expectedLabelSize.width)/2;
            break;
        case NSTextAlignmentLeft:
            xOrigin=0;
            break;
        case NSTextAlignmentRight:
            xOrigin=label.frame.size.width - expectedLabelSize.width;
            break;
        default:
            break;
    }
    viewUnderline.frame=CGRectMake(xOrigin,
                                   expectedLabelSize.height-1,
                                   expectedLabelSize.width,
                                   1);
    viewUnderline.backgroundColor=[UIColor redColor];
    [label addSubview:viewUnderline];
    return label;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SectionHeader *header = [[SectionHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, HEADER_HEIGHT)];
    header.delegate = self;
    header.avatarImage = [UIImage imageWithData:[self.avatarImages objectAtIndex:section]];
    header.userName = [self.titleName objectAtIndex:section];
    header.time = [self.titleTime objectAtIndex:section];
    header.index = section;
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get the size of text
    CGSize constraint = CGSizeMake(320,2000.0f);
    CGSize size = [@"Text" sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat height = size.height;
    
    //调整高度
    NSArray *commentsOfPost = [self.commentsArray objectAtIndex:indexPath.section];
    return [CustomCell cellHeight] + 30 + height * (2 + 0.8) * commentsOfPost.count; //+1为行间距离
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"2012-05-2%d",section];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)performCommentsSegue:(NSInteger)index {
    [self performSegueWithIdentifier:@"showCommentsPage" sender:self];
}

// Tab and segue
- (void)performSegue:(NSInteger)index {
    self.selectedIndex = index;
    [self performSegueWithIdentifier:@"showPostsetPage" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showPostsetPage"]){
        NSInteger userId = [[self.userIds objectAtIndex:self.selectedIndex] integerValue];
        ((UserDetailViewController *)segue.destinationViewController).previousUserid = userId;
    }
}

//弃用的Code
// headerView
//    UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 42)];
//    [headerView setImage:[UIImage imageNamed: @"instagram-banner.png"]];
//    self.tableView.tableHeaderView = headerView;
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(290, 8, 20, 20)];
//    imageView.image = [UIImage imageNamed:@"01-refresh.png"];
//    [self.tableView.tableHeaderView addSubview:imageView];

@end
