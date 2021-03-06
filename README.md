![AreaPicker.gif](https://github.com/wanghui9309/AreaPicker/blob/master/AreaPicker/Supporting%20Files/AreaPicker.gif)

## 如何使用
* 手动导入
    * 将项目中`AreaPicker`文件夹拖入您的项目中
    * 导入主头文件即可:`#import "WHAreaPickerView.h"`

## 使用参考
```oc
WHAreaPickerView *area = [WHAreaPickerView areaPickerView];
area.delegate = self;
```

## area.plist
* 该文件是存放省市区的数据源

## WHAreaPickerView.h
```oc
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
```
