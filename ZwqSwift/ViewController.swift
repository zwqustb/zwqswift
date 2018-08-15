//
//  ViewController.swift
//  ZwqSwift
//
//  Created by zhangwenqiang on 2018/6/30.
//  Copyright © 2018年 zhangwenqiang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var topView: UIView!
    var pView:VideoView?
    @IBOutlet weak var lWalkNum: UILabel!
    @IBAction func showBP(_ sender: UIButton) {
        let pVC = BloodpressureVC.init(nibName: "BloodpressureVC", bundle: nil)
        pushView(pVC)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.perform(#selector(initVideo), with: nil, afterDelay: 0.1)
//        self.getWalkNum()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(_ animated: Bool) {
        self.initVideo()
    }
    @objc func initVideo(){
        pView = Bundle.main.loadNibNamed("VideoView", owner: self, options: nil)?.first as? VideoView
        if pView != nil {
            pView?.frame = topView.bounds
            pView?.parentVC = self
            pView?.parentView = topView
            topView.addSubview(pView!)
            let url = Bundle.main.url(forResource: "test", withExtension: "mp4")
            if url != nil{
                pView?.initPlayerVC(url!)
            }
            
        }
    }
    @IBAction func clickBT(_ sender: Any) {
        let pVC = BlueToothVC.init(nibName: "BlueToothVC", bundle: nil)
        pushView(pVC)
    }
    
    
    @IBAction func clickAudio(_ sender: UIButton) {
           MediaPlayerModule.default.resUrl = Bundle.main.url(forResource: "ElonMusk01", withExtension: "mp3")
        let pVC = AudioVC.init()
        pushView(pVC)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getWalkNum(){
        HearthKitTool.share.getRight()
        HearthKitTool.share.getData(lWalkNum)
    }
    @IBAction func getWalkNum(_ sender: UIButton) {
        self.getWalkNum()
    }
    
}

