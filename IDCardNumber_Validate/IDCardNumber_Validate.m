//
//  IDCardNumber_Validate.m
//
//  Created by wangliang on 16/4/20.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "IDCardNumber_Validate.h"

@interface NSDate (Private)

+ (NSCalendar *)shareCalendar;

+ (NSDateFormatter *)sharedFormatter;

- (NSDateComponents *)dateParts:(NSUInteger)flags;

- (NSInteger)year;

@end

@implementation NSDate (Private)

+ (NSCalendar *)shareCalendar {
    static NSCalendar * calender = nil;
    
    if (calender == nil) {
        calender = [NSCalendar currentCalendar];
    }
    
    return calender;
}


+ (NSDateFormatter *)sharedFormatter {
    static NSDateFormatter * dateFormatter = nil;
    
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    
    return dateFormatter;
}

+ (NSDateComponents *)shareComponents {
    static NSDateComponents * dateComponents = nil;
    
    if (dateComponents == nil) {
        dateComponents = [[NSDateComponents alloc] init];
    }
    
    return dateComponents;
}

- (NSDateComponents *)dateParts:(NSUInteger)flags {
    NSDateComponents * comp = [[NSDate shareCalendar] components:flags fromDate:self];
    return comp;
}

- (NSInteger)year {
    return [self dateParts:NSCalendarUnitYear].year;
}

@end

@implementation IDCardNumber_Validate

//判断是否为合法的身份证号
+ (BOOL)isValidateIDCardString:(NSString *)idCardString {
    // 记录错误信息
    NSString *errorInfo = nil;
    
    NSString *valCodeArr[] = { @"1", @"0", @"X", @"9", @"8", @"7", @"6", @"5", @"4",
                               @"3", @"2" };
    NSString *wi[] = { @"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7",
                       @"9", @"10", @"5", @"8", @"4", @"2" };
    NSString *ai = @"";
    if ([idCardString hasSuffix:@"x"]) {
        idCardString = [idCardString stringByReplacingCharactersInRange:NSMakeRange(idCardString.length-1, 1) withString:@"X"];
    }

    //判断号码的长度是否为 15位或18位
    if (idCardString.length == 15 || idCardString.length == 18) {
        errorInfo = nil;
    } else {
        errorInfo = @"身份证号码长度应该为15位或18位。";
        return NO;
    }

    //判断数字是否 除最后一位都为数字
    if (idCardString.length == 18) {
        ai = [idCardString substringWithRange:NSMakeRange(0, idCardString.length-1)];
    }
    else if (idCardString.length == 15) {
        ai = [NSString stringWithFormat:@"%@%@%@", [idCardString substringWithRange:NSMakeRange(0, 6)], @"19", [idCardString substringWithRange:NSMakeRange(6, 9)]];
    }
    
    if (![IDCardNumber_Validate isPureInt:ai]) {
        errorInfo = @"身份证15位号码都应为数字 ; 18位号码除最后一位外，都应为数字。";
        return NO;
    }

    //判断出生年月是否有效
    NSString *strYear = [ai substringWithRange:NSMakeRange(6, 4)];// 年份
    NSString *strMonth = [ai substringWithRange:NSMakeRange(10, 2)];// 月份
    NSString *strDay = [ai substringWithRange:NSMakeRange(12, 2)];// 月份
    NSString *strDate = [NSString stringWithFormat:@"%@-%@-%@", strYear, strMonth, strDay];
    if (![IDCardNumber_Validate isValidateDate:strDate]) {
        errorInfo = @"身份证生日无效。";
        return NO;
    }

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *idCardDate = [dateFormatter dateFromString:strDate];

    NSDate *nowDate = [NSDate date];

    if (([nowDate year] - [strYear intValue]) > 150
        || ([nowDate timeIntervalSince1970] - [idCardDate timeIntervalSince1970]) < 0) {
        errorInfo = @"身份证生日不在有效范围。";
        return NO;
    }

    if ([strMonth intValue] > 12 || [strMonth intValue] == 0) {
        errorInfo = @"身份证月份无效";
        return NO;
    }
    
    if ([strDay intValue] > 31 || [strDay intValue] == 0) {
        errorInfo = @"身份证日期无效";
        return NO;
    }

    //判断地区码是否有效
    NSDictionary *areaCodeDict = [IDCardNumber_Validate getAreaCode];
    NSString *areaKey = [ai substringWithRange:NSMakeRange(0, 2)];
    if ([areaCodeDict objectForKey:areaKey] == nil) {
        errorInfo = @"身份证地区编码错误。";
        return NO;
    }

    //判断最后一位的值
    int TotalmulAiWi = 0;
    for (int i = 0; i < 17; i++) {
        TotalmulAiWi = TotalmulAiWi + [[NSString stringWithFormat:@"%c", [ai characterAtIndex:i]] intValue] * [wi[i] intValue];
    }

    int modValue = TotalmulAiWi % 11;
    NSString *strVerifyCode = valCodeArr[modValue];
    ai = [NSString stringWithFormat:@"%@%@", ai, strVerifyCode];

    if (idCardString.length == 18) {
        if (![ai isEqualToString:idCardString]) {
            errorInfo = @"身份证无效，不是合法的身份证号码";
            return NO;
        }
    } else {
        return YES;
    }

    return YES;
}


//获取地址编码
+ (NSDictionary *)getAreaCode {
    
    NSMutableDictionary *areaCodeDict = [[NSMutableDictionary alloc] init];
    [areaCodeDict setObject:@"北京" forKey:@"11"];
    [areaCodeDict setObject:@"天津" forKey:@"12"];
    [areaCodeDict setObject:@"河北" forKey:@"13"];
    [areaCodeDict setObject:@"山西" forKey:@"14"];
    [areaCodeDict setObject:@"内蒙古" forKey:@"15"];
    [areaCodeDict setObject:@"辽宁" forKey:@"21"];
    [areaCodeDict setObject:@"吉林" forKey:@"22"];
    [areaCodeDict setObject:@"黑龙江" forKey:@"23"];
    [areaCodeDict setObject:@"上海" forKey:@"31"];
    [areaCodeDict setObject:@"江苏" forKey:@"32"];
    [areaCodeDict setObject:@"浙江" forKey:@"33"];
    [areaCodeDict setObject:@"安徽" forKey:@"34"];
    [areaCodeDict setObject:@"福建" forKey:@"35"];
    [areaCodeDict setObject:@"江西" forKey:@"36"];
    [areaCodeDict setObject:@"山东" forKey:@"37"];
    [areaCodeDict setObject:@"河南" forKey:@"41"];
    [areaCodeDict setObject:@"湖北" forKey:@"42"];
    [areaCodeDict setObject:@"湖南" forKey:@"43"];
    [areaCodeDict setObject:@"广东" forKey:@"44"];
    [areaCodeDict setObject:@"广西" forKey:@"45"];
    [areaCodeDict setObject:@"海南" forKey:@"46"];
    [areaCodeDict setObject:@"重庆" forKey:@"50"];
    [areaCodeDict setObject:@"四川" forKey:@"51"];
    [areaCodeDict setObject:@"贵州" forKey:@"52"];
    [areaCodeDict setObject:@"云南" forKey:@"53"];
    [areaCodeDict setObject:@"西藏" forKey:@"54"];
    [areaCodeDict setObject:@"陕西" forKey:@"61"];
    [areaCodeDict setObject:@"甘肃" forKey:@"62"];
    [areaCodeDict setObject:@"青海" forKey:@"63"];
    [areaCodeDict setObject:@"宁夏" forKey:@"64"];
    [areaCodeDict setObject:@"新疆" forKey:@"65"];
    [areaCodeDict setObject:@"台湾" forKey:@"71"];
    [areaCodeDict setObject:@"香港" forKey:@"81"];
    [areaCodeDict setObject:@"澳门" forKey:@"82"];
    [areaCodeDict setObject:@"国外" forKey:@"91"];
    return areaCodeDict;
}

//判断单个字符是否为数字
+ (BOOL)isDigit:(NSString *)string {
    
    NSString *regex = @"^\\d$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    BOOL isMatch = [pred evaluateWithObject:string];
    if (isMatch) {
        return YES;
    }
    
    return NO;
}

//判断字符串是否由纯数字构成
+ (BOOL)isPureInt:(NSString *)string {
    NSScanner *scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

//判断字符串是否为数值(含带小数的数字)
+ (BOOL)isValidateNumber:(NSString *)string {
    
    NSString *regex = @"^\\d+(\\.\\d+)?$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    BOOL isMatch = [pred evaluateWithObject:string];
    if (isMatch) {
        return YES;
    }
    
    return NO;
}

//判断是否为合法的日期
+ (BOOL)isValidateDate:(NSString *)dateString {
    
    NSString *regex = @"^((\\d{2}(([02468][048])|([13579][26]))[\\-\\/\\s]?((((0?[13578])|(1[02]))[\\-\\/\\s]?((0?[1-9])|([1-2][0-9])|(3[01])))|(((0?[469])|(11))[\\-\\/\\s]?((0?[1-9])|([1-2][0-9])|(30)))|(0?2[\\-\\/\\s]?((0?[1-9])|([1-2][0-9])))))|(\\d{2}(([02468][1235679])|([13579][01345789]))[\\-\\/\\s]?((((0?[13578])|(1[02]))[\\-\\/\\s]?((0?[1-9])|([1-2][0-9])|(3[01])))|(((0?[469])|(11))[\\-\\/\\s]?((0?[1-9])|([1-2][0-9])|(30)))|(0?2[\\-\\/\\s]?((0?[1-9])|(1[0-9])|(2[0-8]))))))(\\s(((0?[0-9])|([1-2][0-3]))\\:([0-5]?[0-9])((\\s)|(\\:([0-5]?[0-9])))))?$";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:dateString];
    
    if (isMatch) {
        return YES;
    }
    return NO;
}
@end
