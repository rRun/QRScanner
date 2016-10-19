//
//  ScanQCodeViewController.h
//  Pods
//
//  Created by 何霞雨 on 16/9/28.
//
//

#import <UIKit/UIKit.h>
#import "QRModuleDelegate.h"

@interface ScanQCodeViewController : UIViewController

@property (nonatomic, copy) void (^callBack)(id data);//扫描后的回调
@property (nonatomic,strong)NSArray<id<QRModuleDelegate>> *modules;//所有的组件

-(void)reStartScan;
-(void)stopScan;

@end
