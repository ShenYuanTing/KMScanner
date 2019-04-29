//
//  UIAlertController_KM.h
//  CocospodDemo
//
//  Created by Kami Sama on 2019/4/29.
//  Copyright © 2019 Kami Sama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (KMScanner)
+ (void)showNormalAlertWithTitle:(NSString*)title
                     contentText:(NSString*)contStr
                 leftButtonTitle:(NSString*)leftstr
                rightButtonTitle:(NSString*)rightstr
                          finish:(void (^)(NSInteger index))block;
@end
