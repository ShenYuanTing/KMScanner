//
//  KM_Config.h
//  CocospodDemo
//
//  Created by Kami Sama on 2019/4/29.
//  Copyright © 2019 Kami Sama. All rights reserved.
//

#ifndef KM_Config_h
#define KM_Config_h

#define TITLE_FONT_SIZE 18
#define MESSAGE_FONT_SIZE 15
#define BUTTON_FONT_SIZE 16
#define MARGIN_TOP 20
#define MARGIN_LEFT_LARGE 25
#define MARGIN_LEFT_SMALL 15
#define MARGIN_RIGHT_LARGE 25
#define MARGIN_RIGHT_SMALL 15
#define SPACE_LARGE 20
#define SPACE_SMALL 5
#define MESSAGE_LINE_SPACE 5

#define KM_BaseColor  KM_HEXCOLOR(0x6293f9)

#define KM_ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define KM_ScreenHeight                        [[UIScreen mainScreen] bounds].size.height

#define KM_RGBA(r, g, b, a)                    [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define KM_RGB(r, g, b)                        KM_RGBA(r, g, b, 1.0f)

//UIColor 使用十六进制
#define KM_HEXCOLOR(hexColor)  [UIColor colorWithRed:((float)((hexColor & 0xFF0000) >> 16))/255.0 green:((float)((hexColor & 0xFF00) >> 8))/255.0 blue:((float)(hexColor & 0xFF))/255.0 alpha:1]

#define KM_Color333  KM_HEXCOLOR(0x333333)//用于文字


/// 最大检测次数
#define kMaxDetectedCount   20

#define inputMessage @"inputMessage"

/// 控件间距
#define kControlMargin  42.0
/// 相册图片最大尺寸
#define kImageMaxSize   CGSizeMake(1000, 1000)

#define BRIGHTLIMIT 80//屏幕亮度临界值 低于显示手电筒按钮


#endif /* KM_Config_h */
