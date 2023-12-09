//
//  String.swift
//  Babycare
//
//  Created by User on 15/05/23.
//

import Foundation

extension String{
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }

}
