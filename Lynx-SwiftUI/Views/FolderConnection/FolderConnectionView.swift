//
//  FolderConnectionView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/29/23.
//

import SwiftUI

struct FolderConnectionView: View {
    var body: some View {
            VStack {
                Text("Uploading Slope Files")
                    .font(.title)
                    .fontWeight(.bold)
                Text(Constants.howToUploadInformation)
                    .multilineTextAlignment(.center)
                    .frame(maxHeight: .infinity)
                Image("StepsToUpload")
                    .resizable()
                    .scaledToFill()
                    .padding()
                    .frame(maxHeight: .infinity)
                Button("Continue") {
                    // TODO:
                }
                .buttonStyle(.borderedProminent)
                .frame(maxHeight: .infinity)
            }
            .padding()
    }
    
    private struct Constants {
        static let howToUploadInformation = """
                                            To upload, please follow the instructions illustrated below. When you are ready, click the 'Continue' button and select the correct directory
                                            """
    }
}

#Preview {
    FolderConnectionView()
}
