//
//  KMScannerMaskView.h
//  CodeScanner
//
//  Created by Kami Sama on 2019/4/27.
//  Copyright © 2019 Kami Sama. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 扫描遮罩视图
@interface KMScannerMaskView : UIView
/// 使用裁切区域实例化遮罩视图
///
/// @param frame    视图区域
/// @param cropRect 裁切区域
///
/// @return 遮罩视图
+ (instancetype)maskViewWithFrame:(CGRect)frame cropRect:(CGRect)cropRect;

/// 裁切区域
@property (nonatomic) CGRect cropRect;
@end

NS_ASSUME_NONNULL_END
