//
//  UIView+ULook.h
//  ULook
//
//  Created by ziezheng on 2019/6/17.
//  Copyright © 2019 ziezheng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ULAssistDirection) {
    ULAssistDirectionVertical             = 0,
    ULAssistDirectionHorizontal           = 1,
};

@interface ULAssist : NSObject

@property(nonatomic, assign) ULAssistDirection direction;

@property(nonatomic, strong) UIColor *color;

@property(nonatomic, assign) CGFloat locationPercent;

@property(nonatomic, copy) CGFloat(^customBeginPoint)(__kindof UIView *view);

@property(nonatomic, copy) CGFloat(^customLength)(__kindof UIView *view);

+ (instancetype)assistWithDirection:(ULAssistDirection)direction;

+ (instancetype)assistWithDirection:(ULAssistDirection)direction color:(UIColor *)color locationPercent:(CGFloat)locationPercent;

@end


@interface UIView (ULook)

- (void)ul_addAssist:(ULAssist *)assist;

@end

NS_ASSUME_NONNULL_END
