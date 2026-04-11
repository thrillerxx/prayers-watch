import SwiftUI

struct MassResponsesView: View {
    @State private var text: String = ""

    var body: some View {
        ScrollView {
            Text(text.isEmpty ? "Loading…" : text)
                .font(.system(.body, design: .serif))
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
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
