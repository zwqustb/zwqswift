//
//  BloodpressureVC.swift
//  ZwqSwift
//
//  Created by zhangwenqiang on 2018/7/4.
//  Copyright © 2018年 zhangwenqiang. All rights reserved.
//

import UIKit
let RefreshDevicesList = "BluetoothDidRefreshDevicesList"
let DidConnectToDevice = "BluetoothDidConnectToDevice"
let DidDisConnectToDevice = "BluetoothDidDisConnectToDevice"
let ConnectTimeout = "BluetoothConnectTimeout"
//连接血压计成功
let ConnectSucceed  = "ConnectToRGKTSphygmomanometerSucceed"
//连接血压计失败
let ConnectFailed  = "ConnectToRGKTSphygmomanometerFailed"
//启动测量成功
let StartSucceed =  "StartMeasureUsingRGKTSphygmomanometerSucceed"
//启动测量失败
let StartFailed  =   "StartMeasureUsingRGKTSphygmomanometerFailed"
//接收到测量结果
let ReceivedResult = "ReceivedRGKTSphygmomanometerMeasureResult"
//接收到测量数据
let ReceivedeData =  "ReceivedRGKTSphygmomanometerMeasureData"
//找到已用过蓝牙
let FindOldBlueTooth = "FindOldBlueTooth"
//获取电量成功
let GetPowerSucccess = "GetPowerSucccess"
//返回测量错误信息
let GetWrongMessage = "GetWrongMessage"

class BloodpressureVC: UIViewController {

    @IBOutlet weak var imgCircle: UIImageView!
    @IBOutlet weak var imgHeart: UIImageView!
    
    @IBOutlet weak var lValue1: UILabel!
    @IBOutlet weak var lValue2: UILabel!
    @IBOutlet weak var lValue3: UILabel!
    
    @IBOutlet weak var btnStart: UIButton!
    
    var peripheral:CBPeripheral?
    
    let stateSearchingDevice = "正在搜索设备..."
    let statePrepareOK = "开始测量"
    let stateWorking = "正在测量中..."
    let stateDisconnect = "打开设备蓝牙,点击配对"
//    var pHeart :UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavgationHidden(true)
//        let szHeart = imgHeart.frame.size
//        pHeart = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: szHeart.width, height: szHeart.height))
//        pHeart?.image = imgHeart.image
//        imgHeart.addSubview(pHeart!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onListRefersh), name: NSNotification.Name(RefreshDevicesList), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDevConnectOK), name: NSNotification.Name(DidConnectToDevice), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDevDisconnect), name: NSNotification.Name(DidDisConnectToDevice), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDevConnectTimeout), name: NSNotification.Name(ConnectTimeout), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onConnectOK), name: NSNotification.Name(ConnectSucceed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onConnectError), name: NSNotification.Name(ConnectFailed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onStartOK), name: NSNotification.Name(StartSucceed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onStartError), name: NSNotification.Name(StartFailed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveResult), name: NSNotification.Name(ReceivedResult), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveData), name: NSNotification.Name(ReceivedeData), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveWrongMsg), name: NSNotification.Name(GetWrongMessage), object: nil)
        // Do any additional setup after loading the view.
        setState(stateDisconnect)
    }

    
    //MARK:click
    @IBAction func clickStart(_ sender: UIButton) {
        let str = sender.title(for: .normal) ?? ""
        if str == statePrepareOK {
             BLEManager.shared().connectToRGKTSphygmomanometer()
        }else if str == stateSearchingDevice {
            BLEManager.shared().startScan()
        }else if str == stateDisconnect{
            setState(stateSearchingDevice)
        }
    }
    @IBAction func clickBack(_ sender: UIButton) {
        popView()
        BLEManager.shared().stopScan()
        if peripheral != nil {
            BLEManager.shared().disconnectDevice(peripheral)
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func log(_ str:String){
//        textView.text  = str + textView.text
//        textView.text = textView.text + "\n"
        print(str)
    }

    func setState(_ str:String){
        btnStart.setTitle(str, for: .normal)
        if str == stateSearchingDevice {
            BLEManager.shared().startScan()
        } else if str == stateDisconnect{
            BLEManager.shared().stopScan()
        }
        let bOk = str == statePrepareOK || str == stateWorking
        showPrepareOK(bOk)
        
    }
    func showPrepareOK(_ bOk:Bool){
        imgHeart.isHidden = !bOk
        if bOk {
            imgCircle.image = #imageLiteral(resourceName: "iconCircleBold")
        }else{
            imgCircle.image = #imageLiteral(resourceName: "iconCircle")
        }
    }
    //MARK:回调事件
    @objc fileprivate func onListRefersh(sender:NSNotification){
         log("设备列表刷新")
        let ary = sender.object as? NSArray ?? []
        let aPeripheral = ary.lastObject as? CBPeripheral
        if aPeripheral?.name == nil {
            return
        }
        if aPeripheral!.name!.hasPrefix("RBP") {
            peripheral = BLEManager.shared().devicesListArr.lastObject as? CBPeripheral
            log("找到RBP")
            BLEManager.shared().stopScan()
            BLEManager.shared().connectDevice(peripheral)
        }
    }
    @objc fileprivate func onDevConnectOK(sender:NSNotification){
        log("设备连接成功")
        setState(statePrepareOK)
       // BLEManager.shared().connectToRGKTSphygmomanometer()
    }
    @objc fileprivate func onDevDisconnect(sender:NSNotification){
        setState(stateDisconnect)
        log("设备断开连接")
    }
    @objc fileprivate func onDevConnectTimeout(sender:NSNotification){
        setState(stateDisconnect)
        log("设备连接超时")
    }
    
     @objc fileprivate func onConnectOK(sender:NSNotification){
        log("血压计连接成功")
        BLEManager.shared().startMeasureUsingRGKTSphygmomanometer()
    }
     @objc fileprivate func onConnectError(sender:NSNotification){
        log("血压计连接失败")
    }
     @objc fileprivate func onStartOK(sender:NSNotification){
        log("启动成功")
        setState(stateWorking)
    }
     @objc fileprivate func onStartError(sender:NSNotification){
        log("启动失败")
    }
     @objc fileprivate func onReceiveResult(sender:NSNotification){
        let pAny = sender.object
        // let pUserInfo = sender.userInfo
        if pAny is NSArray {
            let pAry = pAny as? NSArray ?? []
            log("收到结果ary\(pAry)")
        }else if pAny is NSDictionary{
            let pDic = pAny as? NSDictionary ?? ["":""]
            log("收到结果dic\(pDic)")
        }else if pAny is String{
            log("收到结果Str\(pAny as! String)")
        }else if pAny is NSData{
            let str = String.init(data: pAny as! Data, encoding: .utf8)
            log("收到结果Data\(str ?? "")")
        }else if pAny is RGKT_MeasureResult_Model{
            let pMode = pAny as? RGKT_MeasureResult_Model
            lValue1.text = pMode?.lowPressure
            lValue2.text = pMode?.highPressure
            lValue3.text = pMode?.heartRate
              log("收到结果modal\(pMode?.lowPressure ?? "nil")")
        }
//        let pMode = pAny as! LLBLLodpressEquementmodel
//        lValue1.text = pMode.lowPressure ?? "--"
//        lValue2.text = pMode.highPressure ?? "--"
//        lValue3.text = pMode.heartRate ?? "--"
        log("收到结果Any\(getClassNameOfAnyObject(object: pAny ?? ""))")
        let pMode = pAny as! RGKT_MeasureResult_Model
        lValue1.text = pMode.lowPressure
        lValue2.text = pMode.highPressure
        lValue3.text = pMode.heartRate
        log("收到结果modal\(pMode.lowPressure ?? "nil")")
        self.setAnimation(false)
        setState(statePrepareOK)
    }
    @objc fileprivate func onReceiveWrongMsg(sender:NSNotification){
        let pAny = sender.object
        let pError = sender.userInfo
        log("收到wrongMsgAny\(getClassNameOfAnyObject(object: pAny ?? ""))")
        log("收到wrongMsg\(pAny ?? "nil")")
        if pAny is String{
//            BOEProgressHUD.showError(withStatus: "\(pAny ?? "获取失败")")
        }
        setState(statePrepareOK)
    }
     @objc fileprivate func onReceiveData(sender:NSNotification){
        let pAny = sender.object
        var str = "--"
        // let pUserInfo = sender.userInfo
        if pAny is NSArray {
            let pAry = pAny as? NSArray ?? []
            log("收到数据Ary\(pAry)")
        }else if pAny is NSDictionary{
            let pDic = pAny as? NSDictionary ?? ["":""]
            log("收到数据dic\(pDic)")
        }else if pAny is String{
            str = pAny as? String ?? "--"
            log("收到数据Str\(str)")
        }else if pAny is NSData{
            let str = String.init(data: pAny as! Data, encoding: .utf8)
            log("收到数据Data\(str ?? "")")
        }else{
            log("收到数据\(pAny ?? "")")
        }
        self.setAnimation(true)
        lValue1.text = "\(str)/mmHg"
    }
    func setAnimation(_ bAnimation:Bool){
        
        UIView.animateKeyframes(withDuration: 1.2, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                self.imgHeart?.transform = CGAffineTransform.identity
                    .scaledBy(x: 1.1, y: 1.1)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                self.imgHeart?.transform = CGAffineTransform.identity
                    .scaledBy(x: 1, y: 1)
            })
        }, completion: nil)
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
