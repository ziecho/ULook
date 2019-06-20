//
//  QMUIHelper.h
//  ULook
//
//  Created by ziezheng on 2019/6/17.
//  Copyright © 2019 ziezheng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define IS_IPAD [QMUIHelper isIPad]

#define IOS_VERSION ([[[UIDevice currentDevice] systemVersion] doubleValue])

/// 将所有屏幕按照宽松/紧凑分类，其中 iPad、iPhone XS Max/XR/Plus 均为宽松屏幕，但开启了放大模式的设备均会视为紧凑屏幕
#define PreferredValueForVisualDevice(_regular, _compact) ([QMUIHelper isRegularScreen] ? _regular : _compact)
/// 区分全面屏（iPhone X 系列）和非全面屏
#define PreferredValueForNotchedDevice(_notchedDevice, _otherDevice) ([QMUIHelper isNotchedScreen] ? _notchedDevice : _otherDevice)
/// 是否全面屏设备
#define IS_NOTCHED_SCREEN [QMUIHelper isNotchedScreen]
/// 用户界面横屏了才会返回YES
#define IS_LANDSCAPE UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])
/// 屏幕宽度，跟横竖屏无关
#define DEVICE_WIDTH (IS_LANDSCAPE ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)
/// 屏幕高度，跟横竖屏无关
#define DEVICE_HEIGHT (IS_LANDSCAPE ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)

/// iPhoneX 系列全面屏手机的安全区域的静态值
#define SafeAreaInsetsConstantForDeviceWithNotch [QMUIHelper safeAreaInsetsForDeviceWithNotch]

/// toolBar相关frame
#define ToolBarHeight (IS_IPAD ? (IS_NOTCHED_SCREEN ? 70 : (IOS_VERSION >= 12.0 ? 50 : 44)) : (IS_LANDSCAPE ? PreferredValueForVisualDevice(44, 32) : 44) + SafeAreaInsetsConstantForDeviceWithNotch.bottom)

/// tabBar相关frame
#define TabBarHeight (IS_IPAD ? (IS_NOTCHED_SCREEN ? 65 : (IOS_VERSION >= 12.0 ? 50 : 49)) : PreferredValueForNotchedDevice(IS_LANDSCAPE ? PreferredValueForVisualDevice(49, 32) : 49, 49) + SafeAreaInsetsConstantForDeviceWithNotch.bottom)

/// 状态栏高度(来电等情况下，状态栏高度会发生变化，所以应该实时计算)
#define StatusBarHeight ([UIApplication sharedApplication].statusBarHidden ? 0 : [[UIApplication sharedApplication] statusBarFrame].size.height)

/// 状态栏高度(如果状态栏不可见，也会返回一个普通状态下可见的高度)
#define StatusBarHeightConstant ([UIApplication sharedApplication].statusBarHidden ? (IS_IPAD ? (IS_NOTCHED_SCREEN ? 24 : 20) : PreferredValueForNotchedDevice(IS_LANDSCAPE ? 0 : 44, 20)) : [[UIApplication sharedApplication] statusBarFrame].size.height)

/// navigationBar 的静态高度

#define NavigationBarHeight (IS_IPAD ? (IOS_VERSION >= 12.0 ? 50 : 44) : (IS_LANDSCAPE ? PreferredValueForVisualDevice(44, 32) : 44))

/// 代表(导航栏+状态栏)，这里用于获取其高度
/// @warn 如果是用于 viewController，请使用 UIViewController(QMUI) qmui_navigationBarMaxYInViewCoordinator 代替
#define NavigationContentTop (StatusBarHeight + NavigationBarHeight)

/// 同上，这里用于获取它的静态常量值
#define NavigationContentTopConstant (StatusBarHeightConstant + NavigationBarHeight)

@interface QMUIHelper : NSObject

+ (BOOL)isIPad;

+ (BOOL)isNotchedScreen;

+ (BOOL)isRegularScreen;

+ (NSString *)deviceModelName;

+ (UIEdgeInsets)safeAreaInsetsForDeviceWithNotch;

@end

NS_ASSUME_NONNULL_END
