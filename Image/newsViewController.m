//
//  newsViewController.m
//  Image
//
//  Created by Ian on 2013/01/12.
//  Copyright (c) 2013年 com.yumemi.ian. All rights reserved.
//

#import "newsViewController.h"

@interface newsViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segController;
@property (weak, nonatomic) IBOutlet UIView *viewNews;

@end

@implementation newsViewController

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
    [self.segController addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    self.viewNews.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)segmentAction:(id)sender
{
    switch ([sender selectedSegmentIndex]) {
        case 0:
        {
            self.viewNews.hidden = YES;
        }
            break;
        case 1:
        {
            self.viewNews.hidden = NO;
        }
            break;
            
        default:
            break;
    }
}



- (void) setSelectedSegmentIndex:(NSInteger)index {
//    selectedSegmentIndex = index;
    NSLog(@"%d",index);
}

@end
