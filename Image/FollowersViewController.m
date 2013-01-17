//
//  FollowersViewController.m
//  Image
//
//  Created by Ian on 2013/01/15.
//  Copyright (c) 2013年 com.yumemi.ian. All rights reserved.
//

#import "FollowersViewController.h"
#import "UserCell.h"

@interface FollowersViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation FollowersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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

}

-(void)popViewControllerWithAnimation {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomUserTableCell";
    UserCell *cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomUserTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.imageAvatar.image = [UIImage imageNamed:@"avata_zhangning.jpg"];
    cell.image1.image = [UIImage imageNamed:@"instagram-4.jpg"];
    cell.image2.image = [UIImage imageNamed:@"instagram-4.jpg"];
    cell.image3.image = [UIImage imageNamed:@"instagram-4.jpg"];
    cell.userName.text = @"zn";
    
    [cell.followButton setTitle:@"Following" forState: UIControlStateNormal];
    
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
