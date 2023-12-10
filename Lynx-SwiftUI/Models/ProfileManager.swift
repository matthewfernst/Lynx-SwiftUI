//
//  ProfileManager.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/26/23.
//

import SwiftUI

class ProfileManager: ObservableObject {
    @Published private(set) var profile: Profile?
    
    @Published private(set) var profilePicture: Image?
    
    static let shared = ProfileManager()
    
    
    // MARK: - Intent's
    func edit(newFirstName: String, newLastName: String, newEmail: String) {
        profile?.edit(
            newFirstName: newFirstName,
            newLastName: newLastName,
            newEmail: newEmail
        )
    }
    
    func update(withNewProfile newProfile: Profile) {
        profile = newProfile
        downloadProfilePicture(
            withURL: newProfile.profilePictureURL ?? Constants.defaultProfilePictureURL
        )
    }
    
    func update(withNewProfilePictureURL newURL: URL) {
        profile?.profilePictureURL = newURL
        downloadProfilePicture(withURL: newURL)
    }
    
    func update(withMeasurementSystem newSystem: MeasurementSystem) {
        profile?.measurementSystem = newSystem
    }
    
    func update(withNotifcationsAllowed allowed: Bool) {
        profile?.notificationsAllowed = allowed
    }
    
    // MARK: - Helpers
    private func downloadProfilePicture(withURL url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let uiImage = UIImage(data: data) {
                // Convert the downloaded data to an Image
                let image = Image(uiImage: uiImage)
                
                // Update the profilePicture property on the main thread
                DispatchQueue.main.async {
                    self.profilePicture = image
                }
            }
        }.resume()
    }
    
    
    private init() {
#if DEBUG
        profile = Profile(
            type: SignInType.google.rawValue,
            oauthToken: "123456890",
            id: "123456890",
            firstName: "Matthew",
            lastName: "Ernst",
            email: "matthew.f.ernst@gmail.com",
            profilePictureURL: Constants.defaultProfilePictureURL
        )
#endif
    }
    
    struct Constants {
        static let defaultProfilePictureURL = URL(string: "https://thumbs.dreamstime.com/b/european-teenager-beanie-profile-portrait-male-cartoon-character-blonde-man-avatar-social-network-vector-flat-271205345.jpg")!
    }
}
