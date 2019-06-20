//
//  QMUIHelper.m
//  ULook
//
//  Created by ziezheng on 2019/6/17.
//  Copyright © 2019 ziezheng. All rights reserved.
//

#import "QMUIHelper.h"
#import <sys/utsname.h>
#import <objc/message.h>

@implementation NSObject (QMUI)

- (id)qmui_performSelector:(SEL)selector withArguments:(void *)firstArgument, ... {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    
    if (firstArgument) {
        va_list valist;
        va_start(valist, firstArgument);
        [invocation setArgument:firstArgument atIndex:2];// 0->self, 1->_cmd
        
        void *currentArgument;
        NSInteger index = 3;
        while ((currentArgument = va_arg(valist, void *))) {
            [invocation setArgument:currentArgument atIndex:index];
            index++;
        }
        va_end(valist);
    }
    
    [invocation invoke];
    
    const char *typeEncoding = method_getTypeEncoding(class_getInstanceMethod(object_getClass(self), selector));
    if (strncmp(typeEncoding, "@", 1) == 0) {
        __unsafe_unretained id returnValue;
        [invocation getReturnValue:&returnValue];
        return returnValue;
    }
    return nil;
}

- (void)qmui_performSelector:(SEL)selector withPrimitiveReturnValue:(void *)returnValue {
    [self qmui_performSelector:selector withPrimitiveReturnValue:returnValue arguments:nil];
}

- (void)qmui_performSelector:(SEL)selector withPrimitiveReturnValue:(void *)returnValue arguments:(void *)firstArgument, ... {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    
    if (firstArgument) {
        va_list valist;
        va_start(valist, firstArgument);
        [invocation setArgument:firstArgument atIndex:2];// 0->self, 1->_cmd
        
        void *currentArgument;
        NSInteger index = 3;
        while ((currentArgument = va_arg(valist, void *))) {
            [invocation setArgument:currentArgument atIndex:index];
            index++;
        }
        va_end(valist);
    }
    
    [invocation invoke];
    
    if (returnValue) {
        [invocation getReturnValue:returnValue];
    }
}

@end

@implementation QMUIHelper

static NSInteger isIPhone = -1;
+ (BOOL)isIPhone {
    if (isIPhone < 0) {
        NSString *string = [[UIDevice currentDevice] model];
        isIPhone = [string rangeOfString:@"iPhone"].location != NSNotFound ? 1 : 0;
    }
    return isIPhone > 0;
}

+ (BOOL)isZoomedMode {
    if (![self isIPhone]) {
        return NO;
    }
    
    CGFloat nativeScale = UIScreen.mainScreen.nativeScale;
    CGFloat scale = UIScreen.mainScreen.scale;
    
    // 对于所有的 Plus 系列 iPhone，屏幕物理像素低于软件层面的渲染像素，不管标准模式还是放大模式，nativeScale 均小于 scale，所以需要特殊处理才能准确区分放大模式
    // https://www.paintcodeapp.com/news/ultimate-guide-to-iphone-resolutions
    BOOL shouldBeDownsampledDevice = CGSizeEqualToSize(UIScreen.mainScreen.nativeBounds.size, CGSizeMake(1080, 1920));
    if (shouldBeDownsampledDevice) {
        scale /= 1.15;
    }
    
    return nativeScale > scale;
}

+ (BOOL)isRegularScreen {
    return [self isIPad] || (![self isZoomedMode] && ([self is65InchScreen] || [self is61InchScreen] || [self is55InchScreen]));
}

static NSInteger isIPad = -1;
+ (BOOL)isIPad {
    if (isIPad < 0) {
        // [[[UIDevice currentDevice] model] isEqualToString:@"iPad"] 无法判断模拟器 iPad，所以改为以下方式
        isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 1 : 0;
    }
    return isIPad > 0;
}

static NSInteger isNotchedScreen = -1;
+ (BOOL)isNotchedScreen {
    if (@available(iOS 11, *)) {
        if (isNotchedScreen < 0) {
            if (@available(iOS 12.0, *)) {
                /*
                 检测方式解释/测试要点：
                 1. iOS 11 与 iOS 12 可能行为不同，所以要分别测试。
                 2. 与触发 [QMUIHelper isNotchedScreen] 方法时的进程有关，例如 https://github.com/Tencent/QMUI_iOS/issues/482#issuecomment-456051738 里提到的 [NSObject performSelectorOnMainThread:withObject:waitUntilDone:NO] 就会导致较多的异常。
                 3. iOS 12 下，在非第2点里提到的情况下，iPhone、iPad 均可通过 UIScreen -_peripheryInsets 方法的返回值区分，但如果满足了第2点，则 iPad 无法使用这个方法，这种情况下要依赖第4点。
                 4. iOS 12 下，不管是否满足第2点，不管是什么设备类型，均可以通过一个满屏的 UIWindow 的 rootViewController.view.frame.origin.y 的值来区分，如果是非全面屏，这个值必定为20，如果是全面屏，则可能是24或44等不同的值。但由于创建 UIWindow、UIViewController 等均属于较大消耗，所以只在前面的步骤无法区分的情况下才会使用第4点。
                 5. 对于第4点，经测试与当前设备的方向、是否有勾选 project 里的 General - Hide status bar、当前是否处于来电模式的状态栏这些都没关系。
                 */
                SEL peripheryInsetsSelector = NSSelectorFromString([NSString stringWithFormat:@"_%@%@", @"periphery", @"Insets"]);
                UIEdgeInsets peripheryInsets = UIEdgeInsetsZero;
                [[UIScreen mainScreen] qmui_performSelector:peripheryInsetsSelector withPrimitiveReturnValue:&peripheryInsets];
                if (peripheryInsets.bottom <= 0) {
                    UIWindow *window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
                    peripheryInsets = window.safeAreaInsets;
                    if (peripheryInsets.bottom <= 0) {
                        UIViewController *viewController = [UIViewController new];
                        [viewController loadViewIfNeeded];
                        window.rootViewController = viewController;
                        if (CGRectGetMinY(viewController.view.frame) > 20) {
                            peripheryInsets.bottom = 1;
                        }
                    }
                }
                isNotchedScreen = peripheryInsets.bottom > 0 ? 1 : 0;
            } else {
                isNotchedScreen = [self is58InchScreen] ? 1 : 0;
            }
        }
    } else {
        isNotchedScreen = 0;
    }
    
    return isNotchedScreen > 0;
}


static NSInteger is65InchScreen = -1;
+ (BOOL)is65InchScreen {
    if (is65InchScreen < 0) {
        // Since iPhone XS Max and iPhone XR share the same resolution, we have to distinguish them using the model identifiers
        // 由于 iPhone XS Max 和 iPhone XR 的屏幕宽高是一致的，我们通过机器 Identifier 加以区别
        is65InchScreen = (DEVICE_WIDTH == self.screenSizeFor65Inch.width && DEVICE_HEIGHT == self.screenSizeFor65Inch.height && ([[self deviceModel] isEqualToString:@"iPhone11,4"] || [[self deviceModel] isEqualToString:@"iPhone11,6"])) ? 1 : 0;
    }
    return is65InchScreen > 0;
}

static NSInteger is61InchScreen = -1;
+ (BOOL)is61InchScreen {
    if (is61InchScreen < 0) {
        is61InchScreen = (DEVICE_WIDTH == self.screenSizeFor61Inch.width && DEVICE_HEIGHT == self.screenSizeFor61Inch.height && [[self deviceModel] isEqualToString:@"iPhone11,8"]) ? 1 : 0;
    }
    return is61InchScreen > 0;
}

static NSInteger is58InchScreen = -1;
+ (BOOL)is58InchScreen {
    if (is58InchScreen < 0) {
        // Both iPhone XS and iPhone X share the same actual screen sizes, so no need to compare identifiers
        // iPhone XS 和 iPhone X 的物理尺寸是一致的，因此无需比较机器 Identifier
        is58InchScreen = (DEVICE_WIDTH == self.screenSizeFor58Inch.width && DEVICE_HEIGHT == self.screenSizeFor58Inch.height) ? 1 : 0;
    }
    return is58InchScreen > 0;
}

static NSInteger is55InchScreen = -1;
+ (BOOL)is55InchScreen {
    if (is55InchScreen < 0) {
        is55InchScreen = (DEVICE_WIDTH == self.screenSizeFor55Inch.width && DEVICE_HEIGHT == self.screenSizeFor55Inch.height) ? 1 : 0;
    }
    return is55InchScreen > 0;
}

static NSInteger is47InchScreen = -1;
+ (BOOL)is47InchScreen {
    if (is47InchScreen < 0) {
        is47InchScreen = (DEVICE_WIDTH == self.screenSizeFor47Inch.width && DEVICE_HEIGHT == self.screenSizeFor47Inch.height) ? 1 : 0;
    }
    return is47InchScreen > 0;
}

static NSInteger is40InchScreen = -1;
+ (BOOL)is40InchScreen {
    if (is40InchScreen < 0) {
        is40InchScreen = (DEVICE_WIDTH == self.screenSizeFor40Inch.width && DEVICE_HEIGHT == self.screenSizeFor40Inch.height) ? 1 : 0;
    }
    return is40InchScreen > 0;
}

static NSInteger is35InchScreen = -1;
+ (BOOL)is35InchScreen {
    if (is35InchScreen < 0) {
        is35InchScreen = (DEVICE_WIDTH == self.screenSizeFor35Inch.width && DEVICE_HEIGHT == self.screenSizeFor35Inch.height) ? 1 : 0;
    }
    return is35InchScreen > 0;
}

+ (CGSize)screenSizeFor65Inch {
    return CGSizeMake(414, 896);
}

+ (CGSize)screenSizeFor61Inch {
    return CGSizeMake(414, 896);
}

+ (CGSize)screenSizeFor58Inch {
    return CGSizeMake(375, 812);
}

+ (CGSize)screenSizeFor55Inch {
    return CGSizeMake(414, 736);
}

+ (CGSize)screenSizeFor47Inch {
    return CGSizeMake(375, 667);
}

+ (CGSize)screenSizeFor40Inch {
    return CGSizeMake(320, 568);
}

+ (CGSize)screenSizeFor35Inch {
    return CGSizeMake(320, 480);
}

static NSInteger isSimulator = -1;
+ (BOOL)isSimulator {
    if (isSimulator < 0) {
#if TARGET_OS_SIMULATOR
        isSimulator = 1;
#else
        isSimulator = 0;
#endif
    }
    return isSimulator > 0;
}

+ (UIEdgeInsets)safeAreaInsetsForDeviceWithNotch {
    if (![self isNotchedScreen]) {
        return UIEdgeInsetsZero;
    }
    
    if ([self isIPad]) {
        return UIEdgeInsetsMake(0, 0, 20, 0);
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return UIEdgeInsetsMake(44, 0, 34, 0);
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return UIEdgeInsetsMake(34, 0, 44, 0);
            
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return UIEdgeInsetsMake(0, 44, 21, 44);
            
        case UIInterfaceOrientationUnknown:
        default:
            return UIEdgeInsetsMake(44, 0, 34, 0);
    }
}


+ (NSString *)deviceModel {
    if ([self isSimulator]) {
        // Simulator doesn't return the identifier for the actual physical model, but returns it as an environment variable
        // 模拟器不返回物理机器信息，但会通过环境变量的方式返回
        return [NSString stringWithFormat:@"%s", getenv("SIMULATOR_MODEL_IDENTIFIER")];
    }
    
    // See https://www.theiphonewiki.com/wiki/Models for identifiers
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

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
