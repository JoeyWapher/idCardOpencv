//
//  publicClass.h
//  活期宝app
//
//  Created by joey on 16/3/11.
//  Copyright © 2016年 gcjr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface publicClass : NSObject

+ (NSString *)getFullCacheFilePathWithUrl:(NSString *)url;
+ (BOOL) validateIdentityCard: (NSString *)identityCard; 
+(NSString*)moneyConvert:(NSString*)numberData;
+(NSString*)moneyConvertDouble:(double)numberData;
+(NSString*)moneyConvertInt:(NSString*)numberData;
+(NSString*)InterestConvert:(NSString*)numberData;
//jsonString转NSDictionary
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
//NSDictionary转jsonString
+ (NSString *)JsonStringWithDictionary:(NSDictionary *)dictionary;
//时间转换
+(NSString*)dayStrChangeDateStr:(NSString*)dateStr;
//获取后几天的日期
+(NSString*)nowDayGetNextDay:(int)day;


//手机型号
+ (NSString *)iphoneType;
//判断手机号码格式是否正确
+ (BOOL)valiMobile:(NSString *)mobile;
//正则去除网络标签
+(NSString *)getZZwithString:(NSString *)string;
//正则去除特殊符号空格等
+(NSString *)getZZCharacterwithString:(NSString *)string;
//初始化nav
+(NSArray*)initNavibar:(NSString*)title;
+ (NSString *)uuidString;
+(NSString*)getUUID;
+(NSString*)decimalNumber:(float)rate day:(NSInteger)day money:(NSInteger)money;
//判断对象是否为空
+(BOOL)objectIsEmpty:(id)object;
//删除文件夹及文件
+(void)removeSourcePath:(NSString*)path;
//删除usedefaults
+(void)removeUseDefaults;
//判断输入框是否为空提示
+(void)popAlertView:(id)target andMessage:(NSString*)msg;
@end
