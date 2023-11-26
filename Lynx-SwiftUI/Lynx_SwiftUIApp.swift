//
//  Lynx_SwiftUIApp.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/24/23.
//

import SwiftUI

@main
struct Lynx_SwiftUIApp: App {
    
    @StateObject private var loginHandler = LoginHandler()
    
    var body: some Scene {
        WindowGroup {
//            HomeView()
            LoginView()
                .environmentObject(loginHandler)
        }
    }
}
