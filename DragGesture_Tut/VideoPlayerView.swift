//
//  VideoPlayerView.swift
//  DragGesture_Tut
//
//  Created by yc on 2023/09/03.
//

import UIKit
import SwiftUI
import AVFoundation
import SnapKit
import Then

final class VideoPlayerView: UIView {
    
    let videoURLString = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    
    private lazy var videoModuleView = VideoModuleView(videoURLString: videoURLString).then {
        $0.setupVideoPlayer()
        $0.backgroundColor = .red
//        $0.delegate = self
    }
    
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .systemBlue
        setupLayout()
        videoModuleView.play(rate: 1.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        videoModuleView.setupVideoPlayerLayer()
    }
    
    var miniVideoPlayerViewShrinkRate: Double?
    var miniVideoPlayerViewTransitionY: Double?
    
    func animateMiniVideoPlayerView(_ ty: Double) {
        if videoModuleView.frame.height > 100 {
            let heightShrinkRate = 1 - ty / safeAreaLayoutGuide.layoutFrame.height
            
            miniVideoPlayerViewShrinkRate = heightShrinkRate
            miniVideoPlayerViewTransitionY = ty
            
            videoModuleView.transform = CGAffineTransform(scaleX: 1, y: heightShrinkRate)
            videoModuleView.frame = CGRect(
                x: 0,
                y: 0,
                width: videoModuleView.frame.width,
                height: videoModuleView.frame.height
            )
        } else {
            guard let miniVideoPlayerViewShrinkRate = miniVideoPlayerViewShrinkRate,
                  let miniVideoPlayerViewTransitionY = miniVideoPlayerViewTransitionY else {
                return
            }
            
            let widthShrinkRate = miniVideoPlayerViewTransitionY / ty
            print(widthShrinkRate)
            
            videoModuleView.transform = CGAffineTransform(
                scaleX: widthShrinkRate,
                y: miniVideoPlayerViewShrinkRate
            )
            videoModuleView.frame = CGRect(
                x: 0,
                y: 0,
                width: videoModuleView.frame.width,
                height: videoModuleView.frame.height
            )
        }
    }
    
    private func setupLayout() {
        [
            videoModuleView,
            scrollView
        ].forEach {
            addSubview($0)
        }
        
        videoModuleView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(UIScreen.main.bounds.width * 9 / 16)
        }
        
        scrollView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(safeAreaLayoutGuide)
            $0.top.equalTo(videoModuleView.snp.bottom)
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        let tempView = UIView().then { $0.backgroundColor = .purple }
        
        contentView.addSubview(tempView)
        
        tempView.snp.makeConstraints {
            $0.width.equalTo(50)
            $0.height.equalTo(1200)
            $0.centerX.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
    }
}


struct UIViewPreview: UIViewRepresentable{
    let v: UIView
    
    func makeUIView(context: Context) -> some UIView {
        return v
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct VideoPlayerView_Preview: PreviewProvider {
    static var previews: some View {
        UIViewPreview(v: VideoPlayerView())
            .previewLayout(.sizeThatFits)
    }
}
