//
//  KMAlertView.h
//  CocospodDemo
//
//  Created by Kami Sama on 2019/4/29.
//  Copyright © 2019 Kami Sama. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KMScanner)
/// 获取当前控制器
- (UIViewController *)SG_getCurrentViewController;

@end

@class KMAlertView;

@protocol KMAlertViewDelegate <NSObject>

- (void)alertView:(KMAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface KMAlertView : UIView

@property (strong, nonatomic) UIView *contentView;
@property (assign, nonatomic) BOOL isCanUserInterface;
@property (strong, nonatomic) UIImage *icon;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *message;
@property (copy, nonatomic)void(^touchAlterButton)(NSInteger index);
@property (weak, nonatomic) id<KMAlertViewDelegate> delegate;

- (instancetype)initWithTitle:(NSString * __nullable)title icon:(UIImage *__nullable)icon message:(NSString *__nullable)message textAlignment:(NSTextAlignment)textAlignment delegate:(__nullable id<KMAlertViewDelegate>)delegate buttonTitles:(NSString *__nullable)buttonTitles, ... NS_REQUIRES_NIL_TERMINATION;

// Show the alert view in current window
- (void)show;
- (void)showInCurrentVC:(UIViewController *)vc;
- (void)showInCurrentView:(UIView *)view;

// Hide the alert view
- (void)hide;

// Set the color and font size of title, if color is nil, default is black. if fontsize is 0, default is 14
- (void)setTitleColor:(UIColor *)color fontSize:(CGFloat)size;

// Set the color and font size of message, if color is nil, default is black. if fontsize is 0, default is 12
- (void)setMessageColor:(UIColor *)color fontSize:(CGFloat)size;

// Set the color and font size of button at the index, if color is nil, default is black. if fontsize is 0, default is 16
- (void)setButtonTitleColor:(UIColor *)color fontSize:(CGFloat)size atIndex:(NSInteger)index;


@end

NS_ASSUME_NONNULL_END
