import SwiftUI

struct ContentView: View {
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
        }
    }
}

#Preview {
    ContentView()
}
