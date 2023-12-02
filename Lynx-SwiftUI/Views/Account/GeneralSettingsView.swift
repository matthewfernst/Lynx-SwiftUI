//
//  GeneralSettingsView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 11/30/23.
//

import SwiftUI

struct GeneralSettingsView: View {
    @State private var selectedUnits = "Metric"
    private let availableUnits = ["Metric", "Imperial"]
    
    @State private var selectedTheme = "System"
    private let availableThemes = ["System", "Dark", "Light"]
    
    var body: some View {
        Form {
            pickerSelectionFor(title: "Units", selection: $selectedUnits, options: availableUnits)
            
            pickerSelectionFor(title: "Theme", selection: $selectedTheme, options: availableThemes)
        }
        .navigationTitle("General")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func pickerSelectionFor<T: Hashable>(
        title: String,
        selection: Binding<T>,
        options: [String]
    ) -> some View {
        Section {
            Picker(title, selection: selection) {
                ForEach(options, id: \.self) { option in
                    Text(option)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

#Preview {
    GeneralSettingsView()
}
