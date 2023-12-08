//
//  EditProfileHandler.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/1/23.
//

import SwiftUI

class EditProfileHandler {
    
    
    func saveEdits(
        withFirstName firstName: String,
        lastName: String,
        email: String,
        profilePicture: Image? = nil,
        completion: @escaping () -> Void
    ) {
        ProfileManager.shared.profile?.editAttributes(
            newFirstName: firstName,
            newLastName: lastName,
            newEmail: email,
            newProfilePictureURL: nil
        )
        var profileChanges: [String: Any] = [:]
        profileChanges[ProfileChangesKeys.firstName.rawValue]  = firstName
        profileChanges[ProfileChangesKeys.lastName.rawValue] = lastName
        profileChanges[ProfileChangesKeys.email.rawValue] = email
        
        // TODO: Get New Profile Picture URL
        
        ApolloLynxClient.editUser(profileChanges: profileChanges) { result in
            switch result {
            case .success(let newProfilePictureURL):
                print()
            case .failure(_):
                print()
            }
            completion()
        }

    }
    
}

enum ProfileChangesKeys: String {
    case firstName = "firstName"
    case lastName = "lastName"
    case email = "email"
    case profilePicture = "profilePicture"
}

