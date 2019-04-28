//
//  KMScanner.m
//  CodeScanner
//
//  Created by Kami Sama on 2019/4/27.
//  Copyright © 2019 Kami Sama. All rights reserved.
//

#import "KMScanner.h"
#import "KMScannerViewController.h"
#import <AVFoundation/AVFoundation.h>

/// 最大检测次数
#define kMaxDetectedCount   20

#define inputMessage @"inputMessage"

@interface KMScanner() <AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>
/// 父视图弱引用
@property (nonatomic, weak) UIView *parentView;
/// 扫描范围
@property (nonatomic) CGRect scanFrame;
/// 完成回调
@property (nonatomic, copy) void (^completionCallBack)(NSString *);

@property (nonatomic, copy) void (^brightBlock)(int bright);

@end

@implementation KMScanner {
    ///设备
    AVCaptureDevice *_device;
    /// 拍摄会话
    AVCaptureSession *_session;
    /// 预览图层
    AVCaptureVideoPreviewLayer *_previewLayer;
    /// 绘制图层
    CALayer *_drawLayer;
    /// 当前检测计数
    NSInteger _currentDetectedCount;
    
    //    // 图像捕捉输出
    //    AVCaptureStillImageOutput * _stillImageOutput;
    //    //捕获时钟
    //    NSTimer * _brightTimer;
    
    AVCaptureVideoDataOutput * _videoOutput;
}

+ (UIViewController *)initWithCompletion:(void (^)(NSString *stringValue))completion{
    KMScannerViewController *scanner = [[KMScannerViewController alloc] initWithCompletion:completion];
    return scanner;
}

#pragma mark - 生成二维码
+ (void)qrImageWithAvatar:(UIImage *)avatar completion:(void (^)(UIImage *))completion {
    [self qrImageWithAvatar:avatar scale:0.20 completion:completion];
}

+ (void)qrImageWithAvatar:(UIImage *)avatar scale:(CGFloat)scale completion:(void (^)(UIImage *))completion {
    
    NSAssert(completion != nil, @"必须传入完成回调");
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        
        [qrFilter setDefaults];
        [qrFilter setValue:[inputMessage dataUsingEncoding:NSUTF8StringEncoding] forKey:@"inputMessage"];
        
        CIImage *ciImage = qrFilter.outputImage;
        
        CGAffineTransform transform = CGAffineTransformMakeScale(10, 10);
        CIImage *transformedImage = [ciImage imageByApplyingTransform:transform];
        
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef cgImage = [context createCGImage:transformedImage fromRect:transformedImage.extent];
        UIImage *qrImage = [UIImage imageWithCGImage:cgImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        CGImageRelease(cgImage);
        
        if (avatar != nil) {
            qrImage = [self qrcodeImage:qrImage addAvatar:avatar scale:scale];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{ completion(qrImage); });
    });
}

+ (UIImage *)qrcodeImage:(UIImage *)qrImage addAvatar:(UIImage *)avatar scale:(CGFloat)scale {
    
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGRect rect = CGRectMake(0, 0, qrImage.size.width * screenScale, qrImage.size.height * screenScale);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, screenScale);
    
    [qrImage drawInRect:rect];
    
    CGSize avatarSize = CGSizeMake(rect.size.width * scale, rect.size.height * scale);
    CGFloat x = (rect.size.width - avatarSize.width) * 0.5;
    CGFloat y = (rect.size.height - avatarSize.height) * 0.5;
    [avatar drawInRect:CGRectMake(x, y, avatarSize.width, avatarSize.height)];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithCGImage:result.CGImage scale:screenScale orientation:UIImageOrientationUp];
}

#pragma mark - 扫描图像方法
+ (void)scaneImage:(UIImage *)image completion:(void (^)(NSArray *))completion {
    
    NSAssert(completion != nil, @"必须传入完成回调");
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
        
        CIImage *ciImage = [[CIImage alloc] initWithImage:image];
        
        NSArray *features = [detector featuresInImage:ciImage];
        
        NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:features.count];
        for (CIQRCodeFeature *feature in features) {
            [arrayM addObject:feature.messageString];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(arrayM.copy);
        });
    });
}

#pragma mark - 构造函数
+ (instancetype)scanerWithView:(UIView *)view scanFrame:(CGRect)scanFrame completion:(void (^)(NSString *))completion {
    NSAssert(completion != nil, @"必须传入完成回调");
    
    return [[self alloc] initWithView:view scanFrame:scanFrame completion:completion];
}

- (instancetype)initWithView:(UIView *)view scanFrame:(CGRect)scanFrame completion:(void (^)(NSString *))completion {    
    if (self= [super init]) {
        self.parentView = view;
        self.scanFrame = scanFrame;
        self.completionCallBack = completion;
        
        [self setupSession];
    }
    return self;
}

#pragma mark - 公共方法
/// 开始扫描
- (void)startScan {
    if ([_session isRunning]) {
        return;
    }
    _currentDetectedCount = 0;
    
    [_session startRunning];
}

- (void)stopScan {
    if (![_session isRunning]) {
        return;
    }
    [_session stopRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    [self clearDrawLayer];
    
    for (id obj in metadataObjects) {
        // 判断检测到的对象类型
        if (![obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            return;
        }
        
        // 转换对象坐标
        AVMetadataMachineReadableCodeObject *dataObject = (AVMetadataMachineReadableCodeObject *)[_previewLayer transformedMetadataObjectForMetadataObject:obj];
        
        // 判断扫描范围
        if (!CGRectContainsRect(self.scanFrame, dataObject.bounds)) {
            continue;
        }
        
        if (_currentDetectedCount++ < kMaxDetectedCount) {
            // 绘制边角
            [self drawCornersShape:dataObject];
        } else {
            [self stopScan];
            
            // 完成回调
            if (self.completionCallBack != nil) {
                [self playSound];
                self.completionCallBack(dataObject.stringValue);
            }
        }
    }
}

/// 清空绘制图层
- (void)clearDrawLayer {
    if (_drawLayer.sublayers.count == 0) {
        return;
    }
    
    [_drawLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
}

/// 绘制条码形状
///
/// @param dataObject 识别到的数据对象
- (void)drawCornersShape:(AVMetadataMachineReadableCodeObject *)dataObject {
    
    if (dataObject.corners.count == 0) {
        return;
    }
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    
    layer.lineWidth = 4;
    layer.strokeColor = [UIColor greenColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.path = [self cornersPath:dataObject.corners];
    
    [_drawLayer addSublayer:layer];
}

/// 使用 corners 数组生成绘制路径
///
/// @param corners corners 数组
///
/// @return 绘制路径
- (CGPathRef)cornersPath:(NSArray *)corners {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint point = CGPointZero;
    
    // 1. 移动到第一个点
    NSInteger index = 0;
    CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)corners[index++], &point);
    [path moveToPoint:point];
    
    // 2. 遍历剩余的点
    while (index < corners.count) {
        CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)corners[index++], &point);
        [path addLineToPoint:point];
    }
    
    // 3. 关闭路径
    [path closePath];
    
    return path.CGPath;
}

#pragma mark - 扫描相关方法
/// 设置绘制图层和预览图层
- (void)setupLayers {
    
    if (self.parentView == nil) {
        NSLog(@"父视图不存在");
        return;
    }
    
    if (_session == nil) {
        NSLog(@"拍摄会话不存在");
        return;
    }
    
    // 绘制图层
    _drawLayer = [CALayer layer];
    
    _drawLayer.frame = self.parentView.bounds;
    
    [self.parentView.layer insertSublayer:_drawLayer atIndex:0];
    
    // 预览图层
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = self.parentView.bounds;
    
    [self.parentView.layer insertSublayer:_previewLayer atIndex:0];
}

/// 设置扫描会话
- (void)setupSession {
    
    // 1> 输入设备
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [_device lockForConfiguration:nil];
    _device.activeVideoMinFrameDuration = CMTimeMake(1, 5);
    [_device unlockForConfiguration];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    
    if (videoInput == nil) {
        NSLog(@"创建输入设备失败");
        return;
    }
    
    // 2> 数据输出
    AVCaptureMetadataOutput *dataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    // 3> 拍摄会话 - 判断能够添加设备
    _session = [[AVCaptureSession alloc] init];
    if (![_session canAddInput:videoInput]) {
        NSLog(@"无法添加输入设备");
        _session = nil;
        
        return;
    }
    if (![_session canAddOutput:dataOutput]) {
        NSLog(@"无法添加输入设备");
        _session = nil;
        
        return;
    }
    
    // 4> 添加输入／输出设备
    [_session addInput:videoInput];
    [_session addOutput:dataOutput];
    
    // 5> 设置扫描类型
    dataOutput.metadataObjectTypes = dataOutput.availableMetadataObjectTypes;
    [dataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 6> 设置预览图层会话
    [self setupLayers];
    
}

/************************ 添加图像捕捉输出 *********************/
- (void)addCaptureImage:(void(^)(int bright))brightBlock {
    if ([_device hasTorch]) {
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        dispatch_queue_t queue = dispatch_queue_create("brightCapture.scanner.queue.com", NULL);
        [_videoOutput setSampleBufferDelegate:self queue:queue];
        _videoOutput.videoSettings =
        [NSDictionary dictionaryWithObject:
         [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                    forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        if (![_session canAddOutput:_videoOutput]) {
            return;
        }
        [_session addOutput:_videoOutput];
        
        self.brightBlock = brightBlock;
    }
}


#pragma mark --- AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    int bright = [self getBrightWith:sampleBuffer];
    //    NSLog(@"%d",bright);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.brightBlock(bright);
    });
}

- (int)getBrightWith:(CMSampleBufferRef)sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    unsigned char * baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    //    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    int num = 1;
    double bright = 0;
    int r;
    int g;
    int b;
    for (int i = 0; i < 4 * width * height; i++) {
        if (i%4 == 0) {
            num++;
            r = baseAddress[i+1];
            g = baseAddress[i+2];
            b = baseAddress[i+3];
            bright = bright + 0.299 * r + 0.587 * g + 0.114 * b;
        }
    }
    
    bright = (int) (bright / num);
    return bright;
    
}

- (void)setTorch:(BOOL)isOpen {
    [_device lockForConfiguration:nil];
    if (isOpen) {
        [_device setTorchMode:AVCaptureTorchModeOn];
    }
    else {
        [_device setTorchMode:AVCaptureTorchModeOff];
    }
    [_device unlockForConfiguration];
}

- (BOOL)isTorchOpen {
    return _device.isTorchActive;
}

- (void)playSound {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForResource:@"KMScanner" withExtension:@"bundle"];
    if (url == nil) {
        NSString *bundlePath = bundle.bundlePath;
        NSString *urlString = [[@"file://" stringByAppendingString: bundlePath] stringByAppendingString:@"/KMScanner.framework/KMScanner.bundle/"];
        url = [NSURL URLWithString:urlString];
    }
    NSBundle *imageBundle = [NSBundle bundleWithURL:url];
    
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:@"sound" ofType:nil];
    
    audioFile = [imageBundle pathForResource:@"sound" ofType:@"caf"];
    NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
    
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    AudioServicesPlaySystemSound(soundID); // 播放音效
}
void soundCompleteCallback(SystemSoundID soundID, void *clientData){
    
}

@end
