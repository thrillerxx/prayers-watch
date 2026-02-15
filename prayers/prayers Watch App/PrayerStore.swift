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
        let resourceName = "rosary_prayers_en"
        let resourceExt = "json"

        #if DEBUG
        let dups = (Bundle.main.urls(forResourcesWithExtension: resourceExt, subdirectory: nil) ?? [])
            .filter { $0.lastPathComponent == "\(resourceName).\(resourceExt)" }
        NSLog("[PrayerStore] \(resourceName).\(resourceExt) matches: \(dups.count)")
        assert(dups.count <= 1, "Duplicate \(resourceName).\(resourceExt) bundled")
        #endif

        guard let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExt) else {
            throw NSError(domain: "PrayerStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "\(resourceName).\(resourceExt) not found in bundle"])
        }

        let data = try Data(contentsOf: url)

        #if DEBUG
        NSLog("[PrayerStore] Resolved: \(url.path)")
        NSLog("[PrayerStore] Bytes: \(data.count)")

        // Also persist to app Documents for QA capture.
        let logURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("prayerstore_probe.log")
        let line = "[PrayerStore] Resolved: \(url.path) | Bytes: \(data.count)\n"
        if let d = line.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logURL.path) {
                if let fh = try? FileHandle(forWritingTo: logURL) {
                    try? fh.seekToEnd()
                    try? fh.write(contentsOf: d)
                    try? fh.close()
                }
            } else {
                try? d.write(to: logURL, options: .atomic)
            }
        }
        #endif

        let catalog = try JSONDecoder().decode(PrayerCatalog.self, from: data)
        return catalog.prayers
    }
}
