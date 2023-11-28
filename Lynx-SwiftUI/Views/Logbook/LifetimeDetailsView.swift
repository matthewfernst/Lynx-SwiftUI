//
//  LifetimeDetailsView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/24/23.
//

import SwiftUI

struct LifetimeDetailsView: View {
    @Binding var logbookStats: LogbookStats
    
    var body: some View {
        HStack {
            getDetailView(
                withStat: logbookStats.lifetimeDaysOnMountain,
                andText: "days"
            )
            getDetailView(
                withStat: logbookStats.lifetimeRunsTime,
                andText: "time on runs"
            )
            getDetailView(
                withStat: logbookStats.lifetimeRuns,
                andText: "runs"
            )
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
    LifetimeDetailsView(logbookStats: .constant(LogbookStats()))
}
