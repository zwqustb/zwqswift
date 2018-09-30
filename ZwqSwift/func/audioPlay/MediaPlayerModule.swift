//
//  MediaPlayerModule.swift
//  ZwqSwift
//
//  Created by zhangwenqiang on 2018/8/13.
//  Copyright © 2018年 zhangwenqiang. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
public protocol MediaPlayerDelegate: NSObjectProtocol{
     //nProgress 0~1
    func didProgressChanged(_ curTime:Double ,total totalTime:Double)
}
class MediaPlayerModule: NSObject,AVAudioPlayerDelegate {
    static let `default` =  MediaPlayerModule()
    var resUrl:URL?
    var session:AVAudioSession?
    var audioPlayer:AVAudioPlayer?
    var videoPlayer:AVPlayer?
    var playLayer:AVPlayerLayer?
    var progressObserver:Any?
    var bPlaying = false
    weak var delegate:MediaPlayerDelegate?
    //MARK:private
    func initAudio(){
        if(resUrl == nil){
            print("音频为空")
            return
        }
        session = AVAudioSession.sharedInstance()
        try?session?.setActive(true)
        try?session?.setCategory(AVAudioSessionCategoryPlayback)
        
        audioPlayer = try?AVAudioPlayer.init(contentsOf: resUrl!)
        audioPlayer?.numberOfLoops = -1
        audioPlayer?.delegate = self
        
    }
    func setPlayerLayer(_ view:UIView){
        if playLayer == nil {
            playLayer = AVPlayerLayer.init(player: videoPlayer)
            //player?.play()
            // self.frame = self.parentView?.bounds
            playLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            view.layer.insertSublayer(playLayer!, at: 0)
        }
        playLayer?.frame = view.bounds
    }
    func initVideo(){
        if(resUrl == nil){
            print("视频为空")
            return
        }
        let item = AVPlayerItem.init(url: resUrl!)
        videoPlayer = AVPlayer.init(playerItem: item)
        self.addProgressObserver()
    }
    //MARK:public
    func start(){
        if audioPlayer == nil {
            self.initAudio()
        }
        if audioPlayer != nil {
            audioPlayer?.play()
        }else{
            if(videoPlayer == nil){
                self.initVideo()
            }
            videoPlayer?.play()
        }
        bPlaying = true
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.setRemoteDic(["time":10,"title":"ELonMask"])
    }
    func pauseOrContinue(){
        if bPlaying{
            videoPlayer?.pause()
        }else{
            videoPlayer?.play()
        }
        bPlaying = !bPlaying
        
    }
    func removeObserver(){
        let playerItem = videoPlayer?.currentItem
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        if progressObserver != nil {
            videoPlayer?.removeTimeObserver(progressObserver!)
        }
        NotificationCenter.default.removeObserver(self, name:  Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    func stop(){
        self.removeObserver()
        playLayer?.removeFromSuperlayer()
        playLayer = nil
        bPlaying = false
        videoPlayer?.pause()
        videoPlayer?.cancelPendingPrerolls()
        videoPlayer?.replaceCurrentItem(with: nil)
    }
    func clear(){
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    func setRemoteDic(_ pDic:NSDictionary ){
       // [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = dict;
        let duration = pDic["time"] ?? "0"
        let title = pDic["title"] ?? "未知"
       // let imgPath = pDic["img"]
//        let artWork = MPMediaItemArtwork.init(boundsSize: CGSize.init(width: 20, height: 20)) { (size) -> UIImage in
//            let img = #imageLiteral(resourceName: "heartrate120.png")
//            return img
//        }
//        MPNowPlayingInfoCenter.default().nowPlayingInfo =
//        [
//            MPMediaItemPropertyPlaybackDuration:duration,
//            MPMediaItemPropertyTitle:title,
//            MPMediaItemPropertyArtwork:artWork
//        ]
    }
    //MARK:delegate

    func addProgressObserver() {
        let item = self.videoPlayer?.currentItem
        
        progressObserver = self.videoPlayer?.addPeriodicTimeObserver(forInterval: CMTime.init(seconds: 1.0, preferredTimescale: CMTimeScale(1.0)), queue: DispatchQueue.main, using: { (time:CMTime) in
            
            let current = time.seconds
            let total = item?.duration.seconds ?? 1
            
            self.delegate?.didProgressChanged(current,total: total)
//            if(!self.m_bDraging){
//                //let fProgress = current/total
//                if !total.isNaN{
//                    self.pSlider.maximumValue = Float(total)
//                }
//                self.pSlider.value = Float(current)//Float(fProgress)
//                if current >= total{//播放完成了
//                    self.m_pCoverView.isHidden = false
//                }
//            }
//            self.lCurTime.text = DateTools.getHMSFormS(seconds: Int(current))
//            if !total.isNaN{
//                self.lTotalTime.text = DateTools.getHMSFormS(seconds: Int(total))
//            }
//            if !self.bottomBar.isHidden && !self.m_bDraging{
//                self.m_nTickerCount+=1
//                if self.m_nTickerCount > 7{
//                    self.m_nTickerCount = 0
//                    self.setMenuHidden(true)
//                }
//            }
            
        })
        
    }
}
