//
//  Monitor_it_Complications.swift
//  Monitor.it Complications
//
//  Created by Mark Howard on 02/01/2023.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct Monitor_it_ComplicationsEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family: WidgetFamily
    var body: some View {
        switch family {
        case .accessoryCorner:
            Image(systemName: "heart.fill")
                .font(.title)
                .widgetAccentable()
        case .accessoryCircular:
            Image(systemName: "heart.fill")
                .font(.title)
                .widgetAccentable()
        case .accessoryRectangular:
            HStack {
                VStack(alignment: .leading) {
                    Text("Monitor.it")
                        .bold()
                        .foregroundColor(.pink)
                    Text("Track Your Activity!")
                    Spacer()
                }
                .padding(.horizontal)
                Spacer()
            }
            .widgetAccentable()
        case .accessoryInline:
            Text("Monitor.it")
                .widgetAccentable()
        @unknown default:
            Text("Unknown Widget Size")
        }
    }
}

@main
struct Monitor_it_Complications: Widget {
    let kind: String = "Monitor_it_Complications"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Monitor_it_ComplicationsEntryView(entry: entry)
        }
        .configurationDisplayName("Monitor.it")
        .description("A Widget That Gives A Quick Launch Complication To Display On The Watch Face.")
        .supportedFamilies([.accessoryRectangular, .accessoryCorner, .accessoryInline, .accessoryCircular])
    }
}

struct Monitor_it_Complications_Previews: PreviewProvider {
    static var previews: some View {
        Monitor_it_ComplicationsEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
