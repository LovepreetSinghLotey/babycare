//
//  Register.swift
//  Babycare
//
//  Created by User on 12/05/23.
//

import Foundation

struct RegisterModel: Codable{
    var name: String
    var email: String
    var password: String
    var image: String
    
    init(name: String, email: String, password: String, image: String) {
        self.name = name
        self.email = email
        self.password = password
        self.image = image
    }
}
