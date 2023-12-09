//
//  DataSnapshot.swift
//  Babycare
//
//  Created by User on 14/05/23.
//

import Foundation
import FirebaseDatabase

extension DataSnapshot {
  var valueToJSON: Data {
      guard let dictionary = value as? [String: Any] else {
          return Data()
      }
      return dictionary.JSON
  }

  var listToJSON: Data {
      guard let object = children.allObjects as? [DataSnapshot] else {
          return Data()
      }

      let dictionary: [NSDictionary] = object.compactMap { $0.value as? NSDictionary }

      do {
          return try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
      } catch {
          return Data()
      }
  }
}
