//
//  UIStoryboard.swift
//  Babycare
//
//  Created by User on 12/05/23.
//

import UIKit

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}

extension UIViewController : StoryboardIdentifiable { }

extension UIViewController {
    
    static func loadFromNib(bundle: Bundle? = nil) -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: bundle)
        }
        return instantiateFromNib()
    }
}

extension UIStoryboard{
    
    enum Storyboard: String {
        case Main
        
        var filename: String{
            switch self {
            default: return rawValue
            }
        }
    }
    
    convenience init(storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.filename, bundle: bundle)
    }
    
    func initVC<T: UIViewController>() -> T where T: StoryboardIdentifiable {
        guard let vc = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("Couldn't instantiate view controller with identifier \(T.storyboardIdentifier) ")
        }
        return vc
    }
}
