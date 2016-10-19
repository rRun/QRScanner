//
//  XYViewController.m
//  QRScanner
//
//  Created by hexy on 09/28/2016.
//  Copyright (c) 2016 hexy. All rights reserved.
//

#import "XYViewController.h"
#import <QRScanner/ScanView.h>
#import <QRScanner/QRScannerViewController.h>
@interface XYViewController ()
@property (weak, nonatomic) IBOutlet ScanView *scanView;

@end

@implementation XYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.scanView start];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(100, 30, 50, 30)];
    [button setTitle:@"enter" forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(doEnter) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}

-(void)doEnter{
    QRScannerViewController *vc =[[QRScannerViewController alloc]init];
    vc.title = @"你好";
    [vc setCallBack:^(id str) {
        NSLog(@"ok:%@",str);
    }];
    [vc setAuthrosizeCallBack:^(AVAuthorizationStatus staus) {
        NSLog(@"权限:%ld",(long)staus);
    }];
    
    [self presentViewController:vc animated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
