////
//  UserManager.swift
//  AR Sample
//
//  Created by Richard Jason Lee on 2023-06-20.
//
import SwiftUI

class UserManager: ObservableObject {
   private enum Constants {
      static let preferencesKey = "preferences"
   }
   
   @Published
   var preferences: Preferences = Preferences()

   func load() {
      if let data = UserDefaults.standard.value(forKey: Constants.preferencesKey) as? Data,
         let preferences = try? PropertyListDecoder().decode(Preferences.self, from: data)
      {
            self.preferences = preferences
      }
   }
   
   func persistPreferences() {
      UserDefaults.standard.set(try? PropertyListEncoder().encode(preferences), forKey: Constants.preferencesKey)
   }
   
}


struct Preferences: Codable {
   var showsStatistics: Bool = true
}
