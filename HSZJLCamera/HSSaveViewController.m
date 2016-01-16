//
//  HSSaveViewController.m
//  HSZJLCamera
//
//  Created by 紫霞大仙 on 16/1/16.
//  Copyright © 2016年 Hipal. All rights reserved.
//

#import "HSSaveViewController.h"

@interface HSSaveViewController ()

@end

@implementation HSSaveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)canle:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)save:(id)sender {
    [self saveImageToPhotoAlbum:[self imageShotFromView:self.logoView]];
}

- (void)setPhotoImage:(UIImage *)photo logoImage:(UIImage *)logo {
    [self.photoImageView setImage:photo];
    [self.logoImageView setImage:logo];;
}
#pragma mark --方法截取的屏幕的图片要清晰的多
- (UIImage *)imageShotFromView:(UIView *)view
{
    CGSize size = view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    //  注意起点是从0 开始的
    CGRect rec = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
    [view drawViewHierarchyInRect:rec afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
}

#pragma mark -------------save---------------
//保存照片至本机
- (void)saveImageToPhotoAlbum:(UIImage*)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error != NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错了!" message:@"存不了T_T" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        NSLog(@"保存成功");
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}
@end
