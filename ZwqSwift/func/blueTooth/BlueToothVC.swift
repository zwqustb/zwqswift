//
//  BlueToothVC.swift
//  MobileHealth
//
//  Created by zhangwenqiang on 2018/7/2.
//  Copyright © 2018年 Jiankun Zhang. All rights reserved.
//

import UIKit
import CoreBluetooth
class BlueToothVC: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var lTime: UILabel!
    @IBOutlet weak var lTemperature: UILabel!
    @IBOutlet weak var pTable: UITableView!
    
    var aryPeripherals = NSMutableArray.init()
    
    private var centralManager: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var characteristic: CBCharacteristic?
//    private let Service_UUID: String = "1808"
//    private let Characteristic_UUID: String = "FFF4"
    private let Service_UUID: String = "BA11"
    private let Characteristic_UUID: String = "CD04"
    var aryHistory = NSMutableArray.init()
    var dicData = NSMutableDictionary.init()
    
    @IBOutlet weak var textFiled: UILabel!
    override func viewDidLoad() {
      //  super.viewDidLoad()
        //self.navigationBarHidden = false
//        let pVC = EquipmentListViewController.init()
//        pVC.m_strFliter = "";
//        pushView(pVC)
        pTable.dataSource = self
        pTable.delegate = self
        pTable.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        centralManager = CBCentralManager.init(delegate: self, queue: .main)
        print("可用3")
        //self.startScan()
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            self.startScan()
            print("可用2")
        }
    }
    func startScan(){
        aryPeripherals.removeAllObjects()
        if self.centralManager == nil {
            print("central is nil")
        }
        //self.centralManager?.scan
        self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
       // self.centralManager?.scanForPeripherals(withServices: [CBUUID.init(string: Service_UUID)], options: nil)
    }
    //过滤
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.peripheral = peripheral
        print(peripheral.name ?? "")
        if !self.aryPeripherals.contains(peripheral) {
            self.aryPeripherals.add(peripheral)
        }
        // 根据外设名称来过滤
        //        if (peripheral.name?.hasPrefix("WH"))! {
        //            central.connect(peripheral, options: nil)
        //        }
        central.connect(peripheral, options: nil)
    }
    /** 连接成功 */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.centralManager?.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID.init(string: Service_UUID)])
        print("连接成功")
    }
    /** 连接失败的回调 */
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("连接失败")
    }
    
    /** 断开连接 */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("断开连接")
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
        if service != nil {
            peripheral.discoverCharacteristics([CBUUID.init(string: Characteristic_UUID)], for: service!)
        }
    }
    /** 发现特征 */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic: CBCharacteristic in service.characteristics! {
            print("外设中的特征有：\(characteristic)")
        }
        
        self.characteristic = service.characteristics?.last
        // 读取特征里的数据
        peripheral.readValue(for: self.characteristic!)
        // 订阅
        peripheral.setNotifyValue(true, for: self.characteristic!)
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
        // print(data)
        if data == nil {
            return
        }
        let str = String.init(data: data!, encoding: String.Encoding.utf8)
        if str == nil || str!.count < 12{
            return
        }
        print("接收到数据:\(str!)")
        self.textFiled.text = str
        let cmd = str!.substring(in: 3)
        if str!.hasPrefix("DT") {
            switch cmd{
            case "1":
                let temInt = str!.substring(from: 4,length:2)
                let temFloat = str!.substring(from: 6,length:2)
                self.lTemperature.text = "温度:\(temInt).\(temFloat)℃"
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
        }else if str!.hasPrefix("TM"){
            switch cmd{
            case "1":
                let timeM = str!.substring(from: 4,length:2)
                let timeD = str!.substring(from: 6,length:2)
                let timeHour = str!.substring(from: 8,length:2)
                let timeMin = str!.substring(from: 10,length:2)
                self.lTime.text = "时间:\(timeM)/\(timeD) \(timeHour):\(timeMin)"
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
                    pTable.reloadData()
                }
                break
            default:
                break
            }
            if cmd == "1"{
                
            }
        }
    }
    /** 写入数据完成 */
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("写入数据")
    }
    //MARK:delegate
    /** 读到数据 */
    func getDataByBt(_ sender: Any) {
        self.peripheral?.readValue(for: self.characteristic!)
    }
    //MARK: click  /*写入数据*/
    @IBAction func sendTime(_ sender: Any) {
        let strDate = DateTools.date2String(Date.init(), "MMddHHmm")
        let txt = "TM60\(strDate)0"
        let data = txt.data(using: String.Encoding.utf8)
        //        let data = (self.textFiled.text ?? "empty input")!.data(using: String.Encoding.utf8)
        self.peripheral?.writeValue(data!, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
       // self.peripheral?.readValue(for: self.characteristic!)
    }

    @IBAction func getHistory(_ sender: UIButton) {
        aryHistory.removeAllObjects()
        //let strDate = DateTools.date2String(Date.init(), "MMddHHmm")
        let txt = "DT62000000000"
        let data = txt.data(using: String.Encoding.utf8)
        //        let data = (self.textFiled.text ?? "empty input")!.data(using: String.Encoding.utf8)
        self.peripheral?.writeValue(data!, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    
    @IBAction func clickClearData(_ sender: UIButton) {
        aryHistory.removeAllObjects()
        pTable.reloadData()
        let txt = "DT63000000000"
        let data = txt.data(using: String.Encoding.utf8)
        //        let data = (self.textFiled.text ?? "empty input")!.data(using: String.Encoding.utf8)
        self.peripheral?.writeValue(data!, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    // Mark:table delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell")
//        if cell == nil {
          let  cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "HistoryCell")
//        }
        let pIndex = aryHistory[indexPath.row] as? String ?? ""
        cell.textLabel?.text = dicData["\(pIndex)时间"] as? String
        cell.detailTextLabel?.text = dicData["\(pIndex)温度"] as? String
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
