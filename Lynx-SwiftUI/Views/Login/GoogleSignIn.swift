//
//  GoogleSignIn.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/25/23.
//

import Foundation
import SwiftUI
import GoogleSignIn

class GoogleSignIn: ObservableObject {
    @EnvironmentObject var loginHandler: LoginHandler
    @Published var showErrorSigningIn = false
    
    func signIn(completion: @escaping (ProfileAttributes) -> Void) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] signInResult, error in
                guard error == nil else {
                    self?.showErrorSigningIn = true
                    return
                }
                
                guard let googleId = signInResult?.user.userID,
                      let profile = signInResult?.user.profile,
                      let token = signInResult?.user.idToken?.tokenString else {
                    self?.showErrorSigningIn = true
                    return
                }
                
                let name = profile.name.components(separatedBy: " ")
                let (firstName, lastName) = (name[0], name[1])
                let email = profile.email
                
                var pictureURL: URL? = nil
                if let urlString = profile.imageURL(withDimension: 320)?.absoluteString {
                    pictureURL = URL(string: urlString)
                }
                
                completion(
                    ProfileAttributes(
                        type: SignInType.google.rawValue,
                        oauthToken: token,
                        id: googleId,
                        email: email,
                        firstName: firstName,
                        lastName: lastName,
                        profilePictureURL: pictureURL
                    )
                )
            }
        }
    }
}
