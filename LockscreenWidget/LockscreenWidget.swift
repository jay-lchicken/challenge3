//
//  LockscreenWidget.swift
//  LockscreenWidget
//
//  Created by Gautham Dinakaran on 14/11/25.
//


import WidgetKit
import SwiftUI

struct ExpenseEntry: TimelineEntry {
    let date: Date
}

struct ExpenseProvider: TimelineProvider {
    func placeholder(in context: Context) -> ExpenseEntry {
        ExpenseEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (ExpenseEntry) -> Void) {
        completion(ExpenseEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ExpenseEntry>) -> Void) {
        let entry = ExpenseEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct ExpenseWidgetEntryView: View {
    var entry: ExpenseProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            // Lock screen circular widget
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.blue)
            }
            .widgetURL(URL(string: "myapp://add-expense"))
            
        case .accessoryRectangular:
            // Lock screen rectangular widget
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.blue)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Add Expense")
                        .font(.headline)
                    Text("Quick entry")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .widgetURL(URL(string: "myapp://add-expense"))
            
        case .accessoryInline:
            // Lock screen inline widget (text only)
            Label("Add Expense", systemImage: "plus.circle.fill")
                .widgetURL(URL(string: "myapp://add-expense"))
            
        case .systemSmall:
            // Home screen small widget
            ZStack {
                Color.blue.opacity(0.1)
                VStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.blue)
                    Text("Add Expense")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                .padding()
            }
            .widgetURL(URL(string: "myapp://add-expense"))
            
        default:
            // Fallback
            ZStack {
                Color(.systemBackground)
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(20)
                    .foregroundStyle(.blue)
            }
            .widgetURL(URL(string: "myapp://add-expense"))
        }
    }
}

struct ExpenseWidget: Widget {
    let kind: String = "ExpenseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ExpenseProvider()) { entry in
            ExpenseWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Add Expense")
        .description("Quickly add a new expense")
        // Support both lock screen and home screen
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
            .systemSmall
        ])
    }
}

#Preview(as: .accessoryCircular) {
    ExpenseWidget()
} timeline: {
    ExpenseEntry(date: .now)
}
