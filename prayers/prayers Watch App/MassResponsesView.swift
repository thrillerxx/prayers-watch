import SwiftUI

struct MassResponsesView: View {

    @State private var text: String = ""

    @Environment(\.appColorTheme) private var theme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    private var accent: Color {
        theme.accentColor(reduceTransparency: reduceTransparency, increaseContrast: differentiateWithoutColor)
    }

    var body: some View {
        ZStack {
            DivinityMysteryHeroBackdrop()

            LinearGradient(
                colors: [
                    Color.clear,
                    accent.opacity(reduceTransparency ? 0.14 : 0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                Text(text.isEmpty ? "Loading…" : text)
                    .font(DivinityFont.prayer(13))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(DivinityChrome.elevatedSurface(theme: theme, reduceTransparency: reduceTransparency, increaseContrast: differentiateWithoutColor))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(
                                        DivinityChrome.elevatedSurfaceStroke(theme: theme, accent: accent, reduceTransparency: reduceTransparency),
                                        lineWidth: 0.5
                                    )
                            }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.clear, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationTitle("Mass Responses")
        .task {
            guard text.isEmpty else { return }
            text = loadBundledText(named: "mass_responses_en", ext: "txt")
        }
    }

    private func loadBundledText(named: String, ext: String) -> String {
        guard let url = Bundle.main.url(forResource: named, withExtension: ext),
              let data = try? Data(contentsOf: url),
              let str = String(data: data, encoding: .utf8)
        else {
            return "(Missing resource: \(named).\(ext))"
        }
        return str
    }
}

#Preview {
    NavigationStack {
        MassResponsesView()
    }
}
