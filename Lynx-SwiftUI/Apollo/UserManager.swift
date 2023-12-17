//
//  UserManager.swift
//  Lynx
//
//  Created by Matthew Ernst on 4/30/23.
//

import SwiftUI
import GoogleSignIn
import OSLog

class UserManager {
    static let shared = UserManager()
        
    var token: ExpirableAuthorizationToken? {
        get {
            do {
                return try KeychainManager.get() // will return nil if no token is available
            } catch {
                fatalError("KeychainManager failed to handle getting the ExpirableToken. Please check the logs.")
            }
        }
        set { // if we do UserManager.shared.token = nil -> we want to delete the token
            do {
                try (newValue == nil ? KeychainManager.delete() : KeychainManager.save(token: newValue!))
            } catch {
                fatalError("KeychainManager failed to handle setting the ExpirableToken. Please check the logs.")
            }
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
                    Logger.userManager.error("Restore of previous Google Sign in failed with: \(error)")
                    return
                }
                if let oauthToken = user?.idToken?.tokenString {
                    handleLoginOrCreateUser(oauthToken: oauthToken)
                }
            }
        } else if profile.oauthType == OAuthType.apple.rawValue {
            // TODO: Setup
            handleLoginOrCreateUser(oauthToken: "1234")
        } else {
            fatalError("OAuth type is not supported. Got: \(profile.oauthType)")
        }
    }
}


struct ExpirableAuthorizationToken: Codable {
    let authorizationToken: String
    let expirationDate: Date
    
    var isExpired: Bool {
        return Date().timeIntervalSince1970 >= expirationDate.timeIntervalSince1970
    }
}
