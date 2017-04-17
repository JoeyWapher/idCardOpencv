//
//  Imageprocess.mm
//  FundProgram
//
//  Created by Joey on 2017/4/14.
//  Copyright © 2017年 Joey. All rights reserved.
//
#import "Imageprocess.h"

@implementation Imageprocess

#pragma mark - opencv method
// UIImage to cvMat
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

// CvMat to UIImage
+(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8*cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

//由于OpenCV主要针对的是计算机视觉方面的处理，因此在函数库中，最重要的结构体是IplImage结构。
// NOTE you SHOULD cvReleaseImage() for the return value when end of the code.
+ (IplImage *)CreateIplImageFromUIImage:(UIImage *)image {
    // Getting CGImage from UIImage
    CGImageRef imageRef = image.CGImage;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Creating temporal IplImage for drawing
    IplImage *iplimage = cvCreateImage(
                                       cvSize(image.size.width,image.size.height), IPL_DEPTH_8U, 4
                                       );
    // Creating CGContext for temporal IplImage
    CGContextRef contextRef = CGBitmapContextCreate(
                                                    iplimage->imageData, iplimage->width, iplimage->height,
                                                    iplimage->depth, iplimage->widthStep,
                                                    colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault
                                                    );
    // Drawing CGImage to CGContext
    CGContextDrawImage(
                       contextRef,
                       CGRectMake(0, 0, image.size.width, image.size.height),
                       imageRef
                       );
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    // Creating result IplImage
    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplimage, ret, CV_RGBA2BGR);
    cvReleaseImage(&iplimage);
    
    return ret;
}

// NOTE You should convert color mode as RGB before passing to this function
+ (UIImage *)UIImageFromIplImage:(IplImage *)image {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Allocating the buffer for CGImage
    NSData *data =
    [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider =
    CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    // Creating CGImage from chunk of IplImage
    CGImageRef imageRef = CGImageCreate(
                                        image->width, image->height,
                                        image->depth, image->depth * image->nChannels, image->widthStep,
                                        colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider, NULL, false, kCGRenderingIntentDefault
                                        );
    // Getting UIImage from CGImage
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return ret;
}


#pragma mark - custom method

// OSTU算法求出阈值
int  Otsu(unsigned char* pGrayImg , int iWidth , int iHeight)
{
    if((pGrayImg==0)||(iWidth<=0)||(iHeight<=0))return -1;
    int ihist[256];
    int thresholdValue=0; // „–÷µ
    int n, n1, n2 ;
    double m1, m2, sum, csum, fmax, sb;
    int i,j,k;
    memset(ihist, 0, sizeof(ihist));
    n=iHeight*iWidth;
    sum = csum = 0.0;
    fmax = -1.0;
    n1 = 0;
    for(i=0; i < iHeight; i++)
    {
        for(j=0; j < iWidth; j++)
        {
            ihist[*pGrayImg]++;
            pGrayImg++;
        }
    }
    pGrayImg -= n;
    for (k=0; k <= 255; k++)
    {
        sum += (double) k * (double) ihist[k];
    }
    for (k=0; k <=255; k++)
    {
        n1 += ihist[k];
        if(n1==0)continue;
        n2 = n - n1;
        if(n2==0)break;
        csum += (double)k *ihist[k];
        m1 = csum/n1;
        m2 = (sum-csum)/n2;
        sb = (double) n1 *(double) n2 *(m1 - m2) * (m1 - m2);
        if (sb > fmax)
        {
            fmax = sb;
            thresholdValue = k;
        }
    }
    return(thresholdValue);
}


+(UIImage *)Grayimage:(UIImage *)srcimage{
    UIImage *resimage;
    
    //openCV二值化过程：
    
    
     //1.Src的UIImage ->  Src的IplImage
     IplImage* srcImage1 = [self CreateIplImageFromUIImage:srcimage];
     
     //2.设置Src的IplImage的ImageROI
     int width = srcImage1->width;
     int height = srcImage1->height;
     printf("图片大小%d,%d\n",width,height);
     
     
     // 分割矩形区域
     int x = 240;
     int y = 110;
     int w = 300;
     int h = 120;
     
     //cvSetImageROI:基于给定的矩形设置图像的ROI（感兴趣区域，region of interesting）
     cvSetImageROI(srcImage1, cvRect(x, y, w , h));
     
     //3.创建新的dstImage1的IplImage，并复制Src的IplImage
     IplImage* dstImage1 = cvCreateImage(cvSize(w, h), srcImage1->depth, srcImage1->nChannels);
     //cvCopy:如果输入输出数组中的一个是IplImage类型的话，其ROI和COI将被使用。
     cvCopy(srcImage1, dstImage1,0);
     //cvResetImageROI:释放基于给定的矩形设置图像的ROI（感兴趣区域，region of interesting）
     cvResetImageROI(srcImage1);
     
     resimage = [self UIImageFromIplImage:dstImage1];
    
    
    //4.dstImage1的IplImage转换成cvMat形式的matImage
    cv::Mat matImage = [self cvMatFromUIImage:resimage];
    
//    cv::Mat matGrey;
    
    //5.cvtColor函数对matImage进行灰度处理
    //取得IplImage形式的灰度图像
    cvtColor(matImage, matImage, cv::COLOR_BGR2GRAY);// 转换成灰色
    //6.使用灰度后的IplImage形式图像，用OSTU算法算阈值：threshold
    IplImage grey = matImage;
    
    resimage = [self UIImageFromCVMat:matImage];
    
    
     unsigned char* dataImage = (unsigned char*)grey.imageData;
     int threshold = Otsu(dataImage, grey.width, grey.height);
     printf("阈值：%d\n",threshold);
     
     //7.利用阈值算得新的cvMat形式的图像
     cv::Mat matBinary;
     cv::threshold(matImage, matBinary, 100, 255, cv::THRESH_BINARY);
     
     //8.cvMat形式的图像转UIImage
     UIImage* image = [[UIImage alloc ]init];
     image = [self UIImageFromCVMat:matBinary];
     
     resimage = image;
    
    return resimage;
}

+(UIImage *)Erzhiimage:(UIImage *)srcimage{
    
    UIImage *resimage;
    
    //openCV二值化过程：
    
    /*
     //1.Src的UIImage ->  Src的IplImage
     IplImage* srcImage1 = [self CreateIplImageFromUIImage:srcimage];
     
     //2.设置Src的IplImage的ImageROI
     int width = srcImage1->width;
     int height = srcImage1->height;
     printf("图片大小%d,%d\n",width,height);
     //
     
     // 分割矩形区域
     int x = 400;
     int y = 1100;
     int w = 1200;
     int h = 600;
     
     //cvSetImageROI:基于给定的矩形设置图像的ROI（感兴趣区域，region of interesting）
     cvSetImageROI(srcImage1, cvRect(x, y, w , h));
     
     //3.创建新的dstImage1的IplImage，并复制Src的IplImage
     IplImage* dstImage1 = cvCreateImage(cvSize(w, h), srcImage1->depth, srcImage1->nChannels);
     //cvCopy:如果输入输出数组中的一个是IplImage类型的话，其ROI和COI将被使用。
     cvCopy(srcImage1, dstImage1,0);
     //cvResetImageROI:释放基于给定的矩形设置图像的ROI（感兴趣区域，region of interesting）
     cvResetImageROI(srcImage1);
     
     resimage = [self UIImageFromIplImage:dstImage1];
     */
    
    //4.dstImage1的IplImage转换成cvMat形式的matImage
    cv::Mat matImage = [self cvMatFromUIImage:srcimage];
    
    cv::Mat matGrey;
    
    //5.cvtColor函数对matImage进行灰度处理
    //取得IplImage形式的灰度图像
    cv::cvtColor(matImage, matGrey, CV_BGR2GRAY);// 转换成灰色
    
    //6.使用灰度后的IplImage形式图像，用OSTU算法算阈值：threshold
    IplImage grey = matGrey;
    unsigned char* dataImage = (unsigned char*)grey.imageData;
    int threshold = Otsu(dataImage, grey.width, grey.height);
    printf("阈值：%d\n",threshold);
    
    //7.利用阈值算得新的cvMat形式的图像
    cv::Mat matBinary;
    cv::threshold(matGrey, matBinary, threshold, 255, cv::THRESH_BINARY);
    
    //8.cvMat形式的图像转UIImage
    UIImage* image = [[UIImage alloc ]init];
    image = [self UIImageFromCVMat:matBinary];
    
    resimage = image;
    
    return resimage;
}

@end
