//
//  VideoView.swift
//  MobileHealth
//
//  Created by zhangwenqiang on 2018/6/26.
//  Copyright © 2018年 Jiankun Zhang. All rights reserved.
//

import UIKit
import AVKit
class VideoView: UIView,MediaPlayerDelegate {
   
    
  //  var pPlayerVC:AVPlayerViewController =  AVPlayerViewController.init()
    weak var player:AVPlayer?
//
//    var m_pObserver:Any?
//    var m_pUrl:URL?
//    var playLayer:AVPlayerLayer?
    var m_pWaitingView:UIActivityIndicatorView? //等待条
    
    var m_bPlaying = false //是否正在播放
    var m_bFull = false //是否在全屏状态
    var m_bDraging = false //是否正在拖动进度条
    @IBOutlet weak var lChangedValue: UILabel!
    
    
    @IBOutlet weak var m_pCoverView: UIImageView!
    var m_nTickerCount = 0 //控制menu8s后自动隐藏
    var coverUrl:URL?
    
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var volumeBar: UIView!
    
    @IBOutlet weak var m_btnPlay: UIButton!
    weak var parentVC:UIViewController?
    weak var parentView:UIView?
    
    @IBOutlet weak var cBtnBackTop: NSLayoutConstraint!
    @IBOutlet weak var lCurTime: UILabel!
    @IBOutlet weak var pSlider: UISlider! // 进度条
    @IBOutlet weak var lTotalTime: UILabel!
    
    @IBOutlet weak var pSmallSlider: UISlider! // 声音或亮度
    
    func initPlayerVC(_ urlIn:URL){
//        m_pUrl = urlIn
        
        MediaPlayerModule.default.resUrl = urlIn
        MediaPlayerModule.default.initVideo()
        MediaPlayerModule.default.setPlayerLayer(self)
        MediaPlayerModule.default.delegate = self
        player = MediaPlayerModule.default.videoPlayer
        self.addObserver()
        self.pSlider.isEnabled = true
    }
    func isPlaying()->Bool{
        if m_bPlaying{
            m_bPlaying = false
            return true
        }else{
            return false
        }
    }
    //MARK:click
    @IBAction func clickFullscreen(_ sender: UIButton) {
        let player = MediaPlayerModule.default.videoPlayer
        let playLayer = MediaPlayerModule.default.playLayer

        if m_bPlaying{
            player?.pause()
        }
        
        if m_bFull{
            let rtFrame = self.parentView?.bounds
            self.frame = rtFrame!
            playLayer?.frame = rtFrame!
            self.parentView?.addSubview(self)
            
            self.parentVC?.dismiss(animated: true, completion: {
                if self.parentView != nil{
                    if self.m_bPlaying{
                        player?.play()
                    }
                    self.m_bFull = false
                }
            })
        }else{
            parentView = self.superview
            let pVC = LandscapeVC.init()
            self.parentVC?.present(pVC, animated: true, completion: {
                let rtFrame = pVC.view.frame
                self.frame = rtFrame
                playLayer?.frame = rtFrame
                pVC.view.addSubview(self)
                if(self.m_bPlaying){
                    player?.play()
                }
                self.m_bFull = true
            })
        }
    }
    //MARK slider
    @IBAction func onSliderTouchEnd(_ sender: UISlider) {
        let player = MediaPlayerModule.default.videoPlayer
//        let playLayer = MediaPlayerModule.default.playLayer
        //let strTotal = lTotalTime.text ?? "00:00:01"
        //let nCurPos = DateTools.HMS2S(strTotal)
        let dCurPos = Double(sender.value)
        player?.pause()
        player?.seek(to: CMTime.init(seconds: dCurPos, preferredTimescale: CMTimeScale(1.0)), completionHandler: { (bRet) in
            self.m_bDraging = false
            self.lChangedValue.isHidden = true
            player?.play()
        })
    }
    @IBAction func onSliderDragBgn(_ sender: UISlider) {
        m_bDraging = true
    }
    @IBAction func onSliderValueChanged(_ sender: UISlider) {
        m_bDraging = true
        lChangedValue.isHidden = false
        let fCurValue = DateTools.getHMSFormS(seconds: Int(sender.value))
        lChangedValue.text = fCurValue
    }
    //MARK:点击播放或暂停
    @IBAction func clickBtn(_ sender: UIButton) {
        let player = MediaPlayerModule.default.videoPlayer
        m_pCoverView.isHidden = true
        let img = sender.image(for: .normal)
        if img == #imageLiteral(resourceName: "iconBtnPlay") {
            sender.setImage(#imageLiteral(resourceName: "iconBtnPause"), for: .normal)
            player?.play()
            let status = player?.status
            m_bPlaying = true
        }else{
            m_bPlaying = false
            sender.setImage(#imageLiteral(resourceName: "iconBtnPlay"), for: .normal)
            player?.pause()
        }
    }
    @IBAction func handleGesture(_ sender: Any) {
let player = MediaPlayerModule.default.videoPlayer
        if sender is UITapGestureRecognizer {
            if !m_pCoverView.isHidden {
                self.clickBtn(m_btnPlay)
            }
            setMenuHidden(!bottomBar.isHidden)
            m_nTickerCount = 0
        }else if sender is UIPanGestureRecognizer{
            let pPan = sender as! UIPanGestureRecognizer
            let state = pPan.state
            if state == .began{
                self.volumeBar.isHidden = false
                pSmallSlider.value = player?.volume ?? 1
            }else if state == .cancelled || state == .ended{
                self.volumeBar.isHidden = true
            }
            let ptVelocity = pPan.velocity(in: pPan.view)
            print("\(ptVelocity.y)")
            if ptVelocity.y < 0{
                var nVolume = player?.volume ?? 1
                if nVolume < 1{
                    nVolume += 0.05
                    player?.volume = nVolume
                    pSmallSlider.value = nVolume
                }
            }else if ptVelocity.y > 0{
                var nVolume = player?.volume ?? 1
                if nVolume > 0{
                    nVolume -= 0.05
                    player?.volume = nVolume
                    pSmallSlider.value = nVolume
                }
            }
        }
    }
    @IBAction func clickBack(_ sender: UIButton) {
        let player = MediaPlayerModule.default.videoPlayer
        if m_bFull {
            self.clickFullscreen(sender)
            player?.pause()
           // self.removeFromSuperview()
        }else{
            self.stopPlay()
            popView()
        }
    }
    //MARK:监控 delegate
    func didProgressChanged(_ curTime: Double, total totalTime: Double) {
        let current = curTime
        let total = totalTime
        
        if(!self.m_bDraging){
            //let fProgress = current/total
            if !total.isNaN{
                self.pSlider.maximumValue = Float(total)
            }
            self.pSlider.value = Float(current)//Float(fProgress)
            if current >= total{//播放完成了
                self.m_pCoverView.isHidden = false
            }
        }
        self.lCurTime.text = DateTools.getHMSFormS(seconds: Int(current))
        if !total.isNaN{
            self.lTotalTime.text = DateTools.getHMSFormS(seconds: Int(total))
        }
        if !self.bottomBar.isHidden && !self.m_bDraging{
            self.m_nTickerCount+=1
            if self.m_nTickerCount > 7{
                self.m_nTickerCount = 0
                self.setMenuHidden(true)
            }
        }
    }
    //给AVPlayerItem、AVPlayer添加监控
    func addObserver(){
        //为AVPlayerItem添加status属性观察，得到资源准备好，开始播放视频
        let playerItem = player?.currentItem
        playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        //监听AVPlayerItem的loadedTimeRanges属性来监听缓冲进度更新
        playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    ///  通过KVO监控播放器状态
    ///
    /// - parameter keyPath: 监控属性
    /// - parameter object:  监视器
    /// - parameter change:  状态改变
    /// - parameter context: 上下文
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let object = object as? AVPlayerItem  else { return }
        guard let keyPath = keyPath else { return }
        if keyPath == "status"{
            if object.status == .readyToPlay{ //当资源准备好播放，那么开始播放视频
//                player?.play()
//                print("正在播放...，视频总长度:\(formatPlayTime(seconds: CMTimeGetSeconds(object.duration)))")
            }else if object.status == .failed || object.status == .unknown{
                print("播放出错")
            }
        }else if keyPath == "loadedTimeRanges"{
//            let loadedTime = avalableDurationWithplayerItem()
//            print("当前加载进度\(loadedTime)")
        }
    }
    //计算当前的缓冲进度
    func avalableDurationWithplayerItem()->TimeInterval{
        let player = MediaPlayerModule.default.videoPlayer
        guard let loadedTimeRanges = player?.currentItem?.loadedTimeRanges,let first = loadedTimeRanges.first else {fatalError()}
        //本次缓冲时间范围
        let timeRange = first.timeRangeValue
        let startSeconds = CMTimeGetSeconds(timeRange.start)//本次缓冲起始时间
        let durationSecound = CMTimeGetSeconds(timeRange.duration)//缓冲时间
        let result = startSeconds + durationSecound//缓冲总长度
        return result
    }

    //播放结束，回到最开始位置，播放按钮显示带播放图标
    @objc func playerItemDidReachEnd(notification: Notification){
        let player = MediaPlayerModule.default.videoPlayer
        player?.seek(to: kCMTimeZero, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        //progress.progress = 0.0
        pSlider.value = 0.0
        m_btnPlay.setImage(#imageLiteral(resourceName: "iconBtnPlay"), for: .normal)
    }
    //MARK:辅助方法
    func stopPlay()  {
        
        self.player?.pause()
        self.player?.cancelPendingPrerolls()
        self.player?.replaceCurrentItem(with: nil)
        self.pSlider.isEnabled = false
    }
    func removeObserver(){
        let playerItem = player?.currentItem
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
//        if m_pObserver != nil {
//            player?.removeTimeObserver(m_pObserver!)
//        }
        NotificationCenter.default.removeObserver(self, name:  Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    deinit {
        self.removeObserver()
        self.player?.pause()
        self.player = nil
    }
    func setMenuHidden(_ bHidden:Bool){
        topBar.isHidden = bHidden
        bottomBar.isHidden = bHidden
    }
    func showWaiting(_ bShow:Bool){
        if m_pWaitingView == nil {
            m_pWaitingView = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
            self.addSubview(m_pWaitingView!)
            m_pWaitingView?.center = self.center
        }
        if bShow {
            m_pWaitingView?.startAnimating()
        }else{
            m_pWaitingView?.stopAnimating()
        }
        m_pWaitingView?.isHidden = !bShow
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
