//
//  NotificationSettingsView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/29/23.
//

import SwiftUI

struct NotificationSettingsView: View {
    @State private var notificationOn = false
    
    var body: some View {
        Form {
            Toggle("Allow Notifications", isOn: $notificationOn)
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NotificationSettingsView()
}
