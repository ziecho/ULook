//
//  ULUtils.m
//  ULook
//
//  Created by ziezheng on 2019/6/17.
//  Copyright © 2019 ziezheng. All rights reserved.
//

#import "ULUtils.h"
#import <sys/utsname.h>

@implementation ULUtils

+ (NSString *)deviceModelName {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *phoneModel = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    
    // 第三步：参照对照表
    if ([phoneModel isEqualToString:@"iPhone3,1"] ||
        [phoneModel isEqualToString:@"iPhone3,2"] ||
        [phoneModel isEqualToString:@"iPhone3,3"])      return @"iPhone 4";
    if ([phoneModel isEqualToString:@"iPhone4,1"])      return @"iPhone 4S";
    if ([phoneModel isEqualToString:@"iPhone5,1"] ||
        [phoneModel isEqualToString:@"iPhone5,2"])      return @"iPhone 5";
    if ([phoneModel isEqualToString:@"iPhone5,3"] ||
        [phoneModel isEqualToString:@"iPhone5,4"])      return @"iPhone 5C";
    if ([phoneModel isEqualToString:@"iPhone6,1"] ||
        [phoneModel isEqualToString:@"iPhone6,2"])      return @"iPhone 5S";
    if ([phoneModel isEqualToString:@"iPhone7,1"])      return @"iPhone 6 Plus";
    if ([phoneModel isEqualToString:@"iPhone7,2"])      return @"iPhone 6";
    if ([phoneModel isEqualToString:@"iPhone8,1"])      return @"iPhone 6s";
    if ([phoneModel isEqualToString:@"iPhone8,2"])      return @"iPhone 6s Plus";
    if ([phoneModel isEqualToString:@"iPhone8,4"])      return @"iPhone SE";
    if ([phoneModel isEqualToString:@"iPhone9,1"]||
        [phoneModel isEqualToString:@"iPhone9,3"])      return @"iPhone 7";
    if ([phoneModel isEqualToString:@"iPhone9,2"]||
        [phoneModel isEqualToString:@"iPhone9,4"])      return @"iPhone 7 Plus";
    if ([phoneModel isEqualToString:@"iPhone10,1"] ||
        [phoneModel isEqualToString:@"iPhone10,4"])     return @"iPhone 8";
    if ([phoneModel isEqualToString:@"iPhone10,2"] ||
        [phoneModel isEqualToString:@"iPhone10,5"])     return @"iPhone 8 Plus";
    if ([phoneModel isEqualToString:@"iPhone10,3"] ||
        [phoneModel isEqualToString:@"iPhone10,6"])     return @"iPhone X";
    if ([phoneModel isEqualToString:@"iPhone11,2"])     return @"iPhone XS";
    if ([phoneModel isEqualToString:@"iPhone11,6"])     return @"iPhone XS MAX";
    if ([phoneModel isEqualToString:@"iPhone11,8"])     return @"iPhone XR";
    
    if ([phoneModel isEqualToString:@"iPad1,1"])        return @"iPad";
    if ([phoneModel isEqualToString:@"iPad2,1"] ||
        [phoneModel isEqualToString:@"iPad2,2"] ||
        [phoneModel isEqualToString:@"iPad2,3"] ||
        [phoneModel isEqualToString:@"iPad2,4"])        return @"iPad 2";
    if ([phoneModel isEqualToString:@"iPad3,1"] ||
        [phoneModel isEqualToString:@"iPad3,2"] ||
        [phoneModel isEqualToString:@"iPad3,3"])        return @"iPad 3";
    if ([phoneModel isEqualToString:@"iPad3,4"] ||
        [phoneModel isEqualToString:@"iPad3,5"] ||
        [phoneModel isEqualToString:@"iPad3,6"])        return @"iPad 4";
    if ([phoneModel isEqualToString:@"iPad4,1"] ||
        [phoneModel isEqualToString:@"iPad4,2"] ||
        [phoneModel isEqualToString:@"iPad4,3"])        return @"iPad Air";
    if ([phoneModel isEqualToString:@"iPad5,3"] ||
        [phoneModel isEqualToString:@"iPad5,4"])        return @"iPad Air 2";
    if ([phoneModel isEqualToString:@"iPad6,3"] ||
        [phoneModel isEqualToString:@"iPad6,4"])        return @"iPad Pro 9.7-inch";
    if ([phoneModel isEqualToString:@"iPad6,7"] ||
        [phoneModel isEqualToString:@"iPad6,8"])        return @"iPad Pro 12.9-inch";
    if ([phoneModel isEqualToString:@"iPad6,11"] ||
        [phoneModel isEqualToString:@"iPad6,12"])       return @"iPad 5";
    if ([phoneModel isEqualToString:@"iPad7,1"] ||
        [phoneModel isEqualToString:@"iPad7,2"])        return @"iPad Pro 12.9-inch 2";
    if ([phoneModel isEqualToString:@"iPad7,3"] ||
        [phoneModel isEqualToString:@"iPad7,4"])        return @"iPad Pro 10.5-inch";
    if ([phoneModel isEqualToString:@"iPad7,5"] ||
        [phoneModel isEqualToString:@"iPad7,6"])        return @"iPad 6";
    if ([phoneModel isEqualToString:@"iPad8,1"] ||
        [phoneModel isEqualToString:@"iPad8,2"]||
        [phoneModel isEqualToString:@"iPad8,3"]||
        [phoneModel isEqualToString:@"iPad8,4"])        return @"iPad Pro 11-inch";
    if ([phoneModel isEqualToString:@"iPad8,5"] ||
        [phoneModel isEqualToString:@"iPad8,6"]||
        [phoneModel isEqualToString:@"iPad8,7"]||
        [phoneModel isEqualToString:@"iPad8,8"])        return @"iPad Pro 12.9-inch 3";
    
    
    if ([phoneModel isEqualToString:@"iPad2,5"] ||
        [phoneModel isEqualToString:@"iPad2,6"] ||
        [phoneModel isEqualToString:@"iPad2,7"])        return @"iPad mini";
    if ([phoneModel isEqualToString:@"iPad4,4"] ||
        [phoneModel isEqualToString:@"iPad4,5"] ||
        [phoneModel isEqualToString:@"iPad4,6"])        return @"iPad mini 2";
    if ([phoneModel isEqualToString:@"iPad4,7"] ||
        [phoneModel isEqualToString:@"iPad4,8"] ||
        [phoneModel isEqualToString:@"iPad4,9"])        return @"iPad mini 3";
    if ([phoneModel isEqualToString:@"iPad5,1"] ||
        [phoneModel isEqualToString:@"iPad5,2"])        return @"iPad mini 4";
    
    if ([phoneModel isEqualToString:@"iPod1,1"])        return @"iTouch";
    if ([phoneModel isEqualToString:@"iPod2,1"])        return @"iTouch2";
    if ([phoneModel isEqualToString:@"iPod3,1"])        return @"iTouch3";
    if ([phoneModel isEqualToString:@"iPod4,1"])        return @"iTouch4";
    if ([phoneModel isEqualToString:@"iPod5,1"])        return @"iTouch5";
    if ([phoneModel isEqualToString:@"iPod7,1"])        return @"iTouch6";
    
    if ([phoneModel isEqualToString:@"i386"] ||
        [phoneModel isEqualToString:@"x86_64"])         return @"iPhone Simulator";
    
    return phoneModel;
    
}

@end
