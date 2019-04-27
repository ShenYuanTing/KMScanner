//
//  KMScannerBorder.m
//  CodeScanner
//
//  Created by Kami Sama on 2019/4/27.
//  Copyright © 2019 Kami Sama. All rights reserved.
//

#import "KMScannerBorder.h"
#import "KMScanner.h"

@interface KMScannerBorder ()

@property (nonatomic ,strong)UIImageView *scannerLine;/// 冲击波图像


@end

@implementation KMScannerBorder

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareUI];
    }
    return self;
}

#pragma mark - 扫描动画方法
/// 开始扫描动画
- (void)startScannerAnimating {
    
    [self stopScannerAnimating];
    
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:3.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [UIView setAnimationRepeatCount:MAXFLOAT];
                         
                         weakSelf.scannerLine.center = CGPointMake(weakSelf.bounds.size.width * 0.5, weakSelf.bounds.size.height);
                     } completion:nil];
}

/// 停止扫描动画
- (void)stopScannerAnimating {
    [self.scannerLine.layer removeAllAnimations];
    self.scannerLine.center = CGPointMake(self.bounds.size.width * 0.5, 0);
}

#pragma mark - 设置界面
- (void)prepareUI {
    self.clipsToBounds = YES;
    
    // 图像文件包
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForResource:@"KMScanner" withExtension:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithURL:url];
    
    // 冲击波图像
    self.scannerLine = [[UIImageView alloc] initWithImage:[self imageWithName:@"QRCodeScanLine" bundle:imageBundle]];
    
    self.scannerLine.frame = CGRectMake(0, 0, self.bounds.size.width, self.scannerLine.bounds.size.height);
    self.scannerLine.center = CGPointMake(self.bounds.size.width * 0.5, 0);
    
    [self addSubview:self.scannerLine];
    
    // 加载边框图像
    for (NSInteger i = 1; i < 5; i++) {
        NSString *imgName = [NSString stringWithFormat:@"ScanQR%zd", i];
        UIImageView *img = [[UIImageView alloc] initWithImage:[self imageWithName:imgName bundle:imageBundle]];
        
        [self addSubview:img];
        
        CGFloat offsetX = self.bounds.size.width - img.bounds.size.width;
        CGFloat offsetY = self.bounds.size.height - img.bounds.size.height;
        
        switch (i) {
            case 2:
                img.frame = CGRectOffset(img.frame, offsetX, 0);
                break;
            case 3:
                img.frame = CGRectOffset(img.frame, 0, offsetY);
                break;
            case 4:
                img.frame = CGRectOffset(img.frame, offsetX, offsetY);
                break;
            default:
                break;
        }
    }
}

- (UIImage *)imageWithName:(NSString *)imageName bundle:(NSBundle *)imageBundle {
    NSString *fileName = [NSString stringWithFormat:@"%@@2x", imageName];
    NSString *path = [imageBundle pathForResource:fileName ofType:@"png"];
    
//    return [[UIImage imageWithContentsOfFile:path] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return [UIImage imageWithContentsOfFile:path];
}
@end
