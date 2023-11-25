//
//  LifetimeDetailsView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/24/23.
//

import SwiftUI

struct LifetimeDetailsView: View {
    var body: some View {
        HStack {
            getDetailView(withStat: "--", andText: "days")
            getDetailView(withStat: "--", andText: "time on runs")
            getDetailView(withStat: "--", andText: "runs")
        }
    }
    private func getDetailView(withStat stat: String, andText text: String) -> some View {
        VStack {
            Text(stat)
                .font(.system(size: 22, weight: .bold))
            Text(text)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    LifetimeDetailsView()
}
