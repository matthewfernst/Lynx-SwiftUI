//
//  LoginView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/24/23.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn

struct LoginView: View {
    @EnvironmentObject var loginHandler: LoginHandler
    @State private var goToHome = false
    @State private var showSignInError = false
    @StateObject private var googleSignIn = GoogleSignIn()
    
    
    var body: some View {
        ZStack {
            Image("LynxSignIn")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(.all)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.black]),
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .edgesIgnoringSafeArea(.all)
                )
            
            VStack {
                Spacer()
                Image("LynxLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .offset(x: -90, y: -40)
                signInWithAppleButton
                signInWithGoogleButton
            }
            .fullScreenCover(isPresented: $goToHome, content: HomeView.init) // TODO: Better transition!
            .padding()
        }
    }
    
    private var signInWithAppleButton: some View {
        SignInWithAppleButton(.signIn) { request in
            
        } onCompletion: { result in
            
        }
        .signInWithAppleButtonStyle(.white)
        .frame(
            width: Constants.signInButtonWidth,
            height: Constants.signInButtonHeight
        )
        .padding()
        .clipShape(
            RoundedRectangle(
                cornerRadius: Constants.signInButtonCornerRadius
            )
        )
    }
    
    private var signInWithGoogleButton: some View {
        Button {
            googleSignIn.signIn { profileAttributes in
                self.loginHandler.commonSignIn(
                    type: profileAttributes.type,
                    id: profileAttributes.id,
                    token: profileAttributes.oauthToken,
                    email: profileAttributes.email,
                    firstName: profileAttributes.firstName,
                    lastName: profileAttributes.lastName,
                    profilePictureURL: profileAttributes.profilePictureURL
                ) { result in
                    switch result {
                    case .success(_):
                        goToHome = true
                    case .failure(_):
                        showSignInError = true
                    }
                }
            }
        } label: {
            HStack {
                Image("GoogleLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12)
                Text("Sign in with Google")
                    .foregroundStyle(.black)
                    .fontWeight(.semibold)
            }
        }
        .frame(
            width: Constants.signInButtonWidth,
            height: Constants.signInButtonHeight
        )
        .background(.white)
        
        .clipShape(
            RoundedRectangle(
                cornerRadius: Constants.signInButtonCornerRadius
            )
        )
        .alert("Failed to Sign in", isPresented: $googleSignIn.showErrorSigningIn) { } message: {
            Text("""
                      It looks like we weren't able to sign you in. Please try again. If the issue continues, please contact the developers.
                 """
            )
        }
    }
    
    private struct Constants {
        static let signInButtonWidth: CGFloat = 300
        static let signInButtonHeight: CGFloat = 44
        static let signInButtonCornerRadius: CGFloat = 8
    }
}

enum SignInType: String, CaseIterable {
    case google = "GOOGLE"
    case apple = "APPLE"
}

#Preview {
    LoginView()
        .environmentObject(LoginHandler())
}
