//
//  ScanQCodeViewController.m
//  Pods
//
//  Created by 何霞雨 on 16/9/28.
//
//

#import "ScanQCodeViewController.h"
#import "QRCodeReaderView.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Reachability/Reachability.h>

#define DeviceMaxHeight ([UIScreen mainScreen].bounds.size.height)
#define DeviceMaxWidth ([UIScreen mainScreen].bounds.size.width)
#define widthRate DeviceMaxWidth/320
#define IOS8 ([[UIDevice currentDevice].systemVersion intValue] >= 8 ? YES : NO)

@interface ScanQCodeViewController ()<QRCodeReaderViewDelegate,AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate>
{
    QRCodeReaderView * readview;//二维码扫描对象
    
    BOOL isFirst;//第一次进入该页面
    BOOL isPush;//跳转到下一级页面
    BOOL isBack;//已跳出
    BOOL isOpen;//打开扫描仪
}

@property (strong, nonatomic) CIDetector *detector;

@end

@implementation ScanQCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.title = @"扫一扫";
    self.view.backgroundColor = [UIColor whiteColor];
    
//    UIBarButtonItem * rbbItem = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStyleDone target:self action:@selector(alumbBtnEvent)];
//    self.navigationItem.rightBarButtonItem = rbbItem;
//    
    UIImage *btnImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn_return@2x" ofType:@"png"]];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [btn setImage:btnImg forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backButtonEvent) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *itemBtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = itemBtn;
    
    isFirst = YES;
    isPush = NO;
    isBack = NO;
    
    [self InitScan];
    [self noticeConnection];
    [self authorize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
#pragma mark - 返回
- (void)backButtonEvent
{
    isBack = YES;
    [self stopScan];
    
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}

#pragma mark 初始化扫描
- (void)InitScan
{
    if (readview) {
        [readview removeFromSuperview];
        readview = nil;
    }
    
    readview = [[QRCodeReaderView alloc]initWithFrame:CGRectMake(0, 0, DeviceMaxWidth, DeviceMaxHeight)];
    readview.is_AnmotionFinished = YES;
    readview.backgroundColor = [UIColor clearColor];
    readview.delegate = self;
    readview.alpha = 0;
    
    [self.view addSubview:readview];
    
    [UIView animateWithDuration:0.5 animations:^{
        readview.alpha = 1;
    }completion:^(BOOL finished) {

    }];
    
}

#pragma mark - 监测网络
-(void)noticeConnection{
    
    Reachability *reach =[Reachability reachabilityForInternetConnection];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateNetwork) name:kReachabilityChangedNotification object:nil];
    
    [self updateNetwork];
    
}
-(void)updateNetwork{
    if ([Reachability reachabilityForInternetConnection].isReachable) {
        readview.TIPS = @" ";
        [self reStartScan];
    }else{
        readview.TIPS = @"网络连接失败，扫一扫不可用！";
        [self stopScan];
    }
}
#pragma mark - 相机权限
-(void)authorize{
    // 在iOS7 时，只有部分地区要求授权才能打开相机
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        // Pre iOS 8 -- No camera auth required.
        readview.TIPS = @" ";
        [self startScan];
    }else {
        // iOS 8 后，全部都要授权
        
        
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (status) {
            case AVAuthorizationStatusNotDetermined:{
                // 许可对话没有出现，发起授权许可
                
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    
                    if (granted) {
                        //第一次用户接受
                        readview.TIPS = @" ";
                        [self startScan];
                    }else{
                        //用户拒绝
                        readview.TIPS = @"扫一扫需要访问您的相机。\n请启用相机,设置/隐私/相机！";
                        [self stopScan];
                    }
                }];
                break;
            }
            case AVAuthorizationStatusAuthorized:{
                // 已经开启授权，可继续
                readview.TIPS = @" ";
                [self startScan];
                break;
            }
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted:
                // 用户明确地拒绝授权，或者相机设备无法访问
                readview.TIPS = @"扫一扫需要访问您的相机。\n请启用相机,设置/隐私/相机！";
                [self stopScan];
                break;
            default:
                break;
        }
        
    }
}

#pragma mark - 相册
- (void)alumbBtnEvent
{
    
    self.detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) { //判断设备是否支持相册
        
        if (IOS8) {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"未开启访问相册权限，现在去开启！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 4;
            [alert show];
        }
        else{
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设备不支持访问相册，请在设置->隐私->照片中进行设置！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    
        return;
    }
    
    isPush = YES;
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    mediaUI.mediaTypes = [UIImagePickerController         availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = self;
    [self presentViewController:mediaUI animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }];
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    readview.is_Anmotion = YES;
    
    NSArray *features = [self.detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count >=1) {
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];

            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult = feature.messageString;
            //播放扫描二维码的声音
            SystemSoundID soundID;
            NSString *strSoundFile = [[NSBundle bundleForClass:[self class]] pathForResource:@"noticeMusic" ofType:@"wav"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
            AudioServicesPlaySystemSound(soundID);
            
            [self accordingQcode:scannedResult];
        }];
        
    }
    else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该图片没有包含一个二维码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
            
            readview.is_Anmotion = NO;
            [readview start];
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }];
    
}

#pragma mark -QRCodeReaderViewDelegate
- (void)readerScanResult:(NSString *)result
{
    if ([self.navigationController.viewControllers indexOfObject:self] != self.navigationController.viewControllers.count - 1) {
        return;
    }
    
    if (isBack) {
        return;
    }
    
    [self stopScan];
    
    //播放扫描二维码的声音
    SystemSoundID soundID;
    NSString *strSoundFile = [[NSBundle bundleForClass:[self class]] pathForResource:@"noticeMusic" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
    AudioServicesPlaySystemSound(soundID);
    
    [self accordingQcode:result];
    
    //[self performSelector:@selector(reStartScan) withObject:nil afterDelay:1.5];
}

#pragma mark - 扫描结果处理
- (void)accordingQcode:(NSString *)str
{
    //组件模块处理
    for (id<QRModuleDelegate> module in self.modules) {
        if ([module respondsToSelector:@selector(returnModuleFormat)]) {
            NSString *format = [module returnModuleFormat];
            NSRange range = [str rangeOfString:format options:NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                if ([module respondsToSelector:@selector(didFinishScanCode:fromSuperViewOrController:)]) {
                    [module didFinishScanCode:str fromSuperViewOrController:self];
                }
            }
        }
    }
    
    //实现回调
    if (self.callBack)
    {
        self.callBack(str);
    }
    
    isPush = YES;
}

- (void)reStartScan
{
    [self authorize];
    
}

-(void)startScan{
    
    if (isBack) {
        return;
    }
    
    readview.userInteractionEnabled = YES;
    
    if (isOpen) {
        return;
    }
    isOpen = YES;
    readview.is_Anmotion = NO;
    
    if (readview.is_AnmotionFinished) {
        [readview loopDrawLine];
    }
    
    
    [readview start];
    
    NSLog(@"打开扫描器");
}
-(void)stopScan{
    
    readview.userInteractionEnabled=NO;
    
    if (!isOpen) {
        return;
    }
    isOpen = NO;
    readview.is_Anmotion = YES;

    if (readview.is_Flash) {
        [readview turnTorchOn:NO];
    }
    
    [readview stop];
    NSLog(@"关闭扫描器");
}
#pragma mark - view
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (isFirst || isPush) {
        if (readview) {
            [self performSelector:@selector(reStartScan) withObject:nil afterDelay:1];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (readview) {
        [readview stop];
        readview.is_Anmotion = YES;
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
   
    
    if (isFirst) {
        isFirst = NO;
    }
    if (isPush) {
        isPush = NO;
    }
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
