//
//  LeaderboardView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/24/23.
//

import SwiftUI

struct LeaderboardView: View {
    let debugURL = ProfileManager.Constants.defaultProfilePictureURL
    
    @State private var timeframe: Timeframe = .sevenDays
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Picker("Timeframe", selection: $timeframe) {
                    Text("7 Days").tag(Timeframe.sevenDays)
                    Text("30 Days").tag(Timeframe.thirtyDays)
                    Text("All time").tag(Timeframe.alltime)
                }
                .pickerStyle(.segmented)
                TopLeadersForCategoryView(
                    leaders: [
                        .init(fullName: "Max Rosoff", profilePictureURL: debugURL, stat: 240_600),
                        .init(fullName: "Emily Howell", profilePictureURL: debugURL, stat: 154_713),
                        .init(fullName: "Floris Delèe", profilePictureURL: debugURL, stat: 50_421)
                    ],
                    category: .distance()
                )
                
                
                TopLeadersForCategoryView(
                    leaders: [
                        .init(fullName: "Max Rosoff", profilePictureURL: debugURL, stat: 5),
                        .init(fullName: "Emily Howell", profilePictureURL: debugURL, stat: 4),
                        .init(fullName: "Floris Delèe", profilePictureURL: debugURL, stat: 2)
                    ],
                    category: .runCount()
                )
                
                TopLeadersForCategoryView(
                    leaders: [
                        .init(fullName: "Max Rosoff", profilePictureURL: debugURL, stat: 33),
                        .init(fullName: "Emily Howell", profilePictureURL: debugURL, stat: 12),
                        .init(fullName: "Floris Delèe", profilePictureURL: debugURL, stat: 5)
                    ],
                    category: .topSpeed()
                )
                
                TopLeadersForCategoryView(
                    leaders: [
                        .init(fullName: "Max Rosoff", profilePictureURL: debugURL, stat: 30_120),
                        .init(fullName: "Emily Howell", profilePictureURL: debugURL, stat: 12_123),
                        .init(fullName: "Floris Delèe", profilePictureURL: debugURL, stat: 4_532)
                    ],
                    category: .verticalDistance()
                )
            }
            .padding()
            .navigationTitle("Leaderboard")
            .scrollContentBackground(.hidden)
        }
    }
}

private enum Timeframe {
    case sevenDays, thirtyDays, alltime
}

enum LeaderboardCategory {
    case distance(headerLabelText: String = "Distance", headerSystemImage: String = "arrow.right")
    case runCount(headerLabelText: String = "Run Count", headerSystemImage: String = "figure.skiing.downhill")
    case topSpeed(headerLabelText: String = "Top Speed", headerSystemImage: String = "flame")
    case verticalDistance(headerLabelText: String = "Vertical Distance", headerSystemImage: String = "arrow.down")
    
    var headerLabelText: String {
        switch self {
        case .distance(let labelText, _),
                .runCount(let labelText, _),
                .topSpeed(let labelText, _),
                .verticalDistance(let labelText, _):
            return labelText
        }
    }
    
    var headerSystemImage: String {
        switch self {
        case .distance(_, let systemImage),
                .runCount(_, let systemImage),
                .topSpeed(_, let systemImage),
                .verticalDistance(_, let systemImage):
            return systemImage
        }
    }
}



#Preview {
    LeaderboardView()
}
