//
//  AudioVC.swift
//  ZwqSwift
//
//  Created by zhangwenqiang on 2018/8/13.
//  Copyright © 2018年 zhangwenqiang. All rights reserved.
//

import UIKit

class AudioVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let pView = Bundle.main.loadNibNamed("AudioView", owner: nil, options: nil)?.first as? AudioView
        pView?.center = self.view.center
        self.view.addSubview(pView!)
     
        MediaPlayerModule.default.delegate = pView
       // MediaPlayerModule.default.start()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
