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

class LoginHandler: ObservableObject {
    @Published var profile: Profile?
    
    func commonSignIn(
        type: String,
        id: String,
        token: String,
        email: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        profilePictureURL: URL? = nil,
        completion: @escaping (Result<Void,
                               Error>) -> Void
    ) {
        ApolloLynxClient.loginOrCreateUser(
            type: type,
            id: id,
            token: token,
            email: email,
            firstName: firstName,
            lastName: lastName,
            profilePictureUrl: profilePictureURL) { result in
                switch result {
                case .success(let validatedInvite):
                    Logger.loginHandler.info("Authorization Token successfully received.")
                    if validatedInvite {
                        self.loginUser(completion: completion)
                    } else {
                        // TODO: Show Invitation Sheet!
                    }
                case .failure:
                    completion(.failure(UserError.noAuthorizationTokenReturned))
                }
            }
    }
    
    
    private func loginUser(completion: @escaping (Result<Void, Error>) -> Void) {
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
    
    
    private func signInUser(profileAttributes: ProfileAttributes, completion: @escaping (Result<Void, Error>) -> Void) {
        let defaults = UserDefaults.standard
        defaults.setValue(profileAttributes.type, forKey: UserDefaultsKeys.loginType)
        defaults.setValue(profileAttributes.id, forKey: UserDefaultsKeys.appleOrGoogleId)
        profile = Profile(
            type: profileAttributes.type,
            oauthToken: profileAttributes.oauthToken,
            id: profileAttributes.id,
            firstName: profileAttributes.firstName,
            lastName: profileAttributes.lastName,
            email: profileAttributes.email,
            profilePictureURL: profileAttributes.profilePictureURL
        )
        
        if let profile = profile {
            completion(.success(()))
        } else {
            completion(.failure(ProfileError.profileCreationFailed))
        }
    }
}
