//
//  WHAreaPickerController.h
//  布偶屋
//
//  Created by WangHui on 2018/1/2.
//  Copyright © 2018年 WangHui. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WHAreaList.h"

@class WHAreaPickerController;

@protocol WHAreaPickerControllerDelegate <NSObject>

@optional
/**
 完成了选择地区

 @param picker 选择器
 @param area 地区下标[0:省份下标,1:城市下标,2:县区下标]
 */
- (void)areaPickerController:(WHAreaPickerController *)picker didFinishPickingArea:(NSArray<NSNumber *> *)area;

@end

@interface WHAreaPickerController : UIViewController

@property (nonatomic, weak) id<WHAreaPickerControllerDelegate> delegate;

/**
 初始化方法 / 控制器 Present 的时候使用
 */
+ (instancetype)areaPickerController:(id<WHAreaPickerControllerDelegate>)delegate;

/**
 初始化方法 显示上次结果 / 控制器 Present 的时候使用
 
 @param lastAreas 上次选中的地区下标 delegate 返回的,在传进来
 */
+ (instancetype)areaPickerController:(id<WHAreaPickerControllerDelegate>)delegate lastAreas:(NSArray<NSNumber *> *)lastAreas;

@end
