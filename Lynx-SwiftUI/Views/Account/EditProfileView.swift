//
//  EditProfileView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/29/23.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName = ProfileManager.shared.profile!.firstName
    @State private var lastName = ProfileManager.shared.profile!.lastName
    @State private var email = ProfileManager.shared.profile!.email
    
    var body: some View {
        NavigationStack {
            VStack {
                changeProfilePicture
                Form {
                    nameAndEmailEditableSection
                    mergeAndSignOutSection
                    deleteAccount
                }
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction){
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
               
                ToolbarItemGroup(placement: .confirmationAction) {
                    Button {
                        
                    } label: {
                        Text("Save")
                            .fontWeight(.bold)
                    }
                }
            }
        }
 
    }
    
    private var changeProfilePicture: some View {
        VStack {
            AsyncImage(url: ProfileManager.shared.profile?.profilePictureURL) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
            } placeholder: {
                ProgressView()
            }
            .frame(maxWidth: Constants.profilePictureWidth)
            .padding(.bottom)
            Button {
                
            } label: {
                Text("Change Profile Picture")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
    }
    
    private var nameAndEmailEditableSection: some View {
        Section {
            HStack {
                Text("Name")
                    .bold()
                    .padding(.trailing)
                
            TextField(firstName, text: $firstName)
            TextField(lastName, text: $lastName)
            }
            HStack {
                Text("Email")
                    .bold()
                    .padding(.trailing)
                
                TextField(email, text: $email)
            }
        }
    }
    
    private var mergeAndSignOutSection: some View {
        Section {
            NavigationLink(destination: Text("TODO")) {
                Label("Merge Accounts", systemImage: "shared.with.you")
            }
            Button {
                
            } label: {
                Label("Sign Out", systemImage: "door.right.hand.closed")
            }
        }
    }
    
    private var deleteAccount: some View {
        Section {
            Button(role: .destructive) {
                
            } label: {
                Label("Delete Account", systemImage: "trash.fill")
                    .foregroundStyle(.red)
            }
        }
    }
    
    private struct Constants {
        static let profilePictureWidth: CGFloat = 110
    }
}

#Preview {
    EditProfileView()
}
