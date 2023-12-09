//
//  PrefUtil.swift
//  Babycare
//
//  Created by User on 11/05/23.
//

import Foundation
import CoreLocation

enum PrefKeys{
    case IS_USER_LOGGED_IN
    case USER_OBJECT
    case EMAIL
    case PASSWORD
}

class PrefUtil{
    
    private init(){}
    
    static let instance = PrefUtil()
    private let userDefaults = UserDefaults.standard
    
    func put(value: Any,  forKey key: PrefKeys) {
        userDefaults.set(value, forKey: String(describing: key))
        userDefaults.synchronize()
    }
    
    func get(forKey key: PrefKeys) -> Any? {
        return userDefaults.object(forKey: String(describing: key))
    }
    
    public func clearAll(){
        userDefaults.dictionaryRepresentation().keys.forEach(userDefaults.removeObject(forKey:))
    }
}
