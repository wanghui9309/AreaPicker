//
//  WHAreaList.m
//
//  Created by WangHui on 2017/12/29.
//  Copyright © 2017年 WangHui. All rights reserved.
//

#import "WHAreaList.h"

#import <objc/runtime.h>

@implementation WHAreaList

/**
 通过字典数组来创建一个模型数组

 @param keyValuesArray 字典数组
 @return 模型数组
 */
+ (NSMutableArray *)wh_objectArrayWithKeyValuesArray:(id)keyValuesArray
{
    NSMutableArray *modelArray = [NSMutableArray array];
    
    for (NSDictionary *keyValues in keyValuesArray)
    {
        if ([keyValues isKindOfClass:[NSArray class]])
        {
            [modelArray addObject:[self wh_objectArrayWithKeyValuesArray:keyValues]];
        }
        else
        {
            id model = [self wh_objectWithKeyValues:keyValues];
            if (model) [modelArray addObject:model];
        }
    }
    
    return modelArray;
}

/**
 通过字典来创建一个模型

 @param keyValues 字典
 @return 新建的对象
 */
+ (instancetype)wh_objectWithKeyValues:(id)keyValues
{
    return [[self new] wh_setKeyValues:keyValues];
}

/**
 将字典的键值对转成模型属性

 @param keyValues 字典
 */
- (instancetype)wh_setKeyValues:(id)keyValues
{
    unsigned int count = 0;
    //获取类中所有成员变量名
    objc_property_t *properties = class_copyPropertyList(self.class, &count);
    
    for (int i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        // 1.属性名
        NSString *name = @(property_getName(property));
        // 2.获取value
        id value = [keyValues valueForKey:name];
        
        // 如果没有值，就直接跳过
        if (!value || value == [NSNull null]) continue;
        
        // 3.属性描述
        unsigned int attrCount = 0;
        objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
        
        for (int j = 0; j < attrCount; j++)
        {
            /**
             属性类型  name值：T  value：变化
             编码类型  name值：C(copy) &(strong) W(weak) 空(assign) 等 value：无
             非/原子性 name值：空(atomic) N(Nonatomic)  value：无
             变量名称  name值：V  value：变化
             */
            objc_property_attribute_t attr = attrs[j];
            
            // 判断是否是属性类型
            if (![@(attr.name) isEqualToString:@"T"]) break;
            
            // 去掉 @"和" 截取中间的类型名称
            NSString *code = @(attr.value);
            code = [code substringWithRange:NSMakeRange(2, code.length - 3)];
            Class typeClass = NSClassFromString(code);
            
            if (typeClass == NSString.class)
            {// 属性是字符串类型
                [self setValue:value forKey:name];
            }
            else if (typeClass == NSMutableArray.class && [value isKindOfClass:NSArray.class])
            {// 属性是数组类型
                value = [NSMutableArray arrayWithArray:[self.class wh_objectArrayWithKeyValuesArray:value]];
                [self setValue:value forKey:name];
            }
        }
        free(attrs);
    }
    free(properties);
    
    return self;
}

@end
