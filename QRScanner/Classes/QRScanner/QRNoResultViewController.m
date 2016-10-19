//
//  QRNoResultViewController.m
//  GoodPharmacist
//
//  Created by 何霞雨 on 16/10/11.
//  Copyright © 2016年 成都富顿科技有限公司. All rights reserved.
//

#import "QRNoResultViewController.h"
#import <Masonry.h>
@interface QRNoResultViewController ()

@property (nonatomic,strong)UITextView *textView;

@end

@implementation QRNoResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title  = @"扫描结果";
    self.textView = [[UITextView alloc]init];
    [self.view addSubview:self.textView];
    self.textView.font = [UIFont systemFontOfSize:13];
    self.textView.editable = NO;
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    self.textView.text = self.result;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
