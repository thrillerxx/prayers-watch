import SwiftUI

struct PrayerLibraryView: View {

    @State private var prayers: [Prayer] = []
    @State private var massPrayers: [Prayer] = []
    @State private var errorText: String?

    private let lang: String = "en"

    @ObservedObject private var speech = SpeechManager.shared

    @Environment(\.appColorTheme) private var theme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    private var accent: Color {
        theme.accentColor(reduceTransparency: reduceTransparency, increaseContrast: differentiateWithoutColor)
    }

    var body: some View {
        VStack(spacing: 0) {
            if speech.isSpeaking || speech.isPaused {
                TransportRow(speech: speech, accent: accent)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 6)
            }
            if let errorText {
                Text(errorText)
                    .font(DivinityFont.caption(11))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 6)
            } else if prayers.isEmpty {
                Text("No prayers found")
                    .font(DivinityFont.caption(12))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
            } else {
                List(prayers) { prayer in
                    NavigationLink {
                        PrayerDetailView(prayer: prayer)
                    } label: {
                        Text(prayer.title)
                            .font(DivinityFont.title(14))
                    }
                }
            }
        }
        .navigationTitle("Prayers")
        .tint(accent)
        .onAppear {
            do {
                prayers = try PrayerStore.load().filter { prayer in
                    let id = prayer.id
                    if id.hasPrefix("mysteryset_") { return false }
                    if id.hasSuffix("_title") { return false }
                    if id.hasSuffix("_alt_title") { return false }
                    return true
                }
            } catch {
                errorText = error.localizedDescription
            }
        }
    }

    private func loadPrayers() {
        var errors: [String] = []

        do {
            prayers = try PrayerStore.load().filter { prayer in
                let id = prayer.id
                // Keep only prayable text entries.
                // Hide any metadata/title helper rows.
                if id.hasPrefix("mysteryset_") { return false }
                if id.hasSuffix("_title") { return false }
                if id.hasSuffix("_alt_title") { return false }
                // keep everything else (including *_meditation + core prayers)
                return true
            }
        } catch {
            prayers = []
            errors.append("Prayers: \(error.localizedDescription)")
        }

        do {
            massPrayers = try PrayerStore.loadMassPrayers()
        } catch {
            massPrayers = []
            errors.append("Mass Prayers: \(error.localizedDescription)")
        }

        errorText = errors.isEmpty ? nil : errors.joined(separator: "\n")
    }
}

private struct TransportRow: View {
    @ObservedObject var speech: SpeechManager
    var accent: Color

    var body: some View {
        HStack(spacing: 10) {
            Button {
                if speech.isSpeaking {
                    speech.pause()
                } else {
                    speech.resume()
                }
            } label: {
                Label(speech.isSpeaking ? "Pause" : "Play", systemImage: speech.isSpeaking ? "pause.fill" : "play.fill")
                    .font(DivinityFont.caption(13))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(accent)
            .accessibilityIdentifier("TransportPlayPause")

            Button {
                speech.stop()
            } label: {
                Image(systemName: "stop.fill")
            }
            .buttonStyle(.bordered)
            .tint(accent)
            .accessibilityIdentifier("TransportStop")
        }
    }
}

struct PrayerDetailView: View {
    let prayer: Prayer
    private let lang: String = "en"

    @ObservedObject private var speech = SpeechManager.shared

    @Environment(\.appColorTheme) private var theme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    private var accent: Color {
        theme.accentColor(reduceTransparency: reduceTransparency, increaseContrast: differentiateWithoutColor)
    }

    @State private var didAutoplay = false

    private var text: String {
        prayer.translations[lang] ?? prayer.translations["en"] ?? ""
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(prayer.title)
                    .font(DivinityFont.title(16))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .center)

                if speech.isSpeaking || speech.isPaused {
                    TransportRow(speech: speech, accent: accent)
                }

                if text.isEmpty {
                    Text("No text for this prayer in the selected language.")
                        .font(DivinityFont.caption(11))
                        .foregroundStyle(.secondary)
                } else {
                    Text(text)
                        .font(DivinityFont.prayer(14))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
        .navigationTitle("Prayer")
        .tint(accent)
        .onAppear {
            if !didAutoplay {
                didAutoplay = true
                speech.stop()
                speak()
            }
        }
    }

    private func speak() {
        guard !text.isEmpty else { return }

        speech.speak(text: text, voiceLanguage: "en-US", rate: 0.45)
    }
}

private struct PrayerCategoryListView: View {
    let title: String
    let prayers: [Prayer]

    var body: some View {
        List(prayers) { prayer in
            NavigationLink {
                PrayerDetailView(prayer: prayer)
            } label: {
                Text(prayer.title)
            }
        }
        .navigationTitle(title)
    }
}

#Preview {
    NavigationStack {
        PrayerLibraryView()
    }
}
