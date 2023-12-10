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
    
    let topLeaders: [LeaderAttributes]
    let headerLabelText: String
    let headerSystemImage: String
    
    var body: some View {
            Section {
                List {
                    ForEach(0..<3) { rank in
                        LeaderView(attributes: topLeaders[rank], rank: rank + 1)
                    }
                    showAllLeadersNavigationLink
                }
                .navigationDestination(isPresented: $readyToNavigate) {
                    AllLeadersForCategoryView(
                        category: headerLabelText.capitalized,
                        leaders: topLeaders
                    )
                }
                
            } header: {
                Label(headerLabelText.capitalized, systemImage: headerSystemImage)
            }
            .headerProminence(.increased)
        
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
    
    private struct Constants {
        struct Font {
            static let nameSize: CGFloat = 20
            static let spacing: CGFloat = 5
        }
    }
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

