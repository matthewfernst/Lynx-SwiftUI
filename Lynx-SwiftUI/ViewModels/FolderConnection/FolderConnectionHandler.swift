//
//  FolderConnectionHandler.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/10/23.
//

import SwiftUI
import OSLog

class FolderConnectionHandler: ObservableObject {
    @Published var errorAlert: Alert? = nil {
        didSet {
            showError = true
        }
    }
    @Published var showError = false
    @Published var uploadProgress = 0.0
    @Published var currentFileBeingUploaded = ""
    private var uploadTimer: Timer?
    
    func picker(didPickDocumentsAt url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            // Handle the failure here.
            showUploadError()
            return
        }
        
        defer { url.stopAccessingSecurityScopedResource() }
        
        let gpsLogsURL = url.appendingPathComponent("GPSLogs")
        BookmarkManager.shared.saveBookmark(for: gpsLogsURL)
        
        if FileManager.default.fileExists(atPath: gpsLogsURL.path) {
            // Get the contents of the directory
            guard let contents = try? FileManager.default.contentsOfDirectory(at: gpsLogsURL, includingPropertiesForKeys: nil) else {
                // Failed to access the directory
                showFileAccessError()
                return
            }
            
            if contents.allSatisfy({ $0.pathExtension == "slopes" }) {
                let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey]
                
                guard let totalNumberOfFiles = FileManager.default.enumerator(at: gpsLogsURL, includingPropertiesForKeys: keys)?.allObjects.count else {
                    Logger.folderConnectionHandler.debug("*** Unable to access the contents of \(gpsLogsURL.path) ***\n")
                    showFileAccessError()
                    return
                }
                
                guard let fileList = getFileList(at: gpsLogsURL, includingPropertiesForKeys: keys) else { return }
                
                let requestedPathsForUpload = fileList.compactMap { $0.lastPathComponent }
                Logger.folderConnectionHandler.info("Requested Paths: \(requestedPathsForUpload)")
                
                
                ApolloLynxClient.createUserRecordUploadUrl(filesToUpload: requestedPathsForUpload) { [unowned self] result in
                    switch result {
                    case .success(let urlsForUpload):
                        guard url.startAccessingSecurityScopedResource() else {
                            // Handle the failure here.
                            self.showFileAccessError()
                            return
                        }
                        
                        guard let fileList = self.getFileList(at: gpsLogsURL, includingPropertiesForKeys: keys) else { return }
                        
                        var currentFileNumberBeingUploaded = 0
                        
                        self.uploadTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
                            guard currentFileNumberBeingUploaded < totalNumberOfFiles else {
                                timer.invalidate()
                                return
                            }
                            
                            if case let fileURL = fileList[currentFileNumberBeingUploaded] {
                                Logger.folderConnectionHandler.info("Uploading file: \(fileURL.lastPathComponent) to \(urlsForUpload[currentFileNumberBeingUploaded])")
                                
                                self.putSlopeFiles(urlEndPoint: urlsForUpload[currentFileNumberBeingUploaded], slopeFileURL: fileURL) { result in
                                    switch result {
                                    case .success(_):
                                        currentFileNumberBeingUploaded += 1
                                        self.uploadProgress = Double(currentFileNumberBeingUploaded) / Double(totalNumberOfFiles)
                                        self.currentFileBeingUploaded = fileURL.lastPathComponent.replacingOccurrences(of: "%", with: " ")
                                        
                                        if currentFileNumberBeingUploaded == totalNumberOfFiles {
                                            url.stopAccessingSecurityScopedResource()
                                        }
                                    case .failure(let error):
                                        Logger.folderConnectionHandler.debug("Failed to upload \(fileURL) with error: \(error)")
                                    }
                                }
                            }
                        }
                        
                    case .failure(_):
                        self.showUploadError()
                        Logger.folderConnectionHandler.error("FAILURE")
                    }
                }
            } else {
                showFileExtensionNotSupported(
                    extensions: contents.filter({ $0.lastPathComponent != "slopes" }).map({ $0.lastPathComponent })
                )
            }
        } else {
            showWrongDirectorySelected(directory: url.lastPathComponent)
        }
    }
    
    // MARK: - Document Picker Helper Functions
    
    private func getFileList(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]) -> [URL]? {
        var fileList: [URL] = []
        let fileManager = FileManager.default
        
        guard let directoryEnumerator = fileManager.enumerator(at: url,
                                                               includingPropertiesForKeys: keys,
                                                               options: .skipsHiddenFiles,
                                                               errorHandler: { (url, error) -> Bool in
            Logger.folderConnectionHandler.error("Failed to access file at URL: \(url), error: \(error)")
            return true
        }) else {
            Logger.folderConnectionHandler.error("Unable to access the contents of \(url.path)")
            return nil
        }
        
        for case let fileURL as URL in directoryEnumerator {
            fileList.append(fileURL)
        }
        
        return fileList
    }
    
    private func putSlopeFiles(urlEndPoint: String, slopeFileURL: URL, completion: @escaping (Result<Int, Error>) -> Void) {
        let url = URL(string: urlEndPoint)!
        
        // Create the request object
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // Set the content type for the request
        let contentType = "application/zip" // Replace with the appropriate content type
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // Read the ZIP file data
        guard let zipFileData = try? Data(contentsOf: slopeFileURL) else {
            let error = NSError(domain: "Error reading ZIP file data", code: 0, userInfo: nil)
            completion(.failure(error))
            return
        }
        
        // Set the request body to the ZIP file data
        request.httpBody = zipFileData
        
        // Create a URLSession task for the request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Handle the response
            if let response = response as? HTTPURLResponse {
                print("Response status code: \(response.statusCode)")
                
                if response.statusCode == 200 {
                    DispatchQueue.main.async {
                        completion(.success(response.statusCode))
                    }
                } else {
                    let error = NSError(domain: "Status code is not 200", code: response.statusCode, userInfo: nil)
                    completion(.failure(error))
                }
            }
        }
        
        // Start the task
        task.resume()
    }
    
    // MARK: - Post Bookmark Saved Helpers
    private func isSlopesFiles(_ fileURL: URL) -> Bool {
        return !fileURL.hasDirectoryPath && fileURL.path.lowercased().contains("gpslogs") && fileURL.pathExtension == "slopes"
    }
    
    func resetUploadProgressAndFilename() {
        uploadProgress = 0.0
        currentFileBeingUploaded = ""
    }
    
    func getNonUploadedSlopeFiles(completion: @escaping ([URL]?) -> Void) {
        guard let bookmark = BookmarkManager.shared.bookmark else {
            Logger.folderConnectionHandler.info("No bookmark saved. Cannot check for nonUploadedFiles.")
            completion(nil)
            return
        }

        var nonUploadedSlopeFiles: [URL] = []
        ApolloLynxClient.getUploadedLogs { [unowned self] result in
            switch result {
            case .success(let uploadedFiles):
                do {
                    let resourceValues = try bookmark.url.resourceValues(forKeys: [.isDirectoryKey])
                    if resourceValues.isDirectory ?? false {
                        let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey, .creationDateKey]
                        if let fileList = self.getFileList(at: bookmark.url, includingPropertiesForKeys: keys) {
                            for case let fileURL in fileList {
                                Logger.folderConnectionHandler.debug("Checking \(fileURL.absoluteString) for upload.")
                                if self.isSlopesFiles(fileURL) {
                                    if !uploadedFiles.contains(fileURL.lastPathComponent) {
                                        nonUploadedSlopeFiles.append(fileURL)
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    // Handle the error
                    Logger.folderConnectionHandler.error("Error accessing bookmarked URL: \(error)")
                    completion(nil)
                    return
                }
                
                if nonUploadedSlopeFiles.isEmpty {
                    Logger.folderConnectionHandler.debug("No new files found.")
                    completion(nil)
                } else {
                    Logger.folderConnectionHandler.debug("New files to upload found.")
                    completion(nonUploadedSlopeFiles)
                }
                
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func uploadNewFiles(_ nonUploadedSlopeFiles: [URL], completion: @escaping (() -> Void)) {
        guard let gpsLogsURL = BookmarkManager.shared.bookmark?.url else {
            return
        }
        
        guard let contents = try? FileManager.default.contentsOfDirectory(at: gpsLogsURL, includingPropertiesForKeys: nil) else {
            // Failed to access the directory
            showFileAccessError()
            return
        }
        
        
        if contents.allSatisfy({ $0.pathExtension == "slopes" }) {
            let totalNumberOfFiles = nonUploadedSlopeFiles.count
            
            ApolloLynxClient.createUserRecordUploadUrl(filesToUpload: nonUploadedSlopeFiles.map { $0.lastPathComponent }) { [unowned self] result in
                switch result {
                case .success(let urlsForUpload):
                    guard gpsLogsURL.startAccessingSecurityScopedResource() else {
                        self.showFileAccessError()
                        return
                    }
                    
                    var currentFileNumberBeingUploaded = 0
                    
                    self.uploadTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
                        guard currentFileNumberBeingUploaded < totalNumberOfFiles else {
                            timer.invalidate()
                            completion()
                            return
                        }
                        
                        
                        if case let fileURL = nonUploadedSlopeFiles[currentFileNumberBeingUploaded] {
                            Logger.folderConnectionHandler.info("Uploading newly found file: \(fileURL.lastPathComponent)")
                            
                            self.putSlopeFiles(urlEndPoint: urlsForUpload[currentFileNumberBeingUploaded], slopeFileURL: fileURL) { result in
                                switch result {
                                case .success(_):
                                    currentFileNumberBeingUploaded += 1
                                    
                                    withAnimation {
                                        self.uploadProgress = Double(currentFileNumberBeingUploaded) / Double(totalNumberOfFiles)
                                        
                                        let fileURLString = fileURL.lastPathComponent.replacingOccurrences(of: "%", with: " ")
                                        if let startRange = fileURLString.range(of: "-"), let endRange = fileURLString.range(of: ".slopes") {
                                            self.currentFileBeingUploaded = fileURLString[startRange.upperBound..<endRange.lowerBound].trimmingCharacters(in: .whitespaces)
                                        }
                                    }
                                    if currentFileNumberBeingUploaded == totalNumberOfFiles {
                                        gpsLogsURL.stopAccessingSecurityScopedResource()
                                    }
                                    
                                case .failure(let error):
                                    Logger.folderConnectionHandler.error("Failed to upload \(fileURL.lastPathComponent): \(error)")
                                }
                            }
                        }
                        
                    }
                    
                case .failure(let error):
                    self.showUploadError()
                    Logger.folderConnectionHandler.error("Upload new files error: \(error)")
                }
            }
            
        }
        
    }

    
    
}

