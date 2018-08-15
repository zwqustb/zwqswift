//
//  AnyRGKT_MeasureResult_Model.h
//  健康管理卫士
//
//  Created by lvlei on 15/11/20.
//  Copyright © 2015年 CHNI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RGKT_MeasureResult_Model : NSObject<NSCoding>

//房颤
@property (assign, nonatomic) BOOL heartAtriumShake;
//心率不齐
@property (assign, nonatomic) BOOL heartRateIrregular;
//是否正常
@property (assign, nonatomic) BOOL isHealth;

//测量时间
@property (copy, nonatomic) NSString *measureDate;
//收缩压
@property (copy, nonatomic) NSString *highPressure;
//舒张压
@property (copy, nonatomic) NSString *lowPressure;
//脉压差
@property (copy, nonatomic) NSString *differencePressure;
//心率
@property (copy, nonatomic) NSString *heartRate;
//电量
@property (copy, nonatomic) NSString *power;


@end
