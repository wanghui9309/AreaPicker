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
@property (weak, nonatomic) IBOutlet UIPickerView *areaPickerView;
/** 工具视图 */
@property (weak, nonatomic) IBOutlet UIView *toolView;
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
    
    return vc;
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

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self confirmAction];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.areaPickerView.hidden = YES;
    self.toolView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.areaPickerView.hidden = NO;
    self.toolView.hidden = NO;
    
    CGRect srect = self.areaPickerView.frame;
    CGRect drect = srect;
    CGRect stRect = self.toolView.frame;
    CGRect dtRect = stRect;

    float ah = srect.size.height+stRect.size.height;
    srect.origin.y += ah;
    stRect.origin.y += ah;
    self.areaPickerView.frame= srect;
    self.toolView.frame = stRect;

    [UIView animateWithDuration:0.2 animations:^{
        self.areaPickerView.frame=drect;
        self.toolView.frame = dtRect;
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
    [self.areaPickerView reloadAllComponents];
}

#pragma mark - Action
/**
 取消
 */
- (IBAction)cancelAction
{
    
    CGRect drect = self.areaPickerView.frame;
    CGRect dtRect = self.toolView.frame;
    
    float ah = drect.size.height+dtRect.size.height;
    drect.origin.y += ah;
    dtRect.origin.y += ah;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.areaPickerView.frame=drect;
        self.toolView.frame = dtRect;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
    
}

/**
 确认
 */
- (IBAction)confirmAction
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
    [self.areaPickerView reloadComponent:component];
    [self.areaPickerView selectRow:row inComponent:component animated:YES];
}

@end
