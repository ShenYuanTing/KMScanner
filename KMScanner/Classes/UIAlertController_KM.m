//
//  UIAlertController_KM.m
//  CocospodDemo
//
//  Created by Kami Sama on 2019/4/29.
//  Copyright © 2019 Kami Sama. All rights reserved.
//

#import "UIAlertController_KM.h"

#import "KMAlertView.h"


@implementation UIAlertController (KMScanner)
+ (void)showNormalAlertWithTitle:(NSString*)title
                     contentText:(NSString*)contStr
                 leftButtonTitle:(NSString*)leftstr
                rightButtonTitle:(NSString*)rightstr
                          finish:(void (^)(NSInteger index))block{
    KMAlertView *alert = [[KMAlertView alloc] initWithTitle:[title isEqualToString:@"内容左对齐"] ? @"" : title icon:[UIImage new] message:contStr textAlignment:[title isEqualToString:@"内容左对齐"] ? NSTextAlignmentLeft : NSTextAlignmentCenter delegate:nil buttonTitles:leftstr, rightstr, nil];
    alert.touchAlterButton = ^(NSInteger index){
        if (block){
            block(index);
        }
    };
    [alert show];
}

@end
