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
    private var googleSignInHandler = GoogleSignInHandler()
    private var appleSignInHandler = AppleSignInHandler()
    
    
    @State private var goToHome = false
    @State private var showSignInError = false
    @State private var showInvitationSheet = false
    @State private var isSigningIn = false
    
    // Aniamtion States
    @State private var moveInLogo = false
    @State private var moveInApple = false
    @State private var moveInGoogle = false
    
    var body: some View {
        ZStack {
            backgroundLynxImage
            signLynxLogoAndSignInButtonStack
                .alert("Failed to Sign In", isPresented: $showSignInError) {
                    Button("OK") {
                        withAnimation {
                            isSigningIn = false
                        }
                    }
                } message: {
                    Text(
                        "It looks like we weren't able to sign you in. Please try again. If the issue continues, please contact the developers."
                    )
                }
        }
        .sheet(isPresented: $showInvitationSheet, content: {
            InvitationKeyView(isSigningIn: $isSigningIn) { // TODO: Some way to do this better??
                loginHandler.loginUser { result in
                    switch result {
                    case .success(_):
                        goToHome = true
                    case .failure(_):
                        showSignInError = true
                    }
                }
            }
            .interactiveDismissDisabled()
        })
        .onAppear {
            withAnimation(.easeInOut(duration: 0.75).delay(0.5)) {
                moveInLogo = true
            } completion: {
                withAnimation {
                    moveInApple = true
                } completion: {
                    withAnimation {
                        moveInGoogle = true
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $goToHome, content: HomeView.init) // TODO: Better transition!
    }
    
    // MARK: - Views
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
            withAnimation {
                isSigningIn = true
            }
            request.requestedScopes = [.fullName, .email]
            
        }  onCompletion: { result in
            print("HERE!!!")
            appleSignInHandler.onCompletion(result, showErrorSigningIn: $showSignInError) { attributes in
#if DEBUG
                goToHome = true
#endif
                loginHandler.commonSignIn(
                    withProfileAttributes: attributes,
                    goToHome: $goToHome,
                    showInvitationSheet: $showInvitationSheet,
                    showSignInError: $showSignInError
                )
                
            }
        }
        .signInWithAppleButtonStyle(.white)
        .frame(
            width: Constants.SignInButton.width,
            height: Constants.SignInButton.height
        )
        .padding()
    }
    
    private var signInWithGoogleButton: some View {
        Button {
#if DEBUG
            goToHome = true
#endif
            withAnimation {
                isSigningIn = true
            }
            googleSignInHandler.signIn(showErrorSigningIn: $showSignInError) { attributes in
                loginHandler.commonSignIn(
                    withProfileAttributes: attributes,
                    goToHome: $goToHome,
                    showInvitationSheet: $showInvitationSheet,
                    showSignInError: $showSignInError
                )
            }
        } label: {
            googleLogoAndText
        }
        .buttonStyle(GoogleButtonStyle())
        .frame(
            width: Constants.SignInButton.width,
            height: Constants.SignInButton.height
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: Constants.SignInButton.cornerRadius
            )
        )
    }
    
    struct GoogleButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(maxWidth: .infinity)
                .padding()
                .background(configuration.isPressed ? .gray : .white)
                .transition(.opacity)
        }
    }
    
    private var googleLogoAndText: some View {
        HStack(spacing: Constants.SignInButton.spacing) {
            Image("GoogleLogo")
                .resizable()
                .scaledToFit()
                .frame(width: Constants.googleLogoWidth)
            
            Text("Sign in with Google")
                .foregroundStyle(.black)
                .font(
                    .system(size: Constants.SignInButton.fontSize,
                            weight: .medium)
                )
        }
    }
    
    private var signInProgressView: some View {
        ProgressView("Signing in≈")
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .foregroundStyle(.white)
            .padding(.bottom)
    }
    
    @ViewBuilder
    private var signLynxLogoAndSignInButtonStack: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                Image("LynxLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.Logo.width)
                    .position(
                        x: geometry.size.width / 10 - Constants.Logo.xOffset,
                        y: geometry.size.height / 1.75 - Constants.Logo.yOffset
                    )
                    .offset(x: moveInLogo ? 0 : -200)
                
                if isSigningIn {
                    signInProgressView
                } else {
                    signInWithAppleButton
                        .offset(y: moveInApple ? 0 : 200)
                    signInWithGoogleButton
                        .offset(y: moveInGoogle ? 0 : 100)
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    
    // MARK: - Constants
    private struct Constants {
        struct Logo {
            static let width: CGFloat = 130
            static let xOffset: CGFloat = -90
            static let yOffset: CGFloat = -40
        }
        
        struct SignInButton {
            static let width: CGFloat = 280
            static let height: CGFloat = 40
            static let cornerRadius: CGFloat = 7
            static let fontSize: CGFloat = 15
            static let spacing: CGFloat = 4
        }
        
        static let googleLogoWidth: CGFloat = 12
    }
}

#Preview {
    LoginView()
}
