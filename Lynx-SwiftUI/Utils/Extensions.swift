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
    
    static let loginController = Logger(subsystem: subsystem, category: "UserInfo")
    
    static let invitationKeySheet = Logger(subsystem: subsystem, category: "InvitationKeySheet")
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

struct AnimatedActionButton: View {
    var title: String? = nil
    var systemImage: String? = nil
    var role: ButtonRole?
    let action: () -> Void
    
    init(_ title: String? = nil,
         systemImage: String? = nil,
         role: ButtonRole? = nil,
         action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.action = action
    }
    
    var body: some View {
        Button(role: role) {
            withAnimation {
                action()
            }
        } label: {
            if let title, let systemImage {
                Label(title, systemImage: systemImage)
            } else if let title {
                Text(title)
            } else if let systemImage {
                Image(systemName: systemImage)
            }
        }
    }
}
