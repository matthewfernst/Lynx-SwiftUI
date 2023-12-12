//
//  LeaderView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/10/23.
//

import SwiftUI
/// To be honest, no idea why this looks wack here, but it works :)
struct LeaderView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let attributes: LeaderAttributes
    let rank: Int?
    
    var body: some View {
        HStack {
            profilePicture
            VStack(spacing: Constants.Font.spacing) {
                Text(attributes.fullName)
                    .font(.system(size: Constants.Font.nameSize, weight: .medium))
                Text(attributes.stat)
            }
            .frame(maxWidth: .infinity)
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
    LeaderView(
        attributes: .init(fullName: "Sully Sullivian",
                          profilePictureURL: ProfileManager.Constants.defaultProfilePictureURL,
                          stat: "123.45k FT"),
        rank: 1
    )
}
