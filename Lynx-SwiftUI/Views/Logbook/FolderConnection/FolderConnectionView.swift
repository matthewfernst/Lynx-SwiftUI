//
//  FolderConnectionView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/29/23.
//

import SwiftUI
import OSLog

struct FolderConnectionView: View {
    @ObservedObject private var folderConnectionHandler = FolderConnectionHandler()
    @State private var showDocumentPicker = false
    
    var body: some View {
        NavigationStack {
            initialUploadExplanation
                .navigationTitle("Uploading Slope Files")
                .navigationBarTitleDisplayMode(.inline)
                .fileImporter(
                    isPresented: $showDocumentPicker,
                    allowedContentTypes: [.folder]
                ) { result in
                    switch result {
                    case .success(let url):
                        folderConnectionHandler.picker(didPickDocumentsAt: url)
                    case .failure(let error):
                        Logger.folderConnectionView.error(
                            "Failed in selecting folder with error: \(error)"
                        )
                    }
                }
                .alert(isPresented: $folderConnectionHandler.showError) {
                    folderConnectionHandler.errorAlert!
                }
        }
    }
    
    private var initialUploadExplanation: some View {
        VStack {
            Text(Constants.howToUploadInformation)
                .multilineTextAlignment(.center)
                .frame(maxHeight: .infinity)
            Image("StepsToUpload")
                .resizable()
                .scaledToFill()
                .padding()
                .frame(maxHeight: .infinity)
            Button("Continue") {
                showDocumentPicker = true
            }
            .buttonStyle(.borderedProminent)
            .frame(maxHeight: .infinity)
        }
        .padding()
    }
    
    
    // MARK: - Alert Actions
//    @ViewBuilder
//    private var uploadErrorActions: some View {
//        Button("Try Again") {
//            showDocumentPicker = true
//            folderConnectionHandler.tracker.uploadError = false
//        }
//        Button("Cancel", role: .cancel) {
//            folderConnectionHandler.tracker.uploadError = false
//        }
//    }
//    
//    @ViewBuilder
//    private var fileAccessNotAllowedActions: some View {
//        Button("Go to Settings") {
//            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
//                return
//            }
//            
//            if UIApplication.shared.canOpenURL(settingsURL) {
//                UIApplication.shared.open(settingsURL) { success in
//                    Logger.folderConnectionView.debug("Settings opened.")
//                }
//            }
//            folderConnectionHandler.tracker.fileAccessNotAllowed = false
//        }
//        Button("Cancel", role: .cancel) {
//            folderConnectionHandler.tracker.fileAccessNotAllowed = false
//        }
//    }
    
    
    private struct Constants {
        static let howToUploadInformation = """
                                            To upload, please follow the instructions illustrated below. When you are ready, click the 'Continue' button and select the correct directory
                                            """
    }
}

#Preview {
    FolderConnectionView()
}
