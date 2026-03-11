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
        // Deterministic: load the watch app’s single canonical resource.
        try loadCatalog(resourceName: "rosary_prayers_en", resourceExt: "json")
    }

    static func loadMassPrayers() throws -> [Prayer] {
        try loadCatalog(resourceName: "mass_prayers_en", resourceExt: "json")
    }

    private static func loadCatalog(resourceName: String, resourceExt: String) throws -> [Prayer] {
        #if DEBUG
        let dups = (Bundle.main.urls(forResourcesWithExtension: resourceExt, subdirectory: nil) ?? [])
            .filter { $0.lastPathComponent == "\(resourceName).\(resourceExt)" }
        print("[PrayerStore] \(resourceName).\(resourceExt) matches: \(dups.count)")
        assert(dups.count <= 1, "Duplicate \(resourceName).\(resourceExt) bundled")
        #endif

        guard let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExt) else {
            throw NSError(domain: "PrayerStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "\(resourceName).\(resourceExt) not found in bundle"])
        }
        #if DEBUG
        print("[PrayerStore] Resolved: \(url.path)")
        #endif

        let data = try Data(contentsOf: url)
        let catalog = try JSONDecoder().decode(PrayerCatalog.self, from: data)
        return catalog.prayers
    }
}
