import SwiftUI

struct ContentView: View {
    @StateObject private var speech = SpeechManager.shared

    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Rosary") {
                    RosaryView()
                }

                NavigationLink("Prayer Library") {
                    PrayerLibraryView()
                }

                NavigationLink("Settings") {
                    SettingsView()
                }
            }
            .navigationTitle("Divinity")
            .toolbar {
                TransportToolbarItems()
            }
        }
    }
    }
}

#Preview {
    ContentView()
}
