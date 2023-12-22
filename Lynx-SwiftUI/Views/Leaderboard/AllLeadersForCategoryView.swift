//
//  AllLeadersForCategoryView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/9/23.
//

import SwiftUI

struct AllLeadersForCategoryView: View {
    let category: LeaderboardCategory
    let leaders: [LeaderAttributes]
    
    var body: some View {
        List {
            ForEach(leaders.indices, id: \.self) { index in
                let rank = index < 3 ? index + 1 : nil
                LeaderView(
                    category: category,
                    attributes: leaders[index],
                    rank: rank
                )
            }
        }
        .navigationTitle(category.headerLabelText)
    }
}

/// To be honest, no idea why this looks wack here, but it works :)
struct LeaderView: View {
    @Environment(ProfileManager.self) private var profileManager
    @Environment(\.colorScheme) private var colorScheme
    
    let category: LeaderboardCategory
    let attributes: LeaderAttributes
    let rank: Int?
    private var measurementSystem: MeasurementSystem {
        profileManager.profile?.measurementSystem ?? .imperial
    }
    
    var body: some View {
        HStack {
            profilePicture
            nameAndStat
        }
    }
    
    @ViewBuilder
    private var profilePicture: some View {
        AsyncImage(url: attributes.profilePictureURL) { image in
            GeometryReader { geometry in
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                
                if let rank = rank {
                    let (rankImageName, rankColor, rankImageWidth) = Constants.Rank.rankImageNameAndColor[rank - 1]
                    Circle()
                        .overlay(
                            Image(systemName: rankImageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: rankImageWidth)
                                .foregroundStyle(rankColor)
                        )
                        .frame(maxWidth: Constants.ProfilePicture.medalBackgroundWidth)
                        .foregroundStyle(
                            Color(uiColor: colorScheme == .light ? .tertiarySystemGroupedBackground : .systemBackground)
                        )
                        .offset(
                            x: geometry.size.width / Constants.ProfilePicture.xMedalOffsetDivisor,
                            y: geometry.size.height / Constants.ProfilePicture.yMedalOffsetDivisor
                        )
                }
            }
        } placeholder: {
            ProgressView()
        }
        .frame(maxWidth: Constants.ProfilePicture.imageWidth)
    }
    
    private var nameAndStat: some View {
        VStack(spacing: Constants.Font.spacing) {
            Text(attributes.fullName)
                .font(.system(size: Constants.Font.nameSize, weight: .medium))
            Text(
                LeaderAttributes.formattedStatLabel(
                    attributes.stat,
                    forCategory: category,
                    withMeasurementSystem: measurementSystem
                )
            )
        }
        .frame(maxWidth: .infinity)
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
            static let xMedalOffsetDivisor: CGFloat = 1.5
            static let yMedalOffsetDivisor: CGFloat = 1.5
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
    return AllLeadersForCategoryView(
        category: .distance(),
        leaders: [
            .init(fullName: "Max Rosoff", profilePictureURL: debugURL, stat: 240_609),
            .init(fullName: "Emily Howell", profilePictureURL: debugURL, stat: 154_712),
            .init(fullName: "Floris Delèe", profilePictureURL: debugURL, stat: 50_409),
            .init(fullName: "Sully Sullivian", profilePictureURL: debugURL, stat: 5_431),
            .init(fullName: "Matthew Ernst", profilePictureURL: debugURL, stat: 4_212),
            .init(fullName: "Christine Perich", profilePictureURL: debugURL, stat: 0),
        ]
    )
}
