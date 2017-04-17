//
//  ViewController.m
//  opencvIdCard
//
//  Created by Joey on 2017/4/17.
//  Copyright © 2017年 Joey. All rights reserved.
//

#import "ViewController.h"
#import "RecogizeCardManager.h"
#import "photoViewController.h"
#import "publicClass.h"
@interface ViewController ()<UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel1;
- (IBAction)cameraAction:(id)sender;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    
}
-(void)viewWillAppear:(BOOL)animated{
    [self setNewOrientation:NO];//调用转屏代码
    UIImage* ImageA = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/image1.png",NSHomeDirectory()]];
    if (![publicClass objectIsEmpty:ImageA]) {
        self.imgView.image = ImageA;
        [self didFinishPhotoMediaWithImage:ImageA];
    }
}
- (void)setNewOrientation:(BOOL)fullscreen
{
    
    if (fullscreen) {
        
        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        
        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
        
        
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        
    }else{
        
        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        
        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
        
        
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//拍照
- (IBAction)cameraAction:(id)sender {
    
    //判断是否可以打开照相机
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        photoViewController* vc = [photoViewController new];
        [self presentViewController:vc animated:NO completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设备不能打开相机" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)didFinishPhotoMediaWithImage:(UIImage*)image{

        self.imgView.image = image;
        //识别身份证
        self.textLabel.text = @"图片插入成功，正在识别中...";
        [[RecogizeCardManager recognizeCardManager] recognizeCardWithImage:image compleate:^(NSString *text, NSString *text1) {
            NSLog(@"%@ %@",text,text1);
            //        UIImage* im = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/idcardtest.png",NSHomeDirectory()]];
            //        imv.image = im;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (text != nil) {
                    self.textLabel.text = [NSString stringWithFormat:@"姓名：%@",[publicClass getZZCharacterwithString:text]];
                    self.textLabel1.text = [NSString stringWithFormat:@"身份证号：%@",[publicClass getZZCharacterwithString:text1]];
                }else {
                    self.textLabel.text = @"请选择照片";
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"照片识别失败，请选择清晰、没有复杂背景的身份证照片重试！" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
                    [alert show];
                }
                

            });
        }];

    [self dismissViewControllerAnimated:YES completion:nil];
}

//进入拍摄页面点击取消按钮
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
