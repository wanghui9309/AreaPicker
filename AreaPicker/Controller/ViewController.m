//
//  ViewController.m
//  AreaPicker
//
//  Created by WangHui on 2018/6/28.
//  Copyright © 2018年 WangHui. All rights reserved.
//

#import "ViewController.h"

#import "WHAreaPickerController.h"

@interface ViewController ()<WHAreaPickerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    WHAreaPickerController *area = [WHAreaPickerController areaPickerController:self];
    [self presentViewController:area animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
