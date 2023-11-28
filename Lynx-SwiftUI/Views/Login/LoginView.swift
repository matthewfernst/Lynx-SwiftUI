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
    private var loginHandler = LoginHandler()
    @State private var goToHome = false
    @State private var showSignInError = false
    @State private var isSigningIn = false
    @StateObject private var googleSignIn = GoogleSignIn()
    
    
    var body: some View {
        ZStack {
            backgroundLynxImage
            Group {
                signInProgressView
                signLynxLogoAndSignInButtonStack
            }
            .alert("Failed to Sign In", isPresented: $googleSignIn.showErrorSigningIn) {
                Button("OK") {
                    isSigningIn = false
                }
            } message: {
                Text("""
                          It looks like we weren't able to sign you in. Please try again. If the issue continues, please contact the developers.
                     """
                )
            }
        }
        .fullScreenCover(isPresented: $goToHome, content: HomeView.init) // TODO: Better transition!
    }
    
    private var backgroundLynxImage: some View {
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
            #if DEBUG
            goToHome = true
            #endif
            isSigningIn = true
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

    }
    
    private var signLynxLogoAndSignInButtonStack: some View {
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
        .padding()
    }
    
    @ViewBuilder
    private var signInProgressView: some View {
        if isSigningIn {
            ProgressView("Signing in...")
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.5))
                .ignoresSafeArea(.all)
                .zIndex(100)
        }
    }
    
    private struct Constants {
        static let signInButtonWidth: CGFloat = 300
        static let signInButtonHeight: CGFloat = 44
        static let signInButtonCornerRadius: CGFloat = 8
    }
}

#Preview {
    LoginView()
}
