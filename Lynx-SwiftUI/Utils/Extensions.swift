//
//  Extensions.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/24/23.
//

import SwiftUI
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let apollo = Logger(subsystem: subsystem, category: "Apollo")
    
    static let bookmarkManager = Logger(subsystem: subsystem, category: "BookmarkManager")
    
    static let editProfileHandler = Logger(subsystem: subsystem, category: "EditProfileHandler")
    
    static let folderConnectionHandler = Logger(subsystem: subsystem, category: "FolderConnectionHandler")
    
    static let folderConnectionView = Logger(subsystem: subsystem, category: "FolderConnectionView")
    
    static let homeView = Logger(subsystem: subsystem, category: "HomeView")
    
    static let invitationKeySheet = Logger(subsystem: subsystem, category: "InvitationKeySheet")
    
    static let logbook = Logger(subsystem: subsystem, category: "LogbookView")
    
    static let loginHandler = Logger(subsystem: subsystem, category: "LoginHandler")
    
    static let notifications = Logger(subsystem: subsystem, category: "Notifications")
}

extension String {
    var initials: String {
        let splitName = self.components(separatedBy: .whitespaces)
        var initials = ""
        for name in splitName {
            if let namesFirstLetter = name.first {
                initials += namesFirstLetter.uppercased()
            }
        }
        return initials
    }
}
