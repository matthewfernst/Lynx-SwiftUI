//
//  LoginHandler.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/25/23.
//

import SwiftUI
import OSLog
import GoogleSignIn

enum ProfileError: Error {
    case profileCreationFailed
}

/// Overall Login Handler Class. Used with all OAuths.
class LoginHandler {
    private static var profileAttributes: Optional<ProfileAttributes> = nil
   
    /// Common sign in for users of any OAuth. Will automatically login the user to the home page if validated.
    /// Otherwise, the Invitaiton Sheet will show. Profile Attributes are stored at the login and used right away if validated or
    /// saved until the Invitation Sheet is done.
    /// - Parameters:
    ///   - profileManager: Overall profile manager for the App.
    ///   - attributes: Original attributes from the OAuth.
    ///   - oauthToken: OAuth Token
    ///   - goToHome: Binding for moving to the Home page.
    ///   - showInvitationSheet: Binding for showing the Invitation Sheet.
    ///   - showSignInError: Binding for showing the Sign In Error Alert.
    func commonSignIn(
        profileManager: ProfileManager,
        withOAuthAttributes attributes: ProfileAttributes, // TODO: - Update OAuth Struct
        oauthToken: String,
        goToHome: Binding<Bool>,
        showInvitationSheet: Binding<Bool>,
        showSignInError: Binding<Bool>
    ) {
        
//#if DEBUG
//        profileManager.update(newProfileWith: Profile.debugProfile)
//        goToHome.wrappedValue = true
//#else
        ApolloLynxClient.oauthSignIn(
            id: attributes.id,
            oauthType: attributes.oauthType,
            oauthToken: oauthToken,
            email: attributes.email,
            firstName: attributes.firstName,
            lastName: attributes.lastName,
            profilePictureUrl: attributes.profilePictureURL
        ) { result in
            switch result {
            case .success(let refreshToken):
                ApolloLynxClient.getProfileInformation { result in
                    switch result {
                    case .success(let profileAttributes):
                        LoginHandler.profileAttributes = profileAttributes
                        if profileAttributes.validatedInvite {
                            self.loginUser(
                                profileManager: profileManager,
                                goToHome: goToHome,
                                showSignInError: showSignInError
                            )
                        } else {  // Show Invitation Sheet
                            showInvitationSheet.wrappedValue = true
                        }
                    case .failure(let error):
                        Logger.loginHandler.error("Failed to login user. \(error)")
                        showSignInError.wrappedValue = true
                    }
                }
            case .failure:
                showSignInError.wrappedValue = true
            }
        }
//#endif
    }
    
    func loginUser(
        profileManager: ProfileManager,
        goToHome: Binding<Bool>,
        showSignInError: Binding<Bool>
    ) {
        guard let profileAttributes = LoginHandler.profileAttributes else {
            Logger.loginHandler.error("No profileAttributes when creating a user")
            showSignInError.wrappedValue = true
            return
        }
        
        self.signInUser(
            profileManager: profileManager,
            profileAttributes: profileAttributes
        ) { result in
            switch result {
            case .success(_):
                profileManager.update(loginWith: true)
                goToHome.wrappedValue = true
            case .failure(let error):
                Logger.loginHandler.error("Could not create new profile: \(error)")
                showSignInError.wrappedValue = true
            }
        }
    }
    
    private func signInUser(
        profileManager: ProfileManager,
        profileAttributes: ProfileAttributes,
        completion: @escaping (Result<Bool,
        Error>) -> Void
    ) {
        profileManager.update(
            newProfileWith: Profile(
                id: profileAttributes.id,
                oauthType: profileAttributes.oauthType,
                firstName: profileAttributes.firstName!,
                lastName: profileAttributes.lastName!,
                email: profileAttributes.email!,
                profilePictureURL: profileAttributes.profilePictureURL
            )
        )
        
        
        if let _ = profileManager.profile {
            completion(.success((true)))
        } else {
            completion(.failure(ProfileError.profileCreationFailed))
        }
    }
    
    static func signOut() {
        UserManager.shared.token = nil
        if ProfileManager.shared.profile?.oauthType == OAuthType.google.rawValue {
            GIDSignIn.sharedInstance.signOut()
        }
        ApolloLynxClient.clearCache()
        BookmarkManager.shared.removeAllBookmarks()
        ProfileManager.shared.update(loginWith: false) // Keychain clean up deletes profile ¯\_(ツ)_/¯
    }
}
