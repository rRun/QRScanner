//
//  QRScanner.h
//  Pods
//
//  Created by 何霞雨 on 16/9/28.
//
//

#import <Foundation/Foundation.h>

@interface QRScanner : NSObject


//生成二维码图片
+(UIImage *)createQRImageForString:(NSString *)baseCode WithSize:(CGFloat)size InImage:(UIImage *)image;


@end
