//
//  EditProfileView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/29/23.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @ObservedObject private var profileManager = ProfileManager.shared
    @Environment(\.dismiss) private var dismiss
    
    private var editProfileHandler = EditProfileHandler()
    
    @State private var profilePictureItem: PhotosPickerItem?
    @State private var newProfilePictureData: Data?
    @State private var newProfilePicture: Image?
    
    @State private var firstName = ProfileManager.shared.profile!.firstName
    @State private var lastName = ProfileManager.shared.profile!.lastName
    @State private var email = ProfileManager.shared.profile!.email
    
    @State private var showSavingChanges = false
    
    @State private var gotToLogin = false
    
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
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(showSavingChanges)
            .toolbar {
                ToolbarItemGroup(placement: .confirmationAction) {
                    if showSavingChanges {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Button {
                            showSavingChanges = true
                            editProfileHandler.saveEdits(
                                withFirstName: firstName,
                                lastName: lastName,
                                email: email,
                                profilePictureData: newProfilePictureData
                            ) {
                                showSavingChanges = false
                                dismiss()
                            }
                        } label: {
                            Text("Save")
                                .fontWeight(.bold)
                        }
                    }
                }
            }
        }
        .disabled(showSavingChanges)
        .fullScreenCover(isPresented: $gotToLogin, content: LoginView.init)
        
    }
    
    private var changeProfilePicture: some View {
        VStack {
            if let newProfilePicture {
                newProfilePicture
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(maxWidth: Constants.profilePictureWidth)
            } else {
                AsyncImage(url: profileManager.profile?.profilePictureURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                }
                .frame(maxWidth: Constants.profilePictureWidth)
            }
            PhotosPicker("Change Profile Picture", selection: $profilePictureItem)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .onChange(of: profilePictureItem) { _, _ in
                    Task {
                        if let data = try? await profilePictureItem?.loadTransferable(type: Data.self) {
                            newProfilePictureData = data
                            if let uiImage = UIImage(data: data) {
                                newProfilePicture = Image(uiImage: uiImage)
                            }
                        }
                    }
                }
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
                LoginHandler.signOut()
                gotToLogin = true
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.forward")
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



