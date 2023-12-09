//
//  LoginHandler.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/25/23.
//

import Foundation
import OSLog

enum ProfileError: Error {
    case profileCreationFailed
}

class LoginHandler {
    func commonSignIn(
        type: String,
        id: String,
        token: String,
        email: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        profilePictureURL: URL? = nil,
        completion: @escaping (Result<Bool,
                               Error>) -> Void
    ) {
        ApolloLynxClient.loginOrCreateUser(
            type: type,
            id: id,
            token: token,
            email: email,
            firstName: firstName,
            lastName: lastName,
            profilePictureUrl: profilePictureURL
        ) { result in
                switch result {
                case .success(let validatedInvite):
                    Logger.loginHandler.info("Authorization Token successfully received.")
                    if validatedInvite {
                        self.loginUser(completion: completion)
                    } else {
                        // Show Invitation Sheet
                        completion(.success(validatedInvite))
                    }
                case .failure:
                    completion(.failure(UserError.noAuthorizationTokenReturned))
                }
            }
    }
    
    
    private func loginUser(completion: @escaping (Result<Bool, Error>) -> Void) {
        ApolloLynxClient.getProfileInformation() { result in
            switch result {
            case .success(let profileAttributes):
                self.signInUser(profileAttributes: profileAttributes, completion: completion)
            case .failure(let error):
                Logger.loginHandler.error("Failed to login user. \(error)")
                completion(.failure(error))
            }
        }
    }
    
    
    private func signInUser(profileAttributes: ProfileAttributes, completion: @escaping (Result<Bool, Error>) -> Void) {
        let defaults = UserDefaults.standard
        defaults.setValue(profileAttributes.type, forKey: UserDefaultsKeys.loginType)
        defaults.setValue(profileAttributes.id, forKey: UserDefaultsKeys.appleOrGoogleId)
        ProfileManager.shared.update(
            withNewProfile: Profile(
                type: profileAttributes.type,
                oauthToken: profileAttributes.oauthToken,
                id: profileAttributes.id,
                firstName: profileAttributes.firstName,
                lastName: profileAttributes.lastName,
                email: profileAttributes.email,
                profilePictureURL: profileAttributes.profilePictureURL
            )
        )
        
        if let _ = ProfileManager.shared.profile {
            completion(.success((true)))
        } else {
            completion(.failure(ProfileError.profileCreationFailed))
        }
    }
}

enum SignInType: String, CaseIterable {
    case google = "GOOGLE"
    case apple = "APPLE"
}
