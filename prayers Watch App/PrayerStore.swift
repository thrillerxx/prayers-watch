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
        guard let url = Bundle.main.url(forResource: "prayers", withExtension: "json") else {
            throw NSError(domain: "PrayerStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "prayers.json not found in bundle"])
        }
        let data = try Data(contentsOf: url)
        let catalog = try JSONDecoder().decode(PrayerCatalog.self, from: data)
        return catalog.prayers
    }
}
