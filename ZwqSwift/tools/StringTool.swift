//
//  StringTool.swift
//  biniu
//
//  Created by zhangwenqiang on 2018/4/6.
//  Copyright © 2018年 zhangwenqiang. All rights reserved.
//

import UIKit

class StringTool: NSObject {
    public class func isNil(_ strIn:String?)->Bool
    {
        return strIn == nil || strIn == ""
    }
}
extension String {
    mutating func partValue()->String{
        var ret = self
        let str = NSMutableString.init(string: self)
        if str.length>8 {
            let str1 = str.substring(to: 4)
            let str2 = str.substring(from: str.length-4)
            ret = "\(str1)****\(str2)"
        }else{
            let str1 = str.substring(to: 1)
            let str2 = str.substring(from: str.length-1)
            ret = "\(str1)****\(str2)"
        }
       return ret
    }
    public func substring(from index: Int) -> String {
        if self.count > index {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let subString = self[startIndex..<self.endIndex]
            return String(subString)
        } else {
            return self
        }
    }
    public func substring(from index: Int,length nLength:Int) -> String {
        if self.count >= index+nLength {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let endIndex = self.index(self.startIndex, offsetBy: index+nLength)
            let subString = self[startIndex..<endIndex]
            return String(subString)
        } else {
            return self
        }
    }
    public func substring(in index: Int) -> String {
        if self.count > index {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let endIndex = self.index(self.startIndex, offsetBy: index+1)
            let subString = self[startIndex..<endIndex]
            return String(subString)
        } else {
            return self
        }
    }
    func trim()->String{
        return self.trimmingCharacters(in:NSCharacterSet.whitespacesAndNewlines)
        
    }
}
