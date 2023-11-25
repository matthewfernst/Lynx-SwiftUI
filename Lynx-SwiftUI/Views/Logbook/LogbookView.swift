//
//  LogbookView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/24/23.
//

import SwiftUI

struct LogbookView: View {
    
    @State private var showMoreInfo = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ProfileSummaryView()
                LifetimeDetailsView()
                
                Spacer()
                
                // TODO: List!
                
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
                        
                    }
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
    }
}

#Preview {
    LogbookView()
}
