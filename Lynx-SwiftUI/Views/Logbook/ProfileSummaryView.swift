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
                .frame(maxWidth: 110)
                .padding()
        } placeholder: {
            ProgressView()
        }

    }
    
    private var lifetimeSummary: some View {
        VStack {
            Text(logbookStats.lifetimeVertical)
                .font(.system(size: 32))
                .fontWeight(.semibold)
            Text("lifetime vertical \(logbookStats.feetOrMeters)")
                .font(.system(size: 18))
        }
        .padding()
    }
    

}

#Preview {
    ProfileSummaryView(logbookStats: .constant(LogbookStats()))
}
