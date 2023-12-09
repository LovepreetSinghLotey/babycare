//
//  UIView.swift
//  Babycare
//
//  Created by User on 12/05/23.
//

import Foundation
import UIKit

extension UIView{
    
    @IBInspectable
    var cornerRadiusC: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
            
        }
    }
    
    func showLoader() {
        let blurLoader = Loader(frame: frame)
        self.addSubview(blurLoader)
    }
    
    func removeLoader() {
        if let blurLoader = subviews.first(where: { $0 is Loader }) {
            blurLoader.removeFromSuperview()
        }
    }
    
    private struct AssociatedKeys {
        static var TapHandler = "tapHandler"
    }
        
    private var tapHandler: (() -> Void)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.TapHandler) as? () -> Void
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.TapHandler, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func onTap(withHandler handler: @escaping () -> Void) {
        tapHandler = handler
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        animate()
    }
    
    private func animate() {
        self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        UIView.animate(withDuration: 0.8,
                       delay: 0,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 0.2,
                       options: [.allowUserInteraction, .beginFromCurrentState],
                       animations: { self.transform = .identity },
                       completion: nil)
        tapHandler?()
    }
}
