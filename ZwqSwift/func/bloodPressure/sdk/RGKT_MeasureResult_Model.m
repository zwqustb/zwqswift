//
//  LLBLLodpressEquementmodel.m
//  健康管理卫士
//
//  Created by lvlei on 15/11/20.
//  Copyright © 2015年 CHNI. All rights reserved.
//

#import "RGKT_MeasureResult_Model.h"

@implementation RGKT_MeasureResult_Model

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_measureDate forKey:@"measureDate"];
    [aCoder encodeObject:_highPressure forKey:@"highPressure"];
    [aCoder encodeObject:_lowPressure forKey:@"lowPressure"];
    [aCoder encodeObject:_heartRate forKey:@"heartRate"];
    [aCoder encodeObject:_differencePressure forKey:@"differencePressure"];
    [aCoder encodeBool:_heartAtriumShake forKey:@"heartAtriumShake"];
    [aCoder encodeBool:_heartRateIrregular
                forKey:@"heartRateIrregular"];
    [aCoder encodeBool:_isHealth forKey:@"isHealth "];
    [aCoder encodeObject:_power forKey:@"power "];
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder{
    //使用NSCoder的方法从归档中依次恢复该对象的每一个属性
    self = [super init];
    if (self) {
        
     _measureDate=[[aDecoder decodeObjectForKey:@"measureDate"] copy];
    _highPressure = [[aDecoder decodeObjectForKey:@"highPressure"] copy];
    _lowPressure=[[aDecoder decodeObjectForKey:@"lowPressure"] copy];
     _heartRate=[[aDecoder decodeObjectForKey:@"heartRate"] copy];
      _differencePressure=[[aDecoder decodeObjectForKey:@"differencePressure"] copy];
       _power=[[aDecoder decodeObjectForKey:@"power"] copy];
        _isHealth = [aDecoder decodeBoolForKey:@"isHealth"];
        _heartAtriumShake = [aDecoder decodeBoolForKey:@"heartAtriumShake"];
        _heartRateIrregular = [aDecoder decodeBoolForKey:@"heartRateIrregular"];
    
    }
    
    return self;
}

@end
