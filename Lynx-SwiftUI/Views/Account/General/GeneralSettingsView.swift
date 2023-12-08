//
//  GeneralSettingsView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/30/23.
//

import SwiftUI

struct GeneralSettingsView: View {
    @Environment(\.colorScheme) private var systemTheme
    
    @ObservedObject private var profileManager = ProfileManager.shared
    
    @State private var selectedUnit: MeasurementSystem = .imperial
    private let availableUnits = MeasurementSystem.allCases
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Units", selection: $selectedUnit) {
                        ForEach(availableUnits, id: \.self) { unit in
                            Text(unit.rawValue.capitalized).tag(unit)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .onChange(of: selectedUnit) { _, newUnits in
                        profileManager.profile?.measurementSystem = newUnits
                    }
                    .onAppear {
                        if let profileMeasurementSystem = profileManager.profile?.measurementSystem {
                            selectedUnit = profileMeasurementSystem
                        }
                    }
                }
            }
            .navigationTitle("General")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}


