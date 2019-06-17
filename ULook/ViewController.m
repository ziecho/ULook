//
//  ViewController.m
//  ULook
//
//  Created by ziezheng on 2019/6/17.
//  Copyright © 2019 ziezheng. All rights reserved.
//

#import "ViewController.h"
#import "ULook.h"
#import "ULUtils.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property(weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic, assign) CGRect previousBounds;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ULook";
    
    self.tableView.tableFooterView = [UIView new];
    
    UIWindow *mainWindow = [UIApplication sharedApplication].delegate.window;

    // TabBar
    [self.tabBarController.tabBar ul_addAssist:[ULAssist assistWithDirection:ULAssistDirectionVertical]];
    
    // NavigationBar
    [self.navigationController.navigationBar ul_addAssist:[ULAssist assistWithDirection:ULAssistDirectionVertical color:UIColor.orangeColor locationPercent:0.7]];

    // StatusBar
    [self.navigationController.navigationBar ul_addAssist:({
        ULAssist *assist = [ULAssist assistWithDirection:ULAssistDirectionVertical color:UIColor.orangeColor locationPercent:0.9];
        assist.customBeginPoint = ^CGFloat(__kindof UIView * _Nonnull view) {
            return -[[UIApplication sharedApplication].keyWindow convertPoint:view.frame.origin fromView:view.superview].y;
        };
        assist;
    })];
    
    // NavigationBar + StatusBar
    [self.navigationController.navigationBar ul_addAssist:({
        ULAssist *assist = [ULAssist assistWithDirection:ULAssistDirectionVertical color:UIColor.orangeColor locationPercent:0.8];
        assist.customBeginPoint = ^CGFloat(__kindof UIView * _Nonnull view) {
            return -[[UIApplication sharedApplication].keyWindow convertPoint:view.frame.origin fromView:view.superview].y;
        };
        
         __weak __typeof(assist)weakAssist = assist;
        assist.customLength = ^CGFloat(__kindof UIView * _Nonnull view) {
            return -weakAssist.customBeginPoint(view);
        };
        assist;
    })];
    
    // Window width
    [[UIApplication sharedApplication].delegate.window ul_addAssist:[ULAssist assistWithDirection:ULAssistDirectionVertical color:UIColor.blueColor locationPercent:0.15]];

    // Window height
    [[UIApplication sharedApplication].delegate.window ul_addAssist:[ULAssist assistWithDirection:ULAssistDirectionHorizontal color:UIColor.blueColor locationPercent:0.4]];
    
    if (@available(iOS 11.0, *)) {
        if (mainWindow.safeAreaInsets.bottom == 0) return;
        
        // Window safeAreaInsets Top
        [mainWindow ul_addAssist:({
            ULAssist *assist = [ULAssist assistWithDirection:ULAssistDirectionVertical color:UIColor.redColor locationPercent:0.2];
            assist.customLength = ^CGFloat(UIWindow *window) {
                return window.safeAreaInsets.top;
            };
            assist;
        })];
        
         // Window safeAreaInsets bottom
        [mainWindow ul_addAssist:({
            ULAssist *assist = [ULAssist assistWithDirection:ULAssistDirectionVertical color:UIColor.redColor locationPercent:0.2];
            assist.customBeginPoint = ^CGFloat(UIWindow *window) {
                return CGRectGetHeight(window.bounds) -  window.safeAreaInsets.bottom;
            };
            assist;
        })];
        
         // Tabbar Height (Including SafeArea)
        [self.tabBarController.tabBar ul_addAssist:({
            ULAssist *assist = [ULAssist assistWithDirection:ULAssistDirectionVertical];
            assist.locationPercent = 0.6;
            assist.customLength = ^CGFloat(__kindof UIView * _Nonnull view) {
                return CGRectGetHeight(view.bounds) - view.window.safeAreaInsets.bottom;
            };
            assist;
        })];
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (@available(iOS 11.0, *)) {
        return self.view.window.safeAreaInsets.bottom > 0 ? 7 : 5;
    }
    return 7;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.textLabel.textColor = UIColor.whiteColor;
    }
    cell.textLabel.text = @(indexPath.row).stringValue;

    
    switch (indexPath.row) {
        case 0: {
            cell.textLabel.text = @"    Device Info    ";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@ %@", ULUtils .deviceModelName, UIDevice.currentDevice.systemName, UIDevice.currentDevice.systemVersion];
            cell.textLabel.layer.backgroundColor = UIColor.blueColor.CGColor;
            break;
        }
        case 1: {
            cell.textLabel.text = @"    Window Szie    ";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%zd × %zd", (NSUInteger)self.view.window.frame.size.width, (NSUInteger)self.view.window.frame.size.height];
            cell.textLabel.layer.backgroundColor = UIColor.blueColor.CGColor;
            
            break;
        }
        case 2: {
            cell.textLabel.text = @"    NavigationBar Height    ";
            cell.detailTextLabel.text = @([[UIApplication sharedApplication].keyWindow convertPoint:self.navigationController.navigationBar.frame.origin fromView:self.navigationController.navigationBar.superview].y).stringValue;
            cell.textLabel.layer.backgroundColor = UIColor.orangeColor.CGColor;
            break;
        }
        case 3: {
            cell.textLabel.text = @"    StatusBar Height    ";
            cell.detailTextLabel.text = @(self.navigationController.navigationBar.frame.size.height).stringValue;
            cell.textLabel.layer.backgroundColor = UIColor.orangeColor.CGColor;
            break;
        }
        case 4: {
            cell.textLabel.text = @"    Tabbar Height    ";
            cell.detailTextLabel.text = @(self.tabBarController.tabBar.bounds.size.height).stringValue;
            cell.textLabel.layer.backgroundColor = UIColor.orangeColor.CGColor;
            break;
        }
        case 5: {
            cell.textLabel.text = @"    Tabbar Height (Including SafeArea)     ";
            cell.detailTextLabel.text = @(self.tabBarController.tabBar.bounds.size.height).stringValue;
            cell.textLabel.layer.backgroundColor = UIColor.orangeColor.CGColor;
            break;
        }
        case 6: {
            cell.textLabel.text = @"    Window safeAreaInsets     ";
            cell.detailTextLabel.text = NSStringFromUIEdgeInsets(self.view.window.safeAreaInsets);
            cell.textLabel.layer.backgroundColor = UIColor.redColor.CGColor;
            break;
        }
    }
    
    
    [cell.textLabel sizeToFit];
    cell.textLabel.layer.cornerRadius = CGRectGetHeight(cell.textLabel.bounds) * 0.5;
    cell.textLabel.layer.masksToBounds = YES;
    
    return cell;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (!CGRectEqualToRect(self.previousBounds, self.view.bounds)) {
        [self.tableView reloadData];
    }
}


@end
