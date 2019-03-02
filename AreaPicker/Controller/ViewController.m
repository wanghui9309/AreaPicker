//
//  ViewController.m
//  AreaPicker
//
//  Created by WangHui on 2018/6/28.
//  Copyright © 2018年 WangHui. All rights reserved.
//

#import "ViewController.h"

#import "WHAreaPickerView.h"

@interface ViewController ()<WHAreaPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    WHAreaPickerView *area = [WHAreaPickerView areaPickerView];
    area.delegate = self;
}

#pragma mark - WHAreaPickerControllerDelegate
- (void)areaPickerViewDidFinish:(WHAreaPickerView *)picker
{
    self.label.text = [picker.areaName componentsJoinedByString:@" "];
}


@end
