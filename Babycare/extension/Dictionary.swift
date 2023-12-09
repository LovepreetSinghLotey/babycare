//
//  Dictionary.swift
//  Babycare
//
//  Created by User on 14/05/23.
//

import Foundation

extension Dictionary {
    var JSON: Data {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        } catch {
            return Data()
        }
    }
}
