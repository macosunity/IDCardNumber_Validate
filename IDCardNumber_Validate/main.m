//
//  main.m
//  IDCardNumber_Validate
//
//  Created by 王亮 on 16/8/31.
//  Copyright © 2016年 王亮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDCardNumber_Validate.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        BOOL isValid = [IDCardNumber_Validate isValidateIDCardString:@"512501197203035172"];
        if (isValid) {
            NSLog(@"有效身份证");
        }
        else {
            NSLog(@"无效身份证");
        }
    }
    return 0;
}
