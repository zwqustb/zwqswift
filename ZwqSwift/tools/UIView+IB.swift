//
//  UIView+IB.swift
//  biniu
//
//  Created by zhangwenqiang on 2018/5/18.
//  Copyright © 2018年 zhangwenqiang. All rights reserved.
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        
        set {
            if newValue < 0 {
                let nRadius = round(self.frame.size.height)/2
                layer.cornerRadius = nRadius
            }else{
                layer.cornerRadius = newValue
                layer.masksToBounds = newValue > 0
            }
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue > 0 ? newValue : 0
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
