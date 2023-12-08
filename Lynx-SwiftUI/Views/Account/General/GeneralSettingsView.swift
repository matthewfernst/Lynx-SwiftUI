//
//  GeneralSettingsView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/30/23.
//

import SwiftUI

struct GeneralSettingsView: View {
    @ObservedObject private var profileManager = ProfileManager.shared

    @State private var selectedUnits: MeasurementSystem = .imperial
    private let availableUnits = MeasurementSystem.allCases

    @State private var selectedTheme: AppTheme = .system
    private let availableThemes = AppTheme.allCases

    var body: some View {
        Form {
            Section {
                Picker("Units", selection: $selectedUnits) {
                    ForEach(availableUnits, id: \.self) { option in
                        Text(option.rawValue.capitalized)
                            .tag(option)
                    }
                }
            }
            .onChange(of: selectedUnits) { _, newUnits in
                profileManager.profile?.updateMeasureSystem(with: newUnits)
            }
            .onAppear {
                if let profileMeasurementSystem = profileManager.profile?.measurementSystem {
                    selectedUnits = profileMeasurementSystem
                }
            }
            
            Section {
                Picker("App Theme", selection: $selectedTheme) {
                    ForEach(availableThemes, id: \.self) { option in
                        Text(option.rawValue)
                            .tag(option)
                    }
                }
            }
        }
        .navigationTitle("General")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}

