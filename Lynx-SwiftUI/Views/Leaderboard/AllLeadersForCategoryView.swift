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
