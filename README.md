# ULook
查看系统控件大小的工具，屏幕旋转、分屏会自动刷新

## 控件规则
这里整理下系统常见 UI 控件在各个系统、设备下的高度规则

**Regular & Compact**
目前屏幕宽度为 414 的手机，比如 iPhone 8 Plus、iPhone XR、iPhone XS Max，横屏下时，**标准模式**的宽度为 Regular，**放大模式**为 Compact。
宽度小于 414 的手机，比如 iPhone SE、 iPhone 8、iPhone X ，横屏下宽度始终为 Compact。

**safeAreaInsetsBottom**
iPhone 竖屏 34
iPhone 横屏 21
iPad 20

**StatusBarHeight**
非全面屏 iPhone 20
全面屏 iPhone  44
非全面屏 iPad 20
全面屏 iPad  24

**NavigationBarHeight**
iPhone 竖屏 44
iPhone 横屏 Regular  44  or Compact 32
iPad  iOS >=12 ? 50 : 44 

**TabBarHeight**
非全面屏 iPhone 竖屏    49
非全面屏 iPhone 横屏   49 
全面屏 iPhone 竖屏   49   + safeAreaBottom = 83
全面屏 iPhone 横屏  (Regular  49  or Compact  32)  + safeAreaBottom
非全面屏 iPad iOS >= 12 ? 50 : 49
全面屏 iPad 为 45 + safeAreaBottom = 65 （横竖屏一致）

**ToolBarHeight**
非全面屏 iPhone 竖屏  44
非全面屏 iPhone 横屏   Regular 44 or Compact 32
全面屏 iPhone 竖屏  44 + safeAreaBottom
全面屏 iPhone 横屏   (Regular 44 or Compact 32) + safeAreaBottom
非全面屏  iPad  iOS >=12 ? 50 : 44
全面屏     iPad   50 + safeAreaBottom = 70




## 截图
![iPhone](/ScreenShot/screenshot_iphone.png)

![iPad](/ScreenShot/screenshot_ipad.png)
