//
//  HomeView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/24/23.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            LogbookView()
                .tabItem {
                    Label("Logbook", systemImage: "book.pages")
                }
            
            LeaderboardView()
                .tabItem {
                    Label("Leaderboard", systemImage: "trophy")
                }
        
            
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle.fill")
                }
        }
    }
}

#Preview {
    HomeView()
}
