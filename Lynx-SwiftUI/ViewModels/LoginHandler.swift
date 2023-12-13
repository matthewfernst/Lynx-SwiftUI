//
//  LoginHandler.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/25/23.
//

import SwiftUI
import OSLog

enum ProfileError: Error {
    case profileCreationFailed
}

class LoginHandler {
    func commonSignIn(
        withProfileAttributes attributes: ProfileAttributes,
        goToHome: Binding<Bool>,
        showInvitationSheet: Binding<Bool>,
        showSignInError: Binding<Bool>
    ) {
        ApolloLynxClient.loginOrCreateUser(
            type: attributes.type,
            id: attributes.id,
            token: attributes.oauthToken,
            email: attributes.email,
            firstName: attributes.firstName,
            lastName: attributes.lastName,
            profilePictureUrl: attributes.profilePictureURL
        ) { result in
                switch result {
                case .success(let validatedInvite):
                    Logger.loginHandler.info("Authorization Token successfully received.")
                    if validatedInvite {
                        self.loginUser { result in
                            switch result {
                            case .success(_):
                                goToHome.wrappedValue = true
                            case .failure(_):
                                showSignInError.wrappedValue = true
                            }
                        }
                    } else { // Show Invitation Sheet
                        showInvitationSheet.wrappedValue = true
                    }
                case .failure:
                    showSignInError.wrappedValue = true
                }
            }
    }
    
    
    func loginUser(completion: @escaping (Result<Bool, Error>) -> Void) {
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
                firstName: profileAttributes.firstName!,
                lastName: profileAttributes.lastName!,
                email: profileAttributes.email!,
                profilePictureURL: profileAttributes.profilePictureURL
            )
        )
        
        if let _ = ProfileManager.shared.profile {
            completion(.success((true)))
        } else {
            completion(.failure(ProfileError.profileCreationFailed))
        }
    }
    
    static func signOut() {
        UserManager.shared.token = nil
        ApolloLynxClient.clearCache()
        BookmarkManager.shared.removeAllBookmarks()
    }
}

enum SignInType: String, CaseIterable {
    case google = "GOOGLE"
    case apple = "APPLE"
}
