//
//  QRModuleDelegate.h
//  Pods
//
//  Created by 何霞雨 on 16/9/29.
//
//

#import <Foundation/Foundation.h>

@protocol QRModuleDelegate <NSObject>

@required

//返回匹配的正则表达式＝
-(NSString *)returnModuleFormat;

//返回symbol的回调
-(void)didFinishScanCode:(id)symbol;

@end
