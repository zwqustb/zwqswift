//
//  LogicTool.swift
//  biniu
//
//  Created by zhangwenqiang on 2018/4/6.
//  Copyright © 2018年 zhangwenqiang. All rights reserved.
//

import UIKit
func getClassNameOfAnyObject(object:Any)->String{
    
    let mirror=Mirror(reflecting: object).description.replacingOccurrences(of: "Mirror for", with: "").trim()
    return mirror
    
}
class LogicTool: NSObject {
    

    @objc class  func enableBtn(_ sender:UIButton){
        sender.isEnabled = true
    }
    class func handleHttpResult(_ pAny:Any)->NSDictionary{
        var pDic = NSDictionary.init()
        if pAny is NSDictionary {
             pDic = pAny as! NSDictionary
        }
        return pDic as NSDictionary
    }
    class func getUserId()->String{
        let pDic = UserDefaults.standard.object(forKey:"userData") as? NSDictionary ?? ["":""]
        let strUserID = pDic["userId"] as? String ?? ""
        //UserDefaults.standard.string(forKey: "currentId") ?? ""
        return strUserID
    }
}
