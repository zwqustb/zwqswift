//
//  BlueToothMode.swift
//  MobileHealth
//
//  Created by zhangwenqiang on 2018/7/5.
//  Copyright © 2018年 Jiankun Zhang. All rights reserved.
//

import UIKit
import CoreBluetooth

let kDiscoverCharacter = "DiscoverCharacteristics"
public protocol BlueToothDelegate: NSObjectProtocol{
    func deviceConnectStateChangeTo(_ bConnect:Bool)
    func characteristicDidConnect()
    func didReceiveData(_ strData:String)
}
class BlueToothMode: NSObject,CBCentralManagerDelegate,CBPeripheralDelegate {
    static let `default` = BlueToothMode()
    var centralManager: CBCentralManager?
    var peripheral: CBPeripheral?
//    var characteristic: CBCharacteristic?
    var characteristicWrite: CBCharacteristic?
    var characteristicRead: CBCharacteristic?
    var m_bSearchAllDevice = false
    var bHexData = false // 解析data的方式是hex还是utf8
    //bgn
    //女子体温
    var Service_UUID: String = "1808"
    var Characteristic_UUID_write: String = "FFF4"
    var Characteristic_UUID_read: String = "FFF4"
    var bConnectWhenFind = false
    //end
    var aryPeripheral = NSMutableArray.init()
    
    var aryHistory = NSMutableArray.init()
    var dicData = NSMutableDictionary.init()
    var m_strFliter:String?
    weak var delegate:BlueToothDelegate?
    func initCenter(){
         centralManager = CBCentralManager.init(delegate: self, queue: .main)
    }
    //MARK: BTDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("未知的")
        case .resetting:
            print("重置中")
        case .unsupported:
            print("不支持")
        case .unauthorized:
            print("未验证")
        case .poweredOff:
            print("未启动")
        case .poweredOn:
            print("可用1")
            self.startScan(m_bSearchAllDevice)
            print("可用2")
        }
    }
    func startScan(_ bAll:Bool = false){
        if self.centralManager == nil {
            m_bSearchAllDevice = bAll
            self.initCenter()
            print("central init")
            return
        }
        if bAll {
           //查找全部
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }else{
           //查找女子体温计
            self.centralManager?.scanForPeripherals(withServices: [CBUUID.init(string: Service_UUID)], options: nil)
        }
    }
    func stopScan(){
         self.centralManager?.stopScan()
    }
    func connectDevice(){
        if peripheral != nil {
            centralManager?.connect(peripheral!, options: nil)
        }
    }
    func disconnectDevice(){
        if peripheral != nil {
            centralManager?.cancelPeripheralConnection(peripheral!)
        }
    }
    //过滤 ,发现设备
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //self.peripheral = peripheral
        print(peripheral.name ?? "")
        if m_strFliter != nil {
            let strName = peripheral.name
            if(strName == nil || !strName!.hasPrefix(m_strFliter!)){
                return
            }
        }
        // 根据外设名称来过滤
        //        if (peripheral.name?.hasPrefix("WH"))! {
        //            central.connect(peripheral, options: nil)
        //        }
        //central.connect(peripheral, options: nil)
        if !aryPeripheral.contains(peripheral) {
            aryPeripheral.add(peripheral)
//            NotificationCenter.default.post(name: Notification.Name(RefreshDevicesList), object: self.aryPeripheral)
            if bConnectWhenFind{
                self.peripheral = peripheral
                self.connectDevice()
            }
        }
    }
    /** 连接成功 */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
                self.centralManager?.stopScan()
                peripheral.delegate = self
                peripheral.discoverServices([CBUUID.init(string: Service_UUID)])
                print("连接成功")
//         NotificationCenter.default.post(name: Notification.Name(DidConnectToDevice), object: self.aryPeripheral)
        delegate?.deviceConnectStateChangeTo(true)
        //        self.connectResult(true)
    }
    /** 连接失败的回调 */
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("连接失败")
//        NotificationCenter.default.post(name: Notification.Name(DidDisConnectToDevice), object: self.aryPeripheral)
        //self.connectResult(false)
    }
    
    /** 断开连接 */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("断开连接")
//        NotificationCenter.default.post(name: Notification.Name(DidDisConnectToDevice), object: self.aryPeripheral)
        //self.connectResult(false)
        delegate?.deviceConnectStateChangeTo(false)
        // 重新连接
        central.connect(peripheral, options: nil)
        
    }
    /** 发现服务 */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service: CBService in peripheral.services! {
            print("外设中的服务有：\(service)")
        }
        //本例的外设中只有一个服务
        let service = peripheral.services?.last
        // 根据UUID寻找服务中的特征
        if service != nil{
//            peripheral.discoverCharacteristics([CBUUID.init(string: Characteristic_UUID)], for: service!)
             peripheral.discoverCharacteristics(nil, for: service!)
        }
        
    }
    /** 发现特征 */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic: CBCharacteristic in service.characteristics! {
            print("外设中的特征有：\(characteristic)")
        }
        let ary = service.characteristics
        ary?.forEach({ (c) in
            if c.uuid.uuidString == self.Characteristic_UUID_write{
                self.characteristicWrite = c
            }
            if c.uuid.uuidString == self.Characteristic_UUID_read{
                self.characteristicRead = c
            }
        })
        // 读取特征里的数据
        if self.characteristicRead != nil {
            peripheral.readValue(for: self.characteristicRead!)
            // 订阅
            peripheral.setNotifyValue(true, for: self.characteristicRead!)
        }
        delegate?.characteristicDidConnect()
    }
    /** 订阅状态 */
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("订阅失败: \(error)")
            return
        }
        if characteristic.isNotifying {
            print("订阅成功")
        } else {
            print("取消订阅")
        }
    }
    //MARK:/** 接收到数据 */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let data = characteristic.value
        if data == nil {
            return
        }
        var str = String.init(data: data!, encoding: String.Encoding.utf8)
        if bHexData{
            str = data?.hexString()
        }
        if str == nil {
            return
        }
        delegate?.didReceiveData(str!)
        if str!.count < 12 {
            return
        }
        dicData["data"] = str!
        print("接收到数据:\(str!)")
        let cmd = str!.substring(in: 3)
        if str!.hasPrefix("DT") {//文度
            switch cmd{
            case "0":
                self.getDataByBT()
                break
            case "1":
                let temInt = str!.substring(from: 4,length:2)
                let temFloat = str!.substring(from: 6,length:2)
                dicData["温度"] = "\(temInt).\(temFloat)"

                break
                
            case "2":
                let pIndex = str!.substring(from: 4,length:2)
                let temInt = str!.substring(from: 6,length:2)
                let temFloat = str!.substring(from: 8,length:2)
                dicData["\(pIndex)温度"] = "温度:\(temInt).\(temFloat)℃"
                break
            default:
                print("back:\(str!)")
                break
            }
        }else if str!.hasPrefix("TM"){//时间
            switch cmd{
                
            case "1":
                let timeM = str!.substring(from: 4,length:2)
                let timeD = str!.substring(from: 6,length:2)
                let timeHour = str!.substring(from: 8,length:2)
                let timeMin = str!.substring(from: 10,length:2)
                dicData["时间"] = "\(timeM)/\(timeD) \(timeHour):\(timeMin)"
                break
            case "2":
                let pIndex = str!.substring(from: 4,length:2)
                let timeM = str!.substring(from: 6,length:2)
                let timeD = str!.substring(from: 8,length:2)
                let timeHour = str!.substring(from:10,length:2)
                let timeMin = str!.substring(from: 12,length:2)
                dicData["\(pIndex)时间"] = "时间:\(timeM)/\(timeD) \(timeHour):\(timeMin)"
                if !aryHistory.contains(pIndex){
                    aryHistory.add(pIndex)
                }
                break
            default:
                break
            }
            if cmd == "1"{
                
            }
        }
//        NotificationCenter.default.post(name: Notification.Name(ReceivedeData), object: data)
        
        //self.didReceiveData(str ?? "")
    }
    /** 写入数据完成 */
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("写入数据")
    }
    //MARK:delegate
    /** 读到数据 */
    func getDataByBT() {
        self.peripheral?.readValue(for: self.characteristicRead!)
        self.getHistory()
    }
    //同步时间
    func sendData(_ txt:String)  {
        let data = txt.data(using: String.Encoding.utf8)
        //        let data = (self.textFiled.text ?? "empty input")!.data(using: String.Encoding.utf8)
        self.peripheral?.writeValue(data!, for: self.characteristicWrite!, type: CBCharacteristicWriteType.withResponse)
    }
    func getHistory() {
        aryHistory.removeAllObjects()
        //let strDate = DateTools.date2String(Date.init(), "MMddHHmm")
        let txt = "DT62000000000"
        let data = txt.data(using: String.Encoding.utf8)
        //        let data = (self.textFiled.text ?? "empty input")!.data(using: String.Encoding.utf8)
        self.peripheral?.writeValue(data!, for: self.characteristicWrite!, type: CBCharacteristicWriteType.withResponse)
    }
    func clickClearData(_ sender: UIButton) {
        aryHistory.removeAllObjects()
        let txt = "DT63000000000"
        let data = txt.data(using: String.Encoding.utf8)
        //        let data = (self.textFiled.text ?? "empty input")!.data(using: String.Encoding.utf8)
        self.peripheral?.writeValue(data!, for: self.characteristicWrite!, type: CBCharacteristicWriteType.withResponse)
    }
    //MARK:写入数据
    func writeData(_ strData:String){
//        var data = bHexData ? strData.hexadecimal() : strData.data(using: String.Encoding.utf8)
//        if data == nil {
//            return
//        }
        //        let data = (self.textFiled.text ?? "empty input")!.data(using: String.Encoding.utf8)
        //        let  data =
        //5AA503B0020E
        
        // let bytes:[UInt8] = [0x5A, 0xA5, 0x03, 0xB0,0x02,0x0E];
        // let data0 = Data.init(bytes: bytes)
        self.peripheral?.writeValue(data!, for: self.characteristicWrite!, type: CBCharacteristicWriteType.withResponse)
    }
}
