//
//  ViewController.swift
//  DragGesture_Tut
//
//  Created by yc on 2023/08/28.
//

import UIKit
import SwiftUI
import SnapKit
import Then

final class ViewController: UIViewController {
    private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(panAction))
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
    private lazy var doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
    private lazy var pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction))
    
    private var imageViewScale = 1.0
    
    private lazy var button = UIButton().then {
        $0.setTitle("SHOW", for: .normal)
        $0.setTitleColor(.label, for: .normal)
        $0.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    private lazy var imageView = UIImageView().then { iv in
        doubleTapGesture.numberOfTapsRequired = 2
        
        tapGesture.delegate = self
        doubleTapGesture.delegate = self
        
        iv.addGestureRecognizer(panGesture)
        iv.addGestureRecognizer(tapGesture)
        iv.addGestureRecognizer(doubleTapGesture)
        iv.addGestureRecognizer(pinchGesture)
        iv.isUserInteractionEnabled = true
        
        Task {
            let (data, _) = try await URLSession.shared.data(from: URL(string: "https://fastly.picsum.photos/id/169/200/200.jpg?hmac=MquoCIcsCP_IxfteFmd8LfVF7NCoRre282nO9gVD0Yc")!)
            iv.image = UIImage(data: data)
        }
    }
    
    private var videoPlayerView: VideoPlayerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.size.equalTo(300)
            $0.center.equalToSuperview()
        }
        
        view.addSubview(button)
        button.snp.makeConstraints {
            $0.centerX.equalTo(imageView.snp.centerX)
            $0.top.equalTo(imageView.snp.bottom).offset(16)
        }
    }
    
    @objc func didTapButton(_ sender: UIButton) {
        videoPlayerView = VideoPlayerView()
        
        guard let videoPlayerView = videoPlayerView else {
            return
        }
        
        view.addSubview(videoPlayerView)
        
        videoPlayerView.frame = CGRect(
            x: 0.0,
            y: view.frame.maxY,
            width: view.frame.width,
            height: view.frame.height
        )
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.1,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: .curveEaseInOut
        ) {
            videoPlayerView.center.y -= self.view.frame.height
        } completion: { _ in
            videoPlayerView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
    
    @objc func panAction(_ gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: gesture.view)
        
        if abs(velocity.x) > abs(velocity.y) {
            velocity.x < 0 ? print("좌") : print("우")
        } else if abs(velocity.y) > abs(velocity.x) {
            velocity.y < 0 ? print("상") : print("하")
        }
        
        let transition = gesture.translation(in: gesture.view)
        let dx = gesture.view!.center.x + transition.x * imageViewScale
        let dy = gesture.view!.center.y + transition.y * imageViewScale
        
        gesture.setTranslation(.zero, in: gesture.view)
        
        gesture.view?.center = CGPoint(x: dx, y: dy)
        
        if gesture.state == .ended {
            if (gesture.view?.center.x)! < view.bounds.minX {
                gesture.view?.center.x = view.bounds.minX + (gesture.view?.bounds.width)! / 2
            }
            
            if (gesture.view?.center.x)! > view.bounds.maxX {
                gesture.view?.center.x = view.bounds.maxX - (gesture.view?.bounds.width)! / 2
            }
            
            if (gesture.view?.center.y)! > view.bounds.maxY {
                gesture.view?.center.y = view.bounds.maxY - (gesture.view?.bounds.height)! / 2
            }
            
            if (gesture.view?.center.y)! < view.bounds.minY {
                gesture.view?.center.y = view.bounds.minY + (gesture.view?.bounds.height)! / 2
            }
        }
    }
    
    @objc func tapAction(_ gesture: UITapGestureRecognizer) {
        if let imageView = gesture.view as? UIImageView {
            Task {
                let (data, _) = try await URLSession.shared.data(from: URL(string: "https://picsum.photos/200")!)
                
                UIView.transition(with: imageView, duration: 2, options: .transitionCurlUp) {
                    imageView.image = UIImage(data: data)
                }
            }
        }
    }
    
    @objc func doubleTapAction(_ gesture: UITapGestureRecognizer) {
        if let imageView = gesture.view as? UIImageView {
            imageView.transform = imageView.transform == .identity ? .init(scaleX: 2.0, y: 2.0) : .identity
            imageViewScale = imageView.transform == .identity ? 1.0 : 2.0
        }
    }
    
    @objc func pinchAction(_ gesture: UIPinchGestureRecognizer) {
        print(gesture.scale)
        imageView.transform = imageView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        imageViewScale += gesture.scale - 1
        print(imageViewScale)
        gesture.scale = 1
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if gestureRecognizer == self.tapGesture &&
            otherGestureRecognizer == self.doubleTapGesture {
            return false
        }
        return true
    }
}


struct UIViewControllerPreview: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    let vc: UIViewController
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return vc
    }
}

struct ViewController_Preview: PreviewProvider{
    static var previews: some View {
        UIViewControllerPreview(vc: ViewController())
    }
}
