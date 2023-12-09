//
//  Profile.swift
//  Lynx
//
//  Created by Matthew Ernst on 1/25/23.
//

import Foundation

struct Profile: Identifiable {
    private(set) var id: String
    private(set) var type: String
    private(set) var oauthToken: String
    private(set) var firstName, lastName: String
    var name: String { firstName + " " + lastName }
    private(set) var email: String
    var profilePictureURL: URL?
    var measurementSystem: MeasurementSystem = Profile.getDefaultMeasurementSystem()
    var notificationsAllowed: Bool?
    
    init(
        type: String,
        oauthToken: String,
        id: String,
        firstName: String,
        lastName: String,
        email: String,
        profilePictureURL: URL? = nil
    ) {
        self.type = type
        self.oauthToken = oauthToken
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.profilePictureURL = profilePictureURL
    }
    
    init(profileAttributes: ProfileAttributes) {
        self.init(
            type: profileAttributes.type,
            oauthToken: profileAttributes.oauthToken,
            id: profileAttributes.id,
            firstName: profileAttributes.firstName,
            lastName: profileAttributes.lastName,
            email: profileAttributes.email,
            profilePictureURL: profileAttributes.profilePictureURL
        )
    }
    
    private static func getDefaultMeasurementSystem() -> MeasurementSystem {
        let locale = Locale.current
        if let countryCode = locale.language.region?.identifier, countryCode == "US" {
            return .imperial
        } else {
            return .metric
        }
    }
    
//    static func createProfile(
//        type: String,
//        oauthToken: String,
//        id: String,
//        firstName: String,
//        lastName: String,
//        email: String,
//        profilePictureURL: String? = nil,
//        completion: @escaping (Profile) -> Void
//    ) {
//        guard let profilePictureURL = URL(string: profilePictureURL ?? "") else {
//            completion(Profile(type: type, oauthToken: oauthToken, id: id, firstName: firstName, lastName: lastName, email: email))
//            return
//        }
//        
//        ProfilePictureUtils.downloadProfilePicture(with: profilePictureURL) { profilePicture in
//            let profile = Profile(type: type,
//                                  oauthToken: oauthToken,
//                                  id: id,
//                                  firstName: firstName,
//                                  lastName: lastName,
//                                  email: email,
//                                  profilePictureURL: profilePictureURL.absoluteString)
//            completion(profile)
//        }
//    }
    
    mutating func edit(newFirstName: String?, newLastName: String?, newEmail: String?) {
        self.firstName = newFirstName ?? self.firstName
        self.lastName = newLastName ?? self.lastName
        self.email = newEmail ?? self.email
    }
}

// MARK: - Extensions for Debugging
#if DEBUG
extension Profile: CustomDebugStringConvertible
{
    var debugDescription: String {
        """
        id: \(self.id)
        firstName: \(self.firstName)
        lastName: \(self.lastName)
        email: \(self.email)
        profilePictureURL: \(String(describing: self.profilePictureURL))
        """
    }
}
#endif
