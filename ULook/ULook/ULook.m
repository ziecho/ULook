//
//  UIView+ULook.m
//  ULook
//
//  Created by ziezheng on 2019/6/17.
//  Copyright © 2019 ziezheng. All rights reserved.
//

#import "ULook.h"
#import "QMUIRuntime.h"

CG_INLINE CGFloat
flat(CGFloat floatValue) {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat flattedValue = ceil(floatValue * scale) / scale;
    return flattedValue;
}

@implementation ULAssist

+ (instancetype)assistWithDirection:(ULAssistDirection)direction {
    return [self assistWithDirection:direction color:UIColor.orangeColor locationPercent:0.5];
}

+ (instancetype)assistWithDirection:(ULAssistDirection)direction color:(UIColor *)color locationPercent:(CGFloat)locationPercent {
    ULAssist *assist = [ULAssist new];
    assist.direction = direction;
    assist.locationPercent =locationPercent;
    assist.color = color;
    return assist;
}
@end


@interface ULAssistView : UIView

@property(nonatomic, strong) ULAssist *assist;

@end

@interface UIView (ULook_Private)

@property(nonatomic, readonly) NSMutableArray *ul_assists;

@end

@implementation UIView (ULook)


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfVoidMethodWithoutArguments([UIView class], @selector(layoutSubviews), ^(UIView *selfObject) {
            [selfObject ul_layoutAssists];
        });
        
        ExtendImplementationOfVoidMethodWithoutArguments(NSClassFromString(@"UIStatusBar_Placeholder"), @selector(setBounds:), ^(UIView *selfObject) {
            [selfObject ul_layoutAssists];
        });
        
    });
}

- (void)ul_addAssist:(ULAssist *)assist {
    [self.ul_assists addObject:assist];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)ul_removeAssist:(ULAssist *)assist {
    [self.ul_assists removeObject:assist];
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[ULAssistView class]] && ((ULAssistView *)subView).assist == assist) {
            [subView removeFromSuperview];
        }
    }
}

- (void)ul_removeAllAssists {
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[ULAssistView class]]) {
            [subView removeFromSuperview];
        }
    }
}

- (void)ul_layoutAssists {
    [self ul_removeAllAssists];
    
    for (ULAssist *assist in self.ul_assists) {
        ULAssistView *view = [ULAssistView new];
        view.assist = assist;
        if (assist.direction == ULAssistDirectionVertical) {
            CGFloat x = flat(CGRectGetWidth(self.bounds) * assist.locationPercent);
            CGFloat height = CGRectGetHeight(self.bounds);
            view.frame = CGRectMake(x, 0, 0.5, height);
        } else {
            CGFloat y = flat(CGRectGetHeight(self.bounds) * assist.locationPercent);
            CGFloat width = CGRectGetWidth(self.bounds);
            view.frame = CGRectMake(0, y, width, 0.5);
        }
        
        [self addSubview:view];
    }
}
- (NSMutableArray *)ul_assists {
    id array = objc_getAssociatedObject(self, _cmd);
    if (!array) {
        array = @[].mutableCopy;
        objc_setAssociatedObject(self, _cmd, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return array;
}

@end

@interface ULAssistView()

@property(nonatomic, strong) UILabel *label;
@property(nonatomic, strong) CALayer *beginLayer;
@property(nonatomic, strong) CALayer *lineLayer;
@property(nonatomic, strong) CALayer *endLayer;

@end

@implementation ULAssistView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self.layer addSublayer:({
            _beginLayer = [CALayer new];
            _beginLayer;
        })];
        
        [self.layer addSublayer:({
            _lineLayer = [CALayer new];
            _lineLayer;
        })];
        
        [self.layer addSublayer:({
            _endLayer = [CALayer new];
            _endLayer;
        })];
        [self addSubview:({
            _label = [[UILabel alloc] init];
            _label.backgroundColor = UIColor.whiteColor;
            _label.text = @"0";
            _label.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
            _label.textAlignment = NSTextAlignmentCenter;
            _label.textColor = UIColor.whiteColor;
            [_label sizeToFit];
            _label.layer.cornerRadius = CGRectGetHeight(_label.bounds) * 0.5;
            _label.layer.masksToBounds = YES;
            _label;
        })];
    }
    return self;
}

- (void)setAssist:(ULAssist *)assist {
    _assist = assist;
    
    self.label.backgroundColor = assist.color;
    self.beginLayer.backgroundColor = assist.color.CGColor;
    self.lineLayer.backgroundColor = assist.color.CGColor;
    self.endLayer.backgroundColor = assist.color.CGColor;
}

- (void)layoutSubviews {
    CGFloat beginPoint = self.assist.customBeginPoint ? self.assist.customBeginPoint(self) : 0;
    CGFloat length = 0;
    if (self.assist.customLength) {
        length = self.assist.customLength(self);
    } else {
        length = self.assist.direction == ULAssistDirectionVertical ? CGRectGetHeight(self.bounds) - beginPoint : CGRectGetWidth(self.bounds) - beginPoint;
    }
    
    self.label.text = @(length).stringValue;
    [self.label sizeToFit];
    self.label.frame = ({
        CGRect frame = self.label.frame;
        frame.size.width += 10;
        if (self.assist.direction == ULAssistDirectionVertical) {
            frame.origin.y = beginPoint + length * 0.5 - CGRectGetHeight(self.label.bounds) * 0.5;
            frame.origin.x = -frame.size.width * 0.5;
        } else {
            frame.origin.x = beginPoint + length * 0.5 - CGRectGetWidth(self.label.bounds) * 0.5;
            frame.origin.y = -frame.size.height * 0.5;
        }
        frame;
    });
    
    self.lineLayer.frame = ({
        CGRect frame = self.bounds;
        if (self.assist.direction == ULAssistDirectionVertical) {
            frame.origin.y += beginPoint;
            frame.size.height = length;
        } else {
            frame.origin.x += beginPoint;
            frame.size.width = length;
        }
        frame;
    });
    
    if (self.assist.direction == ULAssistDirectionVertical) {
        self.beginLayer.frame = CGRectMake(self.label.center.x - 10, beginPoint, 20, 1);
        self.endLayer.frame = CGRectMake(self.label.center.x - 10, beginPoint + length - 1, 20, 1);
    } else {
        self.beginLayer.frame = CGRectMake(0, self.label.center.y - 10, 1, 20);
        self.beginLayer.frame = CGRectMake(CGRectGetWidth(self.bounds), self.label.center.y - 10, 1, 20);
    }
}

@end
