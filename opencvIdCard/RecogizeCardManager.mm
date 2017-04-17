//
//  RecogizeCardManager.m
//  RecognizeCard
//
//  Created by 谭高丰 on 16/8/31.
//  Copyright © 2016年 谭高丰. All rights reserved.
//

#import "RecogizeCardManager.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>
#import <TesseractOCR/TesseractOCR.h>
#import "Imageprocess.h"
#import "publicClass.h"

@implementation RecogizeCardManager

+ (instancetype)recognizeCardManager {
    static RecogizeCardManager *recognizeCardManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recognizeCardManager = [[RecogizeCardManager alloc] init];
        
    });
    return recognizeCardManager;
}

- (void)recognizeCardWithImage:(UIImage *)cardImage compleate:(CompleateBlock)compleate {
//    UIImage* numberImage = [Imageprocess Grayimage:cardImage];
//    NSString *path_sandox = NSHomeDirectory();
//    NSString* imagePath= [path_sandox stringByAppendingString:@"/Documents/idcardtest.png"];
//    [UIImagePNGRepresentation(numberImage) writeToFile:imagePath atomically:YES];
    UIImage * newImage =[self imageCompressWithSimple:cardImage scale:0.5];
    //扫描身份证图片，并进行预处理，定位号码区域图片并返回
    NSArray* arr = [self opencvScanCard:newImage];
    if (arr==nil) {
        compleate(@"证件认证失败，请重新拍摄",@"");
    }else{
        //利用TesseractOCR识别文字
        [self tesseractRecognizeImageArr:arr compleate:^(NSString *numbaerText,NSString*numbaerText1) {
            compleate(numbaerText,numbaerText1);
        }];
    }
    
}


//扫描身份证图片，并进行预处理，定位号码区域图片并返回
- (NSArray *)opencvScanCard:(UIImage *)image {
    
    //将UIImage转换成Mat
    cv::Mat resultImage;
    UIImageToMat(image, resultImage);
   //先用使用 3x3内核来降噪
    blur( resultImage, resultImage, cv::Size(3,3),cv::Point(-1,-1));
//    UIImage *Image2 = MatToUIImage(resultImage);
//    //固定阈值二值化
//    cv::threshold(resultImage, resultImage, 100, 255, CV_THRESH_BINARY);
//    //局部阈值二值化
//    cv::adaptiveThreshold(resultImage, resultImage, 255, CV_ADAPTIVE_THRESH_MEAN_C, CV_THRESH_BINARY, 3, 5);
//    //平均阈值二值化
//    IplImage imgTopDown = resultImage;
//    CvScalar mean ,std_dev;//平均值、 标准差
//    double u_threshold,d_threshold;
//    cvAvgSdv(&imgTopDown,&mean,&std_dev,NULL);
//    u_threshold = mean.val[0] +1.5* std_dev.val[0];//上阀值
//    d_threshold = mean.val[0] -1.5* std_dev.val[0];//下阀值
//    u_threshold = mean.val[0];
//    d_threshold = mean.val[0];
//    //u_threshold = mean + 2.5 * std_dev; //错误
//    //d_threshold = mean - 2.5 * std_dev;
//    std::cout<<"The TopThreshold of this Image in TopDown is:"<<d_threshold<<std::endl;//输出显示阀值
//    std::cout<<"The DownThreshold of this Image in TopDown is:"<<u_threshold<<std::endl;
//    cv::threshold(resultImage,resultImage,d_threshold,u_threshold,CV_THRESH_BINARY);//上下阀值
    //积分阈值二值化
    resultImage =AdaptiveThereshold(resultImage, resultImage);
    //腐蚀，填充（腐蚀是让黑色点变大）
    cv::Mat erodeElement = getStructuringElement(cv::MORPH_RECT, cv::Size(22,22));
    cv::erode(resultImage, resultImage, erodeElement);
    //轮廊检测 
    std::vector<std::vector<cv::Point>> contours;//定义一个容器来存储所有检测到的轮廊
    cv::findContours(resultImage, contours, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cvPoint(0, 0));
    //cv::drawContours(resultImage, contours, -1, cv::Scalar(255),4);
    //取出身份证号码区域
    std::vector<cv::Rect> rects;
    cv::Rect NameNumberRect = cv::Rect(0,0,0,0);
    cv::Rect CardNumberRect = cv::Rect(0,0,0,0);
    std::vector<std::vector<cv::Point>>::const_iterator itContours = contours.begin();
    for ( ; itContours != contours.end(); ++itContours) {
        cv::Rect rect = cv::boundingRect(*itContours);
        rects.push_back(rect);
        //算法原理
        if (rect.width > CardNumberRect.width && rect.width > rect.height * 6) {
            CardNumberRect = rect;
        }
        if (rect.x > 60 && rect.y<120 && rect.height*2 < rect.width) {
            NameNumberRect = rect;
        }
    }
    
    
    //定位成功成功，去原图截取身份证号码区域，并转换成灰度图、进行二值化处理
    //去原图截取身份证姓名区域，并转换成灰度图、进行二值化处理
    cv::Mat matImage;
    UIImageToMat(image, matImage);
    cv::Mat NameImageMat;
    NameImageMat = matImage(NameNumberRect);
    IplImage grey = NameImageMat;
    unsigned char* dataImage = (unsigned char*)grey.imageData;
    int threshold = Otsu(dataImage, grey.width, grey.height);
    printf("阈值：%d\n",threshold);
    NameImageMat =AdaptiveThereshold(NameImageMat, NameImageMat);
    UIImage *NameImage = MatToUIImage(NameImageMat);

    cv::Mat CardImageMat;
    CardImageMat = matImage(CardNumberRect);
    CardImageMat =AdaptiveThereshold(CardImageMat, CardImageMat);
    UIImage *CardImage = MatToUIImage(CardImageMat);
    
    //身份证号码定位失败
    if ([publicClass objectIsEmpty:CardImage]||[publicClass objectIsEmpty:NameImage]) {
        return nil;
    }
    NSArray* arr = @[NameImage,CardImage];
    return arr;
}
cv::Mat AdaptiveThereshold(cv::Mat src,cv::Mat dst)
{
    cvtColor(src,dst,CV_BGR2GRAY);
    int x1, y1, x2, y2;
    int count=0;
    long long sum=0;
    int S=src.rows>>3;  //划分区域的大小S*S
    int T=15;         /*百分比，用来最后与阈值的比较。原文：If the value of the current pixel is t percent less than this average
                       then it is set to black, otherwise it is set to white.*/
    int W=dst.cols;
    int H=dst.rows;
    long long **Argv;
    Argv=new long long*[dst.rows];
    for(int ii=0;ii<dst.rows;ii++)
    {
        Argv[ii]=new long long[dst.cols];
    }
    
    for(int i=0;i<W;i++)
    {
        sum=0;
        for(int j=0;j<H;j++)
        {
            sum+=dst.at<uchar>(j,i);
            if(i==0)
                Argv[j][i]=sum;
            else
                Argv[j][i]=Argv[j][i-1]+sum;
        }
    }
    
    for(int i=0;i<W;i++)
    {
        for(int j=0;j<H;j++)
        {
            x1=i-S/2;
            x2=i+S/2;
            y1=j-S/2;
            y2=j+S/2;
            if(x1<0)
                x1=0;
            if(x2>=W)
                x2=W-1;
            if(y1<0)
                y1=0;
            if(y2>=H)
                y2=H-1;
            count=(x2-x1)*(y2-y1);
            sum=Argv[y2][x2]-Argv[y1][x2]-Argv[y2][x1]+Argv[y1][x1];
            
            
            if((long long)(dst.at<uchar>(j,i)*count)<(long long)sum*(100-T)/100)
                dst.at<uchar>(j,i)=0;
            else
                dst.at<uchar>(j,i)=255;
        }
    }
    for (int i = 0 ; i < dst.rows; ++i)
    {
        delete [] Argv[i];
    }
    delete [] Argv;
    return dst;
}
- (UIImage*)imageCompressWithSimple:(UIImage*)image scale:(float)scale
{
    CGSize size = image.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGFloat scaledWidth = width * scale;
    CGFloat scaledHeight = height * scale;
    CGRect smallBounds = CGRectMake(0,0,scaledWidth,scaledHeight);
//    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0, 0, size.width, size.height));
//    UIGraphicsBeginImageContext(smallBounds.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextDrawImage(context, smallBounds, subImageRef);
//    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
//    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(CGSizeMake(scaledWidth, scaledHeight));
    [image drawInRect:smallBounds];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
//利用TesseractOCR识别文字
- (void)tesseractRecognizeImageArr:(NSArray *)arr compleate:(CompleateBlock)compleate {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableArray* marr = [NSMutableArray array];
        for (int i = 0; i<arr.count; i++) {
            G8Tesseract *tesseract;
            if(i==0){
                tesseract = [[G8Tesseract alloc] initWithLanguage:@"chi_sim"];
            }else{
                tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];
            }
            tesseract.image = [arr[i] g8_blackAndWhite];
            tesseract.image = arr[i];
            // Start the recognition
            [tesseract recognize];
            //执行回调
            [marr addObject:tesseract.recognizedText];
        }
        compleate(marr[0],marr[1]);
        
    });
}
//-(UIImage*)plateRecognition:(cv::Mat&)src
//{
//    UIImage *plateimage;
//    pr.setLifemode(true);
//    pr.setDebug(false);
//    pr.setMaxPlates(4);
//    //pr.setDetectType(PR_DETECT_COLOR | PR_DETECT_SOBEL);
//    pr.setDetectType(easypr::PR_DETECT_CMSER);
//    vector<CPlate> plateVec;
//    double t=cv::getTickCount();
//    int result = pr.plateRecognize(src, plateVec);
//    t=cv::getTickCount()-t;
//    NSLog(@"time %f",t*1000/cv::getTickFrequency());
//    if (result == 0) {
//        size_t num = plateVec.size();
//        for (size_t j = 0; j < num; j++) {
//            cout << "plateRecognize: " << plateVec[j].getPlateStr() << endl;
//        }
//    }
//    
//    if (result != 0) cout << "result:" << result << endl;
//    if(plateVec.size()==0){
////        [SVProgressHUD dismiss];
////        [self.textLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"No Plate"] waitUntilDone:NO];
//        return plateimage;
//    }
//    string name=plateVec[0].getPlateStr();
//    NSString *resultMessage = [NSString stringWithCString:plateVec[0].getPlateStr().c_str()
//                                                 encoding:NSUTF8StringEncoding];
////    [self.textLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%@",resultMessage] waitUntilDone:NO];
//    
//    
//    if (result != 0)
//        cout << "result:" << result << endl;
////    [SVProgressHUD dismiss];
//    return plateimage;
//}

@end
