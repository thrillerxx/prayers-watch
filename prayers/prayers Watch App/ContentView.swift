import SwiftUI

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
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Divinity")
                            .font(DivinityFont.chrome(17))
                            .foregroundStyle(.primary)
                        Text("Prayers & Rosary")
                            .font(DivinityFont.caption(11))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                    .padding(.bottom, 6)

                    HomeNavigationTile(
                        route: .rosary,
                        title: "Rosary",
                        subtitle: "Guided mysteries",
                        icon: "cross.fill"
                    )
                    HomeNavigationTile(
                        route: .prayerLibrary,
                        title: "Prayer Library",
                        subtitle: "Browse & listen",
                        icon: "books.vertical.fill"
                    )
                    HomeNavigationTile(
                        route: .massResponses,
                        title: "Mass Responses",
                        subtitle: "At Mass & devotions",
                        icon: "text.book.closed.fill"
                    )
                    HomeNavigationTile(
                        route: .settings,
                        title: "Settings",
                        subtitle: "Theme & voice",
                        icon: "gearshape.fill"
                    )
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 8)
            }
            .scrollIndicators(.hidden)
            .background(DivinityChrome.canvasBackground)
            .navigationBarTitleDisplayMode(.inline)
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
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(DivinityChrome.elevatedSurface(theme: theme, reduceTransparency: reduceTransparency, increaseContrast: differentiateWithoutColor))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(accent.opacity(0.35), lineWidth: 0.5)
                    }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 6)
        .padding(.bottom, 2)
        .shadow(color: .black.opacity(0.4), radius: 8, y: 3)
        .accessibilityIdentifier("RosaryMiniPlayer")
    }
}

#Preview {
    ContentView()
        .environmentObject(RosarySessionController())
}
