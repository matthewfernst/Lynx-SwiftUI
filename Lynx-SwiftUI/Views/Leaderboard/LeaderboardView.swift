//
//  LeaderboardView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/24/23.
//

import SwiftUI

struct LeaderboardView: View {
    @State private var logbookStats = LogbookStats()
    let debugURL = ProfileManager.Constants.defaultProfilePictureURL
    
    var body: some View {
        NavigationStack {
            Form {
                CategoryTopLeadersView(
                    topLeaders: [
                        .init(fullName: "Max Rosoff", profilePictureURL: debugURL, stat: "240.6k FT"),
                        .init(fullName: "Emily Howell", profilePictureURL: debugURL, stat: "154.7k FT"),
                        .init(fullName: "Floris Delèe", profilePictureURL: debugURL, stat: "50.4k FT")
                    ],
                    headerLabelText: "Distance",
                    headerSystemImage: "arrow.right"
                )
                
                CategoryTopLeadersView(
                    topLeaders: [
                        .init(fullName: "Max Rosoff", profilePictureURL: debugURL, stat: "240.6k FT"),
                        .init(fullName: "Emily Howell", profilePictureURL: debugURL, stat: "154.7k FT"),
                        .init(fullName: "Floris Delèe", profilePictureURL: debugURL, stat: "50.4k FT")
                    ],
                    headerLabelText: "Run Count",
                    headerSystemImage: "figure.skiing.downhill"
                )
                
                CategoryTopLeadersView(
                    topLeaders: [
                        .init(fullName: "Max Rosoff", profilePictureURL: debugURL, stat: "240.6k FT"),
                        .init(fullName: "Emily Howell", profilePictureURL: debugURL, stat: "154.7k FT"),
                        .init(fullName: "Floris Delèe", profilePictureURL: debugURL, stat: "50.4k FT")
                    ],
                    headerLabelText: "Top Speed",
                    headerSystemImage: "flame"
                )
                
                CategoryTopLeadersView(
                    topLeaders: [
                        .init(fullName: "Max Rosoff", profilePictureURL: debugURL, stat: "240.6k FT"),
                        .init(fullName: "Emily Howell", profilePictureURL: debugURL, stat: "154.7k FT"),
                        .init(fullName: "Floris Delèe", profilePictureURL: debugURL, stat: "50.4k FT")
                    ],
                    headerLabelText: "Vertical Distance",
                    headerSystemImage: "arrow.down"
                )
                
            }
            .navigationTitle("Leaderboard")
            
        }
    }
    
    
}

#Preview {
    LeaderboardView()
}
