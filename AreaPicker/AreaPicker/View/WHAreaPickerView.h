//
//  WHAreaPickerView.h
//  JYReplaceBatteryBiz_Example
//
//  Created by 王辉 on 2019/3/2.
//  Copyright © 2019 WangHui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WHAreaPickerView;

@protocol WHAreaPickerViewDelegate <NSObject>

@optional
/**
 完成了选择区域
 
 @param picker 选择器
 */
- (void)areaPickerViewDidFinish:(WHAreaPickerView *)picker;

@end

/** 省市区选择器 */
@interface WHAreaPickerView : UIView

@property (nonatomic, weak) id<WHAreaPickerViewDelegate> delegate;
/** 上次选中的地区 [0:省份下标,1:城市下标,2:县区下标] */
@property (nonatomic, strong) NSArray<NSNumber *> *lastAreas;
/** 区域名称 [0:省份名称,1:城市名称,2:县区名称] */
@property (nonatomic, strong) NSArray<NSString *> *areaName;

/**
 快速创建
 */
+ (instancetype)areaPickerView;

@end

NS_ASSUME_NONNULL_END
