//
//  HSZJLCameraViewC.m
//  HSZJLCamera
//
//  Created by 紫霞大仙 on 16/1/16.
//  Copyright © 2016年 Hipal. All rights reserved.
//

#import "HSZJLCameraViewC.h"
#import <AVFoundation/AVFoundation.h>
#import "HSSaveViewController.h"

@interface HSZJLCameraViewC ()
/**
 *  相机显示区域
 */
@property (weak, nonatomic) IBOutlet UIView *cameraView;
/**
 *  水印区域
 */
@property (weak, nonatomic) IBOutlet UIView *logoView;
/**
 *  工具栏
 */
@property (weak, nonatomic) IBOutlet UIView *toolView;

/**
 *  设备之间的数据传递  第一个创建
 */
@property (nonatomic, strong)AVCaptureSession           * session;
/**
 *  输入流->笔者认为是相机
 */
@property (nonatomic, strong)AVCaptureDeviceInput       * videoInput;
/**
 *  照相机
 */
@property (nonatomic, strong)AVCaptureStillImageOutput  * stillImageOutput;
/**
 *  显示层 (相框) 要第二个创建
 */
@property (nonatomic, strong)AVCaptureVideoPreviewLayer * previewLayer;
/**
 *  水印照片
 */
@property (weak, nonatomic) IBOutlet UIImageView *logoImageVIew;

@end

@implementation HSZJLCameraViewC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
            // iOS 7
            [self initSession];
        }
        else {
            // iOS 8
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            switch (status) {
                case AVAuthorizationStatusAuthorized:
                    [self initSession];
                    break;
                default:
                    break;
            }
            
        }
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.clipsToBounds = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setUpCameraLayer];

}
/**
 *  初始化
 */
- (void)initSession
{
    
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:nil];
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    //以JPEG的图片格式输出图片
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    
}
/**
 *  设置相机layer
 */
- (void) setUpCameraLayer
{
    
    if (self.previewLayer == nil) {
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        
        UIView * view = self.cameraView;
        CALayer * viewLayer = [view layer];
        [viewLayer setMasksToBounds:YES];
        
        CGRect bounds = [view bounds];
        bounds.size.width = [UIScreen mainScreen].bounds.size.width;
        bounds.size.height = [UIScreen mainScreen].bounds.size.height * 0.6;
        [self.previewLayer setFrame:bounds];
        [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        [viewLayer insertSublayer:self.previewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
    }
}
/**
 *  拍照
 */
- (void)openCamera{
    [self shutterCamera];
}
/**
 *  获取前后摄像头对象的方法
 */
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

//前置摄像头
- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}
//后置摄像头
- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}
/**
 *  前后摄像头切换
 */
- (void)toggleCamera {
   
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[_videoInput device] position];
        
        if (position == AVCaptureDevicePositionBack)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        else if (position == AVCaptureDevicePositionFront)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
        else
            return;
        
        if (newVideoInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:self.videoInput];
            if ([self.session canAddInput:newVideoInput]) {
                [self.session addInput:newVideoInput];
                [self setVideoInput:newVideoInput];
            } else {
                [self.session addInput:self.videoInput];
            }
            [self.session commitConfiguration];
        } else if (error) {
            NSLog(@"打开失败 %@", error);
        }
    }
}

#pragma mark -- 拍照

- (void) shutterCamera
{
    AVCaptureConnection * videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"拍照失败");
        return;
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }

        //照片
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage * image = [UIImage imageWithData:imageData];
        
        HSSaveViewController *saVC = [[HSSaveViewController alloc] initWithNibName:@"HSSaveViewController" bundle:nil];
        UIImage *logo = [UIImage imageNamed:@"picture_logo1"];
        [self presentViewController:saVC animated:YES completion:^{
            [saVC setPhotoImage:image logoImage:logo];
        }];
    }];
}

- (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2 {
    UIGraphicsBeginImageContext(image1.size);
    
    // Draw image1
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    
    // Draw image2
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

#pragma mark --加水印code
- (UIImage *)completeEditWithImage:(UIImage*)image {
    
    CGSize size = image.size;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width-2, size.height-2), NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *logo = [UIImage imageNamed:@"picture_logo.png"];
    [logo drawAtPoint:CGPointMake(100, 100)];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/**
 *  因为在一切低端机 会莫名其妙的内存警告   startRunning  -> 映射到屏幕上
 */

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    if (self.session) {
        [self.session startRunning];
    }
}
- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
    if (self.session) {
        [self.session stopRunning];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"相机内存警告");
}


- (IBAction)takePictureClick:(id)sender {
    [self shutterCamera];
}

- (IBAction)cancelClick:(UIButton *)sender {
    if (self.navigationController.viewControllers.count >1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (IBAction)changeCameraClick:(UIButton *)sender {
    [self toggleCamera];
}

- (IBAction)choseLogo:(UIButton*)sender {
    switch (sender.tag) {
        case 0:
        {
            //不选
            self.logoImageVIew.image = nil;
        }
            break;
        case 1:
        {
            self.logoImageVIew.image = [UIImage imageNamed:@"picture_logo"];
        }
            break;
        case 2:
        {
            self.logoImageVIew.image = [UIImage imageNamed:@"picture_logo1"];
        }
            break;
        case 3:
        {
            self.logoImageVIew.image = [UIImage imageNamed:@"picture_logo"];
        }
            break;
        default:
            break;
    }
}
@end
