import WidgetKit
import SwiftUI

// Reads shared data written by Flutter via HomeWidget package
// App Group ID must match what you configure in Xcode: group.com.tuapp.sobriety
private let appGroupId = "group.com.tuapp.sobriety"

struct SobrietyEntry: TimelineEntry {
    let date: Date
    let days: Int
    let startDateString: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SobrietyEntry {
        SobrietyEntry(date: Date(), days: 0, startDateString: "")
    }

    func getSnapshot(in context: Context, completion: @escaping (SobrietyEntry) -> Void) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SobrietyEntry>) -> Void) {
        // Refresh at midnight every day
        let midnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        let timeline = Timeline(entries: [entry()], policy: .after(midnight))
        completion(timeline)
    }

    private func entry() -> SobrietyEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        let days = defaults?.integer(forKey: "sobriety_days") ?? 0
        let startDateString = defaults?.string(forKey: "sobriety_start_date") ?? ""
        return SobrietyEntry(date: Date(), days: days, startDateString: startDateString)
    }
}

struct SobrietyWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.98, green: 0.45, blue: 0.09), Color(red: 0.8, green: 0.25, blue: 0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.white.opacity(0.9))
                    .font(.system(size: family == .systemSmall ? 14 : 18))
                Text("\(entry.days)")
                    .font(.system(size: family == .systemSmall ? 36 : 52, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.6)
                Text(entry.days == 1 ? "día sobrio/a" : "días sobrio/a")
                    .font(.system(size: family == .systemSmall ? 11 : 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                if family != .systemSmall && !entry.startDateString.isEmpty {
                    Text("desde \(entry.startDateString)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 2)
                }
            }
            .padding()
        }
    }
}

@main
struct SobrietyWidget: Widget {
    let kind: String = "SobrietyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SobrietyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Días de Sobriedad")
        .description("Muestra tus días de sobriedad en la pantalla de inicio.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
