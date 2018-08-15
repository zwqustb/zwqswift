//
//  BLEManager.h
//  BLEManager
//
//  Created by 赵宇鹏 on 15/5/18.
//  Copyright (c) 2015年 赵宇鹏. All rights reserved.
//

#define BluetoothDidRefreshDevicesList  @"BluetoothDidRefreshDevicesList"
#define BluetoothDidConnectToDevice     @"BluetoothDidConnectToDevice"
#define BluetoothDidDisConnectToDevice  @"BluetoothDidDisConnectToDevice"
#define BluetoothConnectTimeout         @"BluetoothConnectTimeout"

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

//蓝牙状态
typedef NS_ENUM(NSInteger, AllBLESTATUS)
{
    BLE_STATUS_IDLE = 0,
    BLE_STATUS_SCANNING,
    BLE_STATUS_CONNECTING,
    BLE_STATUS_CONNECTED,
    BLE_STATUS_PowerOn,
    BLE_STATUS_PowerOff,
};

@interface BLEManager : NSObject

//搜索到的所有蓝牙设备
@property (strong, nonatomic, readonly) NSMutableArray *devicesListArr;
//蓝牙状态
@property (assign, nonatomic, readonly) AllBLESTATUS BLEStatus;
//当前连接的设备
@property (strong, nonatomic, readonly) CBPeripheral *connectedPeripheral;

+ (BLEManager *)sharedManager;

//开始搜索
- (void)startScan;
//停止搜索
- (void)stopScan;
//连接设备
- (void)connectDevice:(CBPeripheral *)peripheral;
//断开设备
- (void)disconnectDevice:(CBPeripheral *)peripheral;


//**************************************医客网络**************************************
//注册通知ID
//连接血压计成功
#define ConnectToRGKTSphygmomanometerSucceed            @"ConnectToRGKTSphygmomanometerSucceed"
//连接血压计失败
#define ConnectToRGKTSphygmomanometerFailed             @"ConnectToRGKTSphygmomanometerFailed"
//连接血压计
- (void)connectToRGKTSphygmomanometer;


//启动测量成功
#define StartMeasureUsingRGKTSphygmomanometerSucceed    @"StartMeasureUsingRGKTSphygmomanometerSucceed"
//启动测量失败
#define StartMeasureUsingRGKTSphygmomanometerFailed     @"StartMeasureUsingRGKTSphygmomanometerFailed"
//接收到测量结果
#define ReceivedRGKTSphygmomanometerMeasureResult       @"ReceivedRGKTSphygmomanometerMeasureResult"
//接收到测量数据
#define ReceivedRGKTSphygmomanometerMeasureData       @"ReceivedRGKTSphygmomanometerMeasureData"
//找到已用过蓝牙
#define FindOldBlueTooth @"FindOldBlueTooth"
//获取电量成功
#define GetPowerSucccess @"GetPowerSucccess"
//返回测量错误信息
#define GetWrongMessage @"GetWrongMessage"

//启动测量
- (void)startMeasureUsingRGKTSphygmomanometer;
//停止测量
- (void)stopMeasureUsingRGKTSphygmomanometer;
//查询电量
- (void)getMeasureUsingRGKTMessage;
//置空
+ (BLEManager *)returnNil;

//**************************************医客网络**************************************

@end
