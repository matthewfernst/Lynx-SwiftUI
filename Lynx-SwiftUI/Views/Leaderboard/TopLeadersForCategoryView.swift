//
//  CategoryTopLeadersView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/9/23.
//

import SwiftUI
import Charts

struct TopLeadersForCategoryView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ProfileManager.self) private var profileManager
    
    @State private var range: (Double, Double)? = nil
    private var rangeFormattedLabel: (String, String)? {
        guard let range = range else { return nil }
        
        return (
            LeaderAttributes.formattedStatLabel(
                range.0,
                forCategory: category,
                withMeasurementSystem: measurementSystem
            ),
            LeaderAttributes.formattedStatLabel(
                range.1,
                forCategory: category,
                withMeasurementSystem: measurementSystem
            )
        )
    }
    
    @State private var readyToNavigate = false
    @State private var showProgressView = false
    
    let leaders: [LeaderAttributes]
    let category: LeaderboardCategory
    private var measurementSystem: MeasurementSystem {
        profileManager.profile?.measurementSystem ?? .imperial
    }
    
    var body: some View {
        GroupBox(
            label: Label(
                category.headerLabelText.capitalized,
                systemImage: category.headerSystemImage
            )
        ) {
            chartOfTopLeaders
            showAllLeadersNavigationLink
        }
        .navigationDestination(isPresented: $readyToNavigate) {
            AllLeadersForCategoryView(
                category: category,
                leaders: leaders
            )
        }
        .padding(.vertical)
        .listRowSeparator(.hidden)
    }
    
    private var chartOfTopLeaders: some View {
        Chart {
            ForEach(0..<3, id: \.self) { rank in
                BarMark(
                    x: .value("Stat", leaders[rank].stat),
                    y: .value("Name", leaders[rank].fullName)
                )
                .foregroundStyle([Color.blue, .green, .orange][rank])
            }
            
            if let range, let rangeFormattedLabel {
                RectangleMark(
                    xStart: .value("Start Stat", range.0),
                    xEnd: .value("End Stat", range.1)
                )
                .foregroundStyle(Color.gray.opacity(Constants.Chart.brushOpacity))
                .offset(yStart: Constants.Chart.Popover.yOffset)
                .zIndex(-1)
                .annotation(
                    position: .top, spacing: Constants.Chart.Popover.spacing,
                    overflowResolution: .init(
                        x: .fit(to: .chart),
                        y: .disabled
                    )
                ) {
                    RoundedRectangle(cornerRadius: Constants.Chart.Popover.cornerRadius)
                        .fill(.windowBackground)
                        .overlay(
                            Text("\(rangeFormattedLabel.0) - \(rangeFormattedLabel.1)")
                                .font(.caption)
                        )
                        .frame(
                            width: category == LeaderboardCategory.runCount() ? Constants.Chart.Popover.runCountWidth : Constants.Chart.Popover.width,
                            height: Constants.Chart.Popover.height
                        )
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                if let xAxisValue = value.as(Double.self) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(
                        LeaderAttributes.formattedStatLabel(
                            xAxisValue,
                            forCategory: category,
                            withMeasurementSystem: measurementSystem
                        )
                    )
                } else {
                    AxisGridLine()
                }
            }
        }
        .chartPlotStyle { plotArea in
            plotArea.frame(height: Constants.Chart.height)
        }
        .chartOverlay { proxy in
            GeometryReader { g in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(DragGesture()
                        .onChanged { value in
                            let startX = value.startLocation.x - g[proxy.plotFrame!].origin.x
                            let currentX = value.location.x - g[proxy.plotFrame!].origin.x
                            
                            if let startStat: Double = proxy.value(atX: startX),
                               let endStat: Double = proxy.value(atX: currentX) {
                                range = (startStat, endStat)
                            }
                        }
                        .onEnded { _ in range = nil }
                    )
            }
        }
        .padding(.bottom)
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
        struct Chart {
            static let height: CGFloat = 180
            static let brushOpacity: CGFloat = 0.3
            
            struct Popover {
                static let cornerRadius: CGFloat = 15
                static let spacing: CGFloat = 4
                static let yOffset: CGFloat = -4
                static let height: CGFloat = 35
                static let width: CGFloat = 130
                static let runCountWidth: CGFloat = 40
            }
        }
        
        struct Font {
            static let nameSize: CGFloat = 20
            static let spacing: CGFloat = 5
        }
    }
}


#Preview {
    let debugURL = ProfileManager.Constants.defaultProfilePictureURL
    return TopLeadersForCategoryView(
        leaders: [
            .init(fullName: "Max Rosoff", profilePictureURL: debugURL, stat: 240_612),
            .init(fullName: "Emily Howell", profilePictureURL: debugURL, stat: 154_712),
            .init(fullName: "Floris Delèe", profilePictureURL: debugURL, stat: 50_412)
        ],
        category: LeaderboardCategory.distance()
    )
}

