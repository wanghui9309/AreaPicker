//
//  WHAreaPickerView.m
//  JYReplaceBatteryBiz_Example
//
//  Created by 王辉 on 2019/3/2.
//  Copyright © 2019 WangHui. All rights reserved.
//

#import "WHAreaPickerView.h"

#import "WHAreaList.h"

@interface WHAreaPickerView ()<UIPickerViewDataSource, UIPickerViewDelegate>

/** 地址选择器视图 */
@property (weak, nonatomic) UIPickerView *pickerView;
/** 地址选择器 底部约束 */
@property (weak, nonatomic) NSLayoutConstraint *pickerViewBottomCons;
/** 工具视图 */
@property (weak, nonatomic) UIView *toolView;
/** 取消按钮 */
@property (weak, nonatomic) UIButton *cancelBtn;
/** 确认按钮 */
@property (weak, nonatomic) UIButton *confirmBtn;
/** 数据源 */
@property (strong, nonatomic) NSArray<WHAreaList *> *dataSource;
/** 选中的省份 下标 默认为0 */
@property (assign, nonatomic) NSInteger selectProv;
/** 选中的城市 下标 默认为0 */
@property (assign, nonatomic) NSInteger selectCity;
/** 选中的地区 下标 默认为0 */
@property (assign, nonatomic) NSInteger selectArea;

@end

@implementation WHAreaPickerView

/**
 快速创建
 */
+ (instancetype)areaPickerView
{
    UIWindow *window = UIApplication.sharedApplication.keyWindow;

    WHAreaPickerView *view = [[WHAreaPickerView alloc] init];
    view.frame = window.bounds;
    [window addSubview:view];
    
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initUI];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self cancelAction];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.lastAreas.count > 2)
    {
        self.selectProv = self.lastAreas.firstObject.intValue;
        self.selectCity = self.lastAreas[1].intValue;
        self.selectArea = self.lastAreas.lastObject.intValue;
        
        [self pickerReloadComponent:0 selectRow:self.selectProv];
        [self pickerReloadComponent:1 selectRow:self.selectCity];
        [self pickerReloadComponent:2 selectRow:self.selectArea];
    }
}

#pragma mark - 自定义方法
/**
 初始化视图
 */
- (void)initUI
{
    self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    
    NSString *filePath = [NSBundle.mainBundle pathForResource:@"area" ofType:@"plist"];
    NSArray *areaArr = [NSArray arrayWithContentsOfFile:filePath];
    self.dataSource = [WHAreaList wh_objectArrayWithKeyValuesArray:areaArr];
    [self.pickerView reloadAllComponents];
    
    [self toolView];
    [self cancelBtn];
    [self confirmBtn];
}

/**
 选择器刷新
 
 @param component 列
 @param row 行
 */
- (void)pickerReloadComponent:(NSInteger)component selectRow:(NSInteger)row
{
    [self.pickerView reloadComponent:component];
    [self.pickerView selectRow:row inComponent:component animated:YES];
}

#pragma mark - Layout
- (NSLayoutConstraint *)equallyRelatedConstraintWithView:(UIView *)view toView:(UIView *)toView attribute:(NSLayoutAttribute)attribute
{
    NSLayoutConstraint *layoutConstraint = [NSLayoutConstraint constraintWithItem:view attribute:attribute relatedBy:NSLayoutRelationEqual toItem:toView attribute:attribute multiplier:1.0 constant:0.0];
    layoutConstraint.active = YES;
    return layoutConstraint;
}

#pragma mark - Action
/**
 取消
 */
- (void)cancelAction
{
    self.pickerViewBottomCons.constant = 300;
    [UIView animateWithDuration:0.5 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

/**
 确认
 */
- (void)confirmAction
{
    // 省份
    WHAreaList *prov = self.dataSource[self.selectProv];
    // 城市
    WHAreaList *city = prov.child[self.selectCity];
    // 县区
    WHAreaList *area = city.child[self.selectArea];
    
    // 区域下标
    _lastAreas = @[@(self.selectProv), @(self.selectCity), @(self.selectArea)];
    // 区域名称
    _areaName = @[prov.area_name, city.area_name, area.area_name];
    
    if ([self.delegate respondsToSelector:@selector(areaPickerViewDidFinish:)])
    {
        [self.delegate areaPickerViewDidFinish:self];
    }
    
    [self cancelAction];
}

#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
    {
        return self.dataSource.count;
    }
    else if (component == 1)
    {
        NSInteger provinceRow = [pickerView selectedRowInComponent:0];
        if (provinceRow >= self.dataSource.count)
        {
            return 0;
        }
        return self.dataSource[provinceRow].child.count;
    }
    else
    {
        NSInteger provinceRow = [pickerView selectedRowInComponent:0];
        NSInteger cityRow = [pickerView selectedRowInComponent:1];
        if (provinceRow >= self.dataSource.count ||
            cityRow >= self.dataSource[provinceRow].child.count)
        {
            return 0;
        }
        return self.dataSource[provinceRow].child[cityRow].child.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0)
    {
        if (row >= self.dataSource.count)
        {
            return nil;
        }
        return self.dataSource[row].area_name;
    }
    else if (component == 1)
    {
        NSInteger provinceRow = [pickerView selectedRowInComponent:0];
        if (provinceRow >= self.dataSource.count || row >= self.dataSource[provinceRow].child.count)
        {
            return nil;
        }
        return self.dataSource[provinceRow].child[row].area_name;
    }
    else
    {
        NSInteger provinceRow = [pickerView selectedRowInComponent:0];
        NSInteger cityRow = [pickerView selectedRowInComponent:1];
        if (provinceRow >= self.dataSource.count ||
            cityRow >= self.dataSource[provinceRow].child.count ||
            row >= self.dataSource[provinceRow].child[cityRow].child.count)
        {
            return nil;
        }
        return self.dataSource[provinceRow].child[cityRow].child[row].area_name;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *pickerLabel = (UILabel *)view;
    
    if (!pickerLabel)
    {
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:15]];
    }
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0)
    {
        self.selectProv = row;
        self.selectCity = 0;
        self.selectArea = 0;
        [self pickerReloadComponent:1 selectRow:0];
        [self pickerReloadComponent:2 selectRow:0];
    }
    else if (component == 1)
    {
        self.selectCity = row;
        self.selectArea = 0;
        [self pickerReloadComponent:2 selectRow:0];
    }
    else
    {
        self.selectArea = row;
    }
}

#pragma mark - Lazy
- (UIPickerView *)pickerView
{
    if (_pickerView == nil)
    {
        UIPickerView *pickerView = [[UIPickerView alloc] init];
        pickerView.delegate = self;
        pickerView.dataSource = self;
        pickerView.translatesAutoresizingMaskIntoConstraints = NO;
        pickerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:pickerView];
        
        [self equallyRelatedConstraintWithView:pickerView toView:self attribute:NSLayoutAttributeLeading];
        [self equallyRelatedConstraintWithView:pickerView toView:self attribute:NSLayoutAttributeTrailing];
        self.pickerViewBottomCons = [self equallyRelatedConstraintWithView:pickerView toView:self attribute:NSLayoutAttributeBottom];
        
        _pickerView = pickerView;
    }
    return _pickerView;
}

- (UIView *)toolView
{
    if (_toolView == nil)
    {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
        
        [self equallyRelatedConstraintWithView:view toView:self attribute:NSLayoutAttributeLeading];
        [self equallyRelatedConstraintWithView:view toView:self attribute:NSLayoutAttributeTrailing];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.pickerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        bottom.active = YES;
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40.0];
        height.active = YES;
        
        _toolView = view;
    }
    return _toolView;
}

- (UIButton *)cancelBtn
{
    if (_cancelBtn == nil)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [self.toolView addSubview:btn];
        
        NSLayoutConstraint *layoutConstraint = [self equallyRelatedConstraintWithView:btn toView:self.toolView attribute:NSLayoutAttributeLeading];
        layoutConstraint.constant = 10.0f;
        [self equallyRelatedConstraintWithView:btn toView:self.toolView attribute:NSLayoutAttributeCenterY];
        
        _cancelBtn = btn;
    }
    return _cancelBtn;
}

- (UIButton *)confirmBtn
{
    if (_confirmBtn == nil)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [btn setTitle:@"确定" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
        [self.toolView addSubview:btn];
        
        NSLayoutConstraint *layoutConstraint = [self equallyRelatedConstraintWithView:btn toView:self.toolView attribute:NSLayoutAttributeTrailing];
        layoutConstraint.constant = -10.0f;
        [self equallyRelatedConstraintWithView:btn toView:self.toolView attribute:NSLayoutAttributeCenterY];
        
        _confirmBtn = btn;
    }
    return _confirmBtn;
}

@end
