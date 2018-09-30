//
//  DataRangeView.swift
//  MobileHealth
//
//  Created by zhangwenqiang on 2018/8/23.
//  Copyright © 2018年 Jiankun Zhang. All rights reserved.
//

import UIKit

class DataRangeView: UIView {

    @IBOutlet weak var label1: UILabel!
    
     var contentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
     //   label1.text = "123"
//        DataRange = UINib.init(nibName: "DataRangeView", bundle: nil).instantiate(withOwner: self, options: nil).last as! UIView
          contentView = Bundle.main.loadNibNamed("DataRangeView", owner: self, options: nil)?.first  as! UIView
        let rect = self.bounds
        //let rect2 = self.frame
        contentView.frame = rect
        self.addSubview(contentView)
        addConstraints()
    }
    func loadViewFromNib() -> UIView {
        let className = type(of: self)
        let bundle = Bundle(for: className)
        let name = NSStringFromClass(className).components(separatedBy: ".").last
        let nib = UINib(nibName: name!, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    override func layoutSubviews() {
        super.layoutSubviews()
//        let rect = self.bounds
//        let rect2 = self.frame
//        DataRange.frame = rect
    }
    func addConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        var constraint = NSLayoutConstraint(item: contentView, attribute: .leading,
                                            relatedBy: .equal, toItem: self, attribute: .leading,
                                            multiplier: 1, constant: 0)
        addConstraint(constraint)
        constraint = NSLayoutConstraint(item: contentView, attribute: .trailing,
                                        relatedBy: .equal, toItem: self, attribute: .trailing,
                                        multiplier: 1, constant: 0)
        addConstraint(constraint)
        constraint = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal,
                                        toItem: self, attribute: .top, multiplier: 1, constant: 0)
        addConstraint(constraint)
        constraint = NSLayoutConstraint(item: contentView, attribute: .bottom,
                                        relatedBy: .equal, toItem: self, attribute: .bottom,
                                        multiplier: 1, constant: 0)
        addConstraint(constraint)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
