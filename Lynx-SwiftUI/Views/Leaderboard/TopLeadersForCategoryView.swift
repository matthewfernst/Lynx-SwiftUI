//
//  CategoryTopLeadersView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/9/23.
//

import SwiftUI

struct TopLeadersForCategoryView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var readyToNavigate = false
    @State private var showProgressView = false
    
    var topLeaders: [TopLeaderAttributes]
    var headerLabelText: String
    var headerSystemImage: String
    
    var body: some View {
            Section {
                List {
                    ForEach(0..<3) { rank in
                        topLeader(withAttributes: topLeaders[rank], rankedAt: rank + 1) // plus 1 to zero offset
                    }
                    showAllLeadersNavigationLink
                }
                .navigationDestination(isPresented: $readyToNavigate) {
                    Text("TODO")
                }
                
            } header: {
                Label(headerLabelText.capitalized, systemImage: headerSystemImage)
            }
            .headerProminence(.increased)
        
    }
    
    @ViewBuilder
    private func topLeader(withAttributes attributes: TopLeaderAttributes, rankedAt rank: Int) -> some View {
        HStack {
            profilePicture(withURL: attributes.profilePictureURL!, rank: rank)
            VStack(spacing: Constants.Font.spacing) {
                Text(attributes.fullName)
                    .font(.system(size: Constants.Font.nameSize, weight: .medium))
                Text(attributes.stat)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var showAllLeadersNavigationLink: some View {
        Button {
            showProgressView = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                showProgressView = false
                readyToNavigate = true
            }
        } label: {
            HStack {
                Text("Show All Leaders")
                Spacer()
                if showProgressView {
                    ProgressView()
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.gray)
                }
            }
        }
        .foregroundStyle(.primary)
    }
    
    @ViewBuilder
    private func profilePicture(withURL url: URL, rank: Int) -> some View {
        let (rankImageName, rankColor, rankImageWidth) = Constants.Rank.rankImageNameAndColor[rank - 1]
        
        AsyncImage(url: url) { image in
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
                            .frame(maxWidth: Constants.ProfilePicture.medalBackgroundWidth)
                            .foregroundStyle(Color(uiColor: colorScheme == .light ? .tertiarySystemGroupedBackground : .systemBackground))
                            .offset(
                                x: geometry.size.width / Constants.ProfilePicture.xMedalOffsetDivisor,
                                y: geometry.size.height / Constants.ProfilePicture.yMedalOffsetDivisor
                            )
                    )
            }
        } placeholder: {
            ProgressView()
        }
        .frame(maxWidth: Constants.ProfilePicture.imageWidth)
    }
    
    private struct Constants {
        struct Rank {
            static let rankImageNameAndColor: [(String, Color, CGFloat)] = [
                ("crown.fill", .gold, 12),
                ("medal.fill", .silver, 10),
                ("medal.fill", .bronze, 10)
            ]
        }
        
        struct ProfilePicture {
            static let imageWidth: CGFloat = 60
            static let medalBackgroundWidth: CGFloat = 15
            static let xMedalOffsetDivisor: CGFloat = 3
            static let yMedalOffsetDivisor: CGFloat = 4
        }
        
        struct Font {
            static let nameSize: CGFloat = 20
            static let spacing: CGFloat = 5
        }
    }
}



extension Color {
    static let gold = Color(red: 219 / 255, green: 172 / 255, blue: 52 / 255)
    static let silver = Color(red: 170 / 255 , green: 169 / 255, blue: 173 / 255)
    static let bronze = Color(red: 205 / 255 , green: 127 / 255, blue: 50 / 255)
}



#Preview {
    let debugURL = ProfileManager.Constants.defaultProfilePictureURL
    return TopLeadersForCategoryView(
        topLeaders: [
            .init(fullName: "Max Rosoff", profilePictureURL: debugURL, stat: "240.6k FT"),
            .init(fullName: "Emily Howell", profilePictureURL: debugURL, stat: "154.7k FT"),
            .init(fullName: "Floris Delèe", profilePictureURL: debugURL, stat: "50.4k FT")
        ],
        headerLabelText: "Distance",
        headerSystemImage: "arrow.right"
    )
}

