//
//  UserListViewController.m
//  Image
//
//  Created by Ian on 2013/01/08.
//  Copyright (c) 2013年 com.yumemi.ian. All rights reserved.
//

#import "UserListViewController.h"
#import "UserCell.h"
#import "GlobalData.h"
#import "UserDetailViewController.h"


@interface UserListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSInteger selectedIndex;
@end

@implementation UserListViewController

NSArray *tableData;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //加载NavigationBar的背景图片
    UINavigationController *navController = [self navigationController];
    UINavigationBar *navBar = [navController navigationBar];
    CGSize navSize = CGSizeMake(navBar.frame.size.width, navBar.frame.size.height);
    UIImage *scaledImage = [self scaleToSize:[UIImage imageNamed:@"header_user_name.png"] size:navSize];
    [navBar setBackgroundImage:scaledImage forBarMetrics: UIBarMetricsDefault];

}

//隐藏键盘的方法
-(void)hidenKeyboard
{
    [self.searchBar resignFirstResponder];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomUserTableCell";
    UserCell *cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomUserTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    switch (indexPath.row)
    {
        case 0:
        {
            cell.imageAvatar.image = [UIImage imageNamed:@"rsz_2avatar_ian.jpg"];
            cell.image1.image = [UIImage imageNamed:@"image1.jpg"];
            cell.image2.image = [UIImage imageNamed:@"image2.jpg"];
            cell.image3.image = [UIImage imageNamed:@"image3.jpg"];
            cell.userName.text = @"Ian";
            break;
        }
        case 1:
        {
            cell.imageAvatar.image = [UIImage imageNamed:@"avata_zhangning.jpg"];
            cell.image1.image = [UIImage imageNamed:@"instagram-4.jpg"];
            cell.image2.image = [UIImage imageNamed:@"instagram-4.jpg"];
            cell.image3.image = [UIImage imageNamed:@"instagram-4.jpg"];
            cell.userName.text = @"zn";

            break;
        }
    }

    return cell;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)path
{
    self.selectedIndex = path.row;
    [self performSegueWithIdentifier:@"ShowUser" sender:self.tableView];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ShowUser"]){
        NSInteger userId = self.selectedIndex + 1;
        ((UserDetailViewController *)segue.destinationViewController).previousUserid = userId;
    }
}
@end
