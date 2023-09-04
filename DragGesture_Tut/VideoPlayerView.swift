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
    
    private func setupLayout() {
        [
            videoModuleView
        ].forEach {
            addSubview($0)
        }
        
        videoModuleView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(UIScreen.main.bounds.width * 9 / 16)
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
