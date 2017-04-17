//
//  Imageprocess.h
//  FundProgram
//
//  Created by Joey on 2017/4/14.
//  Copyright © 2017年 Joey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>
#import <UIKit/UIKit.h>

@interface Imageprocess : NSObject

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

+ (IplImage *)CreateIplImageFromUIImage:(UIImage *)image;

+ (UIImage *)UIImageFromIplImage:(IplImage *)image;

+ (UIImage *)Grayimage:(UIImage *)srcimage;

+ (UIImage *)Erzhiimage:(UIImage *)srcimage;

int  Otsu(unsigned char* pGrayImg , int iWidth , int iHeight);

@end
