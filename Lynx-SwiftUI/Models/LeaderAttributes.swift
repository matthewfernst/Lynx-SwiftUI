//
//  LeaderAttributes.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/9/23.
//

import Foundation

struct LeaderAttributes: Identifiable {
    var id: UUID
    let fullName: String
    let profilePictureURL: URL?
    let stat: Double
    
    init(fullName: String, profilePictureURL: URL?, stat: Double) {
        self.id = UUID()
        self.fullName = fullName
        self.profilePictureURL = profilePictureURL
        self.stat = stat
    }
    
    static func formattedStatLabel(
        _ stat: Double,
        forCategory category: LeaderboardCategory,
        withMeasurementSystem measurementSystem: MeasurementSystem
    ) -> String {
        switch category {
        case .distance, .verticalDistance:
            return String(format: "%.1fk \(measurementSystem.feetOrMeters)", stat / 1000)
        case .runCount:
            return "\(Int(stat))"
        case .topSpeed:
            return String(format: "%.1f \(measurementSystem.milesOrKilometersPerHour)", stat)
        }
    }
}
