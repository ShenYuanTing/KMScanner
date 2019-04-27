//
//  KMScannerViewController.h
//  CodeScanner
//
//  Created by Kami Sama on 2019/4/27.
//  Copyright © 2019 Kami Sama. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 扫描控制器
@interface KMScannerViewController : UIViewController

/// 实例化扫描控制器
///
/// @param completion 完成回调
///
/// @return 扫描控制器
- (instancetype)initWithCompletion:(void (^)(NSString *stringValue))completion;

@end

NS_ASSUME_NONNULL_END
