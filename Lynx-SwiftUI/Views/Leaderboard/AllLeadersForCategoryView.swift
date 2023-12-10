//
//  AllLeadersForCategoryView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/9/23.
//

import SwiftUI

struct AllLeadersForCategoryView: View {
    let category: String
    let leaders: [LeaderAttributes]
    
    var body: some View {
        List {
            ForEach(leaders.indices, id: \.self) { index in
                let rank = index < 3 ? index + 1 : nil
                LeaderView(attributes: leaders[index], rank: rank)
            }
        }
        .navigationTitle(category)
    }
}

#Preview {
    let debugURL = ProfileManager.Constants.defaultProfilePictureURL
    return AllLeadersForCategoryView(
        category: "Distance",
        leaders: [
            .init(fullName: "Max Rosoff", profilePictureURL: debugURL, stat: "240.6k FT"),
            .init(fullName: "Emily Howell", profilePictureURL: debugURL, stat: "154.7k FT"),
            .init(fullName: "Floris Delèe", profilePictureURL: debugURL, stat: "50.4k FT"),
            .init(fullName: "Sully Sullivian", profilePictureURL: debugURL, stat: "5.4k FT"),
            .init(fullName: "Matthew Ernst", profilePictureURL: debugURL, stat: "4.2k FT"),
            .init(fullName: "Christine Perich", profilePictureURL: debugURL, stat: "0k FT"),
        ]
    )
}
