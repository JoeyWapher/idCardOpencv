//
//  photoViewController.m
//  FundProgram
//
//  Created by Joey on 2017/3/1.
//  Copyright © 2017年 Joey. All rights reserved.
//

#define kScreenBounds   [UIScreen mainScreen].bounds
#define kScreenWidth  kScreenBounds.size.width*1.0
#define kScreenHeight kScreenBounds.size.height*1.0

#import "photoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@interface photoViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>
{
    UILabel* titleLabel;
    UILabel* infoLabel;
    BOOL isPhoto;
    UIView *backgroundView;
    UIView* control;
    UIButton *cancelButton;
    UIView *AlertBackgroundView;
    UIView *AlertView;
    UILabel * Alertlabel;
    UIButton* closeButton;
    UIImageView* maskimgView;
}

//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property(nonatomic)AVCaptureDevice *device;

//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property(nonatomic)AVCaptureDeviceInput *input;

//当启动摄像头开始捕获输入
@property(nonatomic)AVCaptureMetadataOutput *output;

@property (nonatomic)AVCaptureStillImageOutput *ImageOutPut;

//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property(nonatomic)AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic)UIButton *PhotoButton;
@property (nonatomic)UIImageView *imageView;
@property (nonatomic)UIImage *image;
@property (nonatomic)BOOL canCa;
@end

@implementation photoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isPhoto=NO;
    
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    appDelegate.allowRotation = YES;//(以上2行代码,可以理解为打开横屏开关)
    
    [self setNewOrientation:YES];//调用转屏代码
    _canCa = [self canUserCamear];
    if (_canCa) {
        [self customCamera];
        [self customUI];
        
    }else{
        return;
    }
    
    
    // Do any additional setup after loading the view, typically from a nib.
}
#pragma mark //手机转屏
- (void)setNewOrientation:(BOOL)fullscreen

{
    
    if (fullscreen) {
        
//        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
//        
//        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
        
        
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        
    }else{
        
//        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
//        
//        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
        
        
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        
    }
    
}

- (void)customUI{
    backgroundView = [[UIView alloc]init];
    backgroundView.frame =CGRectMake(0, 0, kScreenWidth-80, kScreenHeight);
//    backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:backgroundView];
    UIBezierPath *bpath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, kScreenWidth-80, kScreenHeight)];
    
    // - bezierPathByReversingPath ,反方向绘制path
    [bpath appendPath:[[UIBezierPath bezierPathWithRoundedRect:CGRectMake((kScreenWidth-80)/2-200, (kScreenHeight)/2-125, 400, 250) cornerRadius:2] bezierPathByReversingPath]];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = bpath.CGPath;
    shapeLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.7].CGColor;
    
    //maskView.layer.mask = shapeLayer;
    [self.view.layer addSublayer:shapeLayer];
    control = [[UIView alloc]initWithFrame:CGRectMake(kScreenWidth-80, 0, 80, kScreenHeight)];
    control.backgroundColor = [UIColor blackColor];
    [self.view addSubview:control];
    
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((kScreenWidth-80)/2-100, 30, 200, 20)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    infoLabel = [[UILabel alloc]initWithFrame:CGRectMake((kScreenWidth-80)/2-150, kScreenHeight-50, 300, 20)];
    infoLabel.font= [UIFont systemFontOfSize:13];
    
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.textColor=[UIColor whiteColor];
    [self.view addSubview:infoLabel];
    _PhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _PhotoButton.frame = CGRectMake(80/2-30, kScreenHeight/2-30, 60, 60);
    [_PhotoButton setImage:[UIImage imageNamed:@"ic_idcard_btn_shot_normal"] forState: UIControlStateNormal];
    [_PhotoButton setImage:[UIImage imageNamed:@"ic_idcard_btn_shot_pressed"] forState:UIControlStateHighlighted];
    
    _PhotoButton.titleEdgeInsets = UIEdgeInsetsMake(0, -60, 0, 0);
    [_PhotoButton addTarget:self action:@selector(shutterCamera) forControlEvents:UIControlEventTouchUpInside];
    [control addSubview:_PhotoButton];

    
    maskimgView=[[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-80)/2-200, (kScreenHeight)/2-125, 400, 250)];
    [self.view addSubview:maskimgView];
    
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(80/2-30, kScreenHeight-80, 60, 60);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [control addSubview:cancelButton];
    [self updateUI];
    
}
-(void)updateUI{
    [_PhotoButton setTitle:@"" forState:UIControlStateNormal];
    titleLabel.hidden=NO;
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    AlertBackgroundView = [[UIView alloc]init];
    AlertBackgroundView.frame =CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    AlertBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:AlertBackgroundView];
    AlertView = [[UIView alloc]init];
    AlertView.frame =CGRectMake((kScreenWidth-80)/2-150, kScreenHeight/2-100, 300, 200);
    AlertView.backgroundColor = [UIColor whiteColor];
    AlertView.layer.cornerRadius =5;
    [AlertBackgroundView addSubview:AlertView];
    Alertlabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(AlertView.frame)/2-80, 10, 160, 20)];
    Alertlabel.font = [UIFont systemFontOfSize:14];
    Alertlabel.textColor=[UIColor grayColor];
    Alertlabel.textAlignment = NSTextAlignmentCenter;
    [AlertView addSubview:Alertlabel];
    closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(0, 150, CGRectGetWidth(AlertView.frame), 50);
    [closeButton setTitleColor:[UIColor colorWithRed:0.22 green:0.60 blue:0.98 alpha:1.00] forState:UIControlStateNormal];
    [closeButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [AlertView addSubview:closeButton];
    UIImageView* line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 150, 300, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [AlertView addSubview:line];
    UIImageView* imgv = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(AlertView.frame)/2-75, 40, 150, 100)];
    
    [AlertView addSubview:imgv];
    NSString* str;
    str = @"请拍摄身份证人像面";
    Alertlabel.text = @"请保持人像面朝上";
    [closeButton setTitle:@"拍摄人像面" forState:UIControlStateNormal];
    imgv.image=[UIImage imageNamed:@"ic_idcard_img_default_front"];
    maskimgView.image = [UIImage imageNamed:@"ic_idcard_skeleton_front"];
    NSMutableAttributedString*attributeString_atts=[[NSMutableAttributedString alloc]initWithString:str];
    UIFont *font=[UIFont systemFontOfSize:18];
    UIColor  *foregroundColor=[UIColor colorWithRed:0.22 green:0.60 blue:0.98 alpha:1.00];
    NSDictionary *attrsDic=@{
                             NSForegroundColorAttributeName:foregroundColor,
                             NSFontAttributeName:font,
                             };
    NSDictionary *attrsDic1=@{
                              NSForegroundColorAttributeName:[UIColor whiteColor],
                              NSFontAttributeName:[UIFont systemFontOfSize:18],
                              };
    //全文使用
    [attributeString_atts addAttributes:attrsDic1 range:NSMakeRange(0, 4)];
    [attributeString_atts addAttributes:attrsDic range:NSMakeRange(3, 6)];
    titleLabel.attributedText = attributeString_atts;
    infoLabel.attributedText= [[NSAttributedString alloc]initWithString:@"请保持身份证整体在区域内，并对齐线框边缘"];
}
- (void)customCamera{
    self.view.backgroundColor = [UIColor whiteColor];
    
    //使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //使用设备初始化输入
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    
    //生成输出对象
    self.output = [[AVCaptureMetadataOutput alloc]init];
    self.ImageOutPut = [[AVCaptureStillImageOutput alloc] init];
    
    //生成会话，用来结合输入输出
    self.session = [[AVCaptureSession alloc]init];
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
        
        self.session.sessionPreset = AVCaptureSessionPreset1920x1080;
        
    }
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.ImageOutPut]) {
        [self.session addOutput:self.ImageOutPut];
    }
    
    //使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.connection.videoOrientation =AVCaptureVideoOrientationLandscapeRight;
    [self.view.layer addSublayer:self.previewLayer];
    
    //开始启动
    [self.session startRunning];
    if ([_device lockForConfiguration:nil]) {
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
}
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}
#pragma mark // 对焦
- (void)focusAtPoint{
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( ((size.width-80) /2)/self.view.frame.size.width ,(size.height/2)/self.view.frame.size.height );
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        [self.device unlockForConfiguration];

    }
    
}
#pragma mark - 截取照片
- (void) shutterCamera
{
    [self focusAtPoint];
    [self performSelector:@selector(delayMethod) withObject:nil/*可传任意类型参数*/ afterDelay:1.3];
}
-(void)delayMethod{
    isPhoto=!isPhoto;
    if (isPhoto) {
        AVCaptureConnection * videoConnection = [self.ImageOutPut connectionWithMediaType:AVMediaTypeVideo];
        if (!videoConnection) {
            NSLog(@"take photo failed!");
            return;
        }
        maskimgView.image = [UIImage imageNamed:@"ic_idcard_skeleton_preview"];
        [_PhotoButton setTitle:@"确定" forState:UIControlStateNormal];
        [self.ImageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            if (imageDataSampleBuffer == NULL) {
                return;
            }

            NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage* aImage = [UIImage imageWithData:imageData];
//            CVImageBufferRef imagebuff =[self pixelBufferFromCGImage:[aImage CGImage]];
//            [self IDCardRecognit:imagebuff];
            UIImage* bImage =[self getSubImage:CGRectMake(200, 90 ,aImage.size.height-700, aImage.size.width-300) andImage:aImage];
            CGAffineTransform transform = CGAffineTransformIdentity;
            CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                                     CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                                     CGImageGetColorSpace(aImage.CGImage),
                                                     CGImageGetBitmapInfo(aImage.CGImage));
            CGContextConcatCTM(ctx, transform);
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
            UIImage *img = [UIImage imageWithCGImage:cgimg];
            CGContextRelease(ctx);
            CGImageRelease(cgimg);
            NSString *path_sandox = NSHomeDirectory();
            NSString* str;
            NSString *imagePath;
            NSString *originalImagePath;
            str = @"请确保身份证人像面信息清晰、无遮挡";

            //设置一个图片的存储路径
            imagePath= [path_sandox stringByAppendingString:@"/Documents/image1.png"];
            originalImagePath= [path_sandox stringByAppendingString:@"/Documents/originalImage1.jpeg"];

            //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
            [UIImagePNGRepresentation(bImage) writeToFile:imagePath atomically:YES];
            [UIImageJPEGRepresentation(bImage, 0) writeToFile:originalImagePath atomically:YES];
            NSLog(@"newimg size = %@",NSStringFromCGSize(img.size));
            self.image = img;
            [self.session stopRunning];
            //        [self saveImageToPhotoAlbum:self.image];
            self.imageView = [[UIImageView alloc]initWithFrame:self.previewLayer.frame];
            [self.view insertSubview:_imageView belowSubview:backgroundView];
            self.imageView.layer.masksToBounds = YES;
            self.imageView.image = _image;
            if (isPhoto) {
                titleLabel.hidden=YES;
                [cancelButton setTitle:@"重拍" forState:UIControlStateNormal];
            }
        }];
    }else{
        [self cancel];
    }
}


#pragma mark //截取部分图像
-(UIImage*)getSubImage:(CGRect)rect andImage:(UIImage*)aImage
{
    NSLog(@"aimg size = %@  %@",NSStringFromCGSize(aImage.size),NSStringFromCGRect(rect));
    CGImageRef subImageRef = CGImageCreateWithImageInRect(aImage.CGImage, rect);
    CGRect smallBounds = CGRectMake(0,0, rect.size.width, rect.size.height);
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    return smallImage;
}
#pragma mark //字体转换
-(NSAttributedString*)constr:(NSString*)str{
    
    NSMutableAttributedString*attributeString_atts=[[NSMutableAttributedString alloc]initWithString:str];
    UIFont *font=[UIFont systemFontOfSize:13];
    UIColor  *foregroundColor=[UIColor colorWithRed:0.22 green:0.60 blue:0.98 alpha:1.00];
    NSDictionary *attrsDic=@{
                             NSForegroundColorAttributeName:foregroundColor,
                             NSFontAttributeName:font,
                             };
    NSDictionary *attrsDic1=@{
                              NSForegroundColorAttributeName:[UIColor whiteColor],
                              NSFontAttributeName:[UIFont systemFontOfSize:13],
                              };
    //全文使用
    [attributeString_atts addAttributes:attrsDic1 range:NSMakeRange(0, 4)];
    [attributeString_atts addAttributes:attrsDic range:NSMakeRange(3, 6)];
    [attributeString_atts addAttributes:attrsDic1 range:NSMakeRange(8, 8)];
    return attributeString_atts;
}

//退出或取消
-(void)cancel{
    if (!isPhoto) {
        AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        appDelegate.allowRotation = NO;//(以上2行代码,可以理解为打开横屏开关)
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.imageView removeFromSuperview];
        self.imageView=nil;
        [self.session startRunning];
        [self updateUI];
        isPhoto=NO;
    }
    
}
-(void)closeButtonAction{
    [AlertBackgroundView removeFromSuperview];
    AlertBackgroundView=nil;
}
#pragma mark - 检查相机权限
- (BOOL)canUserCamear{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请打开相机权限" message:@"设置-隐私-相机" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alertView.tag = 100;
        [alertView show];
        return NO;
    }
    else{
        return YES;
    }
    return YES;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0 && alertView.tag == 100) {
        
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            
            [[UIApplication sharedApplication] openURL:url];
            
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
