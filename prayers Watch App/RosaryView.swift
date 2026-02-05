import SwiftUI

struct RosaryView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Rosary")
                .font(.headline)
            Text("Coming next: guided, auto-advancing Rosary")
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    RosaryView()
}
