import Foundation

struct PrayerCatalog: Codable {
    let prayers: [Prayer]
}

struct PrayerSource: Codable, Hashable {
    let name: String
    let url: String
}

struct Prayer: Codable, Identifiable {
    let id: String
    let title: String
    let translations: [String: String]
    let sources: [PrayerSource]?
}

enum PrayerStore {
    static func load() throws -> [Prayer] {
        // Prefer a known-good bundled prayers.json, even if multiple copies exist.
        let candidates: [URL] = (Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? [])
            .filter { $0.lastPathComponent == "prayers.json" }

        // Try all candidates (largest first) until one decodes.
        let sorted = candidates.sorted { (a, b) in
            let sa = (try? a.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            let sb = (try? b.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            return sa > sb
        }

        var lastError: Error?
        for url in (sorted.isEmpty ? [Bundle.main.url(forResource: "prayers", withExtension: "json")].compactMap { $0 } : sorted) {
            do {
                let data = try Data(contentsOf: url)
                let catalog = try JSONDecoder().decode(PrayerCatalog.self, from: data)
                return catalog.prayers
            } catch {
                lastError = error
                continue
            }
        }

        throw lastError ?? NSError(domain: "PrayerStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "prayers.json not found in bundle"])
    }
}
