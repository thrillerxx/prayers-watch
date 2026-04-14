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
            List {
                Section {
                    VStack(alignment: .center, spacing: 4) {
                        Text("Divinity")
                            .font(DivinityFont.chrome(17))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                        Text("Prayers & Rosary")
                            .font(DivinityFont.caption(11))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 2)
                    .padding(.bottom, 4)
                    .listRowInsets(EdgeInsets(top: 6, leading: 8, bottom: 8, trailing: 8))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                Section {
                    homeTile(.rosary, title: "Rosary", subtitle: "Guided mysteries", icon: "cross.fill")
                    homeTile(.prayerLibrary, title: "Prayer Library", subtitle: "Browse & listen", icon: "books.vertical.fill")
                    homeTile(.massResponses, title: "Mass Responses", subtitle: "At Mass & devotions", icon: "text.book.closed.fill")
                    homeTile(.settings, title: "Settings", subtitle: "Theme & voice", icon: "gearshape.fill")
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .background(DivinityChrome.canvasBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DivinityChrome.canvasBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
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

    @ViewBuilder
    private func homeTile(_ route: NavRoute, title: String, subtitle: String, icon: String) -> some View {
        HomeNavigationTile(route: route, title: title, subtitle: subtitle, icon: icon)
            .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }

    private var rosaryMiniPlayer: some View {
        Button {
            path = NavigationPath()
            path.append(NavRoute.rosary)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "cross.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(accent)
                    .symbolRenderingMode(.monochrome)
                    .frame(width: 22, height: 22)

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
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 16, height: 16)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
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
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
        .shadow(color: .black.opacity(0.4), radius: 8, y: 3)
        .accessibilityIdentifier("RosaryMiniPlayer")
    }
}

#Preview {
    ContentView()
        .environmentObject(RosarySessionController())
}
