//
//  UITools.swift
//  YouYiDian
//
//  Created by zhangwenqiang on 2017/12/19.
//  Copyright © 2017年 zhangwenqiang. All rights reserved.
//

import UIKit
let KScreenWidth = UIScreen.main.bounds.size.width
let KScreenHeight = UIScreen.main.bounds.size.height
func getNavHeight(_ bNavHidden:Bool)->CGFloat{
    let nTopH = UIApplication.shared.statusBarFrame.size.height
    if bNavHidden {
        return nTopH
    }else{
        return 44 + nTopH
    }
}
func getNavVC() -> UINavigationController {
    var pNav:UINavigationController? = nil
    let pVC = UIApplication.shared.keyWindow?.rootViewController
    if pVC is UINavigationController {
        pNav = pVC as? UINavigationController
    }else if pVC is UITabBarController{
        let pTabVC = pVC as! UITabBarController
        let pVC1 = pTabVC.selectedViewController
        if pVC1 is UINavigationController{
            pNav = pVC1 as? UINavigationController
        }
    }else{
        pNav = pVC?.navigationController
    }
    return pNav!
}
func pushView(_ pVC:UIViewController){
    let pNav = getNavVC()
    pNav.pushViewController(pVC, animated:true)
}
func popView(){
    let pNav = getNavVC()
    pNav.popViewController(animated: true)
}
func showView(_ pVC:UIViewController){
    let pNav = getNavVC()
    pNav.pushViewController(pVC, animated:false)
}
func setNavgationHidden(_ bVisible:Bool){
    let pNav = getNavVC()
    pNav.isNavigationBarHidden = bVisible
    pNav.navigationBar.isTranslucent = bVisible
}
class UITools: NSObject {
    
    class func alertInfo(_ pInfo:NSDictionary,on pVC:UIViewController,callback:@escaping (_ index:Int,_ text:NSString)->()){
        let pTitle = pInfo["title"] as? String ?? ""
        let pMsg = pInfo["message"] as? String ?? ""
        let pTextNum = pInfo["textNum"] as? NSString ?? "0"
        let pTextPlaceHolder = pInfo["textPlaceholder"] as? NSString ?? "请输入"
        let strOk = pInfo["OKText"] as? String ?? "确定"
        let strCancel = pInfo["CancelText"] as? String ?? "取消"
        let pAlert = UIAlertController.init(title: pTitle, message: pMsg, preferredStyle: UIAlertControllerStyle.alert)
        if pTextNum.intValue>0 {
            pAlert.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = pTextPlaceHolder as String
            }
        }
        let OKAction:UIAlertAction=UIAlertAction.init(title: strOk, style: UIAlertActionStyle.default) { (UIAlertAction) in
            let strText = pAlert.textFields?.last?.text ?? ""
            callback(0,strText as NSString)
        }
        let cancelAction:UIAlertAction=UIAlertAction.init(title: strCancel, style: UIAlertActionStyle.cancel) { (UIAlertAction) in
            let strText = pAlert.textFields?.last?.text ?? ""
            callback(-1,strText as NSString)
        }
        pAlert.addAction(OKAction)
        pAlert.addAction(cancelAction)
        pVC.present(pAlert, animated: true) {
            
        }
    }

    // 获得清晰的二维码图片
    class func getImageInfocus(_ image:CIImage)->UIImage{
        let extent = image.extent.integral
        let size = CGFloat(2000.0)
        let scale = min(size/extent.width, size/extent.height)
        let width = extent.width*scale
        let height = extent.height*scale
        let cs = CGColorSpaceCreateDeviceGray();
//        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.alphaInfoMask.rawValue | CGImageAlphaInfo.none.rawValue)
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: CGImageAlphaInfo.none.rawValue)
        let context = CIContext.init(options: nil)
        let bitmapImage = context.createCGImage(image, from: extent)
        // bitmapRef.se
        bitmapRef?.interpolationQuality = .high
        bitmapRef?.scaleBy(x: scale, y: scale)
        bitmapRef?.draw(bitmapImage!, in: extent)
        // 2.保存bitmap到图片
        let scaledImage = bitmapRef?.makeImage()
        return UIImage.init(cgImage:scaledImage!);
    }

}
