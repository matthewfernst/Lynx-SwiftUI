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
    @State private var showInvitationSheet = false
    @State private var isSigningIn = false
    @StateObject private var googleSignIn = GoogleSignIn()
    
    
    var body: some View {
        ZStack {
            backgroundLynxImage
            signLynxLogoAndSignInButtonStack
                .alert("Failed to Sign In", isPresented: $showSignInError) {
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
        .sheet(isPresented: $showInvitationSheet, content: {
            InvitationKeyView(goToHome: $goToHome)
                .interactiveDismissDisabled()
        })
        
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
            width: Constants.SignInButton.width,
            height: Constants.SignInButton.height
        )
        .padding()
        .clipShape(
            RoundedRectangle(
                cornerRadius: Constants.SignInButton.cornerRadius
            )
        )
    }
    
    private var signInWithGoogleButton: some View {
        Button {
#if DEBUG
            goToHome = true
#endif
            isSigningIn = true
            googleSignIn.signIn(showErrorSigningIn: $showSignInError) { profileAttributes in
                login(withProfileAttributes: profileAttributes)
            }
        } label: {
            googleLogoAndText
        }
        .frame(
            width: Constants.SignInButton.width,
            height: Constants.SignInButton.height
        )
        .background(.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: Constants.SignInButton.cornerRadius
            )
        )
    }
    
    private var googleLogoAndText: some View {
        HStack {
            Image("GoogleLogo")
                .resizable()
                .scaledToFit()
                .frame(width: Constants.googleLogoWidth)
            Text("Sign in with Google")
                .foregroundStyle(.black)
                .fontWeight(.medium)
        }
    }
    
    private var signInProgressView: some View {
        ProgressView("Signing in...")
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .foregroundStyle(.white)
            .padding(.bottom)
    }
    
    @ViewBuilder
    private var signLynxLogoAndSignInButtonStack: some View {
        VStack {
            Spacer()
            Image("LynxLogo")
                .resizable()
                .scaledToFit()
                .frame(width: Constants.Logo.width)
                .offset(x: Constants.Logo.xOffset, y: Constants.Logo.yOffset)
            if isSigningIn {
                signInProgressView
            } else {
                signInWithAppleButton
                signInWithGoogleButton
            }
        }
        .padding()
    }
    
    // MARK: - Helpers
    private func login(withProfileAttributes attributes: ProfileAttributes) {
        self.loginHandler.commonSignIn(
            type: attributes.type,
            id: attributes.id,
            token: attributes.oauthToken,
            email: attributes.email,
            firstName: attributes.firstName,
            lastName: attributes.lastName,
            profilePictureURL: attributes.profilePictureURL
        ) { result in
            switch result {
            case .success(let validatedInvite):
                if validatedInvite {
                    goToHome = true
                } else {
                    showInvitationSheet = true
                }
            case .failure(_):
                showSignInError = true
            }
        }
    }
    
    // MARK: - Constants
    private struct Constants {
        struct Logo {
            static let width: CGFloat = 150
            static let xOffset: CGFloat = -90
            static let yOffset: CGFloat = -40
        }
        
        struct SignInButton {
            static let width: CGFloat = 300
            static let height: CGFloat = 44
            static let cornerRadius: CGFloat = 8
        }
        
        static let googleLogoWidth: CGFloat = 12
    }
}

#Preview {
    LoginView()
}
