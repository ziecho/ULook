//
//  UIWindow+ULook.m
//  ULook
//
//  Created by ziezheng on 2019/6/17.
//  Copyright © 2019 ziezheng. All rights reserved.
//

#import "UIWindow+ULook.h"
#import <objc/message.h>

@implementation UIWindow (ULook)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // https://github.com/SwiftKickMobile/SwiftMessages/issues/142#issuecomment-386327785
        if (UIDevice.currentDevice.systemVersion.doubleValue < 11.0) {
            Method method = class_getInstanceMethod(self, NSSelectorFromString(@"safeAreaInsets_fix"));
            IMP imp = method_getImplementation(method);
            class_addMethod(self, NSSelectorFromString(@"safeAreaInsets"), imp, method_getTypeEncoding(method));
        }
    });
}

- (UIEdgeInsets)safeAreaInsets_fix {
    return UIEdgeInsetsZero;
}

@end
