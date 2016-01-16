//
//  HSZJLCameraViewC.h
//  HSZJLCamera
//
//  Created by 紫霞大仙 on 16/1/16.
//  Copyright © 2016年 Hipal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSZJLCameraViewC : UIViewController
/**
 *  拍照
 *
 *  @param sender
 */
- (IBAction)takePictureClick:(id)sender;
/**
 *  取消
 *
 *  @param sender
 */
- (IBAction)cancelClick:(UIButton *)sender;
/**
 *  前后摄像头切换
 *
 *  @param sender 
 */
- (IBAction)changeCameraClick:(UIButton *)sender;
/**
 *  切换logo水印
 *
 *  @param sender 0 不选 
 */
- (IBAction)choseLogo:(id)sender;

@end
