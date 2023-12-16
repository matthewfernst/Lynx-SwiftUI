//
//  UserDefaultsKeys.swift
//  Lynx
//
//  Created by Matthew Ernst on 3/26/23.
//

import Foundation

struct UserDefaultsKeys {
    // Profile
    static let appleOrGoogleId = "appleOrGoogleId"
    
    // Apollo Authorization Token
    static let authorizationToken = "authorizationToken"
    static let authorizationTokenExpirationDate = "authorizationTokenExpirationDate"
    static let oauthToken = "oauthToken"
    static let loginType = "loginType"
    
    // All Keys
    static let allKeys: [String] = [
        appleOrGoogleId,
        authorizationToken,
        authorizationTokenExpirationDate,
        oauthToken,
        loginType
    ]
    
    static func removeAllObjectsForAllKeys() {
        let defaults = UserDefaults.standard
        for key in UserDefaultsKeys.allKeys {
            defaults.removeObject(forKey: key)
        }
    }
}
