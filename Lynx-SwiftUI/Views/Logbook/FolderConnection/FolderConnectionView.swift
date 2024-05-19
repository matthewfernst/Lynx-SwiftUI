//
//  FolderConnectionView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/29/23.
//

import SwiftUI
import AVKit
import OSLog

struct FolderConnectionView: View {
    @Binding var showUploadProgressView: Bool
    @Bindable var folderConnectionHandler: FolderConnectionHandler
    
    @Environment(\.dismiss) private var dismiss
    @State private var showDocumentPicker = false
    @State var dismissForUpload: Bool = false
    @State private var player: AVPlayer? = nil
    
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
                        folderConnectionHandler.picker(
                            didPickDocumentsAt: url,
                            dismissForUpload: $dismissForUpload
                        )
                    case .failure(let error):
                        Logger.folderConnectionView.error(
                            "Failed in selecting folder with error: \(error)"
                        )
                    }
                }
                .alert(isPresented: $folderConnectionHandler.showError) {
                    folderConnectionHandler.errorAlert!
                }
                .onChange(of: dismissForUpload) { _, newValue in
                    if newValue {
                        dismiss()
                        // Let a small amount of time pass for this view to dismiss
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showUploadProgressView = true
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                .onAppear {
                    if let url = Bundle.main.url(forResource: "HowToUpload", withExtension: "mov") {
                        player = AVPlayer(url: url)
                        player?.play()
                    }
                }
        }
    }
    
    private var initialUploadExplanation: some View {
        VStack {
            Text(Constants.howToUploadInformation)
                .multilineTextAlignment(.center)
                .frame(maxHeight: .infinity)
            if let player {
                VideoPlayer(player: player)
                    .aspectRatio(2/3, contentMode: .fill)
                    .padding()
            }
            Button("Continue") {
                showDocumentPicker = true
            }
            .buttonStyle(.borderedProminent)
            .frame(maxHeight: .infinity)
        }
        .padding()
    }
    
    private struct Constants {
        static let howToUploadInformation = """
                                            To upload, please follow the instructions illustrated below. When you are ready, click the 'Continue' button and select the correct directory.
                                            """
    }
}

#Preview {
    FolderConnectionView(
        showUploadProgressView: .constant(false),
        folderConnectionHandler: FolderConnectionHandler()
    )
}
