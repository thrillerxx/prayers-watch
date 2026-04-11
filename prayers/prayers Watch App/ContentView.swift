import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        RosaryView()
                    } label: {
                        Label("Rosary", systemImage: "cross.fill")
                    }

                    NavigationLink {
                        PrayerLibraryView()
                    } label: {
                        Label("Prayer Library", systemImage: "books.vertical.fill")
                    }
                }

                Section {
                    NavigationLink {
                        MassResponsesView()
                    } label: {
                        Label("Mass Responses & Prayers", systemImage: "text.book.closed.fill")
                    }

                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                }
            }
            .navigationTitle("Divinity")
        }
    }
}

#Preview {
    ContentView()
}
