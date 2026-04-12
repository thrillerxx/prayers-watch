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
            LinearGradient(
                colors: [
                    Color.black.opacity(0.95),
                    Color.black.opacity(0.88),
                    accent.opacity(0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                Text(text.isEmpty ? "Loading…" : text)
                    .font(DivinityFont.prayer(13))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
            }
        }
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
