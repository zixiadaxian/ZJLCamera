//
//  ViewController.m
//  HSZJLCamera
//
//  Created by HiPal on 16/1/15.
//  Copyright © 2016年 Hipal. All rights reserved.
//

#import "ViewController.h"
#import "HSZJLCameraViewC.h"
@interface ViewController ()
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)open:(id)sender {
    HSZJLCameraViewC *zjlVC = [[HSZJLCameraViewC alloc] initWithNibName:@"HSZJLCameraViewC" bundle:nil];
    [self presentViewController:zjlVC animated:YES completion:^{
        
    }];
}
@end