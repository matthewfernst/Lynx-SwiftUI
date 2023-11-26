//
//  ProfileSummaryView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/24/23.
//

import SwiftUI

struct ProfileSummaryView: View {
    @EnvironmentObject var loginHandler: LoginHandler
    var body: some View {
        HStack {
            profilePicture
            lifetimeSummary
        }
    }
    
    
    private var profilePicture: some View {
        AsyncImage(url: loginHandler.profile?.profilePictureURL) { image in
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
            Text("--")
                .font(.system(size: 32))
                .fontWeight(.semibold)
            Text("lifetime vertical ft")
                .font(.system(size: 18))
        }
        .padding()
    }
}

#Preview {
    ProfileSummaryView()
}
