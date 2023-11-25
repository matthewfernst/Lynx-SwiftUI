//
//  LoginView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/24/23.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    
    @State private var goToHome = false
    
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
            // TODO: Google Sign In
            withAnimation {
               goToHome = true
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
    
    private struct Constants {
        static let signInButtonWidth: CGFloat = 300
        static let signInButtonHeight: CGFloat = 44
        static let signInButtonCornerRadius: CGFloat = 8
    }
}

#Preview {
    LoginView()
}
