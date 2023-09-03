//
//  VideoModuleView.swift
//  DragGesture_Tut
//
//  Created by yc on 2023/09/03.
//

import UIKit
import AVFoundation

enum VideoModuleError: Error {
    case setupVideoPlayerFail
}

protocol VideoModuleViewDelegate: AnyObject {
    func videoModuleView(moduleView: VideoModuleView?, occurAnyError: VideoModuleError)
    func videoModuleView(moduleView: VideoModuleView, observe currentTime: CMTime)
    func videoModuleView(moduleView: VideoModuleView, didEndPlayer: Void)
}

final class VideoModuleView: UIView {
    
    private let videoURLString: String
    
    init(videoURLString: String) {
        self.videoURLString = videoURLString
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let avPlayerLayer = AVPlayerLayer()
    var avPlayer: AVPlayer?
    var avPlayerItem: AVPlayerItem?
    
    weak var delegate: VideoModuleViewDelegate?
    
    func setupVideoPlayer() {
        guard let videoURL = URL(string: videoURLString) else {
            delegate?.videoModuleView(moduleView: self, occurAnyError: .setupVideoPlayerFail)
            return
        }
        
        avPlayerItem = AVPlayerItem(url: videoURL)
        avPlayer = AVPlayer(playerItem: avPlayerItem)
        
        avPlayerLayer.player = avPlayer
        
        layer.addSublayer(avPlayerLayer)
        
        let interval = CMTime(value: 1, timescale: 100)
        avPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] currentTime in
            guard let self = self else {
                self?.delegate?.videoModuleView(moduleView: self, occurAnyError: .setupVideoPlayerFail)
                return
            }
            
            self.delegate?.videoModuleView(moduleView: self, observe: currentTime)
        })
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEndAVPlayer),
            name: .AVPlayerItemDidPlayToEndTime,
            object: avPlayer?.currentItem
        )
    }
    
    func setupVideoPlayerLayer() {
        avPlayerLayer.frame = bounds
    }
    
    func play(rate: Float) {
        guard let avPlayer = avPlayer else {
            delegate?.videoModuleView(moduleView: self, occurAnyError: .setupVideoPlayerFail)
            return
        }
        avPlayer.play()
        avPlayer.rate = rate
    }
    
    func pause() {
        guard let avPlayer = avPlayer else {
            delegate?.videoModuleView(moduleView: self, occurAnyError: .setupVideoPlayerFail)
            return
        }
        avPlayer.pause()
    }
    
    func getStatus() -> AVPlayer.TimeControlStatus? {
        guard let avPlayer = avPlayer else {
            delegate?.videoModuleView(moduleView: self, occurAnyError: .setupVideoPlayerFail)
            return nil
        }
        return avPlayer.timeControlStatus
    }
    
    func seek(to: Double) {
        guard let avPlayer = avPlayer else {
            delegate?.videoModuleView(moduleView: self, occurAnyError: .setupVideoPlayerFail)
            return
        }
        let currentTime = CMTimeGetSeconds(avPlayer.currentTime())
        let newTime = CMTimeMake(value: Int64(currentTime + to), timescale: 1)
        
        avPlayer.seek(to: newTime)
    }
    
    func seek(to: CMTime) {
        guard let avPlayer = avPlayer else {
            delegate?.videoModuleView(moduleView: self, occurAnyError: .setupVideoPlayerFail)
            return
        }
        
        avPlayer.seek(to: to)
    }
    
    func getDuration() -> CMTime? {
        guard let avPlayer = avPlayer else {
            delegate?.videoModuleView(moduleView: self, occurAnyError: .setupVideoPlayerFail)
            return nil
        }
        return avPlayer.currentItem?.duration
    }
    
    @objc func didEndAVPlayer(_ playerItem: AVPlayerItem) {
        delegate?.videoModuleView(moduleView: self, didEndPlayer: ())
    }
}
