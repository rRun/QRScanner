//
//  QRScanner.m
//  Pods
//
//  Created by 何霞雨 on 16/9/28.
//
//

#import "QRScanner.h"
#import "QRCodeGenerator.h"
@implementation QRScanner

+(UIImage *)createQRImageForString:(NSString *)baseCode WithSize:(CGFloat)size InImage:(UIImage *)image{
    if ([baseCode length]<=0) {
        return nil;
    }
    if (size <= 0) {
        size = 200;
    }
    
    UIImage *generateImage=[QRCodeGenerator qrImageForString:baseCode imageSize:size Topimg:image];
    return generateImage;
}
@end
