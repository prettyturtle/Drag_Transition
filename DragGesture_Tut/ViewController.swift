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
    
    private lazy var imageView = UIImageView().then { iv in
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction))
        
        iv.addGestureRecognizer(panGesture)
        iv.addGestureRecognizer(tapGesture)
        iv.addGestureRecognizer(pinchGesture)
        iv.isUserInteractionEnabled = true
        
        Task {
            let (data, _) = try await URLSession.shared.data(from: URL(string: "https://fastly.picsum.photos/id/169/200/200.jpg?hmac=MquoCIcsCP_IxfteFmd8LfVF7NCoRre282nO9gVD0Yc")!)
            iv.image = UIImage(data: data)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.size.equalTo(300)
            $0.center.equalToSuperview()
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
        let dx = gesture.view!.center.x + transition.x
        let dy = gesture.view!.center.y + transition.y
        
        gesture.setTranslation(.zero, in: gesture.view)
        
        gesture.view?.center = CGPoint(x: dx, y: dy)
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
    
    @objc func pinchAction(_ gesture: UIPinchGestureRecognizer) {
        print(gesture)
        imageView.transform = imageView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        gesture.scale = 1
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
