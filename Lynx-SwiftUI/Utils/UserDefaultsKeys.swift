//
//  UserDefaultsKeys.swift
//  Lynx
//
//  Created by Matthew Ernst on 3/26/23.
//

import Foundation

struct UserDefaultsKeys {
    // Apollo Authorization Token
    static let authorizationToken = "authorizationToken"
    static let authorizationTokenExpirationDate = "authorizationTokenExpirationDate"
    
    // All Keys
    static let allKeys: [String] = [
        authorizationToken,
        authorizationTokenExpirationDate,
    ]
    
    static func removeAllObjectsForAllKeys() {
        let defaults = UserDefaults.standard
        for key in UserDefaultsKeys.allKeys {
            defaults.removeObject(forKey: key)
        }
    }
}
