//
//  TTQRScanController.m
//  二维码
//
//  Created by ttayaa on 15/12/9.
//  Copyright © 2015年 ttayaa. All rights reserved.
//

#import "TTQRScanController.h"
#import <AVFoundation/AVFoundation.h>

@interface TTQRScanController ()<UITabBarDelegate,AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

{
BOOL LightOn;
}

@property (weak, nonatomic) IBOutlet UIButton *xiangce;
@property (weak, nonatomic) IBOutlet UIButton *diantong;
@property (weak, nonatomic) IBOutlet UITabBarItem *erweima;
@property (weak, nonatomic) IBOutlet UITabBarItem *tiaoxingma;



@property (weak, nonatomic) IBOutlet UIButton *close_btn;

@property (weak, nonatomic) IBOutlet UITabBar *customBar;
@property (weak, nonatomic) IBOutlet UIImageView *scanLineImageView;
//容器视图的高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerHeightConstraint;
//扫描线的顶部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanLineTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *customLabel;
@property (weak, nonatomic) IBOutlet UIView *customContainerView;

@property ( strong , nonatomic ) AVCaptureDevice * device;
@property ( strong , nonatomic ) AVCaptureDeviceInput * input;
@property ( strong , nonatomic ) AVCaptureMetadataOutput * output;
@property ( strong , nonatomic ) AVCaptureSession * session;
@property ( strong , nonatomic ) AVCaptureVideoPreviewLayer * previewLayer;

/*** 专门用于保存描边的图层 ***/
@property (nonatomic,strong) CALayer *containerLayer;

@property (weak, nonatomic) IBOutlet UIImageView *containterView;


@end

@implementation TTQRScanController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    
//    White_StatusBar;
//    [self TTNVAlphaBar:TTAlphaNaviBarStyle1 BarColor:[UIColor blackColor] bindScrollView:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIImage imageWithContentsOfFile:[[TTQRScanController TTQRScanControllerBundle] pathForResource:@"yu_sao_01" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [[UIImage imageWithContentsOfFile:[[TTQRScanController TTQRScanControllerBundle] pathForResource:@"yu_sao_02" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [[UIImage imageWithContentsOfFile:[[TTQRScanController TTQRScanControllerBundle] pathForResource:@"yu_sao_03" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [[UIImage imageWithContentsOfFile:[[TTQRScanController TTQRScanControllerBundle] pathForResource:@"yu_sao_04" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [[UIImage imageWithContentsOfFile:[[TTQRScanController TTQRScanControllerBundle] pathForResource:@"qrcode_tabbar_icon_barcode_highlighted" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [[UIImage imageWithContentsOfFile:[[TTQRScanController TTQRScanControllerBundle] pathForResource:@"qrcode_tabbar_icon_barcode" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [[UIImage imageWithContentsOfFile:[[TTQRScanController TTQRScanControllerBundle] pathForResource:@"qrcode_tabbar_icon_qrcode_highlighted" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [[UIImage imageWithContentsOfFile:[[TTQRScanController TTQRScanControllerBundle] pathForResource:@"qrcode_tabbar_icon_qrcode" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.containterView.image = [UIImage imageNamed:@"yu_sao_01"];
    self.scanLineImageView.image = [UIImage imageNamed:@"yu_sao_02"];
    [self.xiangce setImage:[UIImage imageNamed:@"yu_sao_03"] forState:UIControlStateNormal];
     [self.diantong setImage:[UIImage imageNamed:@"yu_sao_04"] forState:UIControlStateNormal];
    self.erweima.image = [UIImage imageNamed:@"qrcode_tabbar_icon_qrcode"];
    self.tiaoxingma.image = [UIImage imageNamed:@"qrcode_tabbar_icon_barcode"];
   
    //处理左上角关闭按钮
    if (self.navigationController) {
        
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        lb.textAlignment = NSTextAlignmentCenter;
        lb.font = [UIFont boldSystemFontOfSize:18];
        lb.backgroundColor = [UIColor clearColor];
        lb.text = @"扫一扫";
        lb.textColor =[UIColor whiteColor];
        self.navigationItem.titleView = lb;
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Nbar_black"] forBarMetrics:UIBarMetricsDefault];
        
        self.close_btn.hidden = YES;
    }
    else//present出来
    {
        self.close_btn.hidden = NO;
    }
    
    
    
    
    self.customBar.selectedItem = self.customBar.items.firstObject;
    self.customBar.delegate = self;

    // 3.开始扫描二维码
    [self startScan];
}


- (IBAction)FlashlightClick:(id)sender {
    
    LightOn = !LightOn;
    
    if (LightOn) {
        
        [self turnOn];
        
    }else{
        
        [self turnOff];
        
    }
}

-(void) turnOn

{
    
    [_device lockForConfiguration:nil];
    
    [_device setTorchMode:AVCaptureTorchModeOn];
    
    [_device unlockForConfiguration];
    
}

-(void) turnOff

{
    
    [_device lockForConfiguration:nil];
    
    [_device setTorchMode: AVCaptureTorchModeOff];
    
    [_device unlockForConfiguration];
    
}

- (IBAction)closeButtonClick:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)openCameralClick:(id)sender {
    
    // 1.判断相册是否可以打开
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
    // 2. 创建图片选择控制器
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // 4.设置代理
    ipc.delegate = self;
    
    // 5.modal出这个控制器
    [self presentViewController:ipc animated:YES completion:nil];
}

#pragma mark -------- UIImagePickerControllerDelegate---------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // 1.取出选中的图片
    UIImage *pickImage = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(pickImage);

    CIImage *ciImage = [CIImage imageWithData:imageData];
    
    // 2.从选中的图片中读取二维码数据
    // 2.1创建一个探测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    
    // 2.2利用探测器探测数据
    NSArray *feature = [detector featuresInImage:ciImage];

    // 2.3取出探测到的数据
    for (CIQRCodeFeature *result in feature) {
        NSLog(@"%@",result.messageString);
//        NSString *urlStr = result.messageString;
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        
        
        NSDictionary *dict = @{
                               @"ScanNVc":self.navigationController,
                               @"ScanValue":result.messageString,
                               };
        
        [[NSNotificationCenter defaultCenter] postNotificationName: @"KNOTIFICATION_ScanResult" object:dict];
        
    }
       
    
    // 注意: 如果实现了该方法, 当选中一张图片时系统就不会自动关闭相册控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -------- 懒加载---------
- (AVCaptureDevice *)device
{
    if (_device == nil) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _device;
}

- (AVCaptureDeviceInput *)input
{
    if (_input == nil) {
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    return _input;
}

- (AVCaptureSession *)session
{
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if (_previewLayer == nil) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    }
    return _previewLayer;
}

// 设置输出对象解析数据时感兴趣的范围
// 默认值是 CGRect(x: 0, y: 0, width: 1, height: 1)
// 通过对这个值的观察, 我们发现传入的是比例
// 注意: 参照是以横屏的左上角作为, 而不是以竖屏
//        out.rectOfInterest = CGRect(x: 0, y: 0, width: 0.5, height: 0.5)
- (AVCaptureMetadataOutput *)output
{
    if (_output == nil) {
        _output = [[AVCaptureMetadataOutput alloc] init];
        
        // 1.获取屏幕的frame
        CGRect viewRect = self.view.frame;
        // 2.获取扫描容器的frame
        CGRect containerRect = self.customContainerView.frame;
        
        CGFloat x = containerRect.origin.y / viewRect.size.height;
        CGFloat y = containerRect.origin.x / viewRect.size.width;
        CGFloat width = containerRect.size.height / viewRect.size.height;
        CGFloat height = containerRect.size.width / viewRect.size.width;
        
       // CGRect outRect = CGRectMake(x, y, width, height);
       // [_output rectForMetadataOutputRectOfInterest:outRect];
        _output.rectOfInterest = CGRectMake(x, y, width, height);
    }
    return _output;
}

- (CALayer *)containerLayer
{
    if (_containerLayer == nil) {
        _containerLayer = [[CALayer alloc] init];
    }
    return _containerLayer;
}
/*---------------------------- 分割线 ---------------------------- */
- (void)startScan
{
    // 1.判断输入能否添加到会话中
    if (![self.session canAddInput:self.input]) return;
    [self.session addInput:self.input];

    
    // 2.判断输出能够添加到会话中
    if (![self.session canAddOutput:self.output]) return;
    [self.session addOutput:self.output];
    
    // 4.设置输出能够解析的数据类型
    // 注意点: 设置数据类型一定要在输出对象添加到会话之后才能设置
//    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeFace];
    self.output.metadataObjectTypes = self.output.availableMetadataObjectTypes;
//AVMetadataObjectTypeFace
//    AVMetadataObjectTypeQRCode

    // 5.设置监听监听输出解析到的数据
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
 
    // 6.添加预览图层
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    self.previewLayer.frame = self.view.bounds;
   // self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    // 7.添加容器图层
    [self.view.layer addSublayer:self.containerLayer];
    self.containerLayer.frame = self.view.bounds;
    
    // 8.开始扫描
    [self.session startRunning];
}

#pragma mark --------AVCaptureMetadataOutputObjectsDelegate ---------
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    if (metadataObjects.count > 0) {
        // id 类型不能点语法,所以要先去取出数组中对象
        AVMetadataMachineReadableCodeObject *object = [metadataObjects lastObject];
        
        if (object == nil) return;
    
    
//        // 只要扫描到结果就会调用
//        self.customLabel.text = object.stringValue;
    
    
        [self clearLayers];
        
        [self.previewLayer removeFromSuperlayer];
        
        // 2.对扫描到的二维码进行描边
        AVMetadataMachineReadableCodeObject *obj = (AVMetadataMachineReadableCodeObject *)[self.previewLayer transformedMetadataObjectForMetadataObject:object];
        
        [self drawLine:obj];
        // 停止扫描
        [self.session stopRunning];
//
//        // 将预览图层移除
        [self.previewLayer removeFromSuperlayer];
        
        
        
        NSDictionary *dict = @{
                               @"ScanVc":self,
                               @"ScanValue":object.stringValue,
                               };
        
        [[NSNotificationCenter defaultCenter] postNotificationName: @"KNOTIFICATION_ScanResult" object:dict];
    
        
    } else {
        NSLog(@"没有扫描到数据");
    }

    
   
}

// 绘制描边
- (void)drawLine:(AVMetadataMachineReadableCodeObject *)objc
{
    
    if ([objc.type isEqualToString:@"face"]) {
        return;
    }
    
    
    NSArray *array = objc.corners;
    
    // 1.创建形状图层, 用于保存绘制的矩形
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];

    // 设置线宽
    layer.lineWidth = 2;
    layer.strokeColor = [UIColor greenColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;

    // 2.创建UIBezierPath, 绘制矩形
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGPoint point = CGPointZero;
    int index = 0;
    
    CFDictionaryRef dict = (__bridge CFDictionaryRef)(array[index++]);
    // 把点转换为不可变字典
    // 把字典转换为点，存在point里，成功返回true 其他false
    CGPointMakeWithDictionaryRepresentation(dict, &point);
    
    [path moveToPoint:point];
    
    // 2.2连接其它线段
    for (int i = 1; i<array.count; i++) {
        CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)array[i], &point);
        [path addLineToPoint:point];
    }
    // 2.3关闭路径
    [path closePath];
    
    layer.path = path.CGPath;
    // 3.将用于保存矩形的图层添加到界面上
    [self.containerLayer addSublayer:layer];
    
}

- (void)clearLayers
{
    if (self.containerLayer.sublayers)
    {
        for (CALayer *subLayer in self.containerLayer.sublayers)
        {
            [subLayer removeFromSuperlayer];
        }
    }
}

//注意，在界面消失的时候关闭session
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.session stopRunning];
}

// 界面显示,开始动画
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self startAnimation];
}

// 开启冲击波动画
- (void)startAnimation
{
    // 1.设置冲击波底部和容器视图顶部对齐
    self.scanLineTopConstraint.constant = 0;
    // 刷新UI
    [self.view layoutIfNeeded];
    
    // 2.执行扫描动画
    [UIView animateWithDuration:1.0 animations:^{
        // 无线重复动画
        [UIView setAnimationRepeatCount:MAXFLOAT];
        self.scanLineTopConstraint.constant = self.containerHeightConstraint.constant;
        // 刷新UI
        [self.view layoutIfNeeded];
    } completion:nil];
    
}
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    // 根据当前选中的按钮重新设置二维码容器高度

    if ([item.title isEqualToString:@"二维码"]) {
        self.containerHeightConstraint.constant = 250;

    }
    if ([item.title isEqualToString:@"条形码"]) {
        self.containerHeightConstraint.constant   =  125;

    }
    
    // 刷新UI
    [self.view layoutIfNeeded];
    
    // 移除动画
    [self.scanLineImageView.layer removeAllAnimations];
    
    [self startAnimation];
}


+ (NSBundle *)TTQRScanControllerBundle
{
    static NSBundle *TTQRScanControllerBundle = nil;
    if (TTQRScanControllerBundle == nil) {
        // 这里不使用mainBundle是为了适配pod 1.x和0.x
        TTQRScanControllerBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"TTQRScanController" ofType:@"bundle"]];
    }
    return TTQRScanControllerBundle;
}

@end
