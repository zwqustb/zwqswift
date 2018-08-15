//
//  AudioView.swift
//  ZwqSwift
//
//  Created by zhangwenqiang on 2018/8/13.
//  Copyright © 2018年 zhangwenqiang. All rights reserved.
//

import UIKit
import CoreMedia
class AudioView: UIView,MediaPlayerDelegate {
    
    var m_bDraging = false
    
    @IBOutlet weak var lCurTime: UILabel!
    @IBOutlet weak var lTotalTime: UILabel!
    
    @IBOutlet weak var slider: UISlider!
    
    @IBAction func clickPlay(_ sender: UIButton) {
        MediaPlayerModule.default.start()
    }
    
    @IBAction func clickPause(_ sender: Any) {
        MediaPlayerModule.default.pauseOrContinue()
    }
    //MARK:Media delegate
    func didProgressChanged(_ curTime: Double, total totalTime: Double) {
        lCurTime.text = DateTools.getHMSFormS(seconds: Int(curTime))
        lTotalTime.text = DateTools.getHMSFormS(seconds: Int(totalTime))
        slider.maximumValue = Float(totalTime)
        slider.value = Float(curTime)
    }
    //MARK: slider
    @IBAction func onSliderTouchEnd(_ sender: UISlider) {
        
        //let strTotal = lTotalTime.text ?? "00:00:01"
        //let nCurPos = DateTools.HMS2S(strTotal)
        let dCurPos = Double(sender.value)
        let player = MediaPlayerModule.default.videoPlayer
        player?.pause()
        player?.seek(to: CMTime.init(seconds: dCurPos, preferredTimescale: CMTimeScale(1.0)), completionHandler: { (bRet) in
            self.m_bDraging = false
            //self.lChangedValue.isHidden = true
            player?.play()
        })
    }
    @IBAction func onSliderDragBgn(_ sender: UISlider) {
        m_bDraging = true
    }
    @IBAction func onSliderValueChanged(_ sender: UISlider) {
        m_bDraging = true
        //lChangedValue.isHidden = false
        //let fCurValue = DateTools.getHMSFormS(seconds: Int(sender.value))
        //lChangedValue.text = fCurValue
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
