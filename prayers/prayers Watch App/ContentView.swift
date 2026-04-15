import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var rosary: RosarySessionController

    @AppStorage(AppSettings.colorThemeKey) private var themeRaw: String = AppSettings.defaultColorTheme

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    @State private var path = NavigationPath()
    @State private var rosaryScreenActive = false
    /// Rotates whenever navigation returns to root so the home backdrop is not stuck on one image per session.
    @State private var homeHeroAssetName: String = MysteryArt.randomHomeHeroAssetName()

    private var theme: AppColorTheme {
        AppColorTheme(rawValue: themeRaw) ?? .marian
    }

    private var accent: Color {
        theme.accentColor(reduceTransparency: reduceTransparency, increaseContrast: differentiateWithoutColor)
    }

    private var homeHeroSolidChrome: Bool {
        reduceTransparency || differentiateWithoutColor
    }

    /// Readable on full-bleed art; falls back to standard labels when a11y needs solid chrome.
    private var homePrimaryText: Color {
        homeHeroSolidChrome ? Color.primary : Color.white
    }

    private var homeSecondaryText: Color {
        homeHeroSolidChrome ? Color.secondary : Color.white.opacity(0.78)
    }

    private var homeHeroLabelShadow: Color {
        homeHeroSolidChrome ? .clear : Color.black.opacity(0.45)
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                DivinityHomeHeroBackdrop(assetName: homeHeroAssetName)

                ScrollView {
                    VStack(alignment: .center, spacing: 18) {
                        VStack(alignment: .center, spacing: 6) {
                            Text("Divinity")
                                .font(DivinityFont.chrome(20))
                                .foregroundStyle(homePrimaryText)
                                .multilineTextAlignment(.center)
                                .shadow(color: homeHeroLabelShadow, radius: homeHeroSolidChrome ? 0 : 2, x: 0, y: 1)
                            Text("Prayers & Rosary")
                                .font(DivinityFont.caption(11))
                                .foregroundStyle(homeSecondaryText)
                                .multilineTextAlignment(.center)
                                .shadow(color: homeHeroLabelShadow, radius: homeHeroSolidChrome ? 0 : 2, x: 0, y: 1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 6)
                        .padding(.bottom, 2)

                        homeCenterItem(.rosary, title: "Rosary", subtitle: "Mysteries", icon: "cross")
                        homeCenterItem(.prayerLibrary, title: "Prayer Library", subtitle: "Browse & listen", icon: "books.vertical.fill")
                        homeCenterItem(.massResponses, title: "Mass Responses", subtitle: "At Mass", icon: "text.book.closed.fill")
                        homeCenterItem(.settings, title: "Settings", subtitle: "Theme & voice", icon: "gearshape.fill")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .scrollIndicators(.hidden)
            }
            .onChange(of: path.count) { oldCount, newCount in
                if newCount == 0, oldCount > 0 {
                    homeHeroAssetName = MysteryArt.randomHomeHeroAssetName(excluding: homeHeroAssetName)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .toolbarBackground(Color.clear, for: .navigationBar)
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

    private func homeCenterItem(_ route: NavRoute, title: String, subtitle: String, icon: String) -> some View {
        Button {
            path.append(route)
        } label: {
            VStack(alignment: .center, spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(accent)
                    .symbolRenderingMode(.monochrome)
                    .shadow(color: homeHeroLabelShadow, radius: homeHeroSolidChrome ? 0 : 1, x: 0, y: 1)
                Text(title)
                    .font(DivinityPickerRow.titleFont)
                    .foregroundStyle(homePrimaryText)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.85)
                    .lineLimit(2)
                    .shadow(color: homeHeroLabelShadow, radius: homeHeroSolidChrome ? 0 : 2, x: 0, y: 1)
                Text(subtitle)
                    .font(DivinityPickerRow.subtitleFont)
                    .foregroundStyle(homeSecondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .shadow(color: homeHeroLabelShadow, radius: homeHeroSolidChrome ? 0 : 2, x: 0, y: 1)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint(subtitle)
    }

    private var rosaryMiniPlayer: some View {
        Button {
            path = NavigationPath()
            path.append(NavRoute.rosary)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "cross")
                    .font(.system(size: 14, weight: .bold))
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
