//
//  LogbookView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/24/23.
//

import SwiftUI

struct LogbookView: View {
    @State private var logbookStats = LogbookStats()
    @State private var showMoreInfo = false
    @State private var showUploadFilesSheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ProfileSummaryView(logbookStats: $logbookStats)
                LifetimeDetailsView(logbookStats: $logbookStats)
                scrollableSessionSummaries
            }
            .navigationTitle("Logbook")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    AnimatedActionButton(systemImage: "info.circle") {
                        showMoreInfo = true
                    }
                    .confirmationDialog("Slopes Integration", isPresented: $showMoreInfo, titleVisibility: .visible) {
                        Link(
                            "What is Slopes?",
                            destination: URL(string: Constants.slopesLink)!
                        )
                        Link(
                            "What is MountainUI?",
                            destination: URL(string: Constants.mountainUILink)!
                        )
                    } message:  {
                        Text(Constants.slopeIntegrationMessage)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    AnimatedActionButton(systemImage: "folder.badge.plus") {
                        showUploadFilesSheet = true
                    }
                }
            }
            .onAppear {
                requestLogs()
            }
            .sheet(isPresented: $showUploadFilesSheet) {
                FolderConnectionView()
            }

        }
    }
    
    private var scrollableSessionSummaries: some View {
        List {
            Section {
                NavigationLink {
                    FullLifetimeSummaryView(logbookStats: $logbookStats)
                } label: {
                    lifetimeSummaryLabel
                }
            } header: {
                Text(yearHeader)
                    .padding(.top)
            }
            .headerProminence(.increased)
  
            
            ForEach(logbookStats.logbooks.indices, id: \.self) { index in
                if let configuredData = logbookStats.getConfiguredLogbookData(at: index) {
                    configuredSessionSummary(with: configuredData)
                }
            }
        }
        .refreshable {
            requestLogs()
        }
    }
    
    private var yearHeader: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let currentYear = dateFormatter.string(from: .now)
        let pastYear = String((Int(currentYear) ?? 0) - 1)
        return "\(pastYear)/\(currentYear)"
    }
    
    private var lifetimeSummaryLabel: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.dateAndSummary) {
            Text("Lifetime Summary")
                .font(.system(
                    size: Constants.Fonts.resortNameSize,
                    weight: Constants.Fonts.resortNameWeight
                ))
            HStack {
                Text(
                    "\(logbookStats.lifetimeRuns) runs | \(logbookStats.lifetimeDaysOnMountain) days | \(logbookStats.lifetimeVertical)"
                )
            }
            .foregroundStyle(Color(uiColor: .secondaryLabel))
            .font(.system(
                size: Constants.Fonts.detailSize,
                weight: Constants.Fonts.detailWeight
            ))
        }
    }
    
    private func configuredSessionSummary(with data: ConfiguredLogbookData) -> some View {
        HStack(alignment: .top, spacing: Constants.Spacing.mainTitleAndDetails) {
            Text(data.dateOfRun)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: Constants.Spacing.dateAndSummary) {
                Text(data.resortName)
                    .font(.system(
                        size: Constants.Fonts.resortNameSize,
                        weight: Constants.Fonts.resortNameWeight
                    ))
                HStack {
                    Image(systemName: "figure.snowboarding")
                        .rotationEffect(.radians(.pi / 16))
                    Text(
                        "| \(data.numberOfRuns) runs | \(data.runDurationHour)H \(data.runDurationMinutes)M | \(data.conditions) | \(data.topSpeed)"
                    )
                }
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .font(.system(
                    size: Constants.Fonts.detailSize,
                    weight: Constants.Fonts.detailWeight
                ))
            }
        }
    }
    
    private func requestLogs() {
        ApolloLynxClient.clearCache()
        Task {
            ApolloLynxClient.getLogs(
                measurementSystem: ProfileManager.shared.profile!.measurementSystem
            ) { result in
                switch result {
                case .success(let logs):
                    logbookStats.logbooks = logs
                case .failure(_):
                    print("TODO")
                }
            }
        }
    }
    
    private struct Constants {
        static let slopeIntegrationMessage = """
                           Lynx works together with the Slopes App by Breakpoint Studios. Slopes is able to track a skier or snowboarder while they shred it down the mountain. Slopes can track things such as average speed, total vertical feet, and more. Lynx uses the data stored by Slopes and links to your MountainUI display.
                       """
        static let mountainUILink = "https://github.com/matthewfernst/Mountain-UI"
        static let slopesLink = "https://getslopes.com"
        
        struct Spacing {
            static let mainTitleAndDetails: CGFloat = 20
            static let dateAndSummary: CGFloat = 4
        }
        
        struct Fonts {
            static let resortNameSize: CGFloat = 18
            static let resortNameWeight: Font.Weight = .medium
            
            static let detailSize: CGFloat = 12
            static let detailWeight: Font.Weight = .medium
        }
        
    }
}

#Preview {
    LogbookView()
    
}
