//
//  WHAreaPickerController.m
//  布偶屋
//
//  Created by WangHui on 2018/1/2.
//  Copyright © 2018年 WangHui. All rights reserved.
//

#import "WHAreaPickerController.h"

@interface WHAreaPickerController ()<UIPickerViewDataSource, UIPickerViewDelegate>

/** 地址选择器视图 */
@property (weak, nonatomic) UIPickerView *pickerView;
/** 地址选择器 底部约束 */
@property (weak, nonatomic) NSLayoutConstraint *pickerViewBottomCons;
/** 工具视图 */
@property (weak, nonatomic) UIView *toolView;
/** 数据源 */
@property (strong, nonatomic) NSArray<WHAreaList *> *dataSource;
/** 选中的省份 下标 默认为0 */
@property (assign, nonatomic) NSInteger selectProv;
/** 选中的城市 下标 默认为0 */
@property (assign, nonatomic) NSInteger selectCity;
/** 选中的地区 下标 默认为0 */
@property (assign, nonatomic) NSInteger selectArea;
/** 上次选中的地区 [0:省份下标,1:城市下标,2:县区下标] */
@property (strong, nonatomic) NSArray<NSNumber *> *lastAreas;

@end

@implementation WHAreaPickerController

/**
 初始化方法 / 控制器 Present 的时候使用
 */
+ (instancetype)areaPickerController:(id<WHAreaPickerControllerDelegate>)delegate
{
    return [WHAreaPickerController areaPickerController:delegate lastAreas:nil];
}

/**
 初始化方法 显示上次结果 / 控制器 Present 的时候使用
 
 @param lastAreas 上次选中的地区下标 delegate 返回的,在传进来
 */
+ (instancetype)areaPickerController:(id<WHAreaPickerControllerDelegate>)delegate lastAreas:(NSArray<NSNumber *> *)lastAreas
{
    WHAreaPickerController *vc = [WHAreaPickerController new];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    vc.delegate = delegate;
    vc.lastAreas = lastAreas;
    vc.view.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    
    return vc;
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
        pickerView.backgroundColor = [UIColor colorWithRed:236/255.0f green:236/255.0f blue:236/255.0f alpha:1.0f];
        [self.view addSubview:pickerView];
        
        [self equallyRelatedConstraintWithView:pickerView attribute:NSLayoutAttributeLeading];
        [self equallyRelatedConstraintWithView:pickerView attribute:NSLayoutAttributeTrailing];
        self.pickerViewBottomCons = [self equallyRelatedConstraintWithView:pickerView attribute:NSLayoutAttributeBottomMargin];
        self.pickerViewBottomCons.constant = 300;
        
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
        [self.view addSubview:view];
        
        [self equallyRelatedConstraintWithView:view attribute:NSLayoutAttributeLeading];
        [self equallyRelatedConstraintWithView:view attribute:NSLayoutAttributeTrailing];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.pickerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        bottom.active = YES;
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40.0];
        height.active = YES;
        
        _toolView = view;
    }
    return _toolView;
}

#pragma mark - Layout
- (NSLayoutConstraint *)equallyRelatedConstraintWithView:(UIView *)view attribute:(NSLayoutAttribute)attribute
{
    NSLayoutConstraint *layoutConstraint = [NSLayoutConstraint constraintWithItem:view attribute:attribute relatedBy:NSLayoutRelationEqual toItem:self.view attribute:attribute multiplier:1.0 constant:0.0];
    layoutConstraint.active = YES;
    return layoutConstraint;
}

#pragma mark - 系统方法
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
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

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self confirmAction];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.pickerViewBottomCons.constant = 0;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

/**
 初始化数据
 */
- (void)initData
{
    NSString *filePath = [NSBundle.mainBundle pathForResource:@"area" ofType:@"plist"];
    NSArray *areaArr = [NSArray arrayWithContentsOfFile:filePath];
    self.dataSource = [WHAreaList wh_objectArrayWithKeyValuesArray:areaArr];
    [self.pickerView reloadAllComponents];
    
    [self toolView];
}

#pragma mark - Action
/**
 取消
 */
- (void)cancelAction
{
    self.pickerViewBottomCons.constant = 300;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

/**
 确认
 */
- (void)confirmAction
{
    WHAreaList *prov = self.dataSource[self.selectProv];
    WHAreaList *city = prov.child[self.selectCity];
    WHAreaList *area = city.child[self.selectArea];
    
    if ([self.delegate respondsToSelector:@selector(areaPickerController:didFinishPickingArea:)])
    {
        [self.delegate areaPickerController:self didFinishPickingArea:@[@(self.selectProv), @(self.selectCity), @(self.selectArea)]];
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

@end
