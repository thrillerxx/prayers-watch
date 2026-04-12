import SwiftUI

enum NavRoute: Hashable {
    case rosary
    case prayerLibrary
    case massResponses
    case settings
}

struct ContentView: View {

    @EnvironmentObject private var rosary: RosarySessionController

    @AppStorage(AppSettings.colorThemeKey) private var themeRaw: String = AppSettings.defaultColorTheme

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    @State private var path = NavigationPath()
    @State private var rosaryScreenActive = false

    private var theme: AppColorTheme {
        AppColorTheme(rawValue: themeRaw) ?? .marian
    }

    private var accent: Color {
        theme.accentColor(reduceTransparency: reduceTransparency, increaseContrast: differentiateWithoutColor)
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    NavigationLink(value: NavRoute.rosary) {
                        Label("Rosary", systemImage: "cross.fill")
                            .font(DivinityFont.title(15))
                    }

                    NavigationLink(value: NavRoute.prayerLibrary) {
                        Label("Prayer Library", systemImage: "books.vertical.fill")
                            .font(DivinityFont.title(15))
                    }
                }

                Section {
                    NavigationLink(value: NavRoute.massResponses) {
                        Label("Mass Responses & Prayers", systemImage: "text.book.closed.fill")
                            .font(DivinityFont.title(15))
                    }

                    NavigationLink(value: NavRoute.settings) {
                        Label("Settings", systemImage: "gearshape.fill")
                            .font(DivinityFont.title(15))
                    }
                }
            }
            .navigationTitle("Divinity")
            .navigationDestination(for: NavRoute.self) { route in
                switch route {
                case .rosary:
                    RosaryView(rosaryScreenActive: $rosaryScreenActive)
                case .prayerLibrary:
                    PrayerLibraryView()
                case .massResponses:
                    MassResponsesView()
                case .settings:
                    SettingsView()
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if rosary.isRosaryActive && !rosaryScreenActive {
                    rosaryMiniPlayer
                }
            }
        }
        .tint(accent)
        .environment(\.appColorTheme, theme)
    }

    private var rosaryMiniPlayer: some View {
        Button {
            path = NavigationPath()
            path.append(NavRoute.rosary)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "cross.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(accent)

                VStack(alignment: .leading, spacing: 1) {
                    Text(rosary.miniPlayerTitle)
                        .font(DivinityFont.caption(12))
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    Text(rosary.miniPlayerSubtitle)
                        .font(DivinityFont.caption(10))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                if reduceTransparency || differentiateWithoutColor {
                    Color.black.opacity(0.92)
                } else {
                    ZStack {
                        Color.black.opacity(0.35)
                        Rectangle().fill(.ultraThinMaterial)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 6)
        .padding(.bottom, 2)
        .accessibilityIdentifier("RosaryMiniPlayer")
    }
}

#Preview {
    ContentView()
        .environmentObject(RosarySessionController())
}
