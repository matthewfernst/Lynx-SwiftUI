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
    
    func picker(didPickDocumentsAt url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            // Handle the failure here.
            showUploadError()
            return
        }
        
        defer { url.stopAccessingSecurityScopedResource() }
        
        let gpsLogsURL = url.appendingPathComponent("GPSLogs")
        
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
                
                guard let fileList = FolderConnectionHandler.getFileList(at: gpsLogsURL, includingPropertiesForKeys: keys) else { return }
                
                let requestedPathsForUpload = fileList.compactMap { $0.lastPathComponent }
                Logger.folderConnectionHandler.info("Requested Paths: \(requestedPathsForUpload)")

                var currentFileNumberBeingUploaded = 0.0
                for (index, path) in requestedPathsForUpload.enumerated() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 * Double(index)) { [unowned self] in
                        currentFileNumberBeingUploaded += 1
                        Logger.folderConnectionHandler.info("Uploading: \(path)")
                        currentFileBeingUploaded = path
                        self.uploadProgress = currentFileNumberBeingUploaded / Double(totalNumberOfFiles)   
                    }
                }
                // TODO: Delete me from here
                BookmarkManager.shared.saveBookmark(for: url)
                return // TODO: To here
                ApolloLynxClient.createUserRecordUploadUrl(filesToUpload: requestedPathsForUpload) { [unowned self] result in
                    switch result {
                    case .success(let urlsForUpload):
                        guard url.startAccessingSecurityScopedResource() else {
                            // Handle the failure here.
                            self.showFileAccessError()
                            return
                        }
                        
                        guard let fileList = FolderConnectionHandler.getFileList(at: gpsLogsURL, includingPropertiesForKeys: keys) else { return }
                         
                        var currentFileNumberBeingUploaded = 0
                        
                        for (fileURLEnumerator, uploadURL) in zip(fileList, urlsForUpload) {
                            if case let fileURL = fileURLEnumerator {
                                Logger.folderConnectionHandler.debug("Uploading file: \(fileURL.lastPathComponent) to \(uploadURL)")
                                
                                FolderConnectionHandler.putZipFiles(urlEndPoint: uploadURL, zipFilePath: fileURL) {  response in
                                    switch response {
                                    case .success(_):
                                        currentFileNumberBeingUploaded += 1
                                        //                                        self.updateSlopeFilesProgressView(fileBeingUploaded: fileURL.lastPathComponent.replacingOccurrences(of: "%", with: " "),
                                        //                                                                          progress: Float(currentFileNumberBeingUploaded) / Float(totalNumberOfFiles))
                                        
                                        if currentFileNumberBeingUploaded == totalNumberOfFiles {
                                            // All files are uploaded, perform cleanup
                                            //                                            self.cleanupUploadView()
                                        }
                                    case .failure(let error):
                                        Logger.folderConnectionHandler.debug("Failed to upload \(fileURL) with error: \(error)")
                                        //                                        self.tracker.uploadError = true
                                    }
                                }
                            }
                        }
                        url.stopAccessingSecurityScopedResource()
                        BookmarkManager.shared.saveBookmark(for: url)
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
    private static func getFileList(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]) -> [URL]? {
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
    
    private static func putZipFiles(urlEndPoint: String, zipFilePath: URL, completion: @escaping (Result<Int, Error>) -> Void) {
        let url = URL(string: urlEndPoint)!
        
        // Create the request object
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // Set the content type for the request
        let contentType = "application/zip" // Replace with the appropriate content type
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // Read the ZIP file data
        guard let zipFileData = try? Data(contentsOf: zipFilePath) else {
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
                    completion(.success(response.statusCode))
                } else {
                    let error = NSError(domain: "Status code is not 200", code: response.statusCode, userInfo: nil)
                    completion(.failure(error))
                }
            }
        }
        
        // Start the task
        task.resume()
    }    
}

