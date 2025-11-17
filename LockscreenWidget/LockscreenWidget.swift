//
//  LockscreenWidget.swift
//  LockscreenWidget
//
//  Created by Gautham Dinakaran on 14/11/25.
//

import WidgetKit
import SwiftUI


struct SimpleEntry: TimelineEntry {
    let date: Date
}


struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let timeline = Timeline(entries: [SimpleEntry(date: Date())], policy: .never)
        completion(timeline)
    }
}


//struct LockscreenWidgetEntryView: View {
//    var entry: SimpleEntry
//
//    var body: some View {
//        Image(systemName: "plus.circle.fill")
//            .resizable()
//            .scaledToFit()
//            .padding(10)
//            .foregroundColor(.accentColor)
//            .widgetURL(URL(string: "moneymapr://expenses/add"))
//    }
//}
//
//
//@available(iOS 26.0, *)
//struct LockscreenWidget: Widget {
//    let kind: String = "LockscreenWidget"
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: Provider()) { entry in
//            LockscreenWidgetEntryView(entry: entry)
//        }
//        .configurationDisplayName("Add Expense Widget")
//        .description("Tap to add a new expense.")
//        .supportedFamilies([.accessoryCircular])      }
//}
