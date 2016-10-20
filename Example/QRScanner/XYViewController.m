//
//  XYViewController.m
//  QRScanner
//
//  Created by hexy on 09/28/2016.
//  Copyright (c) 2016 hexy. All rights reserved.
//

#import "XYViewController.h"
#import <QRScanner/ScanQCodeViewController.h>
@interface XYViewController ()


@end

@implementation XYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    

    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(100, 30, 50, 30)];
    [button setTitle:@"enter" forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(doEnter) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}

-(void)viewDidAppear:(BOOL)animated{
    [self doEnter];
}
-(void)doEnter{
    ScanQCodeViewController *vc =[[ScanQCodeViewController alloc]init];
    vc.title = @"你好";
    [vc setCallBack:^(id str) {
        NSLog(@"ok:%@",str);
    }];

    
    [self presentViewController:vc animated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
