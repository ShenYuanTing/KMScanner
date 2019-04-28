//
//  KMScannerViewController.m
//  CodeScanner
//
//  Created by Kami Sama on 2019/4/27.
//  Copyright © 2019 Kami Sama. All rights reserved.
//

#import "KMScannerViewController.h"
#import "KMScannerBorder.h"
#import "KMScannerMaskView.h"
#import "KMScanner.h"

/// 控件间距
#define kControlMargin  42.0
/// 相册图片最大尺寸
#define kImageMaxSize   CGSizeMake(1000, 1000)

@interface KMScannerViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
/// 完成回调
@property (nonatomic, copy) void (^completionCallBack)(NSString *);

@property (nonatomic,strong) UIButton *torchBtn;;

@end

@implementation KMScannerViewController {
    /// 扫描框
    KMScannerBorder *_scannerBorder;
    /// 扫描器
    KMScanner *_scanner;
    /// 提示标签
    UILabel *_tipLabel;
    
    
    BOOL _isOpen;
}

-(instancetype) initWithCompletion:(void (^)(NSString * _Nonnull))completion{
    self = [super init];
    if (self) {
        self.completionCallBack = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
    
    // 实例化扫描器
    __weak typeof(self) weakSelf = self;
    _scanner = [KMScanner scanerWithView:self.view scanFrame:_scannerBorder.frame completion:^(NSString *stringValue) {
        // 完成回调
        weakSelf.completionCallBack(stringValue);
        
        // 关闭
        [weakSelf clickCloseButton];
    }];
    
    ///添加获取图像亮度值
    __weak typeof(_scanner) weakScanner = _scanner;
    [_scanner addCaptureImage:^(int bright) {
        if (bright > 40) {
            if (weakScanner.isTorchOpen) {
                return;
            }
            weakSelf.torchBtn.hidden = YES;
        } else {
            weakSelf.torchBtn.hidden = NO;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_scannerBorder startScannerAnimating];
    [_scanner startScan];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_scannerBorder stopScannerAnimating];
    [_scanner stopScan];
}

#pragma mark - 监听方法
/// 点击关闭按钮´
- (void)clickCloseButton {
    NSArray *viewcontrollers = self.navigationController.viewControllers;
    if (viewcontrollers.count > 1) {
        if ([viewcontrollers objectAtIndex:viewcontrollers.count - 1] == self) {//push
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }

}

/// 点击相册按钮
- (void)clickAlbumButton {
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        _tipLabel.text = @"无法访问相册";
        
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.view.backgroundColor = [UIColor whiteColor];
    picker.delegate = self;
    
    [self showDetailViewController:picker sender:nil];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = [self resizeImage:info[UIImagePickerControllerOriginalImage]];
    
    // 扫描图像
    [KMScanner scaneImage:image completion:^(NSArray *values) {
        
        if (values.count > 0) {
            self.completionCallBack(values.firstObject);
            [self dismissViewControllerAnimated:NO completion:^{
                [self clickCloseButton];
            }];
        } else {
            self->_tipLabel.text = @"没有识别到二维码，请选择其他照片";
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (UIImage *)resizeImage:(UIImage *)image {
    
    if (image.size.width < kImageMaxSize.width && image.size.height < kImageMaxSize.height) {
        return image;
    }
    
    CGFloat xScale = kImageMaxSize.width / image.size.width;
    CGFloat yScale = kImageMaxSize.height / image.size.height;
    CGFloat scale = MIN(xScale, yScale);
    CGSize size = CGSizeMake(image.size.width * scale, image.size.height * scale);
    
    UIGraphicsBeginImageContext(size);
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

#pragma mark - 设置界面
- (void)prepareUI {
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    [self prepareNavigationBar];
    [self prepareScanerBorder];
    [self prepareOtherControls];
}

/// 准备提示标签和名片按钮
- (void)prepareOtherControls {
    
    // 1> 提示标签
    _tipLabel = [[UILabel alloc] init];
    
    _tipLabel.text = @"将二维码/条码放入框中，即可自动扫描";
    _tipLabel.font = [UIFont systemFontOfSize:13];
    _tipLabel.textColor = [UIColor whiteColor];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    
    [_tipLabel sizeToFit];
    _tipLabel.center = CGPointMake(_scannerBorder.center.x, CGRectGetMaxY(_scannerBorder.frame) + kControlMargin);
    
    [self.view addSubview:_tipLabel];
    
    
    _torchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _torchBtn.frame = CGRectMake(0, 0, _scannerBorder.bounds.size.width/3, _scannerBorder.bounds.size.width/3);
    _torchBtn.center = CGPointMake(_scannerBorder.bounds.size.width * 0.5, 4*_scannerBorder.bounds.size.width/5);
    [_torchBtn setImageEdgeInsets:UIEdgeInsetsMake(0, _torchBtn.frame.size.width*0.4, _torchBtn.frame.size.height*0.4, 0)];
    [_torchBtn setTitleEdgeInsets:UIEdgeInsetsMake(_torchBtn.frame.size.height/4, -_torchBtn.frame.size.width*0.1, 0, 0)];
    [_torchBtn setTitle:@"轻触照亮" forState:UIControlStateNormal];
    _torchBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForResource:@"KMScanner" withExtension:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithURL:url];
    UIImage *btnImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"QRCodeTorch@2x" ofType:@"png"]];
    [_torchBtn setImage:btnImage forState:UIControlStateNormal];
    _torchBtn.adjustsImageWhenHighlighted = NO;
    [_torchBtn addTarget:self action:@selector(torchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_scannerBorder addSubview:_torchBtn];
    
    _isOpen = NO;
    _torchBtn.hidden = YES;
}

/// 准备扫描框
- (void)prepareScanerBorder {
    
    CGFloat width = self.view.bounds.size.width - 80;
    _scannerBorder = [[KMScannerBorder alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    
    _scannerBorder.center = self.view.center;
    _scannerBorder.tintColor = self.navigationController.navigationBar.tintColor;
    
    [self.view addSubview:_scannerBorder];
    
    KMScannerMaskView *maskView = [KMScannerMaskView maskViewWithFrame:self.view.bounds cropRect:_scannerBorder.frame];
    [self.view insertSubview:maskView atIndex:0];
}

/// 准备导航栏
- (void)prepareNavigationBar {
    // 1> 背景颜色
//    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithWhite:0.1 alpha:0.1]];
//    self.navigationController.navigationBar.translucent = YES;
//    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    // 2> 标题
    self.title = @"扫一扫";
    
    // 3> 左右按钮
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(clickCloseButton)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(clickAlbumButton)];
}

/// 手电筒按钮
- (void)torchBtnClick {
    _isOpen = !_isOpen;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForResource:@"KMScanner" withExtension:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithURL:url];
    if (_isOpen) {
        NSString *path = [imageBundle pathForResource:@"QRCodeTorch@2x" ofType:@"png"];
//        UIImage *openImage = [[UIImage imageWithContentsOfFile:path] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage *openImage = [UIImage imageWithContentsOfFile:path];
        [_torchBtn setImage:openImage forState:UIControlStateNormal];
        [_torchBtn setTitle:@"轻触关闭" forState:UIControlStateNormal];
        [_scanner setTorch:YES];
    }
    else {
        [_torchBtn setTitle:@"轻触照亮" forState:UIControlStateNormal];
        UIImage *btnImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"QRCodeTorch@2x" ofType:@"png"]];
        [_torchBtn setImage:btnImage forState:UIControlStateNormal];
        [_scanner setTorch:NO];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end