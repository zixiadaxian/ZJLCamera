//
//  HSSaveViewController.h
//  HSZJLCamera
//
//  Created by 紫霞大仙 on 16/1/16.
//  Copyright © 2016年 Hipal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSSaveViewController : UIViewController
- (IBAction)canle:(id)sender;
- (IBAction)save:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *logoView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

- (void)setPhotoImage:(UIImage *)photo logoImage:(UIImage *)logo ;
@end
