//
//  CategoryTopLeadersView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/9/23.
//

import SwiftUI

struct CategoryTopLeadersView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var topLeaders: [TopLeaderAttributes]
    var headerLabelText: String
    var headerSystemImage: String
    
    var body: some View {
        Form {
            Section {
                List {
                    ForEach(0..<3) { rank in
                        topLeader(withAttributes: topLeaders[rank], rankedAt: rank + 1) // plus 1 to zero offset
                            .listRowSeparator(.hidden)
                    }
                    NavigationLink("Show All Leaders") {
                        Text("TODO")
                    }
                    
                }
            } header: {
                Label(headerLabelText.capitalized, systemImage: headerSystemImage)
            }
            .headerProminence(.increased)
        }
    }
    
    @ViewBuilder
    private func topLeader(withAttributes attributes: TopLeaderAttributes, rankedAt rank: Int) -> some View {
        let rankImageNameAndColor: [(String, Color, CGFloat)] = [
            ("crown.fill", .gold, 12),
            ("medal.fill", .silver, 10),
            ("medal.fill", .bronze, 10)
        ]
        
        let (rankImageName, rankColor, rankImageWidth) = rankImageNameAndColor[rank - 1]
        
        HStack {
            AsyncImage(url: attributes.profilePictureURL) { image in
                GeometryReader { geometry in
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .overlay(
                                    Image(systemName: rankImageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: rankImageWidth)
                                        .foregroundStyle(rankColor)
                                )
                                .frame(maxWidth: 15)
                                .foregroundStyle(Color(uiColor: colorScheme == .light ? .tertiarySystemGroupedBackground : .systemBackground))
                                .offset(x: geometry.size.width / 3, y: geometry.size.height / 4)
                        )
                }
            } placeholder: {
                ProgressView()
            }
            .frame(maxWidth: 60)
            
            VStack {
                Text(attributes.fullName)
                Text(attributes.stat)
            }
            .frame(maxWidth: .infinity)
        }
    }
}



extension Color {
    static let gold = Color(red: 219 / 255, green: 172 / 255, blue: 52 / 255)
    static let silver = Color(red: 170 / 255 , green: 169 / 255, blue: 173 / 255)
    static let bronze = Color(red: 205 / 255 , green: 127 / 255, blue: 50 / 255)
}



#Preview {
    let debugURL = URL(string: "https://thumbs.dreamstime.com/b/european-teenager-beanie-profile-portrait-male-cartoon-character-blonde-man-avatar-social-network-vector-flat-271205345.jpg")!
    return CategoryTopLeadersView(
        topLeaders: [
            .init(fullName: "Max Rosoff", profilePictureURL: debugURL, stat: "240.6k FT"),
            .init(fullName: "Emily Howell", profilePictureURL: debugURL, stat: "154.7k FT"),
            .init(fullName: "Floris Delèe", profilePictureURL: debugURL, stat: "50.4k FT")
        ],
        headerLabelText: "Distance",
        headerSystemImage: "arrow.right"
    )
}

