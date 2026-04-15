//
//  ContentView.swift
//  prayers
//
//  Created by Car Gonzalez on 2/5/26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage(AppSettings.appAlternateIconKey) private var alternateAppIconRaw: String = AlternateAppIconChoice.appDefault.rawValue

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("App icon", selection: $alternateAppIconRaw) {
                        ForEach(AlternateAppIconChoice.allCases) { choice in
                            Text(choice.title).tag(choice.rawValue)
                        }
                    }
                    Text("This updates the app icon on your iPhone. The same choice syncs when you pick an icon on your Apple Watch.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Change App Icon")
                }
            }
            .navigationTitle("Prayers")
        }
        .onChange(of: alternateAppIconRaw) { _, newValue in
            PhoneCompanionIconSync.persistAndApplyLocalSelection(raw: newValue)
        }
    }
}

#Preview {
    ContentView()
}
