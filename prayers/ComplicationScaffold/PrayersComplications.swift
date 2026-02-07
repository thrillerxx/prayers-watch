import WidgetKit
import SwiftUI

// NOTE: This file is scaffolded to be copied into a Widget Extension target.
// In Xcode: File > New > Target... > "Widget Extension" (watchOS)
// Then replace the generated widget code with this file (and add to target).

struct PrayersEntry: TimelineEntry {
    let date: Date
    let title: String
    let subtitle: String
}

struct PrayersProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayersEntry {
        PrayersEntry(date: .now, title: "Divinity", subtitle: "Rosary")
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayersEntry) -> Void) {
        completion(PrayersEntry(date: .now, title: "Divinity", subtitle: "Rosary"))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayersEntry>) -> Void) {
        // Simple timeline that refreshes periodically.
        let entry = PrayersEntry(date: .now, title: "Divinity", subtitle: "Rosary")
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now.addingTimeInterval(60 * 30)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

struct PrayersComplicationView: View {
    var entry: PrayersProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(entry.subtitle)
                .font(.headline)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

@main
struct PrayersComplicationsWidget: Widget {
    let kind: String = "PrayersComplications"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayersProvider()) { entry in
            PrayersComplicationView(entry: entry)
        }
        .configurationDisplayName("Divinity")
        .description("Quick access to prayers/rosary.")
        // Xcode will infer supported families based on the extension template.
    }
}
