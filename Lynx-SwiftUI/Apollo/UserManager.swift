//
//  UserManager.swift
//  Lynx
//
//  Created by Matthew Ernst on 4/30/23.
//

import SwiftUI
import GoogleSignIn

class UserManager {
    static let shared = UserManager()
    
    private init() {}
    
    var token: ExpirableAuthorizationToken? {
        get {
            guard let savedAuthorizationToken = UserDefaults.standard.string(forKey: UserDefaultsKeys.authorizationToken),
                  let savedExpireDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.authorizationTokenExpirationDate) as? Date else {
                return nil
            }
            return ExpirableAuthorizationToken(
                authorizationToken: savedAuthorizationToken,
                expirationDate: savedExpireDate
            )
        }
        set {
            UserDefaults.standard.set(newValue?.authorizationToken, forKey: UserDefaultsKeys.authorizationToken)
            UserDefaults.standard.set(newValue?.expirationDate, forKey: UserDefaultsKeys.authorizationTokenExpirationDate)
        }
    }
    
    func renewToken(completion: @escaping (Result<String, Error>) -> Void) {
        enum RenewTokenErrors: Error {
            case noProfileSaved
            case noOauthTokenSaved
        }
        
        guard let profile = ProfileManager.shared.profile else { // TODO: Once backend hooked up, probably need a static func to get the profile?
            return completion(.failure(RenewTokenErrors.noProfileSaved))
        }
        
        func handleLoginOrCreateUser(oauthToken: String) {
            ApolloLynxClient.loginOrCreateUser(
                id: profile.id,
                oauthType: profile.oauthType,
                oauthToken: oauthToken,
                email: profile.email,
                firstName: profile.firstName,
                lastName: profile.lastName,
                profilePictureUrl: profile.profilePictureURL
            ) { result in
                switch result {
                case .success:
                    completion(.success((UserManager.shared.token!.authorizationToken)))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        if profile.oauthType == OAuthType.google.rawValue {
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                // Check if `user` exists; otherwise, do something with `error`
                if error != nil {
                    print("Deleted profile as Google restore failed")
                    return
                }
                if let oauthToken = user?.idToken?.tokenString {
                    handleLoginOrCreateUser(oauthToken: oauthToken)
                }
            }
        } else if profile.oauthType == OAuthType.apple.rawValue {
            handleLoginOrCreateUser(oauthToken: "1234")
            
        } else {
            fatalError("Could not get OAuth Token")
        }
    }
}


struct ExpirableAuthorizationToken {
    let authorizationToken: String
    let expirationDate: Date
    
    var isExpired: Bool {
        return Date().timeIntervalSince1970 >= expirationDate.timeIntervalSince1970
    }
}
