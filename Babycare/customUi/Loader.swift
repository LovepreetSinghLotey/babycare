//
//  Loader.swift
//  Babycare
//
//  Created by User on 13/05/23.
//

import UIKit

class Loader: UIView {
    
    var blurEffectView: UIVisualEffectView?
    
    override init(frame: CGRect) {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = frame
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView = blurEffectView
        super.init(frame: frame)
        addSubview(blurEffectView)
        addLoader()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func addLoader() {
        guard let blurEffectView = blurEffectView else { return }
        var style: UIActivityIndicatorView.Style = UIActivityIndicatorView.Style.medium
        
        if #available(iOS 13.0, *) {
            style = .large
        } else{
            style = .gray
        }
        
        let activityIndicator = UIActivityIndicatorView(style: style)
        activityIndicator.color = UIColor(named: "title")
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        blurEffectView.contentView.addSubview(activityIndicator)
        activityIndicator.center = blurEffectView.contentView.center
        activityIndicator.startAnimating()
    }
}
