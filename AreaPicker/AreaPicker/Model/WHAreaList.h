//
//  WHAreaList.h
//
//  Created by WangHui on 2017/12/29.
//  Copyright © 2017年 WangHui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WHAreaList : NSObject

/** 地区编号 */
@property (nonatomic, strong) NSString *area_id;
/** 父级编号 */
@property (nonatomic, strong) NSString *parent_id;
/** 地区名 */
@property (nonatomic, strong) NSString *area_name;
@property (nonatomic, strong) NSString *sort;
/** 子列表 */
@property (nonatomic, strong) NSMutableArray<WHAreaList *> *child;


/**
 通过字典数组来创建一个模型数组
 
 @param keyValuesArray 字典数组
 @return 模型数组
 */
+ (NSMutableArray *)wh_objectArrayWithKeyValuesArray:(id)keyValuesArray;

@end
