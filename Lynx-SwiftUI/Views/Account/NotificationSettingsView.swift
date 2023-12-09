//
//  NotificationSettingsView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/29/23.
//

import SwiftUI
import OSLog

struct NotificationSettingsView: View {
    @ObservedObject private var profileManager = ProfileManager.shared
    
    var body: some View {
        Form {
            Section {
                Toggle("Allow Notifications", isOn: Binding(
                    get: { profileManager.profile?.notificationsAllowed ?? false },
                    set: { newValue in
                        Logger.notifications.info("Notifications turned \(newValue ? "on" : "off").")
                        if !newValue {
                            UIApplication.shared.unregisterForRemoteNotifications()
                            
                        } else {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                        profileManager.update(withNotifcationsAllowed: newValue)
                    }
                ))
            } footer: {
                Text("Notifcations sent from this app are to remind users to come back to upload new files.")
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NotificationSettingsView()
}
