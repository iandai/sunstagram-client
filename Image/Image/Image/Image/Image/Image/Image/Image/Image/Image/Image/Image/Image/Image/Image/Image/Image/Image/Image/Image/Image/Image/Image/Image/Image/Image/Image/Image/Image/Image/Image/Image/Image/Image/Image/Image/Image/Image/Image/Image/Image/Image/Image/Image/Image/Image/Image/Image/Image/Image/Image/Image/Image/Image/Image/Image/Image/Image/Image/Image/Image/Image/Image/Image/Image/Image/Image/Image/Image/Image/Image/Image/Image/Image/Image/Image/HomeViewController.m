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

#define HEADER_HEIGHT 42


@interface HomeViewController ()  <UITableViewDelegate, UITableViewDataSource, SectionHeaderDelegate>

@property NSInteger data_rows;
@property NSMutableArray *titleAvatar;
@property NSMutableArray *titleName;
@property NSMutableArray *titleTime;
@property NSMutableArray *postImagesUrl;
@property NSMutableArray *postImages;
@property NSMutableArray *avatarImages;
@property NSMutableArray *userIds;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableData *responseData;
@property NSInteger selectedIndex;

@end

@implementation HomeViewController

@synthesize previousPosts = _previousPosts;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // prepare data
    NSArray *array = [self getFeedData];
    self.data_rows = array.count;
    self.titleAvatar = [[NSMutableArray alloc] initWithCapacity:array.count];
    self.titleName = [[NSMutableArray alloc] initWithCapacity:array.count];
    self.titleTime = [[NSMutableArray alloc] initWithCapacity:array.count];
    self.postImagesUrl = [[NSMutableArray alloc] initWithCapacity:array.count];
    self.userIds = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSDictionary *object in array) {
        [self.titleAvatar addObject:[object objectForKey:@"user_avatar"]];
        [self.titleName addObject:[object objectForKey:@"user_name"]];
        [self.titleTime addObject:[object objectForKey:@"created_at"]];
        [self.postImagesUrl addObject:[object objectForKey:@"photo_url"]];
        [self.userIds addObject:[object objectForKey:@"user_id"]];
    }
    [self downloadImage];
    [self downloadAvatar];
    // headerView
    UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 42)];
    [headerView setImage:[UIImage imageNamed: @"instagram-banner.png"]];
    self.tableView.tableHeaderView = headerView;
    
    // pass parameter from share page
//    NSLog(@"Array Passed %@", self.previousPosts);
//    if (self.previousPosts){
//        //CGRect labelRect = CGRectMake(0.0,0.0,100,100);
//        UIImage *image = [self.previousPosts objectAtIndex:(0)];
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20,20,100,100)];
//        [imageView setImage:image];
//        [self.view addSubview:imageView];
//    }

}

- (NSArray*)getFeedData {
    // 同步请求
    // 初始化请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    // 设置URL
    [request setURL:[NSURL URLWithString:@"http://172.16.110.69:3000/feed.json"]];
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
        NSMutableString *fileURL = [[NSMutableString alloc] initWithString:@"http://172.16.110.69:3000"];
        [fileURL appendString:imageUrl];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
        [self.avatarImages addObject:data];
    }
}

- (void) downloadImage {
    //初始化Image Array
    self.postImages = [[NSMutableArray alloc] initWithCapacity:self.postImagesUrl.count];
    for (NSString *imageUrl in self.postImagesUrl) {
        NSMutableString *fileURL = [[NSMutableString alloc] initWithString:@"http://172.16.110.69:3000"];
        [fileURL appendString:imageUrl];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
        [self.postImages addObject:data];
    }
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
    
    //UIImage *image = [UIImage imageNamed:@"instagram-4.jpg"];
    //在Image中加载照片
    UIImage *image1 = [UIImage imageWithData:[self.postImages objectAtIndex:indexPath.section]];
    UIImageView* imageView1 = [[UIImageView alloc] initWithImage:image1];
    imageView1.frame = CGRectMake(0, 0, 320, 320);
    imageView1.contentMode = UIViewContentModeScaleAspectFit;

   // UIImageView *view1 = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,320)];
   // view1.contentMode = UIViewContentModeScaleToFill;
    [cell.scrollView addSubview:imageView1];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(320,0,320,320)];
    view2.backgroundColor = [UIColor greenColor];
    [cell.scrollView addSubview:view2];
    
    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(640,0,320,320)];
    view3.backgroundColor = [UIColor blueColor];
    [cell.scrollView addSubview:view3];    
    
    //这个属性很重要，它可以决定是横向还是纵向滚动，一般来说也是其中的 View 的总宽度，和总的高度
    //这里同时考虑到每个 View 间的空隙，所以宽度是 200x3＋5＋10＋10＋5＝630
    //高度上与 ScrollView 相同，只在横向扩展，所以只要在横向上滚动
    cell.scrollView.contentSize = CGSizeMake(960, 320);
    
    //用它指定 ScrollView 中内容的当前位置，即相对于 ScrollView 的左上顶点的偏移
    cell.scrollView.contentOffset = CGPointMake(0, 0);
    cell.scrollView.pagingEnabled = YES;
    
    
    return cell;
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
    return [CustomCell cellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
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


@end
