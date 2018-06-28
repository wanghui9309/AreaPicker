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

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    WHAreaPickerController *area = [WHAreaPickerController areaPickerController:self];
    [self presentViewController:area animated:NO completion:nil];
}

#pragma mark - WHAreaPickerControllerDelegate
- (void)areaPickerController:(WHAreaPickerController *)picker didFinishPickingArea:(NSArray<NSNumber *> *)area
{
    
}


@end
