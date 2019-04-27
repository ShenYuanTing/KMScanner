//
//  KMScannerBorder.h
//  CodeScanner
//
//  Created by Kami Sama on 2019/4/27.
//  Copyright © 2019 Kami Sama. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 扫描框视图
@interface KMScannerBorder : UIView

/// 开始扫描动画
- (void)startScannerAnimating;
/// 停止扫描动画
- (void)stopScannerAnimating;

@end

NS_ASSUME_NONNULL_END
