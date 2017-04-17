//
//  publicClass.m
//  活期宝app
//
//  Created by joey on 16/3/11.
//  Copyright © 2016年 gcjr. All rights reserved.
//

#import "publicClass.h"
#import <CommonCrypto/CommonDigest.h>
#import <sys/utsname.h>

@implementation NSString (NSString_Hashing)

- (NSString *)MD5Hash
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

@end

@implementation publicClass
+ (BOOL) validateIdentityCard: (NSString *)identityCard
{
    BOOL flag;
    if (identityCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}
+(NSString*)moneyConvert:(NSString*)numberData
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"###,##0.00;"];
    NSNumber *formattedNumber = [numberFormatter numberFromString:numberData];
    NSString* formattedNumberString=[numberFormatter stringFromNumber:formattedNumber];
    return formattedNumberString;
}
+(NSString*)moneyConvertDouble:(double)numberData
{
    NSString* dataStr = [NSString stringWithFormat:@"%.2f",numberData];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"###,##0.00;"];
    NSNumber *formattedNumber = [numberFormatter numberFromString:dataStr];
    NSString* formattedNumberString=[numberFormatter stringFromNumber:formattedNumber];
    return formattedNumberString;
}
+(NSString*)moneyConvertInt:(NSString*)numberData
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"###,##0;"];
    NSNumber *formattedNumber = [numberFormatter numberFromString:numberData];
    NSString* formattedNumberString=[numberFormatter stringFromNumber:formattedNumber];
    return formattedNumberString;
}
+(NSString*)InterestConvert:(NSString*)numberData
{
    NSMutableString* interestStr = [NSMutableString stringWithFormat:@"%.2f",[numberData doubleValue]];
    NSString * s = nil;
    NSInteger offset = interestStr.length - 1;
    while (offset)
    {
        s = [interestStr substringWithRange:NSMakeRange(offset, 1)];
        if ([s isEqualToString:@"0"] || [s isEqualToString:@"."])
        {
            offset--;
        }
        else
        {
            break;
        }
    }
    NSString * outNumber = [interestStr substringToIndex:offset+1];

    return outNumber;
}
/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
+ (NSString *)JsonStringWithDictionary:(NSDictionary *)dictionary
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

+(NSString*)dayStrChangeDateStr:(NSString*)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    
    NSDate* dayDate=[dateFormatter dateFromString:dateStr];
    
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    
    NSString* dayStr=[dateFormatter stringFromDate:dayDate];
    
    return dayStr;
    
}

+(NSString*)nowDayGetNextDay:(int)day
{
    NSInteger dis = day; //前后的天数
    
    
    
    NSDate*nowDate = [NSDate date];
    
    NSDate* theDate;
    
    
    
    if(dis!=0)
        
    {
        
        NSTimeInterval  oneDay = 24*60*60*1;  //1天的长度
        
        
        theDate = [nowDate initWithTimeIntervalSinceNow: +oneDay*dis ];
        
//        //or
//        
//        theDate = [nowDate initWithTimeIntervalSinceNow: -oneDay*dis ];
        
    }
    
    else
        
    {
        
        theDate = nowDate;
        
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    
    NSString* dayStr=[dateFormatter stringFromDate:theDate];
    
    return dayStr;


}

//获取缓存文件 在 沙盒 Library/Caches 中的路径
//url 在函数里面进行 md5 加密处理之后的 作为 缓存文件的文件名

+ (NSString *)getFullCacheFilePathWithUrl:(NSString *)url{
    //1.拼接沙盒缓存路径 MyCaches是我们自己创建一个目录
    NSString * myCachePath = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/MyCaches/zgzDiskCache"];
    NSFileManager *fm = [NSFileManager defaultManager];
    //2.判断自己的缓存目录是否存在
    if (![fm fileExistsAtPath:myCachePath]) {
        //不存在那么就创建一个 MyCaches
        BOOL ret = [fm createDirectoryAtPath:myCachePath withIntermediateDirectories:YES attributes:nil error:nil];
        if (!ret) {
            NSLog(@"缓存目录创建失败");
        }
    }
    //md5 对字符串加密 处理
    url = [url MD5Hash];
    //拼接问价的全路径
    return [myCachePath stringByAppendingFormat:@"/%@",url];
}
//判断 缓存文件 是否 超时
//url 是一个网址
//一个url 地址 对应一个 缓存文件， 缓存文件名字 用md5对url 进行加密之后命名
+ (BOOL)isOutTimeOfFileWithUrl:(NSString *)url  outTime:(NSTimeInterval)time{
    
    //获取url 对应的缓存文件的地址
    NSString * fileCache = [publicClass getFullCacheFilePathWithUrl:url];
    NSFileManager *fm = [NSFileManager defaultManager];
    //获取文件 属性字典
    NSDictionary *dict = [fm attributesOfItemAtPath:fileCache error:nil];
    //获取当前文件的上次修改时间
    NSDate *pastDate = [dict fileModificationDate];
    //时间差 获取上次修改时间和当前时间的时间差  单位s
    NSTimeInterval subTimer = [pastDate timeIntervalSinceNow];
    //一般缓存文件 超时时间 设置为 1小时 60*60s
    //时间差是正的
    if (subTimer < 0) {
        subTimer = - subTimer;
    }
    if (subTimer > time) {//超时 可以设置为 1小时
        return YES;//超时
    }else  {
        return NO;//没有超时
    }
}
+ (NSString *)iphoneType {
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];

    
    //iPhone 系列
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    
    //iPod 系列
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    
    //iPad 系列
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (32nm)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad mini (CDMA)";
    
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3(WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3(CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3(4G)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (4G)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";
    
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    
    if ([platform isEqualToString:@"iPad4,4"]
        ||[platform isEqualToString:@"iPad4,5"]
        ||[platform isEqualToString:@"iPad4,6"])      return @"iPad mini 2";
    
    if ([platform isEqualToString:@"iPad4,7"]
        ||[platform isEqualToString:@"iPad4,8"]
        ||[platform isEqualToString:@"iPad4,9"])      return @"iPad mini 3";
    
    if ([platform isEqualToString:@"i386"]) return @"iPhone Simulator";
    
    if ([platform isEqualToString:@"x86_64"]) return @"iPhone Simulator";
    
    return platform;
    
}
//正则去除网络标签
+(NSString *)getZZwithString:(NSString *)string{
    NSRegularExpression *regularExpretion=[NSRegularExpression regularExpressionWithPattern:@"<[^>]*>|\n"
                                                                                    options:0
                                                                                      error:nil];
    string=[regularExpretion stringByReplacingMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length) withTemplate:@""];
    return string;
}
//正则去除特殊符号空格等
+(NSString *)getZZCharacterwithString:(NSString *)string{

    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"\'\":;；：，。·~！@￥%……&*（）「」‘’““、？/.,`~!^&[]{}（#%-*+=_）\\|~(＜＞$%^&*)_+ "];
    NSString *trimmedString1 = [[string componentsSeparatedByCharactersInSet: doNotWant]componentsJoinedByString: @""];
    NSCharacterSet *set2 = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedString2 = [trimmedString1 stringByTrimmingCharactersInSet:set2];
    
    return trimmedString2;
}
+ (NSString *)uuidString
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}
//判断手机号码格式是否正确
+ (BOOL)valiMobile:(NSString *)mobile
{
    if (mobile.length != 11)
    {
        return NO;
    }
    /**
     * 手机号码:
     * 13[0-9], 14[5,7], 15[0, 1, 2, 3, 5, 6, 7, 8, 9], 17[6, 7, 8], 18[0-9], 170[0-9]
     * 移动号段: 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
     * 联通号段: 130,131,132,155,156,185,186,145,176,1709
     * 电信号段: 133,153,180,181,189,177,1700
     */
    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9]|7[0678])\\d{8}$";
    /**
     * 中国移动：China Mobile
     * 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
     */
    NSString *CM = @"(^1(3[4-9]|4[7]|5[0-27-9]|7[8]|8[2-478])\\d{8}$)|(^1705\\d{7}$)";
    /**
     * 中国联通：China Unicom
     * 130,131,132,155,156,185,186,145,176,1709
     */
    NSString *CU = @"(^1(3[0-2]|4[5]|5[56]|7[6]|8[56])\\d{8}$)|(^1709\\d{7}$)";
    /**
     * 中国电信：China Telecom
     * 133,153,180,181,189,177,1700
     */
    NSString *CT = @"(^1(33|53|77|8[019])\\d{8}$)|(^1700\\d{7}$)";
    
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobile] == YES)
        || ([regextestcm evaluateWithObject:mobile] == YES)
        || ([regextestct evaluateWithObject:mobile] == YES)
        || ([regextestcu evaluateWithObject:mobile] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
+(NSString*)decimalNumber:(float)rate day:(NSInteger)day money:(NSInteger)money{
    NSDecimalNumber *oneNum = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInteger:1] decimalValue]];
    NSDecimalNumber *rateNum = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithFloat:rate] decimalValue]];
    NSDecimalNumber *daysNum = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInteger:day] decimalValue]];
    NSDecimalNumber *moneyNum = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInteger:money] decimalValue]];
    //乘
    NSDecimalNumber *num1 = [rateNum decimalNumberByMultiplyingBy:daysNum];
    //加
    NSDecimalNumber *num2 = [oneNum decimalNumberByAdding:num1];
    //乘金额
    NSDecimalNumber *num3 = [num2 decimalNumberByMultiplyingBy:moneyNum];
    return [num3 stringValue];
}
+(void)removeSourcePath:(NSString*)path{
    NSString *sourceDir = [NSString stringWithFormat:@"%@/%@",NSHomeDirectory(),path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:sourceDir error:nil];
}

//判断对象是否为空
+(BOOL)objectIsEmpty:(id)object
{
    if ([object isEqual:[NSNull null]]) {
        return YES;
    }
    else if ([object isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    else if (nil == object){
        return YES;
    }
    return NO;
}

@end
