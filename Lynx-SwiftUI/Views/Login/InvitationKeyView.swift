//
//  InvitationKeyView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/1/23.
//

import SwiftUI

struct InvitationKeyView: View {
    @Binding var goToHome: Bool
    
    @State private var key = ""
    @State private var showDontHaveInvitationAlert = false
    @State private var showInvalidKeyAlert = false
    
    var body: some View {
        VStack {
            Text("Invitation Key")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom)
            

            Spacer()
            ZStack {
                keyInput
                backgroundField
            }
            Text(Constants.explanation)
                .multilineTextAlignment(.center)
                .lineLimit(Constants.explanationLineLimit)
                .padding(.bottom)
            Button {
                showDontHaveInvitationAlert = true
            } label: {
                Text("Don't have an invitation key?")
                    .font(.callout)
            }
            Spacer()
            
        }
        .padding()
        .alert("Need an Invitation Key?", isPresented: $showDontHaveInvitationAlert) {} message: {
            Text(Constants.howToGetInviteKey)
        }
        .alert("Invalid Key", isPresented: $showInvalidKeyAlert) {
            Button {
                key = ""
            } label: {
                Text("Dismiss")
            }
        } message: {
            Text(Constants.invalidKeyExplanation)
        }
    }
    
    private var backgroundField: some View {
        let boundKey = Binding<String>(get: { self.key }, set: { newValue in
            self.key = newValue
            self.submitKey()
        })
        
        return TextField("", text: boundKey, onCommit: submitKey)
            .keyboardType(.numberPad)
            .foregroundStyle(.clear)
            .tint(.clear)
        
    }
    
    private func submitKey() {
        guard !key.isEmpty else { return }
        
        if key.count == Constants.KeyInput.inputLength {
            ApolloLynxClient.submitInviteKey(with: key) { result in
                switch result {
                case .success(_):
                    print("pin matched, go to next page, no action to perfrom here")
                    goToHome = true
                case .failure(_):
                    print("this has to called after showing toast why is the failure")
                    showInvalidKeyAlert = true
                }
            }
        }
        
        // this code is never reached under  normal circumstances. If the user pastes a text with count higher than the
        // max digits, we remove the additional characters and make a recursive call.
        if key.count > Constants.KeyInput.inputLength {
            key = String(key.prefix(Constants.KeyInput.inputLength))
            submitKey()
        }
    }
    
    private func getCharacter(forKeyIndex index: Int) -> String {
        if !key.isEmpty,
           let currentIndex = key.index(key.startIndex, offsetBy: index, limitedBy: key.index(before: key.endIndex)) {
            return String(key[currentIndex])
        }
        return "–"
        
    }
    
    private var keyInput: some View {
        HStack {
            ForEach(0..<Constants.KeyInput.inputLength, id: \.self) { index in
                Text(getCharacter(forKeyIndex: index))
                    .font(.system(size: 28, weight: .semibold))
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    
                if index == (Constants.KeyInput.inputLength / 2) - 1 {
                    Spacer()
                }
            }
        }
    }
    
    private struct Constants {
        static let explanation = """
                                 An invitation key is needed to create an account. Enter your key to continue.
                                 """
        static let explanationLineLimit = 6
        
        static let howToGetInviteKey = """
                                       Invitation keys are required to create an account with Lynx. If you don't have an invitation key, you can request one from a friend who already has an account.
                                       """
        
        static let invalidKeyExplanation = """
                                            The key entered is not recognized in our system. This could be because your invitation has expired. Please double-check the key and try again. If you believe there is an error, please contact our developers for assistance.
                                            """
        
        struct KeyInput {
            static let inputLength: Int = 6
        }
    }
    
    
}

#Preview {
    InvitationKeyView (goToHome: .constant(false))
}
