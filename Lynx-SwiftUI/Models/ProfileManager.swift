//
//  ProfileManager.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/26/23.
//

import Foundation

class ProfileManager: ObservableObject {
    @Published var profile: Profile?
    
    static let shared = ProfileManager()

    private init() { 
        #if DEBUG
            profile = Profile(
                type: SignInType.google.rawValue,
                oauthToken: "123456890",
                id: "123456890",
                firstName: "Matthew",
                lastName: "Ernst",
                email: "matthew.f.ernst@gmail.com",
                profilePictureURL: URL(string: "https://thumbs.dreamstime.com/b/european-teenager-beanie-profile-portrait-male-cartoon-character-blonde-man-avatar-social-network-vector-flat-271205345.jpg")!
            )
        #endif
        
    }
}
