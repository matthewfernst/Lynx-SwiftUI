//
//  ProfileSummaryView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/24/23.
//

import SwiftUI

struct ProfileSummaryView: View {
    @Binding var logbookStats: LogbookStats
    
    var body: some View {
        HStack {
            profilePicture
            lifetimeSummary
        }
    }
    
    private var profilePicture: some View {
        AsyncImage(url: ProfileManager.shared.profile?.profilePictureURL) { image in
            image
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(maxWidth: Constants.Profile.imageWidth)
        } placeholder: {
            ProgressView()
        }
        .padding()
    }
    
    private var lifetimeSummary: some View {
        VStack {
            Text(logbookStats.lifetimeVertical)
                .font(.system(size: Constants.Font.statFontSize))
                .fontWeight(.semibold)
            Text("lifetime vertical \(logbookStats.feetOrMeters.lowercased())")
                .font(.system(size: Constants.Font.labelFontSize))
        }
        .padding()
    }
    
    
    private struct Constants {
        struct Font {
            static let statFontSize: CGFloat = 32
            static let labelFontSize: CGFloat = 18
        }
        
        struct Profile {
            static let imageWidth: CGFloat = 110
        }
    }

}

#Preview {
    ProfileSummaryView(logbookStats: .constant(LogbookStats()))
}
